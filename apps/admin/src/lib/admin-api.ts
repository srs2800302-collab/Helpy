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

export type AdminDisputeRow = {
  id: string;
  job_id: string;
  created_by_user_id: string;
  reason: string;
  status: 'open' | 'resolved';
  resolution: 'refund' | 'no_refund' | null;
  resolved_by_user_id: string | null;
  resolved_at: string | null;
  created_at: string;
  job_title?: string | null;
  job_category?: string | null;
  client_user_id?: string | null;
  selected_master_user_id?: string | null;
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

  const url = `${baseUrl}/admin/jobs${query.toString() ? `?${query}` : ''}`;

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

  const url = `${baseUrl}/admin/payments${query.toString() ? `?${query}` : ''}`;

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

export async function fetchAdminDisputes(): Promise<AdminDisputeRow[]> {
  const baseUrl = getApiBaseUrl();
  if (!baseUrl) return [];

  const url = `${baseUrl}/admin/disputes`;

  try {
    const response = await fetch(url, {
      cache: 'no-store',
    });

    if (!response.ok) {
      return [];
    }

    const json = (await response.json()) as ApiEnvelope<AdminDisputeRow[]>;
    return Array.isArray(json.data) ? json.data : [];
  } catch {
    return [];
  }
}

export async function resolveDispute(input: {
  jobId: string;
  resolution: 'refund' | 'no_refund';
}): Promise<boolean> {
  const baseUrl = getApiBaseUrl();
  if (!baseUrl) return false;

  try {
    const response = await fetch(`${baseUrl}/jobs/${input.jobId}/dispute/resolve`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        resolution: input.resolution,
      }),
      cache: 'no-store',
    });

    return response.ok;
  } catch {
    return false;
  }
}

export function hasAdminApiBaseUrl(): boolean {
  return !!getApiBaseUrl();
}
