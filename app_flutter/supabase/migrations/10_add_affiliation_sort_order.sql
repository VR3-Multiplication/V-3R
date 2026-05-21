-- ==========================================================
-- 10_add_affiliation_sort_order.sql
-- Ajout d'un ordre d'affichage persistant pour les enfants affiliés
-- ==========================================================

-- Ajouter la colonne sort_order à la table affiliations
ALTER TABLE public.affiliations
ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

-- Initialiser l'ordre existant selon la date de création (ordre chronologique)
UPDATE public.affiliations
SET sort_order = sub.rn - 1
FROM (
  SELECT adult_id, child_id,
         ROW_NUMBER() OVER (PARTITION BY adult_id ORDER BY created_at ASC) AS rn
  FROM public.affiliations
) sub
WHERE public.affiliations.adult_id = sub.adult_id
  AND public.affiliations.child_id = sub.child_id;
