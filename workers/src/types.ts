// Re-Link Workers — Shared TypeScript Types
// All timestamps: Unix epoch milliseconds (ms)

// ============================================================
// Cloudflare Bindings
// ============================================================
export interface Env {
  DB: D1Database;
  MEDIA_BUCKET: R2Bucket;
  JWT_SECRET: string;
  ENVIRONMENT: string;
  /** R2 public base URL (optional — for presigned URLs we use signed paths) */
  R2_ACCOUNT_ID?: string;
  R2_ACCESS_KEY_ID?: string;
  R2_SECRET_ACCESS_KEY?: string;
  /** Apple OAuth client ID (bundle ID) */
  APPLE_CLIENT_ID?: string;
  /** Google OAuth client ID */
  GOOGLE_CLIENT_ID?: string;
}

// ============================================================
// JWT
// ============================================================
export interface JWTPayload {
  sub: string;       // user.id
  plan: UserPlan;
  groupId: string | null;
  iat: number;
  exp: number;
}

export interface AuthContext {
  userId: string;
  plan: UserPlan;
  groupId: string | null;
}

// ============================================================
// Domain: User
// ============================================================
export type UserPlan = 'free' | 'plus' | 'family' | 'family_plus';
export type AuthProvider = 'apple' | 'google';

export interface User {
  id: string;
  provider: AuthProvider;
  provider_id: string;
  email: string | null;
  plan: UserPlan;
  plan_expires_at: number | null;
  family_group_id: string | null;
  storage_used_bytes: number;
  created_at: number;
  updated_at: number;
}

export interface UserPublic {
  id: string;
  email: string | null;
  plan: UserPlan;
  plan_expires_at: number | null;
  family_group_id: string | null;
  storage_used_bytes: number;
  created_at: number;
}

// ============================================================
// Domain: Family Group
// ============================================================
export interface FamilyGroup {
  id: string;
  owner_id: string;
  name: string | null;
  max_members: number;
  storage_limit_bytes: number;
  created_at: number;
  updated_at: number;
}

export interface FamilyMember {
  id: string;
  email: string | null;
  plan: UserPlan;
  is_owner: boolean;
  storage_used_bytes: number;
  joined_at: number;
}

// ============================================================
// Domain: Family Invite
// ============================================================
export interface FamilyInvite {
  token: string;
  group_id: string;
  created_by: string;
  expires_at: number;
  accepted_by: string | null;
  accepted_at: number | null;
  is_used: number;
}

export interface InviteInfo {
  token: string;
  group_id: string;
  group_name: string | null;
  expires_at: number;
  is_valid: boolean;
}

// ============================================================
// Domain: Sync — Nodes
// ============================================================
export interface SyncNode {
  id: string;
  group_id: string;
  owner_user_id: string;
  name: string;
  nickname: string | null;
  bio: string | null;
  birth_date: number | null;
  death_date: number | null;
  is_ghost: number;
  temperature: number;
  position_x: number;
  position_y: number;
  tags_json: string;
  photo_r2_key: string | null;
  is_deleted: number;
  updated_at: number;
  created_at: number;
}

// ============================================================
// Domain: Sync — Edges
// ============================================================
export interface SyncEdge {
  id: string;
  group_id: string;
  from_node_id: string;
  to_node_id: string;
  relation: string;
  is_deleted: number;
  updated_at: number;
  created_at: number;
}

// ============================================================
// Domain: Sync — Memories
// ============================================================
export type MemoryType = 'photo' | 'voice' | 'memo' | 'video';

export interface SyncMemory {
  id: string;
  group_id: string;
  node_id: string;
  owner_user_id: string;
  type: MemoryType;
  title: string | null;
  description: string | null;
  file_r2_key: string | null;
  thumbnail_r2_key: string | null;
  duration_seconds: number | null;
  date_taken: number | null;
  tags_json: string;
  is_private: number;
  is_deleted: number;
  updated_at: number;
  created_at: number;
}

// ============================================================
// Sync API — Request / Response
// ============================================================
export interface SyncPullResponse {
  nodes: SyncNode[];
  edges: SyncEdge[];
  memories: SyncMemory[];
  server_time: number;
}

export interface SyncPushItem {
  type: 'node' | 'edge' | 'memory';
  data: Partial<SyncNode> | Partial<SyncEdge> | Partial<SyncMemory>;
}

export interface SyncPushRequest {
  device_id: string;
  items: SyncPushItem[];
}

export interface SyncPushResponse {
  applied: number;
  conflicts: number;
  server_time: number;
}

// ============================================================
// Media API — Request / Response
// ============================================================
export type MediaCategory = 'photo' | 'voice' | 'video' | 'thumbnail';

export interface UploadUrlRequest {
  file_key: string;
  content_type: string;
  category: MediaCategory;
  file_size_bytes: number;
}

export interface UploadUrlResponse {
  upload_url: string;
  file_key: string;
  expires_in_seconds: number;
}

export interface DownloadUrlResponse {
  download_url: string;
  expires_in_seconds: number;
}

export interface StorageUsageResponse {
  used_bytes: number;
  limit_bytes: number;
  used_percent: number;
}

// ============================================================
// Auth API — Request / Response
// ============================================================
export interface AppleAuthRequest {
  id_token: string;
  user_info?: {
    name?: string;
    email?: string;
  };
}

export interface GoogleAuthRequest {
  id_token: string;
}

export interface AuthResponse {
  access_token: string;
  refresh_token: string;
  expires_in: number;
  user: UserPublic;
}

export interface RefreshRequest {
  refresh_token: string;
}

export interface RefreshResponse {
  access_token: string;
  expires_in: number;
}

// ============================================================
// Utility Types
// ============================================================
export interface ErrorResponse {
  error: string;
}

export interface SuccessResponse<T = unknown> {
  data: T;
}

/** Plans that have family sync access */
export const FAMILY_PLANS: UserPlan[] = ['family', 'family_plus'];

/** Storage limits in bytes per plan */
export const STORAGE_LIMITS: Record<UserPlan, number> = {
  free: 0,
  plus: 0,
  family: 21_474_836_480,        // 20 GB
  family_plus: 107_374_182_400,  // 100 GB
};

/** Max members per plan */
export const MAX_MEMBERS: Record<UserPlan, number> = {
  free: 0,
  plus: 0,
  family: 6,
  family_plus: 999,
};
