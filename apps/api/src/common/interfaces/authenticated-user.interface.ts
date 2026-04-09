export interface AuthenticatedUser {
  id: string;
  role: 'client' | 'master' | 'admin' | null;
  phone?: string;
}
