import type { Metadata } from 'next';
import { ReactNode } from 'react';

export const metadata: Metadata = {
  title: 'Fixi Admin',
  description: 'Fixi admin panel MVP',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        style={{
          margin: 0,
          fontFamily: 'Arial, sans-serif',
          background: '#f6f8fb',
          color: '#111827',
        }}
      >
        {children}
      </body>
    </html>
  );
}
