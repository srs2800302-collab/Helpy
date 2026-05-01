import { handleRequest } from './router';

export default {
  fetch(request: Request, env: any, ctx: any) {
    return handleRequest(request, env, ctx);
  },
};
// trigger deploy Wed Apr 15 00:55:16 MSK 2026
