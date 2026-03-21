// Re-Link Workers — Family Group Endpoints
// POST   /family/create                  — Create new family group
// GET    /family/members                 — List members of my group
// POST   /family/invite                  — Generate invite token (72h, single-use)
// GET    /family/invite/:token           — Get invite info
// POST   /family/invite/:token/accept    — Accept invite
// DELETE /family/leave                   — Leave group
// DELETE /family/members/:userId         — Remove member (owner only)

import type {
  Env,
  User,
  FamilyGroup,
  FamilyMember,
  FamilyInvite,
  InviteInfo,
  UserPlan,
} from './types';
import { MAX_MEMBERS, STORAGE_LIMITS } from './types';
import {
  requireAuth,
  requireFamilyPlan,
  requireGroupMembership,
  jsonResponse,
  errorResponse,
} from './middleware';

const INVITE_TTL_MS = 72 * 60 * 60 * 1000; // 72 hours

// ============================================================
// Helper: get member count of a group
// ============================================================
async function getGroupMemberCount(
  db: D1Database,
  groupId: string,
): Promise<number> {
  const result = await db
    .prepare('SELECT COUNT(*) as cnt FROM users WHERE family_group_id = ?')
    .bind(groupId)
    .first<{ cnt: number }>();
  return result?.cnt ?? 0;
}

// ============================================================
// Handler: POST /family/create
// ============================================================
export async function handleCreateFamily(
  request: Request,
  env: Env,
): Promise<Response> {
  const { ctx, error } = await requireAuth(request, env);
  if (error) return error;

  const planError = requireFamilyPlan(ctx, request);
  if (planError) return planError;

  // User must not already be in a group
  if (ctx.groupId) {
    return errorResponse(
      'Already in a family group. Leave first.',
      409,
      request,
    );
  }

  let name: string | null = null;
  try {
    const body = (await request.json()) as { name?: string };
    name = body.name ?? null;
  } catch {
    // name is optional
  }

  const maxMembers = MAX_MEMBERS[ctx.plan as UserPlan] ?? 6;
  const storageLimit = STORAGE_LIMITS[ctx.plan as UserPlan] ?? STORAGE_LIMITS.family;

  const now = Date.now();
  const groupId = crypto.randomUUID();

  await env.DB.prepare(
    `INSERT INTO family_groups (id, owner_id, name, max_members, storage_limit_bytes, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
  )
    .bind(groupId, ctx.userId, name, maxMembers, storageLimit, now, now)
    .run();

  await env.DB.prepare(
    'UPDATE users SET family_group_id = ?, updated_at = ? WHERE id = ?',
  )
    .bind(groupId, now, ctx.userId)
    .run();

  const group: FamilyGroup = {
    id: groupId,
    owner_id: ctx.userId,
    name,
    max_members: maxMembers,
    storage_limit_bytes: storageLimit,
    created_at: now,
    updated_at: now,
  };

  return jsonResponse({ data: group }, 201, request);
}

// ============================================================
// Handler: GET /family/members
// ============================================================
export async function handleGetMembers(
  request: Request,
  env: Env,
): Promise<Response> {
  const { ctx, error } = await requireAuth(request, env);
  if (error) return error;

  const planError = requireFamilyPlan(ctx, request);
  if (planError) return planError;

  const groupError = requireGroupMembership(ctx, request);
  if (groupError) return groupError;

  const groupId = ctx.groupId!;

  const group = await env.DB
    .prepare('SELECT * FROM family_groups WHERE id = ?')
    .bind(groupId)
    .first<FamilyGroup>();

  if (!group) {
    return errorResponse('Family group not found', 404, request);
  }

  const membersResult = await env.DB
    .prepare(
      `SELECT id, email, plan, storage_used_bytes, created_at
       FROM users WHERE family_group_id = ? ORDER BY created_at ASC`,
    )
    .bind(groupId)
    .all<Pick<User, 'id' | 'email' | 'plan' | 'storage_used_bytes' | 'created_at'>>();

  const members: FamilyMember[] = membersResult.results.map((u) => ({
    id: u.id,
    email: u.email,
    plan: u.plan,
    is_owner: u.id === group.owner_id,
    storage_used_bytes: u.storage_used_bytes,
    joined_at: u.created_at,
  }));

  return jsonResponse(
    { data: { group, members } },
    200,
    request,
  );
}

// ============================================================
// Handler: POST /family/invite
// ============================================================
export async function handleCreateInvite(
  request: Request,
  env: Env,
): Promise<Response> {
  const { ctx, error } = await requireAuth(request, env);
  if (error) return error;

  const planError = requireFamilyPlan(ctx, request);
  if (planError) return planError;

  const groupError = requireGroupMembership(ctx, request);
  if (groupError) return groupError;

  const groupId = ctx.groupId!;

  // Check max members
  const group = await env.DB
    .prepare('SELECT max_members FROM family_groups WHERE id = ?')
    .bind(groupId)
    .first<{ max_members: number }>();

  if (!group) {
    return errorResponse('Family group not found', 404, request);
  }

  const currentCount = await getGroupMemberCount(env.DB, groupId);
  if (currentCount >= group.max_members) {
    return errorResponse(
      `Group is full (max ${group.max_members} members)`,
      409,
      request,
    );
  }

  // Generate invite token
  const tokenBytes = new Uint8Array(16);
  crypto.getRandomValues(tokenBytes);
  const token = Array.from(tokenBytes)
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');

  const now = Date.now();
  const expiresAt = now + INVITE_TTL_MS;

  const invite: FamilyInvite = {
    token,
    group_id: groupId,
    created_by: ctx.userId,
    expires_at: expiresAt,
    accepted_by: null,
    accepted_at: null,
    is_used: 0,
  };

  await env.DB.prepare(
    `INSERT INTO family_invites (token, group_id, created_by, expires_at, is_used)
     VALUES (?, ?, ?, ?, 0)`,
  )
    .bind(token, groupId, ctx.userId, expiresAt)
    .run();

  return jsonResponse({ data: invite }, 201, request);
}

// ============================================================
// Handler: GET /family/invite/:token
// ============================================================
export async function handleGetInvite(
  request: Request,
  env: Env,
  token: string,
): Promise<Response> {
  const invite = await env.DB
    .prepare(
      `SELECT fi.*, fg.name as group_name
       FROM family_invites fi
       JOIN family_groups fg ON fi.group_id = fg.id
       WHERE fi.token = ?`,
    )
    .bind(token)
    .first<FamilyInvite & { group_name: string | null }>();

  if (!invite) {
    return errorResponse('Invite not found', 404, request);
  }

  const now = Date.now();
  const isValid = invite.is_used === 0 && invite.expires_at > now;

  const info: InviteInfo = {
    token: invite.token,
    group_id: invite.group_id,
    group_name: invite.group_name,
    expires_at: invite.expires_at,
    is_valid: isValid,
  };

  return jsonResponse({ data: info }, 200, request);
}

// ============================================================
// Handler: POST /family/invite/:token/accept
// ============================================================
export async function handleAcceptInvite(
  request: Request,
  env: Env,
  token: string,
): Promise<Response> {
  const { ctx, error } = await requireAuth(request, env);
  if (error) return error;

  // Must have a family plan to join
  const planError = requireFamilyPlan(ctx, request);
  if (planError) return planError;

  // Cannot accept if already in a group
  if (ctx.groupId) {
    return errorResponse(
      'Already in a family group. Leave first.',
      409,
      request,
    );
  }

  const now = Date.now();

  // Fetch and validate invite
  const invite = await env.DB
    .prepare(
      'SELECT * FROM family_invites WHERE token = ? AND is_used = 0 AND expires_at > ?',
    )
    .bind(token, now)
    .first<FamilyInvite>();

  if (!invite) {
    return errorResponse('Invite is invalid or has expired', 410, request);
  }

  // Check group capacity
  const group = await env.DB
    .prepare('SELECT * FROM family_groups WHERE id = ?')
    .bind(invite.group_id)
    .first<FamilyGroup>();

  if (!group) {
    return errorResponse('Family group no longer exists', 404, request);
  }

  const currentCount = await getGroupMemberCount(env.DB, invite.group_id);
  if (currentCount >= group.max_members) {
    return errorResponse(
      `Group is full (max ${group.max_members} members)`,
      409,
      request,
    );
  }

  // Join group and mark invite as used — in a batch
  await env.DB.batch([
    env.DB.prepare(
      'UPDATE family_invites SET is_used = 1, accepted_by = ?, accepted_at = ? WHERE token = ?',
    ).bind(ctx.userId, now, token),

    env.DB.prepare(
      'UPDATE users SET family_group_id = ?, updated_at = ? WHERE id = ?',
    ).bind(invite.group_id, now, ctx.userId),

    env.DB.prepare(
      'UPDATE family_groups SET updated_at = ? WHERE id = ?',
    ).bind(now, invite.group_id),
  ]);

  return jsonResponse(
    { data: { group_id: invite.group_id, joined_at: now } },
    200,
    request,
  );
}

// ============================================================
// Handler: DELETE /family/leave
// ============================================================
export async function handleLeaveFamily(
  request: Request,
  env: Env,
): Promise<Response> {
  const { ctx, error } = await requireAuth(request, env);
  if (error) return error;

  const groupError = requireGroupMembership(ctx, request);
  if (groupError) return groupError;

  const groupId = ctx.groupId!;
  const now = Date.now();

  const group = await env.DB
    .prepare('SELECT owner_id FROM family_groups WHERE id = ?')
    .bind(groupId)
    .first<{ owner_id: string }>();

  if (!group) {
    return errorResponse('Family group not found', 404, request);
  }

  if (group.owner_id === ctx.userId) {
    // Owner leaving — disband the entire group
    await env.DB.batch([
      // Remove all members from group
      env.DB.prepare(
        'UPDATE users SET family_group_id = NULL, updated_at = ? WHERE family_group_id = ?',
      ).bind(now, groupId),

      // Invalidate all pending invites
      env.DB.prepare('DELETE FROM family_invites WHERE group_id = ?').bind(groupId),

      // Delete sync checkpoints
      env.DB.prepare('DELETE FROM sync_checkpoints WHERE group_id = ?').bind(groupId),

      // Delete group
      env.DB.prepare('DELETE FROM family_groups WHERE id = ?').bind(groupId),
    ]);

    return jsonResponse({ data: { disbanded: true } }, 200, request);
  } else {
    // Regular member leaving
    await env.DB.prepare(
      'UPDATE users SET family_group_id = NULL, updated_at = ? WHERE id = ?',
    )
      .bind(now, ctx.userId)
      .run();

    await env.DB.prepare(
      'UPDATE family_groups SET updated_at = ? WHERE id = ?',
    )
      .bind(now, groupId)
      .run();

    return jsonResponse({ data: { left: true } }, 200, request);
  }
}

// ============================================================
// Handler: DELETE /family/members/:userId
// Only group owner can remove members
// ============================================================
export async function handleRemoveMember(
  request: Request,
  env: Env,
  targetUserId: string,
): Promise<Response> {
  const { ctx, error } = await requireAuth(request, env);
  if (error) return error;

  const groupError = requireGroupMembership(ctx, request);
  if (groupError) return groupError;

  const groupId = ctx.groupId!;

  // Fetch group to check ownership
  const group = await env.DB
    .prepare('SELECT owner_id FROM family_groups WHERE id = ?')
    .bind(groupId)
    .first<{ owner_id: string }>();

  if (!group) {
    return errorResponse('Family group not found', 404, request);
  }

  if (group.owner_id !== ctx.userId) {
    return errorResponse('Only the group owner can remove members', 403, request);
  }

  if (targetUserId === ctx.userId) {
    return errorResponse(
      'Owner cannot remove themselves. Use DELETE /family/leave instead.',
      400,
      request,
    );
  }

  // Verify target is actually in this group
  const target = await env.DB
    .prepare(
      'SELECT id FROM users WHERE id = ? AND family_group_id = ?',
    )
    .bind(targetUserId, groupId)
    .first<{ id: string }>();

  if (!target) {
    return errorResponse('User is not a member of this group', 404, request);
  }

  const now = Date.now();

  await env.DB.batch([
    env.DB.prepare(
      'UPDATE users SET family_group_id = NULL, updated_at = ? WHERE id = ?',
    ).bind(now, targetUserId),

    env.DB.prepare(
      'UPDATE family_groups SET updated_at = ? WHERE id = ?',
    ).bind(now, groupId),
  ]);

  return jsonResponse({ data: { removed: true } }, 200, request);
}
