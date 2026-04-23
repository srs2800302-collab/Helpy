"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createUser = createUser;
exports.getUser = getUser;
exports.getUserFull = getUserFull;
const auth_context_1 = require("./auth-context");
const PUBLIC_ROLES = new Set(['client', 'master']);
const ALLOWED_LANGUAGES = new Set(['ru', 'en', 'th']);
const USER_SELECT = 'SELECT id, role, phone, language, created_at FROM users WHERE id = ?1 LIMIT 1';
function jsonError(error, status) {
    return Response.json({ success: false, error }, { status });
}
function forbidden() {
    return jsonError('Forbidden', 403);
}
function sanitizeUser(row) {
    if (!row)
        return null;
    return {
        id: row.id,
        role: row.role,
        phone: row.phone,
        language: row.language,
        created_at: row.created_at ?? null,
    };
}
function sanitizeClientProfile(row) {
    if (!row)
        return null;
    return {
        id: row.id,
        user_id: row.user_id,
        name: row.name ?? null,
        created_at: row.created_at ?? null,
    };
}
function sanitizeMasterProfile(row) {
    if (!row)
        return null;
    return {
        id: row.id,
        user_id: row.user_id,
        name: row.name ?? null,
        category: row.category ?? null,
        bio: row.bio ?? null,
        is_verified: row.is_verified ?? 0,
        created_at: row.created_at ?? null,
    };
}
async function getUserRow(id, env) {
    return env.DB.prepare(USER_SELECT).bind(id).first();
}
async function createUser(request, env) {
    let body;
    try {
        body = await request.json();
    }
    catch {
        return jsonError('Invalid JSON', 400);
    }
    if (!body.role || !body.phone || !body.language) {
        return jsonError('role, phone, language required', 400);
    }
    if (!PUBLIC_ROLES.has(body.role)) {
        return jsonError('Invalid role', 400);
    }
    if (!ALLOWED_LANGUAGES.has(body.language)) {
        return jsonError('Invalid language', 400);
    }
    const id = crypto.randomUUID();
    const createdAt = new Date().toISOString();
    await env.DB.prepare('INSERT INTO users (id, role, phone, language, created_at) VALUES (?1, ?2, ?3, ?4, ?5)')
        .bind(id, body.role, body.phone, body.language, createdAt)
        .run();
    return Response.json({
        success: true,
        data: {
            id,
            role: body.role,
            phone: body.phone,
            language: body.language,
            created_at: createdAt,
        },
    });
}
async function getUser(id, request, env) {
    const auth = await (0, auth_context_1.requireAuth)(request, env);
    if (!auth.ok)
        return auth.response;
    if (auth.userId !== id && auth.role !== 'admin') {
        return forbidden();
    }
    const user = await getUserRow(id, env);
    if (!user) {
        return jsonError('User not found', 404);
    }
    return Response.json({
        success: true,
        data: sanitizeUser(user),
    });
}
async function getUserFull(id, request, env) {
    const auth = await (0, auth_context_1.requireAuth)(request, env);
    if (!auth.ok)
        return auth.response;
    if (auth.userId !== id && auth.role !== 'admin') {
        return forbidden();
    }
    const user = await getUserRow(id, env);
    if (!user) {
        return jsonError('User not found', 404);
    }
    const clientProfile = await env.DB.prepare(`SELECT id, user_id, name, created_at
     FROM client_profiles
     WHERE user_id = ?1
     LIMIT 1`)
        .bind(id)
        .first();
    const masterProfile = await env.DB.prepare(`SELECT id, user_id, name, category, bio, is_verified, created_at
     FROM master_profiles
     WHERE user_id = ?1
     LIMIT 1`)
        .bind(id)
        .first();
    return Response.json({
        success: true,
        data: {
            user: sanitizeUser(user),
            client_profile: sanitizeClientProfile(clientProfile),
            master_profile: sanitizeMasterProfile(masterProfile),
        },
    });
}
//# sourceMappingURL=users.js.map