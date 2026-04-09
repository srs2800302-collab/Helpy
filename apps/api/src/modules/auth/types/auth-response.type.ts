export type UserRole = 'client' | 'master' | 'admin';

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface AuthUser {
  id: string;
  phone: string;
  role: UserRole | null;
  isActive: boolean;
  isPhoneVerified: boolean;
  createdAt: string;
}

export interface AuthResponse {
  user: AuthUser;
  tokens: AuthTokens;
  isNewUser: boolean;
  needsRoleSelection: boolean;
}

export interface RequestOtpResult {
  sent: boolean;
  expiresInSeconds: number;
  debugCode?: string;
}

export interface VerifyOtpResult extends AuthResponse {}
