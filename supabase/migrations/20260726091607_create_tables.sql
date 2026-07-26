-- ============================================
-- MIGRATION: CREATE TABLES
-- ============================================

-- ============================================
-- 1. TABEL USERS
-- Menyimpan data kasir & manager
-- Terhubung ke auth.users (Supabase Auth)
-- ============================================
CREATE TABLE public.users (
  id           UUID         PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email        TEXT         UNIQUE NOT NULL,
  full_name    TEXT         NOT NULL,
  role         user_role    NOT NULL DEFAULT 'kasir',
  is_active    BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.users IS 'Data kasir dan manager coffee shop';

-- ============================================
-- 2. TABEL CATEGORIES
-- Kategori menu: Kopi, Non-Kopi, Makanan, dll
-- ============================================
CREATE TABLE public.categories (
  id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT         UNIQUE NOT NULL,
  description  TEXT,
  sort_order   INTEGER      NOT NULL DEFAULT 0,
  is_active    BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.categories IS 'Kategori menu produk';

-- ============================================
-- 3. TABEL PRODUCTS
-- Data menu utama
-- ============================================
CREATE TABLE public.products (
  id                UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id       UUID         NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
  name              TEXT         NOT NULL,
  description       TEXT,
  image_url         TEXT,
  has_size          BOOLEAN      NOT NULL DEFAULT FALSE,
  has_temperature   BOOLEAN      NOT NULL DEFAULT FALSE,
  is_active         BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.products IS 'Menu utama coffee shop';

-- ============================================
-- 4. TABEL PRODUCT_VARIANTS
-- Kombinasi variasi (size + suhu) + harga
-- ============================================
CREATE TABLE public.product_variants (
  id           UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id   UUID           NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  size         product_size,
  temperature  product_temp,
  price        INTEGER        NOT NULL CHECK (price >= 0),
  is_active    BOOLEAN        NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  
  -- Cegah duplikasi variasi untuk produk yang sama
  UNIQUE(product_id, size, temperature)
);

COMMENT ON TABLE public.product_variants IS 'Varian produk (size + suhu) beserta harga';

-- ============================================
-- 5. TABEL TRANSACTIONS
-- Header setiap transaksi
-- ============================================
CREATE TABLE public.transactions (
  id                UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_number    TEXT                UNIQUE NOT NULL,
  kasir_id          UUID                NOT NULL REFERENCES public.users(id) ON DELETE RESTRICT,
  total_amount      INTEGER             NOT NULL CHECK (total_amount >= 0),
  payment_method    payment_method      NOT NULL,
  amount_paid       INTEGER             NOT NULL CHECK (amount_paid >= 0),
  change_amount     INTEGER             NOT NULL DEFAULT 0 CHECK (change_amount >= 0),
  status            transaction_status  NOT NULL DEFAULT 'completed',
  notes             TEXT,
  created_at        TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.transactions IS 'Data transaksi/penjualan';

-- ============================================
-- 6. TABEL TRANSACTION_ITEMS
-- Detail item per transaksi
-- Menyimpan SNAPSHOT (nama, harga saat transaksi)
-- ============================================
CREATE TABLE public.transaction_items (
  id                UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id    UUID          NOT NULL REFERENCES public.transactions(id) ON DELETE CASCADE,
  product_id        UUID          NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
  variant_id        UUID          NOT NULL REFERENCES public.product_variants(id) ON DELETE RESTRICT,
  product_name      TEXT          NOT NULL,
  variant_info      TEXT,
  quantity          INTEGER       NOT NULL CHECK (quantity > 0),
  unit_price        INTEGER       NOT NULL CHECK (unit_price >= 0),
  subtotal          INTEGER       NOT NULL CHECK (subtotal >= 0),
  created_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.transaction_items IS 'Detail item setiap transaksi (dengan snapshot)';

-- ============================================
-- INDEXES untuk PERFORMA
-- ============================================
CREATE INDEX idx_products_category_id       ON public.products(category_id);
CREATE INDEX idx_products_is_active         ON public.products(is_active);
CREATE INDEX idx_product_variants_product   ON public.product_variants(product_id);
CREATE INDEX idx_transactions_kasir_id      ON public.transactions(kasir_id);
CREATE INDEX idx_transactions_created_at    ON public.transactions(created_at DESC);
CREATE INDEX idx_transactions_status        ON public.transactions(status);
CREATE INDEX idx_transaction_items_trx      ON public.transaction_items(transaction_id);