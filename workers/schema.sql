-- Re-Link D1 Database Schema
-- Cloudflare D1 (SQLite-compatible)
-- All timestamps are Unix epoch milliseconds (ms)

-- ============================================================
-- Users
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id                  TEXT    PRIMARY KEY,
  provider            TEXT    NOT NULL,                     -- 'apple' | 'google' | 'kakao'
  provider_id         TEXT    NOT NULL UNIQUE,
  email               TEXT,
  name                TEXT,
  plan                TEXT    NOT NULL DEFAULT 'free',      -- 'free' | 'plus' | 'family' | 'family_plus'
  plan_expires_at     INTEGER,
  family_group_id     TEXT,
  storage_used_bytes  INTEGER DEFAULT 0,
  created_at          INTEGER NOT NULL,
  updated_at          INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_users_provider ON users(provider, provider_id);
CREATE INDEX IF NOT EXISTS idx_users_group    ON users(family_group_id);

-- ============================================================
-- Family Groups
-- ============================================================
CREATE TABLE IF NOT EXISTS family_groups (
  id                    TEXT    PRIMARY KEY,
  owner_id              TEXT    NOT NULL,
  name                  TEXT,
  max_members           INTEGER NOT NULL DEFAULT 6,
  storage_limit_bytes   INTEGER NOT NULL DEFAULT 21474836480, -- 20 GB (family plan)
  created_at            INTEGER NOT NULL,
  updated_at            INTEGER NOT NULL
);

-- ============================================================
-- Family Invites
-- ============================================================
CREATE TABLE IF NOT EXISTS family_invites (
  token        TEXT    PRIMARY KEY,
  group_id     TEXT    NOT NULL,
  created_by   TEXT    NOT NULL,
  expires_at   INTEGER NOT NULL,   -- 72 hours from creation
  accepted_by  TEXT,
  accepted_at  INTEGER,
  is_used      INTEGER DEFAULT 0   -- 0 = unused, 1 = used
);
CREATE INDEX IF NOT EXISTS idx_invites_group ON family_invites(group_id);

-- ============================================================
-- Sync: Nodes
-- ============================================================
CREATE TABLE IF NOT EXISTS sync_nodes (
  id              TEXT    NOT NULL,
  group_id        TEXT    NOT NULL,
  owner_user_id   TEXT    NOT NULL,
  name            TEXT    NOT NULL,
  nickname        TEXT,
  bio             TEXT,
  birth_date      INTEGER,
  death_date      INTEGER,
  is_ghost        INTEGER DEFAULT 0,
  temperature     INTEGER DEFAULT 2,  -- 0..5
  position_x      REAL    DEFAULT 0,
  position_y      REAL    DEFAULT 0,
  tags_json       TEXT    DEFAULT '[]',
  photo_r2_key    TEXT,
  is_deleted      INTEGER DEFAULT 0,
  updated_at      INTEGER NOT NULL,
  created_at      INTEGER NOT NULL,
  PRIMARY KEY (id, group_id)
);
CREATE INDEX IF NOT EXISTS idx_nodes_group ON sync_nodes(group_id, updated_at);

-- ============================================================
-- Sync: Edges
-- ============================================================
CREATE TABLE IF NOT EXISTS sync_edges (
  id           TEXT    NOT NULL,
  group_id     TEXT    NOT NULL,
  from_node_id TEXT    NOT NULL,
  to_node_id   TEXT    NOT NULL,
  relation     TEXT    NOT NULL,
  is_deleted   INTEGER DEFAULT 0,
  updated_at   INTEGER NOT NULL,
  created_at   INTEGER NOT NULL,
  PRIMARY KEY (id, group_id)
);
CREATE INDEX IF NOT EXISTS idx_edges_group ON sync_edges(group_id, updated_at);

-- ============================================================
-- Sync: Memories
-- ============================================================
CREATE TABLE IF NOT EXISTS sync_memories (
  id                TEXT    NOT NULL,
  group_id          TEXT    NOT NULL,
  node_id           TEXT    NOT NULL,
  owner_user_id     TEXT    NOT NULL,
  type              TEXT    NOT NULL,   -- 'photo' | 'voice' | 'memo' | 'video'
  title             TEXT,
  description       TEXT,
  file_r2_key       TEXT,
  thumbnail_r2_key  TEXT,
  duration_seconds  INTEGER,
  date_taken        INTEGER,
  tags_json         TEXT    DEFAULT '[]',
  is_private        INTEGER DEFAULT 0,
  is_deleted        INTEGER DEFAULT 0,
  updated_at        INTEGER NOT NULL,
  created_at        INTEGER NOT NULL,
  PRIMARY KEY (id, group_id)
);
CREATE INDEX IF NOT EXISTS idx_memories_group ON sync_memories(group_id, updated_at);
CREATE INDEX IF NOT EXISTS idx_memories_node  ON sync_memories(group_id, node_id);

-- ============================================================
-- Sync Checkpoints (per device per group)
-- ============================================================
CREATE TABLE IF NOT EXISTS sync_checkpoints (
  device_id    TEXT    NOT NULL,
  user_id      TEXT    NOT NULL,
  group_id     TEXT    NOT NULL,
  last_pull_at INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (device_id, group_id)
);

-- ============================================================
-- Refresh Tokens
-- ============================================================
CREATE TABLE IF NOT EXISTS refresh_tokens (
  token      TEXT    PRIMARY KEY,
  user_id    TEXT    NOT NULL,
  expires_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_refresh_user ON refresh_tokens(user_id);

-- ============================================================
-- Purchase Receipts (audit log)
-- ============================================================
CREATE TABLE IF NOT EXISTS purchase_receipts (
  id              TEXT    PRIMARY KEY,
  user_id         TEXT    NOT NULL,
  product_id      TEXT    NOT NULL,
  platform        TEXT    NOT NULL,                       -- 'ios' | 'android'
  receipt_hash    TEXT    NOT NULL,
  verified_at     INTEGER NOT NULL,                      -- epoch ms
  expires_at      INTEGER,                               -- epoch ms (subscriptions only)
  is_valid        INTEGER NOT NULL DEFAULT 1
);
CREATE INDEX IF NOT EXISTS idx_purchase_receipts_user ON purchase_receipts(user_id);

-- ============================================================
-- Access Logs (user access statistics)
-- ============================================================
CREATE TABLE IF NOT EXISTS access_logs (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id    TEXT    NOT NULL,
  accessed_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_access_logs_date ON access_logs(accessed_at);
