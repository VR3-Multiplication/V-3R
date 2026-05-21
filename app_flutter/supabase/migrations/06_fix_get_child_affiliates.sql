-- ==========================================================
-- 06_FIX_GET_CHILD_AFFILIATES.SQL
-- Correction de la fonction get_child_affiliates pour éviter les conflits de noms de colonnes
-- ==========================================================

CREATE OR REPLACE FUNCTION public.get_child_affiliates(p_child_id uuid)
RETURNS TABLE(
  adult_id uuid,
  pseudo text,
  is_super_admin boolean
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.adult_id,
    p.pseudo,
    a.is_super_admin
  FROM public.affiliations a
  JOIN public.profiles p ON p.id = a.adult_id
  WHERE a.child_id = p_child_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
