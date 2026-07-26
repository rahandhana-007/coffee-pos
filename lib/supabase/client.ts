// ============================================
// SUPABASE CLIENT — untuk BROWSER
// ============================================
// Dipakai di Client Components ("use client")
// Contoh: form login, tombol interaktif, dll
// ============================================

import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}