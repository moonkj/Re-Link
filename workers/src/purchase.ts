// Re-Link Workers — Purchase Verification Endpoint
// POST /purchase/verify — Verify App Store / Google Play receipt

import type {
  Env,
  PurchaseVerifyRequest,
  PurchaseVerifyResponse,
  UserPlan,
} from './types';
import { STORAGE_LIMITS, MAX_MEMBERS } from './types';
import {
  requireAuth,
  jsonResponse,
  errorResponse,
} from './middleware';

// ============================================================
// Product ID → Plan mapping (mirrors Flutter PlanProductIds)
// ============================================================
const PRODUCT_PLAN_MAP: Record<string, UserPlan> = {
  'com.relink.plus': 'plus',
  'com.relink.family_monthly': 'family',
  'com.relink.family_annual': 'family',
  'com.relink.family_plus_monthly': 'family_plus',
  'com.relink.family_plus_annual': 'family_plus',
};

// ============================================================
// SHA-256 hash helper for receipt dedup
// ============================================================
async function sha256Hex(data: string): Promise<string> {
  const buffer = await crypto.subtle.digest(
    'SHA-256',
    new TextEncoder().encode(data),
  );
  return Array.from(new Uint8Array(buffer))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

// ============================================================
// Apple App Store receipt validation
// https://developer.apple.com/documentation/appstoreserverapi
// For simplicity, we validate via the legacy verifyReceipt endpoint.
// In production, migrate to App Store Server API v2.
// ============================================================
async function verifyAppleReceipt(
  receipt: string,
  _productId: string,
): Promise<{ valid: boolean; expiresAt: string | null; error: string | null }> {
  // Try production first, then sandbox
  const urls = [
    'https://buy.itunes.apple.com/verifyReceipt',
    'https://sandbox.itunes.apple.com/verifyReceipt',
  ];

  for (const url of urls) {
    try {
      const res = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          'receipt-data': receipt,
          'exclude-old-transactions': true,
        }),
      });

      if (!res.ok) continue;

      const data = (await res.json()) as {
        status: number;
        latest_receipt_info?: Array<{
          product_id: string;
          expires_date_ms?: string;
        }>;
      };

      // Status 21007 = sandbox receipt sent to production → retry sandbox
      if (data.status === 21007) continue;

      if (data.status === 0) {
        // Find the matching product in latest_receipt_info
        const latestInfo = data.latest_receipt_info;
        if (latestInfo && latestInfo.length > 0) {
          const matching = latestInfo.find((r) => r.product_id === _productId) ?? latestInfo[0];
          const expiresMs = matching.expires_date_ms
            ? parseInt(matching.expires_date_ms, 10)
            : null;

          return {
            valid: true,
            expiresAt: expiresMs
              ? new Date(expiresMs).toISOString()
              : null,
            error: null,
          };
        }
        return { valid: true, expiresAt: null, error: null };
      }

      return {
        valid: false,
        expiresAt: null,
        error: `Apple verification failed with status ${data.status}`,
      };
    } catch {
      continue;
    }
  }

  // If all attempts fail, accept optimistically (offline-first approach)
  return { valid: true, expiresAt: null, error: null };
}

// ============================================================
// Google Play receipt validation
// Uses Google Play Developer API v3
// Requires server-to-server authentication (not implemented here;
// in production, use a service account or backend verification)
// ============================================================
async function verifyGoogleReceipt(
  receipt: string,
  _productId: string,
): Promise<{ valid: boolean; expiresAt: string | null; error: string | null }> {
  // Google Play receipts are purchase tokens.
  // Full server-side verification requires Google Play Developer API
  // with service account credentials. For now, accept optimistically
  // and log for audit. In production, implement:
  //
  // For subscriptions:
  //   GET https://androidpublisher.googleapis.com/androidpublisher/v3/applications/{packageName}/purchases/subscriptions/{subscriptionId}/tokens/{token}
  //
  // For one-time purchases:
  //   GET https://androidpublisher.googleapis.com/androidpublisher/v3/applications/{packageName}/purchases/products/{productId}/tokens/{token}

  if (!receipt || receipt.trim().length === 0) {
    return { valid: false, expiresAt: null, error: 'Empty receipt' };
  }

  // Accept optimistically (offline-first)
  // The receipt hash is stored for future server-side verification
  return { valid: true, expiresAt: null, error: null };
}

// ============================================================
// Handler: POST /purchase/verify
// ============================================================
export async function handlePurchaseVerify(
  request: Request,
  env: Env,
): Promise<Response> {
  const { ctx, error } = await requireAuth(request, env);
  if (error) return error;

  let body: PurchaseVerifyRequest;
  try {
    body = (await request.json()) as PurchaseVerifyRequest;
  } catch {
    return errorResponse('Invalid JSON body', 400, request);
  }

  const { receipt, product_id, platform } = body;

  if (!receipt || !product_id || !platform) {
    return errorResponse(
      'receipt, product_id, and platform are required',
      400,
      request,
    );
  }

  // Validate product_id
  const newPlan = PRODUCT_PLAN_MAP[product_id];
  if (!newPlan) {
    return errorResponse(`Unknown product_id: ${product_id}`, 400, request);
  }

  // Verify receipt with the appropriate store
  let result: { valid: boolean; expiresAt: string | null; error: string | null };

  if (platform === 'ios') {
    result = await verifyAppleReceipt(receipt, product_id);
  } else if (platform === 'android') {
    result = await verifyGoogleReceipt(receipt, product_id);
  } else {
    return errorResponse('platform must be "ios" or "android"', 400, request);
  }

  // Store receipt for audit
  const receiptHash = await sha256Hex(receipt);
  const now = Date.now();
  const receiptId = crypto.randomUUID();

  await env.DB.prepare(
    `INSERT INTO purchase_receipts (id, user_id, product_id, platform, receipt_hash, verified_at, expires_at, is_valid)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)
     ON CONFLICT (id) DO UPDATE SET verified_at = excluded.verified_at, is_valid = excluded.is_valid`,
  )
    .bind(
      receiptId,
      ctx.userId,
      product_id,
      platform,
      receiptHash,
      now,
      result.expiresAt ? new Date(result.expiresAt).getTime() : null,
      result.valid ? 1 : 0,
    )
    .run();

  // If valid, upgrade user's plan
  if (result.valid) {
    const planExpiresAt = result.expiresAt
      ? new Date(result.expiresAt).getTime()
      : null;

    await env.DB.prepare(
      `UPDATE users SET plan = ?, plan_expires_at = ?, updated_at = ? WHERE id = ?`,
    )
      .bind(newPlan, planExpiresAt, now, ctx.userId)
      .run();

    // If upgrading to a family plan and user has a family group, update group limits
    if (newPlan === 'family' || newPlan === 'family_plus') {
      const user = await env.DB.prepare('SELECT family_group_id FROM users WHERE id = ?')
        .bind(ctx.userId)
        .first<{ family_group_id: string | null }>();

      if (user?.family_group_id) {
        const storageLimit = STORAGE_LIMITS[newPlan];
        const maxMembers = MAX_MEMBERS[newPlan];

        await env.DB.prepare(
          `UPDATE family_groups SET storage_limit_bytes = ?, max_members = ?, updated_at = ? WHERE id = ?`,
        )
          .bind(storageLimit, maxMembers, now, user.family_group_id)
          .run();
      }
    }
  }

  const response: PurchaseVerifyResponse = {
    valid: result.valid,
    expires_at: result.expiresAt,
    error: result.error,
  };

  return jsonResponse({ data: response }, 200, request);
}
