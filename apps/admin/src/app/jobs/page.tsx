import { AdminNav } from '@/components/admin-nav';

const mockJobs = [
  {
    id: 'job_001',
    title: 'Fix leaking sink',
    category: 'plumbing',
    client: '+66 900000001',
    status: 'open',
    createdAt: '2026-04-10 12:00',
  },
  {
    id: 'job_002',
    title: 'Aircon cleaning',
    category: 'aircon',
    client: '+66 900000002',
    status: 'awaiting_payment',
    createdAt: '2026-04-10 13:15',
  },
  {
    id: 'job_003',
    title: 'Door lock replacement',
    category: 'locks',
    client: '+66 900000003',
    status: 'completed',
    createdAt: '2026-04-10 14:40',
  },
];

export default function AdminJobsPage() {
  return (
    <main style={{ maxWidth: 1100, margin: '0 auto', padding: 24 }}>
      <h1 style={{ marginTop: 0 }}>Jobs</h1>
      <p style={{ color: '#4b5563' }}>
        MVP placeholder table. Next pass will connect this page to API.
      </p>

      <AdminNav />

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
            {mockJobs.map((job) => (
              <tr key={job.id}>
                <td style={tdStyle}>{job.title}</td>
                <td style={tdStyle}>{job.category}</td>
                <td style={tdStyle}>{job.client}</td>
                <td style={tdStyle}>{job.status}</td>
                <td style={tdStyle}>{job.createdAt}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </main>
  );
}

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
