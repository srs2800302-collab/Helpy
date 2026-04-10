import { AdminNav } from '@/components/admin-nav';

const mockPayments = [
  {
    id: 'pay_001',
    jobId: 'job_001',
    userId: 'user_001',
    type: 'deposit',
    status: 'paid',
    amount: '100.00',
    currency: 'THB',
    createdAt: '2026-04-10 12:05',
  },
  {
    id: 'pay_002',
    jobId: 'job_002',
    userId: 'user_002',
    type: 'deposit',
    status: 'pending',
    amount: '100.00',
    currency: 'THB',
    createdAt: '2026-04-10 13:20',
  },
];

export default function AdminPaymentsPage() {
  return (
    <main style={{ maxWidth: 1100, margin: '0 auto', padding: 24 }}>
      <h1 style={{ marginTop: 0 }}>Payments</h1>
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
              <th style={thStyle}>Job ID</th>
              <th style={thStyle}>User ID</th>
              <th style={thStyle}>Type</th>
              <th style={thStyle}>Status</th>
              <th style={thStyle}>Amount</th>
              <th style={thStyle}>Created</th>
            </tr>
          </thead>
          <tbody>
            {mockPayments.map((payment) => (
              <tr key={payment.id}>
                <td style={tdStyle}>{payment.jobId}</td>
                <td style={tdStyle}>{payment.userId}</td>
                <td style={tdStyle}>{payment.type}</td>
                <td style={tdStyle}>{payment.status}</td>
                <td style={tdStyle}>
                  {payment.amount} {payment.currency}
                </td>
                <td style={tdStyle}>{payment.createdAt}</td>
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
