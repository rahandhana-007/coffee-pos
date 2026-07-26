-- ============================================
-- MIGRATION: CREATE ENUM TYPES
-- ============================================
-- Enum digunakan untuk membatasi nilai kolom
-- hanya boleh berisi value tertentu.

-- Role user: kasir atau manager
CREATE TYPE user_role AS ENUM ('kasir', 'manager');

-- Ukuran produk (untuk minuman)
CREATE TYPE product_size AS ENUM ('S', 'M', 'L');

-- Suhu produk (untuk minuman)
CREATE TYPE product_temp AS ENUM ('hot', 'ice');

-- Metode pembayaran
CREATE TYPE payment_method AS ENUM ('tunai', 'qris', 'transfer');

-- Status transaksi
CREATE TYPE transaction_status AS ENUM ('completed', 'cancelled');