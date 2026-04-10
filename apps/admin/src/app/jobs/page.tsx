import Link from 'next/link';

import { AdminNav } from '@/components/admin-nav';
import { fetchAdminJobs, hasAdminApiBaseUrl } from '@/lib/admin-api';

export const dynamic = 'force-dynamic';

const jobStatuses = [
  'draft',
  'awaiting_payment',
  'open',
  'master_selected',
  'in_progress',
  'completed',
  'cancelled',
  'disputed',
];

export default async function AdminJobsPage({
  searchParams,
}: {
  searchParams?: Promise<{ status?: string }>;
}) {
  const params = (await searchParams) ?? {};
  const status = params.status?.trim() || '';
  const jobs = await fetchAdminJobs(status || undefined);
  const hasApiBaseUrl = hasAdminApiBaseUrl();

  return (
    <main style={{ maxWidth: 1100, margin: '0 auto', padding: 24 }}>
      <h1 style={{ marginTop: 0 }}>Jobs</h1>
      <p style={{ color: '#4b5563' }}>Admin jobs list from API.</p>

      <AdminNav />

      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 16 }}>
        <Link href="/jobs" style={status ? filterLinkStyle : activeFilterLinkStyle}>
          All
        </Link>
        {jobStatuses.map((item) => (
          <Link
            key={item}
            href={`/jobs?status=${item}`}
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

      {hasApiBaseUrl && jobs.length === 0 && (
        <div style={noticeStyle}>
          No jobs returned for current filter or API is currently unavailable.
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
              <th style={thStyle}>Title</th>
              <th style={thStyle}>Category</th>
              <th style={thStyle}>Client</th>
              <th style={thStyle}>Status</th>
              <th style={thStyle}>Created</th>
            </tr>
          </thead>
          <tbody>
            {jobs.map((job) => (
              <tr key={job.id}>
                <td style={tdStyle}>{job.title || '-'}</td>
                <td style={tdStyle}>{job.category?.slug || '-'}</td>
                <td style={tdStyle}>{job.client?.phone || job.clientUserId}</td>
                <td style={tdStyle}>{job.status || '-'}</td>
                <td style={tdStyle}>{formatDate(job.createdAt)}</td>
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
