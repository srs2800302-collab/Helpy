type ApiEnvelope<T> = {
  success: boolean;
  data: T;
};

export type AdminJobRow = {
  id: string;
  title: string;
  status: string;
  createdAt: string;
  clientUserId: string;
  categoryId: string;
  category?: {
    slug?: string;
  };
  client?: {
    phone?: string;
  };
};

export type AdminPaymentRow = {
  id: string;
  jobId: string;
  userId: string;
  type: string;
  status: string;
  amount: string | number;
  currency: string;
  createdAt: string;
};

function getApiBaseUrl(): string | null {
  const value = process.env.FIXI_ADMIN_API_BASE_URL?.trim();
  if (!value) return null;
  return value.replace(/\/+$/, '');
}

export async function fetchAdminJobs(status?: string): Promise<AdminJobRow[]> {
  const baseUrl = getApiBaseUrl();
  if (!baseUrl) return [];

  const query = new URLSearchParams();
  if (status) query.set('status', status);

  const url = `${baseUrl}/jobs/admin/all${query.toString() ? `?${query}` : ''}`;

  try {
    const response = await fetch(url, {
      cache: 'no-store',
    });

    if (!response.ok) {
      return [];
    }

    const json = (await response.json()) as ApiEnvelope<AdminJobRow[]>;
    return Array.isArray(json.data) ? json.data : [];
  } catch {
    return [];
  }
}

export async function fetchAdminPayments(status?: string): Promise<AdminPaymentRow[]> {
  const baseUrl = getApiBaseUrl();
  if (!baseUrl) return [];

  const query = new URLSearchParams();
  if (status) query.set('status', status);

  const url = `${baseUrl}/payments/admin/all${query.toString() ? `?${query}` : ''}`;

  try {
    const response = await fetch(url, {
      cache: 'no-store',
    });

    if (!response.ok) {
      return [];
    }

    const json = (await response.json()) as ApiEnvelope<AdminPaymentRow[]>;
    return Array.isArray(json.data) ? json.data : [];
  } catch {
    return [];
  }
}

export function hasAdminApiBaseUrl(): boolean {
  return !!getApiBaseUrl();
}
