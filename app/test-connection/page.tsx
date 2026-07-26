// ============================================
// HALAMAN TEST KONEKSI (SEMENTARA)
// ============================================
// Hapus folder app/test-connection/ sebelum deploy production
// ============================================

import { createClient } from '@/lib/supabase/server'

export default async function TestConnectionPage() {
  // 1. Cek environment variables
  const envCheck = {
    url: {
      exists: !!process.env.NEXT_PUBLIC_SUPABASE_URL,
      length: process.env.NEXT_PUBLIC_SUPABASE_URL?.length ?? 0,
    },
    anonKey: {
      exists: !!process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
      length: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY?.length ?? 0,
    },
    serviceRole: {
      exists: !!process.env.SUPABASE_SERVICE_ROLE_KEY,
      length: process.env.SUPABASE_SERVICE_ROLE_KEY?.length ?? 0,
    },
  }

  // 2. Test koneksi ke database
  const supabase = await createClient()

  // Query ke tabel categories (paling sederhana)
  const { data: categories, error: categoriesError } = await supabase
    .from('categories')
    .select('*')
    .limit(1)

  // 3. Cek auth session
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser()

  // Helper untuk render status
  const StatusBadge = ({ ok }: { ok: boolean }) => (
    <span
      style={{
        display: 'inline-block',
        padding: '2px 8px',
        borderRadius: '4px',
        backgroundColor: ok ? '#10b981' : '#ef4444',
        color: 'white',
        fontSize: '12px',
        fontWeight: 'bold',
      }}
    >
      {ok ? '✅ OK' : '❌ FAIL'}
    </span>
  )

  return (
    <div style={{ maxWidth: '700px', margin: '40px auto', fontFamily: 'monospace', padding: '20px' }}>
      <h1 style={{ borderBottom: '2px solid #333', paddingBottom: '10px' }}>
        🔌 Test Koneksi Supabase
      </h1>

      {/* Section 1: Environment Variables */}
      <section style={{ marginBottom: '30px' }}>
        <h2>1️⃣ Environment Variables</h2>
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <tbody>
            <tr style={{ borderBottom: '1px solid #ddd' }}>
              <td style={{ padding: '8px' }}>NEXT_PUBLIC_SUPABASE_URL</td>
              <td style={{ padding: '8px' }}>
                <StatusBadge ok={envCheck.url.exists} />
                {envCheck.url.exists && ` (${envCheck.url.length} chars)`}
              </td>
            </tr>
            <tr style={{ borderBottom: '1px solid #ddd' }}>
              <td style={{ padding: '8px' }}>NEXT_PUBLIC_SUPABASE_ANON_KEY</td>
              <td style={{ padding: '8px' }}>
                <StatusBadge ok={envCheck.anonKey.exists} />
                {envCheck.anonKey.exists && ` (${envCheck.anonKey.length} chars)`}
              </td>
            </tr>
            <tr style={{ borderBottom: '1px solid #ddd' }}>
              <td style={{ padding: '8px' }}>SUPABASE_SERVICE_ROLE_KEY</td>
              <td style={{ padding: '8px' }}>
                <StatusBadge ok={envCheck.serviceRole.exists} />
                {envCheck.serviceRole.exists && ` (${envCheck.serviceRole.length} chars)`}
              </td>
            </tr>
          </tbody>
        </table>
      </section>

      {/* Section 2: Database Query */}
      <section style={{ marginBottom: '30px' }}>
        <h2>2️⃣ Database Query (categories)</h2>
        {categoriesError ? (
          <div style={{ backgroundColor: '#fee', padding: '10px', borderRadius: '4px' }}>
            <strong>Error:</strong> {categoriesError.message}
            <br />
            <small>Code: {categoriesError.code}</small>
          </div>
        ) : (
          <div style={{ backgroundColor: '#efe', padding: '10px', borderRadius: '4px' }}>
            <StatusBadge ok={true} /> Query berhasil!
            <br />
            <small>Jumlah kategori ditemukan: {categories?.length ?? 0}</small>
            <br />
            <small style={{ color: '#666' }}>
              (0 itu wajar — tabel masih kosong, yang penting TIDAK ERROR)
            </small>
          </div>
        )}
      </section>

      {/* Section 3: Auth Session */}
      <section style={{ marginBottom: '30px' }}>
        <h2>3️⃣ Auth Session</h2>
        {userError ? (
          <div style={{ backgroundColor: '#fff3cd', padding: '10px', borderRadius: '4px' }}>
            <small>Tidak ada user login (ini NORMAL untuk halaman publik)</small>
            <br />
            <small>Message: {userError.message}</small>
          </div>
        ) : user ? (
          <div style={{ backgroundColor: '#efe', padding: '10px', borderRadius: '4px' }}>
            <StatusBadge ok={true} /> User login: {user.email}
          </div>
        ) : (
          <div style={{ backgroundColor: '#eef', padding: '10px', borderRadius: '4px' }}>
            <StatusBadge ok={true} /> Auth system bekerja (belum ada user login)
          </div>
        )}
      </section>

      {/* Summary */}
      <section
        style={{
          padding: '15px',
          backgroundColor: '#f0f0f0',
          borderRadius: '8px',
          border: '2px solid #333',
        }}
      >
        <h2 style={{ marginTop: 0 }}>📊 Kesimpulan</h2>
        {envCheck.url.exists &&
        envCheck.anonKey.exists &&
        !categoriesError ? (
          <p style={{ color: 'green', fontSize: '18px', margin: 0 }}>
            ✅ KONEKSI BERHASIL! Siap lanjut ke development fitur.
          </p>
        ) : (
          <p style={{ color: 'red', fontSize: '18px', margin: 0 }}>
            ❌ Ada masalah. Cek section di atas untuk detail.
          </p>
        )}
      </section>

      <p style={{ marginTop: '30px', color: '#999', fontSize: '12px' }}>
        ⚠️ Halaman ini sementara. Hapus folder <code>app/test-connection/</code> sebelum deploy.
      </p>
    </div>
  )
}