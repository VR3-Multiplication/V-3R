-- ==========================================================
-- 08_UPDATE_LINK_CHILD_FUNCTION.SQL
-- Met à jour la fonction link_child pour lever une exception si le code est invalide
-- ==========================================================

CREATE OR REPLACE FUNCTION public.link_child(affiliation_code text)
RETURNS void AS $$
DECLARE
  v_child_id uuid;
BEGIN
  -- Récupérer l'ID de l'enfant correspondant au code d'affiliation
  SELECT id INTO v_child_id 
  FROM public.profiles 
  WHERE profiles.affiliation_code = link_child.affiliation_code;
  
  -- Si l'enfant n'existe pas, lever une exception
  IF v_child_id IS NULL THEN
    RAISE EXCEPTION 'Code invalide : aucun enfant trouvé avec ce code.';
  END IF;
  
  -- Insérer la liaison d'affiliation (si elle n'existe pas déjà)
  INSERT INTO public.affiliations (adult_id, child_id, is_super_admin)
  VALUES (auth.uid(), v_child_id, true)
  ON CONFLICT DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
