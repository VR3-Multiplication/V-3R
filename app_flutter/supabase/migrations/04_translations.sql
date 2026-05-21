-- ==========================================================
-- 04_TRANSLATIONS.SQL (VERSION COMPLÈTE)
-- Dictionnaire multilingue complet (FR, EN, WOLOF)
-- ==========================================================

CREATE TABLE IF NOT EXISTS public.translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT NOT NULL,
    language_code TEXT NOT NULL,
    value TEXT NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(key, language_code)
);

ALTER TABLE public.translations ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------
-- INSERTIONS / UPDATES
-- ----------------------------------------------------------

INSERT INTO public.translations (key, language_code, value) VALUES
-- Français
('math_runner', 'fr', 'Math Runner'),
('who_is_playing', 'fr', 'Qui joue aujourd''hui ?'),
('i_am_student', 'fr', 'Je suis un Élève'),
('i_am_adult', 'fr', 'Je suis un Adulte'),
('i_am_parent', 'fr', 'Je suis un Parent'),
('i_am_teacher', 'fr', 'Je suis un Enseignant'),
('pin_helper', 'fr', '6 chiffres minimum'),
('garage_title', 'fr', 'Mon Garage'),
('mon_pseudo', 'fr', 'Mon Pseudo'),
('mon_code_secret', 'fr', 'Mon Code Secret'),
('bon_retour', 'fr', 'Bon retour !'),
('creer_profil', 'fr', 'Créer mon profil'),
('dashboard_title', 'fr', 'Espace Parents'),
('child_dashboard_title', 'fr', 'Mon Espace'),
('ready_for_adventure', 'fr', 'Prêt pour l''aventure ?'),
('no_challenge', 'fr', 'Pas de défi pour l''instant'),
('free_play_description', 'fr', 'Entraîne-toi librement en attendant tes missions !'),
('free_play_mode', 'fr', 'Mode Libre'),

-- English
('math_runner', 'en', 'Math Runner'),
('who_is_playing', 'en', 'Who is playing today ?'),
('i_am_student', 'en', 'I am a Student'),
('i_am_adult', 'en', 'I am an Adult'),
('i_am_parent', 'en', 'I am a Parent'),
('i_am_teacher', 'en', 'I am a Teacher'),
('pin_helper', 'en', '6 digits minimum'),
('garage_title', 'en', 'My Garage'),
('mon_pseudo', 'en', 'My Nickname'),
('mon_code_secret', 'en', 'My Secret Code'),
('bon_retour', 'en', 'Welcome back !'),
('creer_profil', 'en', 'Create my profile'),
('dashboard_title', 'en', 'Parents Space'),
('child_dashboard_title', 'en', 'My Space'),
('ready_for_adventure', 'en', 'Ready for adventure ?'),
('no_challenge', 'en', 'No challenge yet'),
('free_play_description', 'en', 'Practice freely while waiting for your missions !'),
('free_play_mode', 'en', 'Free Play'),

-- Wolof
('math_runner', 'wolof', 'Math Runner'),
('who_is_playing', 'wolof', 'Kañ moy fowé tay ?'),
('i_am_student', 'wolof', 'Elew la'),
('i_am_adult', 'wolof', 'Mag la'),
('i_am_parent', 'wolof', 'Waajur la'),
('i_am_teacher', 'wolof', 'Jangalekat la'),
('pin_helper', 'wolof', '6 bind minimum'),
('garage_title', 'wolof', 'Sama Garage'),
('mon_pseudo', 'wolof', 'Sama Pseudo'),
('mon_code_secret', 'wolof', 'Sama Code Secret'),
('bon_retour', 'wolof', 'Dalal ak djam !'),
('creer_profil', 'wolof', 'Sama Profil'),
('dashboard_title', 'wolof', 'Espace Waajur'),
('child_dashboard_title', 'wolof', 'Sama Boor'),
('ready_for_adventure', 'wolof', 'Paré nga ?'),
('no_challenge', 'wolof', 'Amoul défi tay'),
('free_play_description', 'wolof', 'Entraînel ba sa mission dikk !'),
('free_play_mode', 'wolof', 'Fowé doundou')

ON CONFLICT (key, language_code) DO UPDATE SET value = EXCLUDED.value;
