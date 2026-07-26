-- ============================================
-- MIGRATION: ROW LEVEL SECURITY (RLS)
-- ============================================

-- ============================================
-- ENABLE RLS di semua tabel
-- ============================================
ALTER TABLE public.users              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_items  ENABLE ROW LEVEL SECURITY;

-- ============================================
-- HELPER FUNCTION: Cek apakah user adalah manager
-- ============================================
CREATE OR REPLACE FUNCTION public.is_manager()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid()
      AND role = 'manager'
      AND is_active = TRUE
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ============================================
-- POLICIES: USERS
-- ============================================
CREATE POLICY "users_select_own_or_manager"
  ON public.users FOR SELECT
  USING (auth.uid() = id OR public.is_manager());

CREATE POLICY "users_insert_manager_only"
  ON public.users FOR INSERT
  WITH CHECK (public.is_manager());

CREATE POLICY "users_update_own_profile"
  ON public.users FOR UPDATE
  USING (auth.uid() = id OR public.is_manager());

-- ============================================
-- POLICIES: CATEGORIES
-- ============================================
CREATE POLICY "categories_select_all_authenticated"
  ON public.categories FOR SELECT
  TO authenticated
  USING (TRUE);

CREATE POLICY "categories_insert_manager_only"
  ON public.categories FOR INSERT
  TO authenticated
  WITH CHECK (public.is_manager());

CREATE POLICY "categories_update_manager_only"
  ON public.categories FOR UPDATE
  TO authenticated
  USING (public.is_manager());

CREATE POLICY "categories_delete_manager_only"
  ON public.categories FOR DELETE
  TO authenticated
  USING (public.is_manager());

-- ============================================
-- POLICIES: PRODUCTS
-- ============================================
CREATE POLICY "products_select_all_authenticated"
  ON public.products FOR SELECT
  TO authenticated
  USING (TRUE);

CREATE POLICY "products_insert_manager_only"
  ON public.products FOR INSERT
  TO authenticated
  WITH CHECK (public.is_manager());

CREATE POLICY "products_update_manager_only"
  ON public.products FOR UPDATE
  TO authenticated
  USING (public.is_manager());

CREATE POLICY "products_delete_manager_only"
  ON public.products FOR DELETE
  TO authenticated
  USING (public.is_manager());

-- ============================================
-- POLICIES: PRODUCT_VARIANTS
-- ============================================
CREATE POLICY "product_variants_select_all_authenticated"
  ON public.product_variants FOR SELECT
  TO authenticated
  USING (TRUE);

CREATE POLICY "product_variants_insert_manager_only"
  ON public.product_variants FOR INSERT
  TO authenticated
  WITH CHECK (public.is_manager());

CREATE POLICY "product_variants_update_manager_only"
  ON public.product_variants FOR UPDATE
  TO authenticated
  USING (public.is_manager());

CREATE POLICY "product_variants_delete_manager_only"
  ON public.product_variants FOR DELETE
  TO authenticated
  USING (public.is_manager());

-- ============================================
-- POLICIES: TRANSACTIONS
-- ============================================
-- Kasir hanya bisa lihat transaksinya sendiri, 
-- manager bisa lihat semua
CREATE POLICY "transactions_select_own_or_manager"
  ON public.transactions FOR SELECT
  TO authenticated
  USING (auth.uid() = kasir_id OR public.is_manager());

-- Kasir & manager bisa buat transaksi
CREATE POLICY "transactions_insert_authenticated"
  ON public.transactions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = kasir_id);

-- Hanya manager yang bisa update (untuk cancel)
CREATE POLICY "transactions_update_manager_only"
  ON public.transactions FOR UPDATE
  TO authenticated
  USING (public.is_manager());

-- TIDAK ADA policy DELETE = tidak ada yang bisa hapus
-- (data transaksi harus permanen untuk audit)

-- ============================================
-- POLICIES: TRANSACTION_ITEMS
-- ============================================
CREATE POLICY "transaction_items_select_via_transaction"
  ON public.transaction_items FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.transactions t
      WHERE t.id = transaction_id
        AND (t.kasir_id = auth.uid() OR public.is_manager())
    )
  );

CREATE POLICY "transaction_items_insert_via_transaction"
  ON public.transaction_items FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.transactions t
      WHERE t.id = transaction_id
        AND t.kasir_id = auth.uid()
    )
  );

-- Tidak ada UPDATE/DELETE untuk transaction_items