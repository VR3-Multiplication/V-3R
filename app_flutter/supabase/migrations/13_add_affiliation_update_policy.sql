-- ==========================================================
-- 13_ADD_AFFILIATION_UPDATE_POLICY.SQL
-- Autorise les adultes à modifier leurs propres affiliations (tri, etc.)
-- ==========================================================

DROP POLICY IF EXISTS "Affil_Modif" ON public.affiliations;
CREATE POLICY "Affil_Modif" ON public.affiliations 
FOR UPDATE 
USING (auth.uid() = adult_id)
WITH CHECK (auth.uid() = adult_id);
