"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireAuth = requireAuth;
exports.requireRequestUserId = requireRequestUserId;
const response_1 = require("./response");
async function requireAuth(request, env) {
    const userId = request.headers.get('x-user-id');
    if (!userId) {
        return {
            ok: false,
            response: (0, response_1.fail)('Missing x-user-id header', 401),
        };
    }
    const user = await env.DB.prepare('SELECT * FROM users WHERE id = ?1 LIMIT 1')
        .bind(userId)
        .first();
    if (!user) {
        return {
            ok: false,
            response: (0, response_1.fail)('User not found', 404),
        };
    }
    return {
        ok: true,
        userId: user.id,
        user,
        role: user.role,
    };
}
function requireRequestUserId(request) {
    const userId = request.headers.get('x-user-id');
    if (!userId) {
        return {
            ok: false,
            response: (0, response_1.fail)('Missing x-user-id header', 401),
        };
    }
    return {
        ok: true,
        userId,
    };
}
//# sourceMappingURL=auth-context.js.map