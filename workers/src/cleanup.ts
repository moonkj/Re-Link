// Re-Link Workers — Scheduled Cleanup & Subscription Enforcement
// Runs daily via cron trigger (0 3 * * * UTC)
// Also callable via POST /admin/cleanup

import type { Env } from './types';

// Grace period: 30 days after plan_expires_at before data deletion
const GRACE_PERIOD_MS = 30 * 24 * 60 * 60 * 1000;

// ============================================================
// Main entry point — called by scheduled event or admin endpoint
// ============================================================
export async function handleScheduledCleanup(env: Env): Promise<CleanupResult> {
  const result: CleanupResult = {
    downgraded_users: 0,
    cleaned_users: 0,
    expired_tokens: 0,
    expired_invites: 0,
    errors: [],
  };

  try {
    result.downgraded_users = await downgradeExpiredSubscriptions(env);
  } catch (e) {
    const msg = `downgradeExpiredSubscriptions failed: ${(e as Error).message}`;
    console.error(msg);
    result.errors.push(msg);
  }

  try {
    result.cleaned_users = await deleteGracePeriodExpiredData(env);
  } catch (e) {
    const msg = `deleteGracePeriodExpiredData failed: ${(e as Error).message}`;
    console.error(msg);
    result.errors.push(msg);
  }

  try {
    result.expired_tokens = await cleanupExpiredTokens(env);
  } catch (e) {
    const msg = `cleanupExpiredTokens failed: ${(e as Error).message}`;
    console.error(msg);
    result.errors.push(msg);
  }

  try {
    result.expired_invites = await cleanupExpiredInvites(env);
  } catch (e) {
    const msg = `cleanupExpiredInvites failed: ${(e as Error).message}`;
    console.error(msg);
    result.errors.push(msg);
  }

  console.log('Cleanup completed:', JSON.stringify(result));
  return result;
}

// ============================================================
// Result type
// ============================================================
export interface CleanupResult {
  downgraded_users: number;
  cleaned_users: number;
  expired_tokens: number;
  expired_invites: number;
  errors: string[];
}

// ============================================================
// 1. Downgrade expired subscriptions to free
// ============================================================
async function downgradeExpiredSubscriptions(env: Env): Promise<number> {
  const now = Date.now();

  const expiredUsers = await env.DB
    .prepare(
      `SELECT id, plan, plan_expires_at
       FROM users
       WHERE plan IN ('family', 'family_plus')
         AND plan_expires_at IS NOT NULL
         AND plan_expires_at < ?`,
    )
    .bind(now)
    .all<{ id: string; plan: string; plan_expires_at: number }>();

  if (expiredUsers.results.length === 0) {
    return 0;
  }

  let downgraded = 0;

  for (const user of expiredUsers.results) {
    try {
      // Set plan to free but keep plan_expires_at for grace period calculation
      await env.DB
        .prepare(
          `UPDATE users SET plan = 'free', updated_at = ? WHERE id = ?`,
        )
        .bind(now, user.id)
        .run();
      downgraded++;
    } catch (e) {
      console.error(
        `Failed to downgrade user ${user.id}:`,
        (e as Error).message,
      );
    }
  }

  console.log(`Downgraded ${downgraded} expired subscription(s) to free`);
  return downgraded;
}

// ============================================================
// 2. Delete data for users whose grace period has expired
// ============================================================
async function deleteGracePeriodExpiredData(env: Env): Promise<number> {
  const now = Date.now();
  const graceCutoff = now - GRACE_PERIOD_MS;

  // Users who are free, have a past plan_expires_at, and grace period is over
  const expiredUsers = await env.DB
    .prepare(
      `SELECT id, family_group_id
       FROM users
       WHERE plan = 'free'
         AND plan_expires_at IS NOT NULL
         AND plan_expires_at < ?`,
    )
    .bind(graceCutoff)
    .all<{ id: string; family_group_id: string | null }>();

  if (expiredUsers.results.length === 0) {
    return 0;
  }

  let cleaned = 0;

  for (const user of expiredUsers.results) {
    try {
      await cleanupUserData(env, user.id, user.family_group_id);
      cleaned++;
    } catch (e) {
      console.error(
        `Failed to clean data for user ${user.id}:`,
        (e as Error).message,
      );
    }
  }

  console.log(`Cleaned data for ${cleaned} grace-period-expired user(s)`);
  return cleaned;
}

// ============================================================
// Helper: clean up a single user's cloud data
// ============================================================
async function cleanupUserData(
  env: Env,
  userId: string,
  groupId: string | null,
): Promise<void> {
  const now = Date.now();

  // Check if user is the group owner
  let isOwner = false;
  if (groupId) {
    const group = await env.DB
      .prepare('SELECT owner_id FROM family_groups WHERE id = ?')
      .bind(groupId)
      .first<{ owner_id: string }>();
    isOwner = group?.owner_id === userId;
  }

  // Only delete group-level sync data if user is the group owner
  if (groupId && isOwner) {
    // 1. Collect R2 keys from sync_memories before deleting rows
    const memories = await env.DB
      .prepare(
        'SELECT file_r2_key, thumbnail_r2_key FROM sync_memories WHERE group_id = ?',
      )
      .bind(groupId)
      .all<{ file_r2_key: string | null; thumbnail_r2_key: string | null }>();

    // 2. Delete sync data rows
    await env.DB.batch([
      env.DB.prepare('DELETE FROM sync_nodes WHERE group_id = ?').bind(groupId),
      env.DB.prepare('DELETE FROM sync_edges WHERE group_id = ?').bind(groupId),
      env.DB.prepare('DELETE FROM sync_memories WHERE group_id = ?').bind(groupId),
    ]);

    // 3. Delete R2 files
    const r2Keys: string[] = [];
    for (const mem of memories.results) {
      if (mem.file_r2_key) r2Keys.push(mem.file_r2_key);
      if (mem.thumbnail_r2_key) r2Keys.push(mem.thumbnail_r2_key);
    }

    // R2 delete supports batches — delete in chunks to avoid timeouts
    const BATCH_SIZE = 100;
    for (let i = 0; i < r2Keys.length; i += BATCH_SIZE) {
      const batch = r2Keys.slice(i, i + BATCH_SIZE);
      // R2 .delete() accepts a single key or an array of keys
      await env.MEDIA_BUCKET.delete(batch);
    }

    console.log(
      `Deleted ${r2Keys.length} R2 file(s) for group ${groupId}`,
    );
  }

  // 4. Delete sync checkpoints for this user
  await env.DB
    .prepare('DELETE FROM sync_checkpoints WHERE user_id = ?')
    .bind(userId)
    .run();

  // 5. Reset user's cloud state
  await env.DB
    .prepare(
      `UPDATE users
       SET family_group_id = NULL,
           storage_used_bytes = 0,
           plan_expires_at = NULL,
           updated_at = ?
       WHERE id = ?`,
    )
    .bind(now, userId)
    .run();

  // 6. Delete family_groups row if user was owner
  if (groupId && isOwner) {
    // Remove other members from group first
    await env.DB
      .prepare(
        `UPDATE users
         SET family_group_id = NULL, updated_at = ?
         WHERE family_group_id = ? AND id != ?`,
      )
      .bind(now, groupId, userId)
      .run();

    // Delete invites and group
    await env.DB.batch([
      env.DB
        .prepare('DELETE FROM family_invites WHERE group_id = ?')
        .bind(groupId),
      env.DB
        .prepare('DELETE FROM family_groups WHERE id = ?')
        .bind(groupId),
    ]);
  }
}

// ============================================================
// 3. Clean up expired refresh tokens
// ============================================================
async function cleanupExpiredTokens(env: Env): Promise<number> {
  const now = Date.now();

  const result = await env.DB
    .prepare('DELETE FROM refresh_tokens WHERE expires_at < ?')
    .bind(now)
    .run();

  const deleted = result.meta?.changes ?? 0;
  console.log(`Deleted ${deleted} expired refresh token(s)`);
  return deleted;
}

// ============================================================
// 4. Clean up expired or used invites
// ============================================================
async function cleanupExpiredInvites(env: Env): Promise<number> {
  const now = Date.now();

  const result = await env.DB
    .prepare('DELETE FROM family_invites WHERE expires_at < ? OR is_used = 1')
    .bind(now)
    .run();

  const deleted = result.meta?.changes ?? 0;
  console.log(`Deleted ${deleted} expired/used invite(s)`);
  return deleted;
}

// ============================================================
// Data retention status for a user
// ============================================================
export interface DataRetentionStatus {
  plan: string;
  plan_expires_at: string | null;
  grace_period_ends_at: string | null;
  days_remaining: number | null;
  status: 'active' | 'grace_period' | 'no_cloud_data';
}

export function computeDataRetentionStatus(
  plan: string,
  planExpiresAt: number | null,
): DataRetentionStatus {
  const now = Date.now();

  // Active subscription (family/family_plus with valid or no expiry)
  if (
    (plan === 'family' || plan === 'family_plus') &&
    (planExpiresAt === null || planExpiresAt > now)
  ) {
    return {
      plan,
      plan_expires_at: planExpiresAt ? new Date(planExpiresAt).toISOString() : null,
      grace_period_ends_at: null,
      days_remaining: null,
      status: 'active',
    };
  }

  // Downgraded user with grace period
  if (planExpiresAt !== null) {
    const graceEndsAt = planExpiresAt + GRACE_PERIOD_MS;

    if (graceEndsAt > now) {
      const daysRemaining = Math.ceil((graceEndsAt - now) / (24 * 60 * 60 * 1000));
      return {
        plan,
        plan_expires_at: new Date(planExpiresAt).toISOString(),
        grace_period_ends_at: new Date(graceEndsAt).toISOString(),
        days_remaining: daysRemaining,
        status: 'grace_period',
      };
    }

    // Grace period expired — data already cleaned or will be cleaned
    return {
      plan,
      plan_expires_at: new Date(planExpiresAt).toISOString(),
      grace_period_ends_at: new Date(graceEndsAt).toISOString(),
      days_remaining: 0,
      status: 'no_cloud_data',
    };
  }

  // Free/plus user who never had a subscription
  return {
    plan,
    plan_expires_at: null,
    grace_period_ends_at: null,
    days_remaining: null,
    status: 'no_cloud_data',
  };
}
