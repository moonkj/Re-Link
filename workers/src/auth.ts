// Re-Link Workers — Auth Endpoints
// POST /auth/apple    — Apple ID token → JWT
// POST /auth/google   — Google ID token → JWT
// POST /auth/refresh  — Refresh token → new Access token
// DELETE /auth/signout — Logout (invalidate refresh token)
// DELETE /auth/account — Delete account (App Store policy)
// GET /me             — Current user info

import type {
  Env,
  User,
  UserPublic,
  AuthProvider,
  AppleAuthRequest,
  GoogleAuthRequest,
  AuthResponse,
  RefreshRequest,
  RefreshResponse,
} from './types';
import {
  signJWT,
  verifyJWTString,
  generateRefreshToken,
  requireAuth,
  jsonResponse,
  errorResponse,
} from './middleware';

// ============================================================
// Constants
// ============================================================
const ACCESS_TOKEN_TTL = 60 * 60;           // 1 hour (seconds)
const REFRESH_TOKEN_TTL = 30 * 24 * 60 * 60; // 30 days (seconds)

// ============================================================
// Apple JWKS verification
// ============================================================
interface AppleJWKS {
  keys: AppleJWK[];
}
interface AppleJWK {
  kty: string;
  kid: string;
  use: string;
  alg: string;
  n: string;
  e: string;
}

async function importRsaPublicKey(jwk: AppleJWK): Promise<CryptoKey> {
  return crypto.subtle.importKey(
    'jwk',
    jwk as unknown as JsonWebKey,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['verify'],
  );
}

function base64UrlToBytes(str: string): Uint8Array {
  const padded = str.replace(/-/g, '+').replace(/_/g, '/');
  const pad = padded.length % 4;
  const b64 = pad ? padded + '='.repeat(4 - pad) : padded;
  const binary = atob(b64);
  return Uint8Array.from(binary, (c) => c.charCodeAt(0));
}

async function verifyAppleToken(
  idToken: string,
  clientId: string,
): Promise<{ sub: string; email?: string }> {
  const parts = idToken.split('.');
  if (parts.length !== 3) throw new Error('Invalid Apple token format');

  const headerJson = JSON.parse(atob(parts[0])) as { kid: string; alg: string };

  // Fetch Apple's public keys
  const jwksRes = await fetch('https://appleid.apple.com/auth/keys');
  if (!jwksRes.ok) throw new Error('Failed to fetch Apple JWKS');
  const jwks = (await jwksRes.json()) as AppleJWKS;

  const key = jwks.keys.find((k) => k.kid === headerJson.kid);
  if (!key) throw new Error('Apple signing key not found');

  const cryptoKey = await importRsaPublicKey(key);
  const signingInput = `${parts[0]}.${parts[1]}`;
  const signature = base64UrlToBytes(parts[2]);

  const valid = await crypto.subtle.verify(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    signature,
    new TextEncoder().encode(signingInput),
  );
  if (!valid) throw new Error('Invalid Apple token signature');

  const payload = JSON.parse(atob(parts[1])) as {
    sub: string;
    email?: string;
    aud: string;
    exp: number;
    iss: string;
  };

  // Validate claims
  const now = Math.floor(Date.now() / 1000);
  if (payload.exp < now) throw new Error('Apple token expired');
  if (payload.iss !== 'https://appleid.apple.com')
    throw new Error('Invalid Apple token issuer');
  if (payload.aud !== clientId)
    throw new Error('Apple token audience mismatch');

  return { sub: payload.sub, email: payload.email };
}

// ============================================================
// Google tokeninfo verification
// ============================================================
async function verifyGoogleToken(
  idToken: string,
  clientId: string,
): Promise<{ sub: string; email?: string }> {
  const url = `https://oauth2.googleapis.com/tokeninfo?id_token=${encodeURIComponent(idToken)}`;
  const res = await fetch(url);
  if (!res.ok) throw new Error('Invalid Google token');

  const info = (await res.json()) as {
    sub: string;
    email?: string;
    aud: string;
    exp: string;
    error_description?: string;
  };

  if (info.error_description) throw new Error(info.error_description);

  const now = Math.floor(Date.now() / 1000);
  if (parseInt(info.exp) < now) throw new Error('Google token expired');
  if (info.aud !== clientId)
    throw new Error('Google token audience mismatch');

  return { sub: info.sub, email: info.email };
}

// ============================================================
// DB helpers
// ============================================================
async function findOrCreateUser(
  db: D1Database,
  provider: AuthProvider,
  providerId: string,
  email: string | undefined,
): Promise<User> {
  const now = Date.now();

  // Try to find existing user
  const existing = await db
    .prepare('SELECT * FROM users WHERE provider_id = ?')
    .bind(providerId)
    .first<User>();

  if (existing) {
    // Update email if changed
    if (email && email !== existing.email) {
      await db
        .prepare('UPDATE users SET email = ?, updated_at = ? WHERE id = ?')
        .bind(email, now, existing.id)
        .run();
      existing.email = email;
      existing.updated_at = now;
    }
    return existing;
  }

  // Create new user
  const userId = crypto.randomUUID();
  await db
    .prepare(
      `INSERT INTO users (id, provider, provider_id, email, plan, storage_used_bytes, created_at, updated_at)
       VALUES (?, ?, ?, ?, 'free', 0, ?, ?)`,
    )
    .bind(userId, provider, providerId, email ?? null, now, now)
    .run();

  return {
    id: userId,
    provider,
    provider_id: providerId,
    email: email ?? null,
    plan: 'free',
    plan_expires_at: null,
    family_group_id: null,
    storage_used_bytes: 0,
    created_at: now,
    updated_at: now,
  };
}

async function issueTokenPair(
  db: D1Database,
  user: User,
  jwtSecret: string,
): Promise<{ accessToken: string; refreshToken: string }> {
  const accessToken = await signJWT(
    { sub: user.id, plan: user.plan, groupId: user.family_group_id },
    jwtSecret,
    ACCESS_TOKEN_TTL,
  );

  const refreshToken = generateRefreshToken();
  const now = Date.now();
  const expiresAt = now + REFRESH_TOKEN_TTL * 1000;

  await db
    .prepare(
      'INSERT INTO refresh_tokens (token, user_id, expires_at, created_at) VALUES (?, ?, ?, ?)',
    )
    .bind(refreshToken, user.id, expiresAt, now)
    .run();

  return { accessToken, refreshToken };
}

function toPublicUser(user: User): UserPublic {
  return {
    id: user.id,
    email: user.email,
    plan: user.plan,
    plan_expires_at: user.plan_expires_at,
    family_group_id: user.family_group_id,
    storage_used_bytes: user.storage_used_bytes,
    created_at: user.created_at,
  };
}

// ============================================================
// Handler: POST /auth/apple
// ============================================================
export async function handleAppleAuth(
  request: Request,
  env: Env,
): Promise<Response> {
  let body: AppleAuthRequest;
  try {
    body = (await request.json()) as AppleAuthRequest;
  } catch {
    return errorResponse('Invalid JSON body', 400, request);
  }

  if (!body.id_token) {
    return errorResponse('id_token is required', 400, request);
  }

  const clientId = env.APPLE_CLIENT_ID ?? 'com.relink';

  let providerInfo: { sub: string; email?: string };
  try {
    providerInfo = await verifyAppleToken(body.id_token, clientId);
  } catch (e) {
    return errorResponse(
      `Apple token verification failed: ${(e as Error).message}`,
      401,
      request,
    );
  }

  const email = body.user_info?.email ?? providerInfo.email;
  const user = await findOrCreateUser(env.DB, 'apple', providerInfo.sub, email);
  const { accessToken, refreshToken } = await issueTokenPair(
    env.DB,
    user,
    env.JWT_SECRET,
  );

  const response: AuthResponse = {
    access_token: accessToken,
    refresh_token: refreshToken,
    expires_in: ACCESS_TOKEN_TTL,
    user: toPublicUser(user),
  };

  return jsonResponse(response, 200, request);
}

// ============================================================
// Handler: POST /auth/google
// ============================================================
export async function handleGoogleAuth(
  request: Request,
  env: Env,
): Promise<Response> {
  let body: GoogleAuthRequest;
  try {
    body = (await request.json()) as GoogleAuthRequest;
  } catch {
    return errorResponse('Invalid JSON body', 400, request);
  }

  if (!body.id_token) {
    return errorResponse('id_token is required', 400, request);
  }

  const clientId = env.GOOGLE_CLIENT_ID ?? '';

  let providerInfo: { sub: string; email?: string };
  try {
    providerInfo = await verifyGoogleToken(body.id_token, clientId);
  } catch (e) {
    return errorResponse(
      `Google token verification failed: ${(e as Error).message}`,
      401,
      request,
    );
  }

  const user = await findOrCreateUser(
    env.DB,
    'google',
    providerInfo.sub,
    providerInfo.email,
  );
  const { accessToken, refreshToken } = await issueTokenPair(
    env.DB,
    user,
    env.JWT_SECRET,
  );

  const response: AuthResponse = {
    access_token: accessToken,
    refresh_token: refreshToken,
    expires_in: ACCESS_TOKEN_TTL,
    user: toPublicUser(user),
  };

  return jsonResponse(response, 200, request);
}

// ============================================================
// Handler: POST /auth/refresh
// ============================================================
export async function handleRefresh(
  request: Request,
  env: Env,
): Promise<Response> {
  let body: RefreshRequest;
  try {
    body = (await request.json()) as RefreshRequest;
  } catch {
    return errorResponse('Invalid JSON body', 400, request);
  }

  if (!body.refresh_token) {
    return errorResponse('refresh_token is required', 400, request);
  }

  const now = Date.now();

  // Lookup refresh token
  const rt = await env.DB
    .prepare(
      'SELECT * FROM refresh_tokens WHERE token = ? AND expires_at > ?',
    )
    .bind(body.refresh_token, now)
    .first<{ token: string; user_id: string; expires_at: number }>();

  if (!rt) {
    return errorResponse('Invalid or expired refresh token', 401, request);
  }

  // Fetch user
  const user = await env.DB
    .prepare('SELECT * FROM users WHERE id = ?')
    .bind(rt.user_id)
    .first<User>();

  if (!user) {
    return errorResponse('User not found', 401, request);
  }

  // Issue new access token (keep same refresh token)
  const accessToken = await signJWT(
    { sub: user.id, plan: user.plan, groupId: user.family_group_id },
    env.JWT_SECRET,
    ACCESS_TOKEN_TTL,
  );

  const response: RefreshResponse = {
    access_token: accessToken,
    expires_in: ACCESS_TOKEN_TTL,
  };

  return jsonResponse(response, 200, request);
}

// ============================================================
// Handler: DELETE /auth/signout
// ============================================================
export async function handleSignout(
  request: Request,
  env: Env,
): Promise<Response> {
  const { ctx, error } = await requireAuth(request, env);
  if (error) return error;

  // Optionally accept specific refresh token to invalidate
  let refreshToken: string | null = null;
  try {
    const body = (await request.json()) as { refresh_token?: string };
    refreshToken = body.refresh_token ?? null;
  } catch {
    // No body — invalidate all tokens for user
  }

  if (refreshToken) {
    await env.DB
      .prepare('DELETE FROM refresh_tokens WHERE token = ? AND user_id = ?')
      .bind(refreshToken, ctx.userId)
      .run();
  } else {
    await env.DB
      .prepare('DELETE FROM refresh_tokens WHERE user_id = ?')
      .bind(ctx.userId)
      .run();
  }

  return jsonResponse({ data: { success: true } }, 200, request);
}

// ============================================================
// Handler: DELETE /auth/account
// App Store policy: user must be able to delete their account
// ============================================================
export async function handleDeleteAccount(
  request: Request,
  env: Env,
): Promise<Response> {
  const { ctx, error } = await requireAuth(request, env);
  if (error) return error;

  const { userId } = ctx;

  // Remove from family group if member
  if (ctx.groupId) {
    const group = await env.DB
      .prepare('SELECT owner_id FROM family_groups WHERE id = ?')
      .bind(ctx.groupId)
      .first<{ owner_id: string }>();

    if (group?.owner_id === userId) {
      // Owner deleting — disband the group
      await env.DB
        .prepare(
          "UPDATE users SET family_group_id = NULL, updated_at = ? WHERE family_group_id = ?",
        )
        .bind(Date.now(), ctx.groupId)
        .run();
      await env.DB
        .prepare('DELETE FROM family_invites WHERE group_id = ?')
        .bind(ctx.groupId)
        .run();
      await env.DB
        .prepare('DELETE FROM family_groups WHERE id = ?')
        .bind(ctx.groupId)
        .run();
    } else {
      // Non-owner — just leave the group
      await env.DB
        .prepare(
          'UPDATE users SET family_group_id = NULL, updated_at = ? WHERE id = ?',
        )
        .bind(Date.now(), userId)
        .run();
    }
  }

  // Delete user's sync data
  // (Media files in R2 are not deleted here — background cleanup job recommended)
  await env.DB.prepare('DELETE FROM refresh_tokens WHERE user_id = ?').bind(userId).run();
  await env.DB.prepare('DELETE FROM sync_checkpoints WHERE user_id = ?').bind(userId).run();
  await env.DB.prepare('DELETE FROM users WHERE id = ?').bind(userId).run();

  return jsonResponse({ data: { success: true } }, 200, request);
}

// ============================================================
// Handler: GET /me
// ============================================================
export async function handleGetMe(
  request: Request,
  env: Env,
): Promise<Response> {
  const { ctx, error } = await requireAuth(request, env);
  if (error) return error;

  const user = await env.DB
    .prepare('SELECT * FROM users WHERE id = ?')
    .bind(ctx.userId)
    .first<User>();

  if (!user) {
    return errorResponse('User not found', 404, request);
  }

  return jsonResponse(toPublicUser(user), 200, request);
}
