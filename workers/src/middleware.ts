// Re-Link Workers — JWT Middleware
// HS256 JWT verification using Web Crypto API (available in Workers runtime)

import type { Env, JWTPayload, AuthContext, UserPlan } from './types';

// ============================================================
// CORS
// ============================================================
const ALLOWED_ORIGINS = [
  'capacitor://localhost',
  'ionic://localhost',
  'http://localhost',
  'http://localhost:3000',
  'https://relink.app',
];

export function corsHeaders(requestOrigin: string | null): HeadersInit {
  const origin =
    requestOrigin && ALLOWED_ORIGINS.some((o) => requestOrigin.startsWith(o))
      ? requestOrigin
      : ALLOWED_ORIGINS[0];

  return {
    'Access-Control-Allow-Origin': origin,
    'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Device-Id',
    'Access-Control-Max-Age': '86400',
    Vary: 'Origin',
  };
}

export function corsPreflightResponse(request: Request): Response {
  return new Response(null, {
    status: 204,
    headers: corsHeaders(request.headers.get('Origin')),
  });
}

// ============================================================
// Response helpers
// ============================================================
export function jsonResponse(
  body: unknown,
  status = 200,
  request?: Request,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...corsHeaders(request?.headers.get('Origin') ?? null),
    },
  });
}

export function errorResponse(
  message: string,
  status = 400,
  request?: Request,
): Response {
  // Flutter reads both 'error' and 'message' fields
  return jsonResponse({ error: message, message }, status, request);
}

// ============================================================
// JWT — encode / decode helpers (HS256, Web Crypto)
// ============================================================

function base64UrlEncode(data: string | ArrayBuffer): string {
  let bytes: Uint8Array;
  if (typeof data === 'string') {
    bytes = new TextEncoder().encode(data);
  } else {
    bytes = new Uint8Array(data);
  }
  // btoa works with binary strings
  const binary = String.fromCharCode(...bytes);
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
}

function base64UrlDecode(str: string): string {
  const padded = str.replace(/-/g, '+').replace(/_/g, '/');
  const pad = padded.length % 4;
  const paddedStr = pad ? padded + '='.repeat(4 - pad) : padded;
  return atob(paddedStr);
}

async function importHmacKey(secret: string): Promise<CryptoKey> {
  const keyData = new TextEncoder().encode(secret);
  return crypto.subtle.importKey(
    'raw',
    keyData,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign', 'verify'],
  );
}

export async function signJWT(
  payload: Omit<JWTPayload, 'iat' | 'exp'>,
  secret: string,
  expiresInSeconds: number,
): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const fullPayload: JWTPayload = {
    ...payload,
    iat: now,
    exp: now + expiresInSeconds,
  };

  const header = base64UrlEncode(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const body = base64UrlEncode(JSON.stringify(fullPayload));
  const signingInput = `${header}.${body}`;

  const key = await importHmacKey(secret);
  const signatureBuffer = await crypto.subtle.sign(
    'HMAC',
    key,
    new TextEncoder().encode(signingInput),
  );

  const signature = base64UrlEncode(signatureBuffer);
  return `${signingInput}.${signature}`;
}

export async function verifyJWTString(
  token: string,
  secret: string,
): Promise<JWTPayload> {
  const parts = token.split('.');
  if (parts.length !== 3) {
    throw new Error('Invalid JWT format');
  }

  const [header, body, signature] = parts;
  const signingInput = `${header}.${body}`;

  const key = await importHmacKey(secret);
  const sigBytes = Uint8Array.from(atob(signature.replace(/-/g, '+').replace(/_/g, '/')), (c) =>
    c.charCodeAt(0),
  );

  const valid = await crypto.subtle.verify(
    'HMAC',
    key,
    sigBytes,
    new TextEncoder().encode(signingInput),
  );
  if (!valid) {
    throw new Error('Invalid JWT signature');
  }

  const payload = JSON.parse(base64UrlDecode(body)) as JWTPayload;
  const now = Math.floor(Date.now() / 1000);
  if (payload.exp < now) {
    throw new Error('JWT expired');
  }

  return payload;
}

// ============================================================
// Auth Middleware — extract and verify Bearer token
// ============================================================
export async function verifyJWT(
  request: Request,
  env: Env,
): Promise<AuthContext | null> {
  const authHeader = request.headers.get('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null;
  }

  const token = authHeader.slice(7);
  try {
    const payload = await verifyJWTString(token, env.JWT_SECRET);
    return {
      userId: payload.sub,
      plan: payload.plan,
      groupId: payload.groupId,
    };
  } catch {
    return null;
  }
}

/** Middleware: require valid JWT. Returns 401 Response on failure, null on success. */
export async function requireAuth(
  request: Request,
  env: Env,
): Promise<{ ctx: AuthContext; error: null } | { ctx: null; error: Response }> {
  const ctx = await verifyJWT(request, env);
  if (!ctx) {
    return {
      ctx: null,
      error: errorResponse('Unauthorized', 401, request),
    };
  }
  return { ctx, error: null };
}

/** Middleware: require family plan (family | family_plus). */
export function requireFamilyPlan(
  ctx: AuthContext,
  request: Request,
): Response | null {
  const familyPlans: UserPlan[] = ['family', 'family_plus'];
  if (!familyPlans.includes(ctx.plan)) {
    return errorResponse(
      'Family or Family Plus plan required',
      403,
      request,
    );
  }
  return null;
}

/** Middleware: require active family group membership. */
export function requireGroupMembership(
  ctx: AuthContext,
  request: Request,
): Response | null {
  if (!ctx.groupId) {
    return errorResponse('Not a member of any family group', 403, request);
  }
  return null;
}

// ============================================================
// Refresh Token helpers
// ============================================================
export function generateRefreshToken(): string {
  const bytes = new Uint8Array(32);
  crypto.getRandomValues(bytes);
  return Array.from(bytes)
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}
