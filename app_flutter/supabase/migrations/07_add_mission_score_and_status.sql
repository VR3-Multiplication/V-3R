-- ==========================================================
-- 07_ADD_MISSION_SCORE_AND_STATUS.SQL
-- Ajout des colonnes de statut et de score pour les missions
-- ==========================================================

-- Ajout du score (optionnel, stocké lors de la complétion)
ALTER TABLE public.missions ADD COLUMN IF NOT EXISTS score INTEGER;

-- Ajout du statut (valeurs: 'pending', 'completed', 'abandoned')
ALTER TABLE public.missions ADD COLUMN IF NOT EXISTS status TEXT CHECK (status IN ('pending', 'completed', 'abandoned')) DEFAULT 'pending' NOT NULL;
