import Link from 'next/link';

const linkStyle = {
  display: 'inline-block',
  padding: '10px 14px',
  border: '1px solid #d0d7de',
  borderRadius: 8,
  textDecoration: 'none',
  color: '#111827',
  background: '#ffffff',
};

export function AdminNav() {
  return (
    <nav style={{ display: 'flex', gap: 12, marginBottom: 24, flexWrap: 'wrap' }}>
      <Link href="/" style={linkStyle}>
        Dashboard
      </Link>
      <Link href="/jobs" style={linkStyle}>
        Jobs
      </Link>
      <Link href="/payments" style={linkStyle}>
        Payments
      </Link>
      <Link href="/disputes" style={linkStyle}>
        Disputes
      </Link>
    </nav>
  );
}
