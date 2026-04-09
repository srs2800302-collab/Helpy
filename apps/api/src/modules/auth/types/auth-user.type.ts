export type UserRole = 'client' | 'master' | 'admin';

export interface AuthUser {
  id: string;
  phone: string;
  role: UserRole | null;
  isActive: boolean;
  isPhoneVerified: boolean;
  createdAt: string;
}
