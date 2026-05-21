-- ==========================================================
-- 14_UPDATE_REVOKE_AFFILIATION.SQL
-- Met à jour la fonction revoke_affiliation pour retirer automatiquement
-- l'élève de toutes les classes de l'enseignant lors de la désaffiliation.
-- Nettoie également les orphelins déjà existants en base de données.
-- ==========================================================

CREATE OR REPLACE FUNCTION public.revoke_affiliation(p_adult_id uuid, p_child_id uuid)
RETURNS void AS $$
DECLARE
  v_is_caller_super_admin boolean;
BEGIN
  -- 1. Est-ce que l'utilisateur essaie de se retirer lui-même ?
  IF auth.uid() = p_adult_id THEN
    -- Supprimer de la liste d'affiliations
    DELETE FROM public.affiliations 
    WHERE adult_id = p_adult_id AND child_id = p_child_id;

    -- Supprimer des classes de cet adulte (enseignant)
    DELETE FROM public.class_students
    WHERE student_id = p_child_id
      AND class_id IN (SELECT id FROM public.classes WHERE teacher_id = p_adult_id);
    RETURN;
  END IF;

  -- 2. Est-ce que l'utilisateur est Super-Admin de cet enfant ?
  SELECT is_super_admin INTO v_is_caller_super_admin
  FROM public.affiliations
  WHERE adult_id = auth.uid() AND child_id = p_child_id;

  IF v_is_caller_super_admin = true THEN
    -- Supprimer de la liste d'affiliations
    DELETE FROM public.affiliations 
    WHERE adult_id = p_adult_id AND child_id = p_child_id;

    -- Supprimer des classes de l'adulte révoqué (enseignant)
    DELETE FROM public.class_students
    WHERE student_id = p_child_id
      AND class_id IN (SELECT id FROM public.classes WHERE teacher_id = p_adult_id);
  ELSE
    RAISE EXCEPTION 'Droits insuffisants. Seul le Super-Admin peut révoquer d''autres membres.';
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- NETTOYAGE DES ORPHELINS EXISTANTS :
-- Supprime de class_students tout élève dont l'enseignant de la classe n'est plus affilié.
DELETE FROM public.class_students
WHERE (class_id, student_id) IN (
  SELECT cs.class_id, cs.student_id
  FROM public.class_students cs
  JOIN public.classes c ON c.id = cs.class_id
  LEFT JOIN public.affiliations a ON a.adult_id = c.teacher_id AND a.child_id = cs.student_id
  WHERE a.adult_id IS NULL
);
