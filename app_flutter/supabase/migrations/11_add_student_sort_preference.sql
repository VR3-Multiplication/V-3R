-- ==========================================================
-- 11_add_student_sort_preference.sql
-- Ajout d'une préférence de tri pour les élèves/enfants affiliés
-- ==========================================================

-- Ajouter la colonne student_sort_preference à la table profiles
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS student_sort_preference TEXT DEFAULT 'custom';
