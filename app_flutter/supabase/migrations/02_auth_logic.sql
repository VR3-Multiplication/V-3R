-- ==========================================================
-- 02_AUTH_LOGIC.SQL (VERSION SÉCURISÉE)
-- Fonctions et Triggers pour l'authentification
-- ==========================================================

-- 1. Générateur de code ultra-simple (MD5)
CREATE OR REPLACE FUNCTION public.generate_affiliation_code()
RETURNS TEXT AS $$
BEGIN
  RETURN UPPER(SUBSTRING(MD5(RANDOM()::TEXT), 1, 6));
END;
$$ LANGUAGE plpgsql VOLATILE;

-- 2. Création automatique du profil après inscription Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  -- Bloc BEGIN/EXCEPTION pour éviter les erreurs 500 bloquantes
  BEGIN
    INSERT INTO public.profiles (id, role, pseudo, affiliation_code, stars)
    VALUES (
      new.id, 
      COALESCE(new.raw_user_meta_data->>'role', 'parent'),
      COALESCE(new.raw_user_meta_data->>'pseudo', 'Joueur'),
      CASE WHEN (new.raw_user_meta_data->>'role') = 'child' THEN generate_affiliation_code() ELSE NULL END,
      0
    );
  EXCEPTION WHEN OTHERS THEN
    -- On ignore l'erreur pour ne pas faire planter le signUp Supabase
  END;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Réinitialisation du trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created 
  AFTER INSERT ON auth.users 
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 3. Fonction de liaison manuelle par code
CREATE OR REPLACE FUNCTION public.link_child(affiliation_code text)
RETURNS void AS $$
BEGIN
  INSERT INTO public.affiliations (adult_id, child_id, is_super_admin)
  SELECT auth.uid(), id, true FROM public.profiles 
  WHERE profiles.affiliation_code = link_child.affiliation_code
  ON CONFLICT DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
