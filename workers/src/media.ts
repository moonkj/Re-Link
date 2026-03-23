// Re-Link Workers — Media (R2) Endpoints
// POST /media/upload-url              — Generate presigned upload URL
// POST /media/confirm-upload          — Confirm R2 upload & update storage usage
// GET  /media/:fileKey/download-url   — Generate presigned download URL
// DELETE /media/:fileKey              — Delete R2 object
// GET  /media/usage                   — Storage usage for current user's group

import type {
  Env,
  MediaCategory,
  UploadUrlRequest,
  UploadUrlResponse,
  DownloadUrlResponse,
  StorageUsageResponse,
  ConfirmUploadRequest,
  ConfirmUploadResponse,
  UserPlan,
} from './types';
import { STORAGE_LIMITS } from './types';
import {
  requireAuth,
  requireFamilyPlan,
  requireGroupMembership,
  jsonResponse,
  errorResponse,
} from './middleware';

// ============================================================
// Content type allow-list
// ============================================================
const ALLOWED_CONTENT_TYPES: Record<MediaCategory, string[]> = {
  photo: ['image/jpeg', 'image/png', 'image/webp', 'image/heic'],
  thumbnail: ['image/jpeg', 'image/webp'],
  voice: ['audio/mp4', 'audio/aac', 'audio/mpeg', 'audio/ogg'],
  video: ['video/mp4', 'video/quicktime', 'video/mpeg'],
};

// Max file sizes per category (bytes)
const MAX_FILE_SIZES: Record<MediaCategory, number> = {
  photo: 20 * 1024 * 1024,      // 20 MB
  thumbnail: 2 * 1024 * 1024,   // 2 MB
  voice: 50 * 1024 * 1024,      // 50 MB
  video: 500 * 1024 * 1024,     // 500 MB
};

const UPLOAD_URL_TTL = 900;    // 15 minutes (seconds)
const DOWNLOAD_URL_TTL = 3600; // 1 hour (seconds)

// ============================================================
// AWS Signature V4 for R2 presigned URLs
// R2 is S3-compatible; we sign manually using Web Crypto
// ============================================================

function toHex(buffer: ArrayBuffer): string {
  return Array.from(new Uint8Array(buffer))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

async function sha256(message: string): Promise<string> {
  const data = new TextEncoder().encode(message);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  return toHex(hashBuffer);
}

async function hmacSha256(key: ArrayBuffer | string, data: string): Promise<ArrayBuffer> {
  const keyData =
    typeof key === 'string' ? new TextEncoder().encode(key) : key;
  const cryptoKey = await crypto.subtle.importKey(
    'raw',
    keyData,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  return crypto.subtle.sign('HMAC', cryptoKey, new TextEncoder().encode(data));
}

async function getSigningKey(
  secretKey: string,
  dateStamp: string,
  region: string,
  service: string,
): Promise<ArrayBuffer> {
  const kDate = await hmacSha256(`AWS4${secretKey}`, dateStamp);
  const kRegion = await hmacSha256(kDate, region);
  const kService = await hmacSha256(kRegion, service);
  const kSigning = await hmacSha256(kService, 'aws4_request');
  return kSigning;
}

interface PresignedUrlParams {
  accountId: string;
  accessKeyId: string;
  secretAccessKey: string;
  bucketName: string;
  fileKey: string;
  method: 'GET' | 'PUT';
  contentType?: string;
  expiresInSeconds: number;
}

async function generatePresignedUrl(params: PresignedUrlParams): Promise<string> {
  const {
    accountId,
    accessKeyId,
    secretAccessKey,
    bucketName,
    fileKey,
    method,
    contentType,
    expiresInSeconds,
  } = params;

  const region = 'auto';
  const service = 's3';
  const host = `${accountId}.r2.cloudflarestorage.com`;
  const endpoint = `https://${host}/${bucketName}/${encodeURIComponent(fileKey)}`;

  const now = new Date();
  const amzDate = now.toISOString().replace(/[:-]|\.\d{3}/g, '').slice(0, 15) + 'Z';
  const dateStamp = amzDate.slice(0, 8);

  const credentialScope = `${dateStamp}/${region}/${service}/aws4_request`;
  const credential = `${accessKeyId}/${credentialScope}`;

  const queryParams: Record<string, string> = {
    'X-Amz-Algorithm': 'AWS4-HMAC-SHA256',
    'X-Amz-Credential': credential,
    'X-Amz-Date': amzDate,
    'X-Amz-Expires': String(expiresInSeconds),
    'X-Amz-SignedHeaders': 'host',
  };

  if (contentType && method === 'PUT') {
    queryParams['Content-Type'] = contentType;
    queryParams['X-Amz-SignedHeaders'] = 'content-type;host';
  }

  const sortedQuery = Object.keys(queryParams)
    .sort()
    .map((k) => `${encodeURIComponent(k)}=${encodeURIComponent(queryParams[k])}`)
    .join('&');

  const signedHeaders =
    contentType && method === 'PUT' ? 'content-type;host' : 'host';

  const canonicalHeaders =
    contentType && method === 'PUT'
      ? `content-type:${contentType}\nhost:${host}\n`
      : `host:${host}\n`;

  const canonicalRequest = [
    method,
    `/${bucketName}/${fileKey}`,
    sortedQuery,
    canonicalHeaders,
    signedHeaders,
    'UNSIGNED-PAYLOAD',
  ].join('\n');

  const canonicalRequestHash = await sha256(canonicalRequest);

  const stringToSign = [
    'AWS4-HMAC-SHA256',
    amzDate,
    credentialScope,
    canonicalRequestHash,
  ].join('\n');

  const signingKey = await getSigningKey(
    secretAccessKey,
    dateStamp,
    region,
    service,
  );
  const signatureBuffer = await hmacSha256(signingKey, stringToSign);
  const signature = toHex(signatureBuffer);

  return `${endpoint}?${sortedQuery}&X-Amz-Signature=${signature}`;
}

// ============================================================
// Helper: check if R2 credentials are configured
// ============================================================
function getR2Config(env: Env): {
  accountId: string;
  accessKeyId: string;
  secretAccessKey: string;
} | null {
  if (!env.R2_ACCOUNT_ID || !env.R2_ACCESS_KEY_ID || !env.R2_SECRET_ACCESS_KEY) {
    return null;
  }
  return {
    accountId: env.R2_ACCOUNT_ID,
    accessKeyId: env.R2_ACCESS_KEY_ID,
    secretAccessKey: env.R2_SECRET_ACCESS_KEY,
  };
}

// ============================================================
// Handler: POST /media/upload-url
// ============================================================
export async function handleUploadUrl(
  request: Request,
  env: Env,
): Promise<Response> {
  const { ctx, error } = await requireAuth(request, env);
  if (error) return error;

  const planError = requireFamilyPlan(ctx, request);
  if (planError) return planError;

  const groupError = requireGroupMembership(ctx, request);
  if (groupError) return groupError;

  let body: UploadUrlRequest;
  try {
    body = (await request.json()) as UploadUrlRequest;
  } catch {
    return errorResponse('Invalid JSON body', 400, request);
  }

  const { file_key, content_type, category, file_size_bytes } = body;

  if (!file_key || !content_type || !category || !file_size_bytes) {
    return errorResponse(
      'file_key, content_type, category, and file_size_bytes are required',
      400,
      request,
    );
  }

  // Validate category
  const allowedTypes = ALLOWED_CONTENT_TYPES[category as MediaCategory];
  if (!allowedTypes) {
    return errorResponse(`Invalid category: ${category}`, 400, request);
  }

  // Validate content type
  if (!allowedTypes.includes(content_type)) {
    return errorResponse(
      `Content type ${content_type} not allowed for category ${category}`,
      400,
      request,
    );
  }

  // Validate file size
  const maxSize = MAX_FILE_SIZES[category as MediaCategory];
  if (file_size_bytes > maxSize) {
    return errorResponse(
      `File too large. Max ${maxSize / (1024 * 1024)}MB for ${category}`,
      413,
      request,
    );
  }

  // Check storage quota
  const groupId = ctx.groupId!;
  const planLimit = STORAGE_LIMITS[ctx.plan as UserPlan] ?? 0;

  const usageResult = await env.DB
    .prepare(
      'SELECT SUM(storage_used_bytes) as total FROM users WHERE family_group_id = ?',
    )
    .bind(groupId)
    .first<{ total: number | null }>();

  const currentUsage = usageResult?.total ?? 0;

  if (currentUsage + file_size_bytes > planLimit) {
    return errorResponse(
      'Storage quota exceeded',
      507,
      request,
    );
  }

  // Enforce file_key prefix convention: groupId/userId/...
  const expectedPrefix = `${groupId}/${ctx.userId}/`;
  if (!file_key.startsWith(expectedPrefix)) {
    return errorResponse(
      `file_key must start with "${expectedPrefix}"`,
      400,
      request,
    );
  }

  // Generate presigned URL (or use Workers binding directly)
  const r2Config = getR2Config(env);

  let uploadUrl: string;

  if (r2Config) {
    // Use AWS Signature V4 presigned URL
    uploadUrl = await generatePresignedUrl({
      accountId: r2Config.accountId,
      accessKeyId: r2Config.accessKeyId,
      secretAccessKey: r2Config.secretAccessKey,
      bucketName: 'relink-media',
      fileKey: file_key,
      method: 'PUT',
      contentType: content_type,
      expiresInSeconds: UPLOAD_URL_TTL,
    });
  } else {
    // Fallback: Workers R2 binding (no presigned URL support, use our own proxy)
    // In production, always configure R2 credentials for presigned URLs
    uploadUrl = `${new URL(request.url).origin}/media/proxy-upload/${encodeURIComponent(file_key)}`;
  }

  const response: UploadUrlResponse = {
    upload_url: uploadUrl,
    file_key,
    expires_in_seconds: UPLOAD_URL_TTL,
  };

  return jsonResponse({ data: response }, 200, request);
}

// ============================================================
// Handler: POST /media/confirm-upload
// Confirms a file was uploaded to R2, then updates storage usage
// ============================================================
export async function handleConfirmUpload(
  request: Request,
  env: Env,
): Promise<Response> {
  const { ctx, error } = await requireAuth(request, env);
  if (error) return error;

  const planError = requireFamilyPlan(ctx, request);
  if (planError) return planError;

  const groupError = requireGroupMembership(ctx, request);
  if (groupError) return groupError;

  let body: ConfirmUploadRequest;
  try {
    body = (await request.json()) as ConfirmUploadRequest;
  } catch {
    return errorResponse('Invalid JSON body', 400, request);
  }

  const { file_key, file_size_bytes } = body;

  if (!file_key || typeof file_size_bytes !== 'number' || file_size_bytes <= 0) {
    return errorResponse(
      'file_key (string) and file_size_bytes (positive number) are required',
      400,
      request,
    );
  }

  // Validate file_key ownership: must start with groupId/userId/
  const groupId = ctx.groupId!;
  const ownerPrefix = `${groupId}/${ctx.userId}/`;
  if (!file_key.startsWith(ownerPrefix)) {
    return errorResponse(
      `file_key must start with "${ownerPrefix}"`,
      403,
      request,
    );
  }

  // Verify the object actually exists in R2
  const r2Object = await env.MEDIA_BUCKET.head(file_key);
  if (!r2Object) {
    return errorResponse(
      'File not found in storage. Upload may not have completed.',
      404,
      request,
    );
  }

  // Optionally cross-check reported size vs actual R2 object size
  const actualSize = r2Object.size;
  const sizeDiff = Math.abs(actualSize - file_size_bytes);
  // Allow small tolerance (1 KB) for encoding overhead
  if (sizeDiff > 1024) {
    return errorResponse(
      `Reported size (${file_size_bytes}) does not match actual size (${actualSize})`,
      400,
      request,
    );
  }

  // Use actual R2 object size for accuracy
  const confirmedSize = actualSize;

  // Check storage quota before confirming
  const planLimit = STORAGE_LIMITS[ctx.plan as UserPlan] ?? 0;

  const usageResult = await env.DB
    .prepare(
      'SELECT SUM(storage_used_bytes) as total FROM users WHERE family_group_id = ?',
    )
    .bind(groupId)
    .first<{ total: number | null }>();

  const currentUsage = usageResult?.total ?? 0;

  if (currentUsage + confirmedSize > planLimit) {
    // Over quota — delete the uploaded file from R2 to reclaim space
    await env.MEDIA_BUCKET.delete(file_key);
    return errorResponse(
      'Storage quota exceeded. Uploaded file has been removed.',
      507,
      request,
    );
  }

  // Update the user's storage_used_bytes
  await env.DB
    .prepare(
      `UPDATE users
       SET storage_used_bytes = storage_used_bytes + ?,
           updated_at = ?
       WHERE id = ?`,
    )
    .bind(confirmedSize, Date.now(), ctx.userId)
    .run();

  // Fetch the updated value
  const updatedUser = await env.DB
    .prepare('SELECT storage_used_bytes FROM users WHERE id = ?')
    .bind(ctx.userId)
    .first<{ storage_used_bytes: number }>();

  const newUsage = updatedUser?.storage_used_bytes ?? confirmedSize;

  const response: ConfirmUploadResponse = {
    ok: true,
    storage_used_bytes: newUsage,
  };

  return jsonResponse({ data: response }, 200, request);
}

// ============================================================
// Handler: GET /media/:fileKey/download-url
// ============================================================
export async function handleDownloadUrl(
  request: Request,
  env: Env,
  fileKey: string,
): Promise<Response> {
  const { ctx, error } = await requireAuth(request, env);
  if (error) return error;

  const planError = requireFamilyPlan(ctx, request);
  if (planError) return planError;

  const groupError = requireGroupMembership(ctx, request);
  if (groupError) return groupError;

  // Validate file belongs to user's group
  const groupId = ctx.groupId!;
  if (!fileKey.startsWith(groupId + '/')) {
    return errorResponse('Access denied to this file', 403, request);
  }

  const r2Config = getR2Config(env);

  let downloadUrl: string;

  if (r2Config) {
    downloadUrl = await generatePresignedUrl({
      accountId: r2Config.accountId,
      accessKeyId: r2Config.accessKeyId,
      secretAccessKey: r2Config.secretAccessKey,
      bucketName: 'relink-media',
      fileKey,
      method: 'GET',
      expiresInSeconds: DOWNLOAD_URL_TTL,
    });
  } else {
    // Fallback: serve via Workers proxy
    downloadUrl = `${new URL(request.url).origin}/media/proxy-download/${encodeURIComponent(fileKey)}`;
  }

  const response: DownloadUrlResponse = {
    download_url: downloadUrl,
    expires_in_seconds: DOWNLOAD_URL_TTL,
  };

  return jsonResponse({ data: response }, 200, request);
}

// ============================================================
// Handler: DELETE /media/:fileKey
// ============================================================
export async function handleDeleteMedia(
  request: Request,
  env: Env,
  fileKey: string,
): Promise<Response> {
  const { ctx, error } = await requireAuth(request, env);
  if (error) return error;

  const planError = requireFamilyPlan(ctx, request);
  if (planError) return planError;

  const groupError = requireGroupMembership(ctx, request);
  if (groupError) return groupError;

  const groupId = ctx.groupId!;

  // Validate ownership: file_key must start with groupId/userId/
  const ownerPrefix = `${groupId}/${ctx.userId}/`;
  if (!fileKey.startsWith(ownerPrefix)) {
    return errorResponse('Access denied: can only delete your own files', 403, request);
  }

  // Check object exists before deleting
  const obj = await env.MEDIA_BUCKET.head(fileKey);
  if (!obj) {
    return errorResponse('File not found', 404, request);
  }

  const fileSize = obj.size;

  // Delete from R2
  await env.MEDIA_BUCKET.delete(fileKey);

  // Update storage_used_bytes for user
  if (fileSize > 0) {
    await env.DB.prepare(
      `UPDATE users
       SET storage_used_bytes = MAX(0, storage_used_bytes - ?),
           updated_at = ?
       WHERE id = ?`,
    )
      .bind(fileSize, Date.now(), ctx.userId)
      .run();
  }

  return jsonResponse({ data: { deleted: true } }, 200, request);
}

// ============================================================
// Handler: GET /media/storage-usage
// ============================================================
export async function handleStorageUsage(
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

  const usageResult = await env.DB
    .prepare(
      `SELECT SUM(storage_used_bytes) as total
       FROM users WHERE family_group_id = ?`,
    )
    .bind(groupId)
    .first<{ total: number | null }>();

  const limitResult = await env.DB
    .prepare('SELECT storage_limit_bytes FROM family_groups WHERE id = ?')
    .bind(groupId)
    .first<{ storage_limit_bytes: number }>();

  const usedBytes = usageResult?.total ?? 0;
  const limitBytes = limitResult?.storage_limit_bytes ?? STORAGE_LIMITS.family;

  // Flutter reads data['data']['total_bytes']
  const response = {
    total_bytes: usedBytes,
    used_bytes: usedBytes,
    limit_bytes: limitBytes,
    used_percent: limitBytes > 0 ? Math.round((usedBytes / limitBytes) * 10000) / 100 : 0,
  };

  return jsonResponse({ data: response }, 200, request);
}
