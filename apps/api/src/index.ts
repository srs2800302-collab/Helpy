import { handleRequest } from './router';

export default {
  fetch(request: Request, env: any) {
    return handleRequest(request, env);
  },
};
