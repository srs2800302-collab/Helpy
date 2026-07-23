import Link from 'next/link';
import { revalidatePath } from 'next/cache';

import { AdminNav } from '@/components/admin-nav';
import {
  fetchAdminDisputes,
  hasAdminApiBaseUrl,
  resolveDispute,
} from '@/lib/admin-api';

export const dynamic = 'force-dynamic';

const disputeStatuses = ['open', 'resolved'] as const;

export default async function AdminDisputesPage({
  searchParams,
}: {
  searchParams?: Promise<{ status?: string }>;
}) {
  const params = (await searchParams) ?? {};
  const status = params.status?.trim() || '';
  const allDisputes = await fetchAdminDisputes();
  const disputes = status
    ? allDisputes.filter((dispute) => dispute.status === status)
    : allDisputes;
  const hasApiBaseUrl = hasAdminApiBaseUrl();

  async function resolveDisputeAction(formData: FormData) {
    'use server';

    const jobId = formData.get('jobId')?.toString() ?? '';
    const resolution = formData.get('resolution')?.toString() as
      | 'refund'
      | 'no_refund';

    if (!jobId || !resolution) {
      return;
    }

    await resolveDispute({ jobId, resolution });

    revalidatePath('/disputes');
  }

  return (
    <main style={{ maxWidth: 1100, margin: '0 auto', padding: 24 }}>
      <h1 style={{ marginTop: 0 }}>Disputes</h1>
      <p style={{ color: '#4b5563' }}>Admin disputes list from API.</p>

      <AdminNav />

      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 16 }}>
        <Link href="/disputes" style={status ? filterLinkStyle : activeFilterLinkStyle}>
          All
        </Link>
        {disputeStatuses.map((item) => (
          <Link
            key={item}
            href={`/disputes?status=${item}`}
            style={status === item ? activeFilterLinkStyle : filterLinkStyle}
          >
            {item}
          </Link>
        ))}
      </div>

      {!hasApiBaseUrl && (
        <div style={noticeStyle}>
          FIXI_ADMIN_API_BASE_URL is not configured. Showing empty state.
        </div>
      )}

      {hasApiBaseUrl && disputes.length === 0 && (
        <div style={noticeStyle}>
          No disputes returned for current filter or API is currently unavailable.
        </div>
      )}

      <div
        style={{
          background: '#fff',
          border: '1px solid #e5e7eb',
          borderRadius: 12,
          overflow: 'hidden',
        }}
      >
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead style={{ background: '#f9fafb' }}>
            <tr>
              <th style={thStyle}>Job</th>
              <th style={thStyle}>Opened by</th>
              <th style={thStyle}>Reason</th>
              <th style={thStyle}>Status</th>
              <th style={thStyle}>Created</th>
              <th style={thStyle}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {disputes.map((dispute) => (
              <tr key={dispute.id}>
                <td style={tdStyle}>{dispute.job_title || dispute.job_id}</td>
                <td style={tdStyle}>{dispute.created_by_user_id}</td>
                <td style={tdStyle}>{dispute.reason || '-'}</td>
                <td style={tdStyle}>{dispute.status || '-'}</td>
                <td style={tdStyle}>{formatDate(dispute.created_at)}</td>
                <td style={tdStyle}>
                  {dispute.status === 'open' && (
                    <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                      <form action={resolveDisputeAction}>
                        <input type="hidden" name="jobId" value={dispute.job_id} />
                        <input type="hidden" name="resolution" value="refund" />
                        <button type="submit" style={buttonStyle}>
                          Resolve with refund
                        </button>
                      </form>

                      <form action={resolveDisputeAction}>
                        <input type="hidden" name="jobId" value={dispute.job_id} />
                        <input type="hidden" name="resolution" value="no_refund" />
                        <button type="submit" style={buttonStyleSecondary}>
                          Resolve without refund
                        </button>
                      </form>
                    </div>
                  )}

                  {dispute.status === 'resolved' && (
                    <span style={{ color: '#6b7280', fontSize: 13 }}>
                      Resolved ({dispute.resolution ?? '-'})
                    </span>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </main>
  );
}

function formatDate(value: string): string {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return date.toLocaleString();
}

const noticeStyle = {
  marginBottom: 16,
  padding: 12,
  background: '#fff7ed',
  border: '1px solid #fdba74',
  borderRadius: 8,
  color: '#9a3412',
};

const filterLinkStyle = {
  display: 'inline-block',
  padding: '8px 12px',
  border: '1px solid #d1d5db',
  borderRadius: 999,
  textDecoration: 'none',
  color: '#374151',
  background: '#fff',
  fontSize: 14,
};

const activeFilterLinkStyle = {
  ...filterLinkStyle,
  border: '1px solid #111827',
  color: '#111827',
  background: '#f3f4f6',
};

const thStyle = {
  textAlign: 'left' as const,
  padding: 12,
  borderBottom: '1px solid #e5e7eb',
  fontSize: 14,
  verticalAlign: 'top' as const,
};

const tdStyle = {
  padding: 12,
  borderBottom: '1px solid #e5e7eb',
  fontSize: 14,
  verticalAlign: 'top' as const,
};

const buttonStyle = {
  padding: '8px 12px',
  border: '1px solid #111827',
  borderRadius: 8,
  background: '#111827',
  color: '#fff',
  cursor: 'pointer',
  fontSize: 13,
};

const buttonStyleSecondary = {
  padding: '8px 12px',
  border: '1px solid #9ca3af',
  borderRadius: 8,
  background: '#fff',
  color: '#111827',
  cursor: 'pointer',
  fontSize: 13,
};
