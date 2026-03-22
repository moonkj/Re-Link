// Re-Link Workers — Main Entry Point
// Cloudflare Workers fetch handler + URL router

import type { Env } from './types';
import { corsPreflightResponse, errorResponse, jsonResponse } from './middleware';

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
  handleDownloadUrl,
  handleDeleteMedia,
  handleStorageUsage,
} from './media';

// Purchase handlers
import { handlePurchaseVerify } from './purchase';

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
} satisfies ExportedHandler<Env>;
