import Link from 'next/link';
import { revalidatePath } from 'next/cache';

import { AdminNav } from '@/components/admin-nav';
import {
  fetchAdminDisputes,
  hasAdminApiBaseUrl,
  updateDisputeStatus,
} from '@/lib/admin-api';

export const dynamic = 'force-dynamic';

const disputeStatuses = ['open', 'in_review', 'resolved', 'rejected'];

export default async function AdminDisputesPage({
  searchParams,
}: {
  searchParams?: Promise<{ status?: string }>;
}) {
  const params = (await searchParams) ?? {};
  const status = params.status?.trim() || '';
  const disputes = await fetchAdminDisputes(status || undefined);
  const hasApiBaseUrl = hasAdminApiBaseUrl();

  async function changeDisputeStatus(formData: FormData) {
    'use server';

    const disputeId = formData.get('disputeId')?.toString() ?? '';
    const nextStatus = formData.get('nextStatus')?.toString() as
      | 'open'
      | 'in_review'
      | 'resolved'
      | 'rejected';
    const resolutionNote = formData.get('resolutionNote')?.toString() ?? '';

    if (!disputeId || !nextStatus) {
      return;
    }

    await updateDisputeStatus({
      disputeId,
      status: nextStatus,
      resolutionNote,
    });

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
                <td style={tdStyle}>{dispute.job?.title || dispute.jobId}</td>
                <td style={tdStyle}>{dispute.openedBy?.phone || dispute.openedByUserId}</td>
                <td style={tdStyle}>{dispute.reason || '-'}</td>
                <td style={tdStyle}>{dispute.status || '-'}</td>
                <td style={tdStyle}>{formatDate(dispute.createdAt)}</td>
                <td style={tdStyle}>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                    {dispute.status === 'open' && (
                      <form action={changeDisputeStatus}>
                        <input type="hidden" name="disputeId" value={dispute.id} />
                        <input type="hidden" name="nextStatus" value="in_review" />
                        <button type="submit" style={buttonStyle}>
                          Move to in_review
                        </button>
                      </form>
                    )}

                    {dispute.status === 'in_review' && (
                      <>
                        <form action={changeDisputeStatus}>
                          <input type="hidden" name="disputeId" value={dispute.id} />
                          <input type="hidden" name="nextStatus" value="resolved" />
                          <input
                            type="text"
                            name="resolutionNote"
                            placeholder="Resolution note"
                            style={inputStyle}
                          />
                          <div style={{ height: 8 }} />
                          <button type="submit" style={buttonStyle}>
                            Resolve
                          </button>
                        </form>

                        <form action={changeDisputeStatus}>
                          <input type="hidden" name="disputeId" value={dispute.id} />
                          <input type="hidden" name="nextStatus" value="rejected" />
                          <input
                            type="text"
                            name="resolutionNote"
                            placeholder="Rejection note"
                            style={inputStyle}
                          />
                          <div style={{ height: 8 }} />
                          <button type="submit" style={buttonStyleSecondary}>
                            Reject
                          </button>
                        </form>
                      </>
                    )}

                    {(dispute.status === 'resolved' || dispute.status === 'rejected') && (
                      <span style={{ color: '#6b7280', fontSize: 13 }}>No actions</span>
                    )}
                  </div>
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

const inputStyle = {
  width: '100%',
  minWidth: 180,
  padding: '8px 10px',
  border: '1px solid #d1d5db',
  borderRadius: 8,
  fontSize: 13,
  boxSizing: 'border-box' as const,
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
