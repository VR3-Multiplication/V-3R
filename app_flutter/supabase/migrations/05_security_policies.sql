-- ==========================================================
-- 05_SECURITY_POLICIES.SQL
-- Définition de toutes les politiques de sécurité (RLS)
-- ==========================================================

-- PROFILS
DROP POLICY IF EXISTS "Lect_Prof" ON public.profiles;
CREATE POLICY "Lect_Prof" ON public.profiles FOR SELECT USING (true);
DROP POLICY IF EXISTS "Mod_Prof" ON public.profiles;
CREATE POLICY "Mod_Prof" ON public.profiles FOR UPDATE USING (auth.uid() = id);
DROP POLICY IF EXISTS "Ins_Prof" ON public.profiles;
CREATE POLICY "Ins_Prof" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- TRADUCTIONS
DROP POLICY IF EXISTS "Lect_Trad" ON public.translations;
CREATE POLICY "Lect_Trad" ON public.translations FOR SELECT USING (true);

-- BOUTIQUE
DROP POLICY IF EXISTS "Lect_Bout" ON public.shop_items;
CREATE POLICY "Lect_Bout" ON public.shop_items FOR SELECT USING (true);

-- INVENTAIRE
DROP POLICY IF EXISTS "Lect_Inv" ON public.child_inventory;
CREATE POLICY "Lect_Inv" ON public.child_inventory FOR SELECT USING (auth.uid() = child_id);
DROP POLICY IF EXISTS "Mod_Inv" ON public.child_inventory;
CREATE POLICY "Mod_Inv" ON public.child_inventory FOR UPDATE USING (auth.uid() = child_id);

-- MISSIONS
DROP POLICY IF EXISTS "Miss_All" ON public.missions;
CREATE POLICY "Miss_All" ON public.missions FOR ALL USING (auth.uid() = assigned_by OR auth.uid() = assigned_to);

-- AFFILIATIONS
DROP POLICY IF EXISTS "Affil_Lect" ON public.affiliations;
CREATE POLICY "Affil_Lect" ON public.affiliations FOR SELECT USING (auth.uid() = adult_id OR auth.uid() = child_id);
