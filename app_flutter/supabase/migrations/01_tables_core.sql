-- ==========================================================
-- 01_TABLES_CORE.SQL
-- Structure fondamentale de l'application
-- ==========================================================

-- Table des Profils (Standardisée)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT CHECK (role IN ('parent', 'teacher', 'child')),
    pseudo TEXT,
    full_name TEXT,
    affiliation_code TEXT UNIQUE,
    stars INTEGER DEFAULT 0,
    has_active_subscription BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Table des Missions
CREATE TABLE IF NOT EXISTS public.missions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assigned_by UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  assigned_to UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  operation_type TEXT NOT NULL,
  difficulty SMALLINT NOT NULL,
  is_completed BOOLEAN DEFAULT false NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Table des Affiliations (Lien Parent/Enfant)
CREATE TABLE IF NOT EXISTS public.affiliations (
  adult_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  child_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  is_super_admin BOOLEAN DEFAULT false NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (adult_id, child_id)
);

-- Activation du RLS pour toutes les tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.affiliations ENABLE ROW LEVEL SECURITY;
