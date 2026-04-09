export interface ApiSuccess<T> {
  success: true;
  data: T;
}

export interface ApiErrorPayload {
  code: string;
  message: string;
  details?: unknown;
}

export interface ApiError {
  success: false;
  error: ApiErrorPayload;
}

export type ApiResponse<T> = ApiSuccess<T> | ApiError;

export function ok<T>(data: T): ApiSuccess<T> {
  return {
    success: true,
    data,
  };
}

export function fail(code: string, message: string, details?: unknown): ApiError {
  return {
    success: false,
    error: {
      code,
      message,
      details,
    },
  };
}
