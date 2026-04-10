import Link from 'next/link';

import { AdminNav } from '@/components/admin-nav';
import { fetchAdminPayments, hasAdminApiBaseUrl } from '@/lib/admin-api';

export const dynamic = 'force-dynamic';

const paymentStatuses = ['pending', 'paid', 'failed', 'refunded', 'cancelled'];

export default async function AdminPaymentsPage({
  searchParams,
}: {
  searchParams?: Promise<{ status?: string }>;
}) {
  const params = (await searchParams) ?? {};
  const status = params.status?.trim() || '';
  const payments = await fetchAdminPayments(status || undefined);
  const hasApiBaseUrl = hasAdminApiBaseUrl();

  return (
    <main style={{ maxWidth: 1100, margin: '0 auto', padding: 24 }}>
      <h1 style={{ marginTop: 0 }}>Payments</h1>
      <p style={{ color: '#4b5563' }}>Admin payments list from API.</p>

      <AdminNav />

      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 16 }}>
        <Link href="/payments" style={status ? filterLinkStyle : activeFilterLinkStyle}>
          All
        </Link>
        {paymentStatuses.map((item) => (
          <Link
            key={item}
            href={`/payments?status=${item}`}
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

      {hasApiBaseUrl && payments.length === 0 && (
        <div style={noticeStyle}>
          No payments returned for current filter or API is currently unavailable.
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
              <th style={thStyle}>Job ID</th>
              <th style={thStyle}>User ID</th>
              <th style={thStyle}>Type</th>
              <th style={thStyle}>Status</th>
              <th style={thStyle}>Amount</th>
              <th style={thStyle}>Created</th>
            </tr>
          </thead>
          <tbody>
            {payments.map((payment) => (
              <tr key={payment.id}>
                <td style={tdStyle}>{payment.jobId}</td>
                <td style={tdStyle}>{payment.userId}</td>
                <td style={tdStyle}>{payment.type}</td>
                <td style={tdStyle}>{payment.status}</td>
                <td style={tdStyle}>
                  {payment.amount} {payment.currency}
                </td>
                <td style={tdStyle}>{formatDate(payment.createdAt)}</td>
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
};

const tdStyle = {
  padding: 12,
  borderBottom: '1px solid #e5e7eb',
  fontSize: 14,
};
