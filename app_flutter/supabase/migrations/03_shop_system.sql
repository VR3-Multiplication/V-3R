-- ==========================================================
-- 03_SHOP_SYSTEM.SQL
-- Boutique et Inventaire des voitures
-- ==========================================================

-- Table des objets
CREATE TABLE IF NOT EXISTS public.shop_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    price INTEGER NOT NULL,
    image_url TEXT,
    category TEXT DEFAULT 'car',
    unity_id TEXT NOT NULL UNIQUE
);

-- Table de l'inventaire
CREATE TABLE IF NOT EXISTS public.child_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    item_id UUID REFERENCES public.shop_items(id) ON DELETE CASCADE,
    is_equipped BOOLEAN DEFAULT false,
    UNIQUE(child_id, item_id)
);

ALTER TABLE public.shop_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.child_inventory ENABLE ROW LEVEL SECURITY;

-- Insertion des voitures de base
INSERT INTO public.shop_items (name, price, unity_id, description) VALUES
('Fulguro-Rouge', 0, 'car_red', 'Ta première voiture de course !'),
('L''Éclair Bleu', 50, 'car_blue', 'Rapide comme l''éclair.'),
('Le Tank Vert', 100, 'car_green', 'Rien ne l''arrête.'),
('La Cyber-Jaune', 250, 'car_yellow', 'Le futur de la vitesse.')
ON CONFLICT (unity_id) DO NOTHING;
