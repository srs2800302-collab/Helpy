"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ok = ok;
exports.fail = fail;
function ok(data, status = 200) {
    return Response.json({ success: true, data }, { status });
}
function fail(error, status = 400) {
    return Response.json({ success: false, error }, { status });
}
//# sourceMappingURL=response.js.map