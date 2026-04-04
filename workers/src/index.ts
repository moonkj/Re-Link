// Re-Link Workers — Main Entry Point
// Cloudflare Workers fetch handler + URL router + scheduled cron handler

import type { Env } from './types';
import type { User } from './types';
import { corsPreflightResponse, errorResponse, jsonResponse, requireAuth } from './middleware';

// Auth handlers
import {
  handleAppleAuth,
  handleGoogleAuth,
  handleKakaoAuth,
  handleRefresh,
  handleSignout,
  handleDeleteAccount,
  handleGetMe,
} from './auth';

// Sync handlers
import { handlePull, handlePush } from './sync';

// Family handlers
import {
  handleCreateFamily,
  handleGetMembers,
  handleCreateInvite,
  handleGetInvite,
  handleAcceptInvite,
  handleLeaveFamily,
  handleRemoveMember,
} from './family';

// Media handlers
import {
  handleUploadUrl,
  handleConfirmUpload,
  handleDownloadUrl,
  handleDeleteMedia,
  handleStorageUsage,
} from './media';

// Purchase handlers
import { handlePurchaseVerify } from './purchase';

// Cleanup handlers
import { handleScheduledCleanup, computeDataRetentionStatus } from './cleanup';

// ============================================================
// Route table type
// ============================================================
type Handler = (
  request: Request,
  env: Env,
  ...params: string[]
) => Promise<Response>;

interface Route {
  method: string;     // 'GET' | 'POST' | 'DELETE' | '*'
  pattern: RegExp;
  handler: Handler;
}

// ============================================================
// Route definitions
// Order matters — first match wins
// ============================================================
const routes: Route[] = [
  // ── Auth ─────────────────────────────────────────────────
  {
    method: 'POST',
    pattern: /^\/auth\/apple$/,
    handler: (req, env) => handleAppleAuth(req, env),
  },
  {
    method: 'POST',
    pattern: /^\/auth\/google$/,
    handler: (req, env) => handleGoogleAuth(req, env),
  },
  {
    method: 'POST',
    pattern: /^\/auth\/kakao$/,
    handler: (req, env) => handleKakaoAuth(req, env),
  },
  {
    // 카카오 OAuth 콜백 (WebView에서 코드를 가로채므로 실제 호출 안 됨)
    // 카카오 콘솔 Redirect URI 검증용
    method: 'GET',
    pattern: /^\/auth\/kakao\/callback/,
    handler: async (req) => {
      const url = new URL(req.url);
      const code = url.searchParams.get('code');
      return new Response(
        `<html><body><script>window.close();</script><p>인증 완료. code=${code}</p></body></html>`,
        { headers: { 'Content-Type': 'text/html' } },
      );
    },
  },
  {
    method: 'POST',
    pattern: /^\/auth\/refresh$/,
    handler: (req, env) => handleRefresh(req, env),
  },
  {
    // Flutter uses POST for signout
    method: 'POST',
    pattern: /^\/auth\/signout$/,
    handler: (req, env) => handleSignout(req, env),
  },
  {
    method: 'DELETE',
    pattern: /^\/auth\/account$/,
    handler: (req, env) => handleDeleteAccount(req, env),
  },
  {
    // Flutter calls GET /auth/me
    method: 'GET',
    pattern: /^\/auth\/me$/,
    handler: (req, env) => handleGetMe(req, env),
  },

  // ── Sync ─────────────────────────────────────────────────
  {
    method: 'GET',
    pattern: /^\/sync\/pull$/,
    handler: (req, env) => handlePull(req, env),
  },
  {
    method: 'POST',
    pattern: /^\/sync\/push$/,
    handler: (req, env) => handlePush(req, env),
  },

  // ── Family ───────────────────────────────────────────────
  {
    method: 'POST',
    pattern: /^\/family\/create$/,
    handler: (req, env) => handleCreateFamily(req, env),
  },
  {
    method: 'GET',
    pattern: /^\/family\/members$/,
    handler: (req, env) => handleGetMembers(req, env),
  },
  {
    method: 'POST',
    pattern: /^\/family\/invite$/,
    handler: (req, env) => handleCreateInvite(req, env),
  },
  {
    // GET /family/invite/:token  (not followed by /accept)
    method: 'GET',
    pattern: /^\/family\/invite\/([^/]+)$/,
    handler: (req, env, token) => handleGetInvite(req, env, token),
  },
  {
    // POST /family/invite/:token/accept
    method: 'POST',
    pattern: /^\/family\/invite\/([^/]+)\/accept$/,
    handler: (req, env, token) => handleAcceptInvite(req, env, token),
  },
  {
    method: 'DELETE',
    pattern: /^\/family\/leave$/,
    handler: (req, env) => handleLeaveFamily(req, env),
  },
  {
    // DELETE /family/members/:userId
    method: 'DELETE',
    pattern: /^\/family\/members\/([^/]+)$/,
    handler: (req, env, userId) => handleRemoveMember(req, env, userId),
  },

  // ── Media ────────────────────────────────────────────────
  {
    method: 'POST',
    pattern: /^\/media\/upload-url$/,
    handler: (req, env) => handleUploadUrl(req, env),
  },
  {
    // POST /media/confirm-upload — confirm R2 upload & update storage usage
    method: 'POST',
    pattern: /^\/media\/confirm-upload$/,
    handler: (req, env) => handleConfirmUpload(req, env),
  },
  {
    // Flutter calls GET /media/usage
    method: 'GET',
    pattern: /^\/media\/usage$/,
    handler: (req, env) => handleStorageUsage(req, env),
  },
  {
    // GET /media/:fileKey/download-url
    // fileKey may contain slashes (decoded from URL)
    method: 'GET',
    pattern: /^\/media\/(.+)\/download-url$/,
    handler: (req, env, fileKey) =>
      handleDownloadUrl(req, env, decodeURIComponent(fileKey)),
  },
  {
    // DELETE /media/:fileKey
    method: 'DELETE',
    pattern: /^\/media\/(.+)$/,
    handler: (req, env, fileKey) =>
      handleDeleteMedia(req, env, decodeURIComponent(fileKey)),
  },

  // ── Purchase ──────────────────────────────────────────────
  {
    method: 'POST',
    pattern: /^\/purchase\/verify$/,
    handler: (req, env) => handlePurchaseVerify(req, env),
  },

  // ── Admin ────────────────────────────────────────────────
  {
    method: 'POST',
    pattern: /^\/admin\/cleanup$/,
    handler: (req, env) => handleAdminCleanup(req, env),
  },
  {
    method: 'POST',
    pattern: /^\/admin\/grant-plan$/,
    handler: (req, env) => handleAdminGrantPlan(req, env),
  },
  {
    method: 'GET',
    pattern: /^\/admin\/search-user$/,
    handler: (req, env) => handleAdminSearchUser(req, env),
  },
  {
    method: 'GET',
    pattern: /^\/admin\/stats$/,
    handler: (req, env) => handleAdminStats(req, env),
  },
  {
    method: 'POST',
    pattern: /^\/admin\/reset-stats$/,
    handler: (req, env) => handleAdminResetStats(req, env),
  },
  {
    method: 'GET',
    pattern: /^\/admin\/revenue$/,
    handler: (req, env) => handleAdminRevenue(req, env),
  },
  {
    method: 'GET',
    pattern: /^\/admin\/user-detail$/,
    handler: (req, env) => handleAdminUserDetail(req, env),
  },
  {
    method: 'GET',
    pattern: /^\/admin\/health$/,
    handler: (req, env) => handleAdminHealth(req, env),
  },
  {
    method: 'GET',
    pattern: /^\/admin\/storage-overview$/,
    handler: (req, env) => handleAdminStorageOverview(req, env),
  },
  {
    method: 'GET',
    pattern: /^\/admin\/errors$/,
    handler: (req, env) => handleAdminErrors(req, env),
  },
  {
    method: 'POST',
    pattern: /^\/admin\/force-logout$/,
    handler: (req, env) => handleAdminForceLogout(req, env),
  },
  {
    method: 'GET',
    pattern: /^\/admin\/announcement$/,
    handler: (req, env) => handleGetAnnouncement(req, env),
  },
  {
    method: 'POST',
    pattern: /^\/admin\/announcement$/,
    handler: (req, env) => handleSetAnnouncement(req, env),
  },
  {
    method: 'GET',
    pattern: /^\/admin\/families$/,
    handler: (req, env) => handleAdminFamilies(req, env),
  },
  {
    method: 'GET',
    pattern: /^\/system\/announcement$/,
    handler: (req, env) => handlePublicAnnouncement(req, env),
  },

  // ── User Data Retention ──────────────────────────────────
  {
    method: 'GET',
    pattern: /^\/user\/data-retention$/,
    handler: (req, env) => handleDataRetention(req, env),
  },
];

// ============================================================
// Router
// ============================================================
function matchRoute(
  method: string,
  pathname: string,
): { handler: Handler; params: string[] } | null {
  for (const route of routes) {
    if (route.method !== '*' && route.method !== method) continue;
    const match = pathname.match(route.pattern);
    if (match) {
      const params = match.slice(1); // capture groups
      return { handler: route.handler, params };
    }
  }
  return null;
}

// ============================================================
// Admin: POST /admin/cleanup — manual cleanup trigger
// ============================================================
async function handleAdminCleanup(
  request: Request,
  env: Env,
): Promise<Response> {
  // Verify admin secret header
  const adminSecret = request.headers.get('X-Admin-Secret');
  if (!env.ADMIN_SECRET || !adminSecret || adminSecret !== env.ADMIN_SECRET) {
    return errorResponse('Forbidden', 403, request);
  }

  const result = await handleScheduledCleanup(env);
  return jsonResponse({ data: result }, 200, request);
}

// ============================================================
// User: GET /user/data-retention — data retention status
// ============================================================
async function handleDataRetention(
  request: Request,
  env: Env,
): Promise<Response> {
  const { ctx, error } = await requireAuth(request, env);
  if (error) return error;

  const user = await env.DB
    .prepare('SELECT plan, plan_expires_at FROM users WHERE id = ?')
    .bind(ctx.userId)
    .first<Pick<User, 'plan' | 'plan_expires_at'>>();

  if (!user) {
    return errorResponse('User not found', 404, request);
  }

  const status = computeDataRetentionStatus(user.plan, user.plan_expires_at);
  return jsonResponse({ data: status }, 200, request);
}

// ============================================================
// Admin: POST /admin/grant-plan — grant plan to user by email
// ============================================================
async function handleAdminGrantPlan(
  request: Request,
  env: Env,
): Promise<Response> {
  const adminSecret = request.headers.get('X-Admin-Secret');
  if (!env.ADMIN_SECRET || !adminSecret || adminSecret !== env.ADMIN_SECRET) {
    return errorResponse('Forbidden', 403, request);
  }

  let body: { email: string; plan: string; duration_days: number };
  try {
    body = (await request.json()) as typeof body;
  } catch {
    return errorResponse('Invalid JSON body', 400, request);
  }

  if (!body.email || !body.plan || !body.duration_days) {
    return errorResponse('email, plan, duration_days are required', 400, request);
  }

  const validPlans = ['free', 'plus', 'family', 'family_plus'];
  if (!validPlans.includes(body.plan)) {
    return errorResponse(`Invalid plan. Must be one of: ${validPlans.join(', ')}`, 400, request);
  }

  const user = await env.DB
    .prepare('SELECT id, email, plan, plan_expires_at FROM users WHERE email = ?')
    .bind(body.email)
    .first<{ id: string; email: string; plan: string; plan_expires_at: number | null }>();

  if (!user) {
    return errorResponse(`User not found: ${body.email}`, 404, request);
  }

  const now = Date.now();
  const expiresAt = now + body.duration_days * 24 * 60 * 60 * 1000;

  await env.DB
    .prepare('UPDATE users SET plan = ?, plan_expires_at = ? WHERE id = ?')
    .bind(body.plan, expiresAt, user.id)
    .run();

  return jsonResponse({
    data: {
      user_id: user.id,
      email: user.email,
      previous_plan: user.plan,
      new_plan: body.plan,
      expires_at: new Date(expiresAt).toISOString(),
      duration_days: body.duration_days,
    },
  }, 200, request);
}

// ============================================================
// Admin: GET /admin/search-user — search user by email
// ============================================================
async function handleAdminSearchUser(
  request: Request,
  env: Env,
): Promise<Response> {
  const adminSecret = request.headers.get('X-Admin-Secret');
  if (!env.ADMIN_SECRET || !adminSecret || adminSecret !== env.ADMIN_SECRET) {
    return errorResponse('Forbidden', 403, request);
  }

  const url = new URL(request.url);
  const email = url.searchParams.get('email');
  if (!email) {
    return errorResponse('email query parameter required', 400, request);
  }

  const users = await env.DB
    .prepare('SELECT id, email, name, plan, plan_expires_at, storage_used_bytes, created_at FROM users WHERE email LIKE ?')
    .bind(`%${email}%`)
    .all<{ id: string; email: string; name: string | null; plan: string; plan_expires_at: number | null; storage_used_bytes: number; created_at: number }>();

  return jsonResponse({
    data: {
      count: users.results.length,
      users: users.results.map((u) => ({
        id: u.id,
        email: u.email,
        name: u.name,
        plan: u.plan,
        plan_expires_at: u.plan_expires_at ? new Date(u.plan_expires_at).toISOString() : null,
        storage_used_mb: Math.round(u.storage_used_bytes / 1024 / 1024 * 10) / 10,
        created_at: new Date(u.created_at).toISOString(),
      })),
    },
  }, 200, request);
}

// ============================================================
// Admin: GET /admin/stats — access statistics
// ============================================================
async function handleAdminStats(
  request: Request,
  env: Env,
): Promise<Response> {
  const adminSecret = request.headers.get('X-Admin-Secret');
  if (!env.ADMIN_SECRET || !adminSecret || adminSecret !== env.ADMIN_SECRET) {
    return errorResponse('Forbidden', 403, request);
  }

  const todayStart = new Date();
  todayStart.setHours(0, 0, 0, 0);
  const weekStart = new Date(todayStart);
  weekStart.setDate(weekStart.getDate() - weekStart.getDay());
  const monthStart = new Date(todayStart);
  monthStart.setDate(1);

  const todayMs = todayStart.getTime();
  const weekMs = weekStart.getTime();
  const monthMs = monthStart.getTime();

  const today = await env.DB
    .prepare('SELECT COUNT(DISTINCT user_id) as cnt FROM access_logs WHERE accessed_at >= ?')
    .bind(todayMs)
    .first<{ cnt: number }>();
  const week = await env.DB
    .prepare('SELECT COUNT(DISTINCT user_id) as cnt FROM access_logs WHERE accessed_at >= ?')
    .bind(weekMs)
    .first<{ cnt: number }>();
  const month = await env.DB
    .prepare('SELECT COUNT(DISTINCT user_id) as cnt FROM access_logs WHERE accessed_at >= ?')
    .bind(monthMs)
    .first<{ cnt: number }>();
  const total = await env.DB
    .prepare('SELECT COUNT(DISTINCT user_id) as cnt FROM access_logs')
    .first<{ cnt: number }>();
  const totalUsers = await env.DB
    .prepare('SELECT COUNT(*) as cnt FROM users')
    .first<{ cnt: number }>();

  // 플랜별 인원
  const planCounts = await env.DB
    .prepare('SELECT plan, COUNT(*) as cnt FROM users GROUP BY plan')
    .all<{ plan: string; cnt: number }>();
  const planMap: Record<string, number> = {};
  for (const row of planCounts.results) {
    planMap[row.plan] = row.cnt;
  }

  return jsonResponse({
    data: {
      today: today?.cnt ?? 0,
      this_week: week?.cnt ?? 0,
      this_month: month?.cnt ?? 0,
      total_unique: total?.cnt ?? 0,
      total_registered: totalUsers?.cnt ?? 0,
      plan_free: planMap['free'] ?? 0,
      plan_plus: planMap['plus'] ?? 0,
      plan_family: planMap['family'] ?? 0,
      plan_family_plus: planMap['family_plus'] ?? 0,
    },
  }, 200, request);
}

// ============================================================
// Admin: POST /admin/reset-stats — reset access logs
// ============================================================
async function handleAdminResetStats(
  request: Request,
  env: Env,
): Promise<Response> {
  const adminSecret = request.headers.get('X-Admin-Secret');
  if (!env.ADMIN_SECRET || !adminSecret || adminSecret !== env.ADMIN_SECRET) {
    return errorResponse('Forbidden', 403, request);
  }

  await env.DB.prepare('DELETE FROM access_logs').run();

  return jsonResponse({ data: { message: 'Access logs cleared' } }, 200, request);
}

// ============================================================
// Admin: GET /admin/revenue — purchase & subscription revenue stats
// ============================================================
async function handleAdminRevenue(
  request: Request,
  env: Env,
): Promise<Response> {
  const adminSecret = request.headers.get('X-Admin-Secret');
  if (!env.ADMIN_SECRET || !adminSecret || adminSecret !== env.ADMIN_SECRET) {
    return errorResponse('Forbidden', 403, request);
  }

  const now = Date.now();
  const todayStart = new Date();
  todayStart.setHours(0, 0, 0, 0);
  const weekStart = new Date(todayStart);
  weekStart.setDate(weekStart.getDate() - weekStart.getDay());
  const monthStart = new Date(todayStart);
  monthStart.setDate(1);

  const todayMs = todayStart.getTime();
  const weekMs = weekStart.getTime();
  const monthMs = monthStart.getTime();

  // Purchase counts by period
  const todayCount = await env.DB
    .prepare('SELECT COUNT(*) as cnt FROM purchase_receipts WHERE verified_at >= ?')
    .bind(todayMs)
    .first<{ cnt: number }>();
  const weekCount = await env.DB
    .prepare('SELECT COUNT(*) as cnt FROM purchase_receipts WHERE verified_at >= ?')
    .bind(weekMs)
    .first<{ cnt: number }>();
  const monthCount = await env.DB
    .prepare('SELECT COUNT(*) as cnt FROM purchase_receipts WHERE verified_at >= ?')
    .bind(monthMs)
    .first<{ cnt: number }>();

  // Breakdown by product_id
  const byProduct = await env.DB
    .prepare('SELECT product_id, COUNT(*) as cnt FROM purchase_receipts GROUP BY product_id')
    .all<{ product_id: string; cnt: number }>();
  const productBreakdown: Record<string, number> = {};
  for (const row of byProduct.results) {
    productBreakdown[row.product_id] = row.cnt;
  }

  // iOS vs Android
  const byPlatform = await env.DB
    .prepare('SELECT platform, COUNT(*) as cnt FROM purchase_receipts GROUP BY platform')
    .all<{ platform: string; cnt: number }>();
  const platformBreakdown: Record<string, number> = {};
  for (const row of byPlatform.results) {
    platformBreakdown[row.platform] = row.cnt;
  }

  // Active subscriptions
  const activeSubs = await env.DB
    .prepare('SELECT product_id, COUNT(*) as cnt FROM purchase_receipts WHERE expires_at > ? AND is_valid = 1 GROUP BY product_id')
    .bind(now)
    .all<{ product_id: string; cnt: number }>();
  const activeBreakdown: Record<string, number> = {};
  for (const row of activeSubs.results) {
    activeBreakdown[row.product_id] = row.cnt;
  }

  // MRR estimate
  const familyMonthly = activeBreakdown['family_monthly'] ?? 0;
  const familyAnnual = activeBreakdown['family_annual'] ?? 0;
  const familyPlusMonthly = activeBreakdown['family_plus_monthly'] ?? 0;
  const familyPlusAnnual = activeBreakdown['family_plus_annual'] ?? 0;

  const mrr =
    familyMonthly * 3900 +
    familyAnnual * 3158 +
    familyPlusMonthly * 6900 +
    familyPlusAnnual * 5158;

  return jsonResponse({
    data: {
      purchases_today: todayCount?.cnt ?? 0,
      purchases_this_week: weekCount?.cnt ?? 0,
      purchases_this_month: monthCount?.cnt ?? 0,
      by_product: productBreakdown,
      by_platform: platformBreakdown,
      active_subscriptions: activeBreakdown,
      mrr_krw: mrr,
    },
  }, 200, request);
}

// ============================================================
// Admin: GET /admin/user-detail — detailed user info
// ============================================================
async function handleAdminUserDetail(
  request: Request,
  env: Env,
): Promise<Response> {
  const adminSecret = request.headers.get('X-Admin-Secret');
  if (!env.ADMIN_SECRET || !adminSecret || adminSecret !== env.ADMIN_SECRET) {
    return errorResponse('Forbidden', 403, request);
  }

  const url = new URL(request.url);
  const userId = url.searchParams.get('id');
  const email = url.searchParams.get('email');

  if (!userId && !email) {
    return errorResponse('id or email query parameter required', 400, request);
  }

  // Fetch user
  let user: User | null;
  if (userId) {
    user = await env.DB
      .prepare('SELECT * FROM users WHERE id = ?')
      .bind(userId)
      .first<User>();
  } else {
    user = await env.DB
      .prepare('SELECT * FROM users WHERE email = ?')
      .bind(email!)
      .first<User>();
  }

  if (!user) {
    return errorResponse('User not found', 404, request);
  }

  // Last access
  const lastAccess = await env.DB
    .prepare('SELECT accessed_at FROM access_logs WHERE user_id = ? ORDER BY accessed_at DESC LIMIT 1')
    .bind(user.id)
    .first<{ accessed_at: number }>();

  // Purchase count
  const purchaseCount = await env.DB
    .prepare('SELECT COUNT(*) as cnt FROM purchase_receipts WHERE user_id = ?')
    .bind(user.id)
    .first<{ cnt: number }>();

  // Family group info
  let familyGroup: { id: string; name: string | null; owner_id: string; max_members: number; storage_limit_bytes: number } | null = null;
  if (user.family_group_id) {
    familyGroup = await env.DB
      .prepare('SELECT id, name, owner_id, max_members, storage_limit_bytes FROM family_groups WHERE id = ?')
      .bind(user.family_group_id)
      .first<{ id: string; name: string | null; owner_id: string; max_members: number; storage_limit_bytes: number }>();
  }

  return jsonResponse({
    data: {
      id: user.id,
      provider: user.provider,
      provider_id: user.provider_id,
      email: user.email,
      name: user.name,
      plan: user.plan,
      plan_expires_at: user.plan_expires_at ? new Date(user.plan_expires_at).toISOString() : null,
      family_group_id: user.family_group_id,
      storage_used_bytes: user.storage_used_bytes,
      storage_used_mb: Math.round(user.storage_used_bytes / 1024 / 1024 * 10) / 10,
      created_at: new Date(user.created_at).toISOString(),
      updated_at: new Date(user.updated_at).toISOString(),
      last_access: lastAccess ? new Date(lastAccess.accessed_at).toISOString() : null,
      purchase_count: purchaseCount?.cnt ?? 0,
      family_group: familyGroup ? {
        id: familyGroup.id,
        name: familyGroup.name,
        owner_id: familyGroup.owner_id,
        max_members: familyGroup.max_members,
        storage_limit_bytes: familyGroup.storage_limit_bytes,
      } : null,
    },
  }, 200, request);
}

// ============================================================
// Admin: GET /admin/health — table row counts
// ============================================================
async function handleAdminHealth(
  request: Request,
  env: Env,
): Promise<Response> {
  const adminSecret = request.headers.get('X-Admin-Secret');
  if (!env.ADMIN_SECRET || !adminSecret || adminSecret !== env.ADMIN_SECRET) {
    return errorResponse('Forbidden', 403, request);
  }

  const tables = [
    'users',
    'family_groups',
    'family_invites',
    'sync_nodes',
    'sync_edges',
    'sync_memories',
    'sync_checkpoints',
    'refresh_tokens',
    'purchase_receipts',
    'access_logs',
    'error_logs',
  ];

  const counts: Record<string, number> = {};
  for (const table of tables) {
    const result = await env.DB
      .prepare(`SELECT COUNT(*) as cnt FROM ${table}`)
      .first<{ cnt: number }>();
    counts[table] = result?.cnt ?? 0;
  }

  return jsonResponse({
    data: {
      table_counts: counts,
      timestamp: new Date().toISOString(),
    },
  }, 200, request);
}

// ============================================================
// Admin: GET /admin/storage-overview — storage usage summary
// ============================================================
async function handleAdminStorageOverview(
  request: Request,
  env: Env,
): Promise<Response> {
  const adminSecret = request.headers.get('X-Admin-Secret');
  if (!env.ADMIN_SECRET || !adminSecret || adminSecret !== env.ADMIN_SECRET) {
    return errorResponse('Forbidden', 403, request);
  }

  // Total storage used
  const totalStorage = await env.DB
    .prepare('SELECT SUM(storage_used_bytes) as total FROM users')
    .first<{ total: number | null }>();

  // Top 5 families by storage
  const topFamilies = await env.DB
    .prepare(`
      SELECT
        fg.id as group_id,
        fg.name as group_name,
        fg.owner_id,
        fg.storage_limit_bytes,
        COUNT(u.id) as member_count,
        SUM(u.storage_used_bytes) as total_storage
      FROM family_groups fg
      LEFT JOIN users u ON u.family_group_id = fg.id
      GROUP BY fg.id
      ORDER BY total_storage DESC
      LIMIT 5
    `)
    .all<{
      group_id: string;
      group_name: string | null;
      owner_id: string;
      storage_limit_bytes: number;
      member_count: number;
      total_storage: number | null;
    }>();

  return jsonResponse({
    data: {
      total_storage_bytes: totalStorage?.total ?? 0,
      total_storage_mb: Math.round((totalStorage?.total ?? 0) / 1024 / 1024 * 10) / 10,
      top_families: topFamilies.results.map((f) => ({
        group_id: f.group_id,
        group_name: f.group_name,
        owner_id: f.owner_id,
        member_count: f.member_count,
        storage_used_bytes: f.total_storage ?? 0,
        storage_used_mb: Math.round((f.total_storage ?? 0) / 1024 / 1024 * 10) / 10,
        storage_limit_bytes: f.storage_limit_bytes,
      })),
    },
  }, 200, request);
}

// ============================================================
// Admin: GET /admin/errors — recent error logs
// ============================================================
async function handleAdminErrors(
  request: Request,
  env: Env,
): Promise<Response> {
  const adminSecret = request.headers.get('X-Admin-Secret');
  if (!env.ADMIN_SECRET || !adminSecret || adminSecret !== env.ADMIN_SECRET) {
    return errorResponse('Forbidden', 403, request);
  }

  const errors = await env.DB
    .prepare('SELECT * FROM error_logs ORDER BY created_at DESC LIMIT 50')
    .all<{
      id: number;
      endpoint: string;
      method: string;
      error_message: string;
      user_id: string | null;
      created_at: number;
    }>();

  return jsonResponse({
    data: {
      count: errors.results.length,
      errors: errors.results.map((e) => ({
        id: e.id,
        endpoint: e.endpoint,
        method: e.method,
        error_message: e.error_message,
        user_id: e.user_id,
        created_at: new Date(e.created_at).toISOString(),
      })),
    },
  }, 200, request);
}

// ============================================================
// Admin: POST /admin/force-logout — revoke all refresh tokens
// ============================================================
async function handleAdminForceLogout(
  request: Request,
  env: Env,
): Promise<Response> {
  const adminSecret = request.headers.get('X-Admin-Secret');
  if (!env.ADMIN_SECRET || !adminSecret || adminSecret !== env.ADMIN_SECRET) {
    return errorResponse('Forbidden', 403, request);
  }

  let body: { user_id: string };
  try {
    body = (await request.json()) as typeof body;
  } catch {
    return errorResponse('Invalid JSON body', 400, request);
  }

  if (!body.user_id) {
    return errorResponse('user_id is required', 400, request);
  }

  const result = await env.DB
    .prepare('DELETE FROM refresh_tokens WHERE user_id = ?')
    .bind(body.user_id)
    .run();

  return jsonResponse({
    data: {
      message: `Force logout successful for user ${body.user_id}`,
      tokens_revoked: result.meta.changes ?? 0,
    },
  }, 200, request);
}

// ============================================================
// Admin: GET /admin/announcement — get current announcement
// ============================================================
async function handleGetAnnouncement(
  request: Request,
  env: Env,
): Promise<Response> {
  const adminSecret = request.headers.get('X-Admin-Secret');
  if (!env.ADMIN_SECRET || !adminSecret || adminSecret !== env.ADMIN_SECRET) {
    return errorResponse('Forbidden', 403, request);
  }

  const text = await env.DB
    .prepare("SELECT value FROM system_config WHERE key = 'announcement_text'")
    .first<{ value: string }>();
  const type = await env.DB
    .prepare("SELECT value FROM system_config WHERE key = 'announcement_type'")
    .first<{ value: string }>();

  return jsonResponse({
    data: {
      text: text?.value ?? null,
      type: type?.value ?? null,
    },
  }, 200, request);
}

// ============================================================
// Admin: POST /admin/announcement — set announcement
// ============================================================
async function handleSetAnnouncement(
  request: Request,
  env: Env,
): Promise<Response> {
  const adminSecret = request.headers.get('X-Admin-Secret');
  if (!env.ADMIN_SECRET || !adminSecret || adminSecret !== env.ADMIN_SECRET) {
    return errorResponse('Forbidden', 403, request);
  }

  let body: { text: string; type: 'info' | 'warning' | 'critical' };
  try {
    body = (await request.json()) as typeof body;
  } catch {
    return errorResponse('Invalid JSON body', 400, request);
  }

  if (!body.text || !body.type) {
    return errorResponse('text and type are required', 400, request);
  }

  const validTypes = ['info', 'warning', 'critical'];
  if (!validTypes.includes(body.type)) {
    return errorResponse(`Invalid type. Must be one of: ${validTypes.join(', ')}`, 400, request);
  }

  const now = Date.now();

  await env.DB.batch([
    env.DB
      .prepare("INSERT OR REPLACE INTO system_config (key, value, updated_at) VALUES ('announcement_text', ?, ?)")
      .bind(body.text, now),
    env.DB
      .prepare("INSERT OR REPLACE INTO system_config (key, value, updated_at) VALUES ('announcement_type', ?, ?)")
      .bind(body.type, now),
  ]);

  return jsonResponse({
    data: {
      message: 'Announcement updated',
      text: body.text,
      type: body.type,
    },
  }, 200, request);
}

// ============================================================
// Public: GET /system/announcement — public announcement
// ============================================================
async function handlePublicAnnouncement(
  request: Request,
  env: Env,
): Promise<Response> {
  const text = await env.DB
    .prepare("SELECT value FROM system_config WHERE key = 'announcement_text'")
    .first<{ value: string }>();
  const type = await env.DB
    .prepare("SELECT value FROM system_config WHERE key = 'announcement_type'")
    .first<{ value: string }>();

  if (!text) {
    return jsonResponse({ data: null }, 200, request);
  }

  return jsonResponse({
    data: {
      text: text.value,
      type: type?.value ?? 'info',
    },
  }, 200, request);
}

// ============================================================
// Admin: GET /admin/families — list all family groups
// ============================================================
async function handleAdminFamilies(
  request: Request,
  env: Env,
): Promise<Response> {
  const adminSecret = request.headers.get('X-Admin-Secret');
  if (!env.ADMIN_SECRET || !adminSecret || adminSecret !== env.ADMIN_SECRET) {
    return errorResponse('Forbidden', 403, request);
  }

  const families = await env.DB
    .prepare(`
      SELECT
        fg.id,
        fg.name,
        fg.owner_id,
        fg.max_members,
        fg.storage_limit_bytes,
        fg.created_at,
        owner.email as owner_email,
        COUNT(u.id) as member_count,
        SUM(u.storage_used_bytes) as total_storage
      FROM family_groups fg
      LEFT JOIN users owner ON owner.id = fg.owner_id
      LEFT JOIN users u ON u.family_group_id = fg.id
      GROUP BY fg.id
      ORDER BY fg.created_at DESC
    `)
    .all<{
      id: string;
      name: string | null;
      owner_id: string;
      max_members: number;
      storage_limit_bytes: number;
      created_at: number;
      owner_email: string | null;
      member_count: number;
      total_storage: number | null;
    }>();

  return jsonResponse({
    data: {
      count: families.results.length,
      families: families.results.map((f) => ({
        id: f.id,
        name: f.name,
        owner_id: f.owner_id,
        owner_email: f.owner_email,
        max_members: f.max_members,
        member_count: f.member_count,
        storage_used_bytes: f.total_storage ?? 0,
        storage_used_mb: Math.round((f.total_storage ?? 0) / 1024 / 1024 * 10) / 10,
        storage_limit_bytes: f.storage_limit_bytes,
        created_at: new Date(f.created_at).toISOString(),
      })),
    },
  }, 200, request);
}

// ============================================================
// Health check
// ============================================================
function handleHealth(request: Request, env: Env): Response {
  return jsonResponse(
    {
      status: 'ok',
      environment: env.ENVIRONMENT,
      timestamp: Date.now(),
    },
    200,
    request,
  );
}

// ============================================================
// Workers Fetch Handler
// ============================================================
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const method = request.method.toUpperCase();
    const pathname = url.pathname.replace(/\/$/, '') || '/'; // strip trailing slash

    // ── CORS preflight ──────────────────────────────────────
    if (method === 'OPTIONS') {
      return corsPreflightResponse(request);
    }

    // ── Health check ────────────────────────────────────────
    if (pathname === '/health' || pathname === '/') {
      return handleHealth(request, env);
    }

    // ── Route matching ──────────────────────────────────────
    const matched = matchRoute(method, pathname);

    if (!matched) {
      return errorResponse('Not found', 404, request);
    }

    // ── Execute handler ─────────────────────────────────────
    try {
      return await matched.handler(request, env, ...matched.params);
    } catch (err) {
      console.error('Unhandled error:', err);

      // Log error to D1 error_logs table
      try {
        const errMsg = err instanceof Error ? err.message : String(err);
        await env.DB
          .prepare('INSERT INTO error_logs (endpoint, method, error_message, user_id, created_at) VALUES (?, ?, ?, ?, ?)')
          .bind(pathname, method, errMsg, null, Date.now())
          .run();
      } catch {
        // Silently ignore logging failures to avoid masking the original error
      }

      const message =
        env.ENVIRONMENT === 'development' && err instanceof Error
          ? err.message
          : 'Internal server error';

      return errorResponse(message, 500, request);
    }
  },

  async scheduled(
    _controller: ScheduledController,
    env: Env,
    ctx: ExecutionContext,
  ): Promise<void> {
    ctx.waitUntil(
      handleScheduledCleanup(env).catch((err) => {
        console.error('Scheduled cleanup failed:', err);
      }),
    );
  },
} satisfies ExportedHandler<Env>;
