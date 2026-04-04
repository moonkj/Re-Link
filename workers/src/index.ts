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
