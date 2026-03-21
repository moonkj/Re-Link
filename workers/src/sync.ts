// Re-Link Workers — Sync Endpoints
// GET  /sync/pull?since=<timestamp_ms>  — Pull delta changes from server
// POST /sync/push                       — Push local changes batch to server

import type {
  Env,
  SyncNode,
  SyncEdge,
  SyncMemory,
  SyncPullResponse,
  SyncPushRequest,
  SyncPushItem,
  SyncPushResponse,
} from './types';
import {
  requireAuth,
  requireFamilyPlan,
  requireGroupMembership,
  jsonResponse,
  errorResponse,
} from './middleware';

// ============================================================
// Handler: GET /sync/pull?since=<timestamp_ms>
// Returns all rows updated after `since` (Last-Write-Wins delta)
// ============================================================
export async function handlePull(
  request: Request,
  env: Env,
): Promise<Response> {
  const { ctx, error } = await requireAuth(request, env);
  if (error) return error;

  const planError = requireFamilyPlan(ctx, request);
  if (planError) return planError;

  const groupError = requireGroupMembership(ctx, request);
  if (groupError) return groupError;

  const url = new URL(request.url);
  const sinceParam = url.searchParams.get('since');
  const deviceId = request.headers.get('X-Device-Id') ?? 'unknown';
  const since = sinceParam ? parseInt(sinceParam, 10) : 0;

  if (isNaN(since)) {
    return errorResponse('Invalid `since` timestamp', 400, request);
  }

  const groupId = ctx.groupId!;
  const serverTime = Date.now();

  // Fetch delta rows in parallel
  const [nodesResult, edgesResult, memoriesResult] = await Promise.all([
    env.DB.prepare(
      'SELECT * FROM sync_nodes WHERE group_id = ? AND updated_at > ? ORDER BY updated_at ASC',
    )
      .bind(groupId, since)
      .all<SyncNode>(),

    env.DB.prepare(
      'SELECT * FROM sync_edges WHERE group_id = ? AND updated_at > ? ORDER BY updated_at ASC',
    )
      .bind(groupId, since)
      .all<SyncEdge>(),

    env.DB.prepare(
      `SELECT * FROM sync_memories
       WHERE group_id = ?
         AND updated_at > ?
         AND (is_private = 0 OR owner_user_id = ?)
       ORDER BY updated_at ASC`,
    )
      .bind(groupId, since, ctx.userId)
      .all<SyncMemory>(),
  ]);

  // Update checkpoint
  await env.DB.prepare(
    `INSERT INTO sync_checkpoints (device_id, user_id, group_id, last_pull_at)
     VALUES (?, ?, ?, ?)
     ON CONFLICT (device_id, group_id)
     DO UPDATE SET last_pull_at = excluded.last_pull_at, user_id = excluded.user_id`,
  )
    .bind(deviceId, ctx.userId, groupId, serverTime)
    .run();

  const response: SyncPullResponse = {
    nodes: nodesResult.results,
    edges: edgesResult.results,
    memories: memoriesResult.results,
    server_time: serverTime,
  };

  return jsonResponse(response, 200, request);
}

// ============================================================
// Handler: POST /sync/push
// Body: { device_id, items: SyncPushItem[] }
// Last-Write-Wins: only update if incoming updated_at >= existing
// ============================================================
export async function handlePush(
  request: Request,
  env: Env,
): Promise<Response> {
  const { ctx, error } = await requireAuth(request, env);
  if (error) return error;

  const planError = requireFamilyPlan(ctx, request);
  if (planError) return planError;

  const groupError = requireGroupMembership(ctx, request);
  if (groupError) return groupError;

  let body: SyncPushRequest;
  try {
    body = (await request.json()) as SyncPushRequest;
  } catch {
    return errorResponse('Invalid JSON body', 400, request);
  }

  if (!body.device_id || !Array.isArray(body.items)) {
    return errorResponse('device_id and items[] are required', 400, request);
  }

  if (body.items.length > 500) {
    return errorResponse('Maximum 500 items per push batch', 400, request);
  }

  const groupId = ctx.groupId!;
  let applied = 0;
  let conflicts = 0;

  for (const item of body.items) {
    try {
      const result = await applyPushItem(env.DB, item, groupId, ctx.userId);
      if (result === 'applied') applied++;
      else if (result === 'conflict') conflicts++;
    } catch (e) {
      // Log but continue processing remaining items
      console.error('Push item error:', e, item);
    }
  }

  const response: SyncPushResponse = {
    applied,
    conflicts,
    server_time: Date.now(),
  };

  return jsonResponse(response, 200, request);
}

// ============================================================
// Apply a single push item (Last-Write-Wins)
// ============================================================
async function applyPushItem(
  db: D1Database,
  item: SyncPushItem,
  groupId: string,
  userId: string,
): Promise<'applied' | 'conflict' | 'skipped'> {
  switch (item.type) {
    case 'node':
      return applyNodeUpsert(db, item.data as Partial<SyncNode>, groupId, userId);
    case 'edge':
      return applyEdgeUpsert(db, item.data as Partial<SyncEdge>, groupId, userId);
    case 'memory':
      return applyMemoryUpsert(db, item.data as Partial<SyncMemory>, groupId, userId);
    default:
      return 'skipped';
  }
}

async function applyNodeUpsert(
  db: D1Database,
  data: Partial<SyncNode>,
  groupId: string,
  userId: string,
): Promise<'applied' | 'conflict'> {
  if (!data.id || !data.updated_at) return 'conflict';

  const existing = await db
    .prepare('SELECT updated_at FROM sync_nodes WHERE id = ? AND group_id = ?')
    .bind(data.id, groupId)
    .first<{ updated_at: number }>();

  // Conflict: server is newer
  if (existing && existing.updated_at > data.updated_at) {
    return 'conflict';
  }

  const now = Date.now();
  const isNew = !existing;

  if (isNew) {
    await db
      .prepare(
        `INSERT INTO sync_nodes
         (id, group_id, owner_user_id, name, nickname, bio, birth_date, death_date,
          is_ghost, temperature, position_x, position_y, tags_json,
          photo_r2_key, is_deleted, updated_at, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      )
      .bind(
        data.id,
        groupId,
        data.owner_user_id ?? userId,
        data.name ?? '',
        data.nickname ?? null,
        data.bio ?? null,
        data.birth_date ?? null,
        data.death_date ?? null,
        data.is_ghost ?? 0,
        data.temperature ?? 2,
        data.position_x ?? 0,
        data.position_y ?? 0,
        data.tags_json ?? '[]',
        data.photo_r2_key ?? null,
        data.is_deleted ?? 0,
        data.updated_at,
        data.created_at ?? now,
      )
      .run();
  } else {
    await db
      .prepare(
        `UPDATE sync_nodes
         SET name = COALESCE(?, name),
             nickname = ?,
             bio = ?,
             birth_date = ?,
             death_date = ?,
             is_ghost = COALESCE(?, is_ghost),
             temperature = COALESCE(?, temperature),
             position_x = COALESCE(?, position_x),
             position_y = COALESCE(?, position_y),
             tags_json = COALESCE(?, tags_json),
             photo_r2_key = ?,
             is_deleted = COALESCE(?, is_deleted),
             updated_at = ?
         WHERE id = ? AND group_id = ?`,
      )
      .bind(
        data.name ?? null,
        data.nickname ?? null,
        data.bio ?? null,
        data.birth_date ?? null,
        data.death_date ?? null,
        data.is_ghost ?? null,
        data.temperature ?? null,
        data.position_x ?? null,
        data.position_y ?? null,
        data.tags_json ?? null,
        data.photo_r2_key ?? null,
        data.is_deleted ?? null,
        data.updated_at,
        data.id,
        groupId,
      )
      .run();
  }

  return 'applied';
}

async function applyEdgeUpsert(
  db: D1Database,
  data: Partial<SyncEdge>,
  groupId: string,
  _userId: string,
): Promise<'applied' | 'conflict'> {
  if (!data.id || !data.updated_at) return 'conflict';

  const existing = await db
    .prepare('SELECT updated_at FROM sync_edges WHERE id = ? AND group_id = ?')
    .bind(data.id, groupId)
    .first<{ updated_at: number }>();

  if (existing && existing.updated_at > data.updated_at) {
    return 'conflict';
  }

  const now = Date.now();

  if (!existing) {
    await db
      .prepare(
        `INSERT INTO sync_edges
         (id, group_id, from_node_id, to_node_id, relation, is_deleted, updated_at, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      )
      .bind(
        data.id,
        groupId,
        data.from_node_id ?? '',
        data.to_node_id ?? '',
        data.relation ?? '',
        data.is_deleted ?? 0,
        data.updated_at,
        data.created_at ?? now,
      )
      .run();
  } else {
    await db
      .prepare(
        `UPDATE sync_edges
         SET from_node_id = COALESCE(?, from_node_id),
             to_node_id = COALESCE(?, to_node_id),
             relation = COALESCE(?, relation),
             is_deleted = COALESCE(?, is_deleted),
             updated_at = ?
         WHERE id = ? AND group_id = ?`,
      )
      .bind(
        data.from_node_id ?? null,
        data.to_node_id ?? null,
        data.relation ?? null,
        data.is_deleted ?? null,
        data.updated_at,
        data.id,
        groupId,
      )
      .run();
  }

  return 'applied';
}

async function applyMemoryUpsert(
  db: D1Database,
  data: Partial<SyncMemory>,
  groupId: string,
  userId: string,
): Promise<'applied' | 'conflict'> {
  if (!data.id || !data.updated_at) return 'conflict';

  const existing = await db
    .prepare(
      'SELECT updated_at, owner_user_id FROM sync_memories WHERE id = ? AND group_id = ?',
    )
    .bind(data.id, groupId)
    .first<{ updated_at: number; owner_user_id: string }>();

  if (existing && existing.updated_at > data.updated_at) {
    return 'conflict';
  }

  // Only memory owner can update private memories
  if (existing && existing.owner_user_id !== userId && data.is_private === 1) {
    return 'conflict';
  }

  const now = Date.now();

  if (!existing) {
    await db
      .prepare(
        `INSERT INTO sync_memories
         (id, group_id, node_id, owner_user_id, type, title, description,
          file_r2_key, thumbnail_r2_key, duration_seconds, date_taken,
          tags_json, is_private, is_deleted, updated_at, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      )
      .bind(
        data.id,
        groupId,
        data.node_id ?? '',
        data.owner_user_id ?? userId,
        data.type ?? 'memo',
        data.title ?? null,
        data.description ?? null,
        data.file_r2_key ?? null,
        data.thumbnail_r2_key ?? null,
        data.duration_seconds ?? null,
        data.date_taken ?? null,
        data.tags_json ?? '[]',
        data.is_private ?? 0,
        data.is_deleted ?? 0,
        data.updated_at,
        data.created_at ?? now,
      )
      .run();
  } else {
    await db
      .prepare(
        `UPDATE sync_memories
         SET node_id = COALESCE(?, node_id),
             type = COALESCE(?, type),
             title = ?,
             description = ?,
             file_r2_key = ?,
             thumbnail_r2_key = ?,
             duration_seconds = ?,
             date_taken = ?,
             tags_json = COALESCE(?, tags_json),
             is_private = COALESCE(?, is_private),
             is_deleted = COALESCE(?, is_deleted),
             updated_at = ?
         WHERE id = ? AND group_id = ?`,
      )
      .bind(
        data.node_id ?? null,
        data.type ?? null,
        data.title ?? null,
        data.description ?? null,
        data.file_r2_key ?? null,
        data.thumbnail_r2_key ?? null,
        data.duration_seconds ?? null,
        data.date_taken ?? null,
        data.tags_json ?? null,
        data.is_private ?? null,
        data.is_deleted ?? null,
        data.updated_at,
        data.id,
        groupId,
      )
      .run();
  }

  return 'applied';
}
