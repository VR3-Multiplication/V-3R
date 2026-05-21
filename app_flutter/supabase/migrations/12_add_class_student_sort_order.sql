-- ==========================================================
-- 12_ADD_CLASS_STUDENT_SORT_ORDER.SQL
-- Ajout de l'ordre persistant et du tri pour les élèves de classe
-- ==========================================================

-- 1. Ajouter la colonne student_sort_preference à la table classes
ALTER TABLE public.classes
ADD COLUMN IF NOT EXISTS student_sort_preference TEXT DEFAULT 'custom';

-- 2. Ajouter la colonne sort_order à la table class_students
ALTER TABLE public.class_students
ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;
