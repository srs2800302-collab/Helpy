export type UserRole = 'client' | 'master' | 'admin';

export type JobStatus =
  | 'draft'
  | 'awaiting_payment'
  | 'open'
  | 'master_selected'
  | 'in_progress'
  | 'completed'
  | 'cancelled'
  | 'disputed';

export type ServiceCategorySlug =
  | 'cleaning'
  | 'handyman'
  | 'plumbing'
  | 'electrical'
  | 'locks'
  | 'aircon'
  | 'furniture_assembly';

export interface ApiSuccess<T> {
  success: true;
  data: T;
}

export interface ApiError {
  success: false;
  error: {
    code: string;
    message: string;
  };
}

export type ApiResponse<T> = ApiSuccess<T> | ApiError;
