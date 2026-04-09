export type UserRole = 'client' | 'master' | 'admin';

export interface RequestOtpDto {
  phone: string;
}

export interface VerifyOtpDto {
  phone: string;
  code: string;
}

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

export interface RequestOtpResponse {
  sent: boolean;
  expiresInSeconds: number;
}

export interface VerifyOtpResponse extends AuthResponse {}
