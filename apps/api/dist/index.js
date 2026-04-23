"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const router_1 = require("./router");
exports.default = {
    fetch(request, env) {
        return (0, router_1.handleRequest)(request, env);
    },
};
//# sourceMappingURL=index.js.map