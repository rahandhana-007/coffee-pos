// ============================================
// NEXT.JS MIDDLEWARE
// ============================================
// Dijalankan sebelum setiap request ke halaman
// Fungsinya: refresh Supabase session otomatis
// ============================================

import { type NextRequest } from 'next/server'
import { updateSession } from '@/lib/supabase/middleware'

export async function middleware(request: NextRequest) {
  return await updateSession(request)
}

export const config = {
  matcher: [
    /*
     * Jalankan middleware di SEMUA request, kecuali:
     * - _next/static (file statis Next.js)
     * - _next/image (optimisasi gambar)
     * - favicon.ico
     * - file gambar (.svg, .png, .jpg, .jpeg, .gif, .webp)
     */
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}