import type { AuthUser } from './auth-user.type';

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface AuthResponse {
  user: AuthUser;
  tokens: AuthTokens;
  isNewUser: boolean;
  needsRoleSelection: boolean;
}
