import { AdminNav } from '@/components/admin-nav';

export default function AdminDashboardPage() {
  return (
    <main style={{ maxWidth: 1100, margin: '0 auto', padding: 24 }}>
      <h1 style={{ marginTop: 0 }}>Fixi Admin</h1>
      <p style={{ color: '#4b5563' }}>
        MVP admin dashboard for jobs, payments, and operations control.
      </p>

      <AdminNav />

      <section
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
          gap: 16,
        }}
      >
        <div
          style={{
            background: '#fff',
            border: '1px solid #e5e7eb',
            borderRadius: 12,
            padding: 16,
          }}
        >
          <h2 style={{ marginTop: 0, fontSize: 18 }}>Jobs</h2>
          <p style={{ marginBottom: 0, color: '#4b5563' }}>
            Review job statuses, client requests, and execution progress.
          </p>
        </div>

        <div
          style={{
            background: '#fff',
            border: '1px solid #e5e7eb',
            borderRadius: 12,
            padding: 16,
          }}
        >
          <h2 style={{ marginTop: 0, fontSize: 18 }}>Payments</h2>
          <p style={{ marginBottom: 0, color: '#4b5563' }}>
            Track deposits, paid statuses, and payment lifecycle.
          </p>
        </div>

        <div
          style={{
            background: '#fff',
            border: '1px solid #e5e7eb',
            borderRadius: 12,
            padding: 16,
          }}
        >
          <h2 style={{ marginTop: 0, fontSize: 18 }}>Disputes</h2>
          <p style={{ marginBottom: 0, color: '#4b5563' }}>
            Placeholder for next admin wave after jobs and payments pages.
          </p>
        </div>
      </section>
    </main>
  );
}
