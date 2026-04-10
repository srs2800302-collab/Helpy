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
  jobId: string;
  openedByUserId: string;
  reason: string;
  status: string;
  resolutionNote?: string | null;
  createdAt: string;
  resolvedAt?: string | null;
  job?: {
    id: string;
    title: string;
    status: string;
    clientUserId: string;
    selectedMasterUserId?: string | null;
  };
  openedBy?: {
    id: string;
    phone?: string;
    role?: string;
  };
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

export async function fetchAdminDisputes(status?: string): Promise<AdminDisputeRow[]> {
  const baseUrl = getApiBaseUrl();
  if (!baseUrl) return [];

  const query = new URLSearchParams();
  if (status) query.set('status', status);

  const url = `${baseUrl}/disputes/admin/all${query.toString() ? `?${query}` : ''}`;

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

export async function updateDisputeStatus(input: {
  disputeId: string;
  status: 'open' | 'in_review' | 'resolved' | 'rejected';
  resolutionNote?: string;
}): Promise<boolean> {
  const baseUrl = getApiBaseUrl();
  if (!baseUrl) return false;

  try {
    const response = await fetch(`${baseUrl}/disputes/${input.disputeId}/status`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        status: input.status,
        resolutionNote: input.resolutionNote?.trim() || undefined,
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
