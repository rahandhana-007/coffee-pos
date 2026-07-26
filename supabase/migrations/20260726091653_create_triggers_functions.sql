-- ============================================
-- MIGRATION: TRIGGERS & FUNCTIONS
-- ============================================

-- ============================================
-- FUNCTION: Auto-update kolom updated_at
-- ============================================
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Pasang trigger di semua tabel yang punya updated_at
CREATE TRIGGER trigger_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_categories_updated_at
  BEFORE UPDATE ON public.categories
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_products_updated_at
  BEFORE UPDATE ON public.products
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_product_variants_updated_at
  BEFORE UPDATE ON public.product_variants
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_transactions_updated_at
  BEFORE UPDATE ON public.transactions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- ============================================
-- FUNCTION: Auto-create user profile saat sign up
-- ============================================
-- Setiap user baru di auth.users akan otomatis 
-- dibuatkan row di public.users
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', SPLIT_PART(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'kasir')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- FUNCTION: Auto-generate invoice_number
-- Format: INV-YYYYMMDD-XXX (contoh: INV-20260726-001)
-- ============================================
CREATE OR REPLACE FUNCTION public.generate_invoice_number()
RETURNS TRIGGER AS $$
DECLARE
  today_date TEXT;
  next_number INTEGER;
  new_invoice TEXT;
BEGIN
  -- Hanya generate jika invoice_number kosong
  IF NEW.invoice_number IS NULL OR NEW.invoice_number = '' THEN
    today_date := TO_CHAR(NOW(), 'YYYYMMDD');
    
    -- Cari nomor urut berikutnya untuk hari ini
    SELECT COALESCE(MAX(
      CAST(SUBSTRING(invoice_number FROM 'INV-\d{8}-(\d+)') AS INTEGER)
    ), 0) + 1
    INTO next_number
    FROM public.transactions
    WHERE invoice_number LIKE 'INV-' || today_date || '-%';
    
    -- Format: INV-20260726-001
    new_invoice := 'INV-' || today_date || '-' || LPAD(next_number::TEXT, 3, '0');
    NEW.invoice_number := new_invoice;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_generate_invoice_number
  BEFORE INSERT ON public.transactions
  FOR EACH ROW EXECUTE FUNCTION public.generate_invoice_number();