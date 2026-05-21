-- ==========================================================
-- 09_ADD_CLASSES.SQL
-- Crée les structures nécessaires pour la gestion des classes par les enseignants
-- ==========================================================

-- Table pour les classes créées par un enseignant
CREATE TABLE IF NOT EXISTS public.classes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name text NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  CONSTRAINT unique_teacher_class_name UNIQUE(teacher_id, name)
);

-- RLS sur les classes
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Lect_Classes" ON public.classes;
CREATE POLICY "Lect_Classes" ON public.classes FOR SELECT USING (
  auth.uid() = teacher_id OR 
  EXISTS (
    SELECT 1 FROM public.affiliations 
    WHERE affiliations.child_id = auth.uid() AND affiliations.adult_id = classes.teacher_id
  )
);

DROP POLICY IF EXISTS "Mod_Classes" ON public.classes;
CREATE POLICY "Mod_Classes" ON public.classes FOR ALL USING (auth.uid() = teacher_id);

-- Table de liaison entre les classes et les élèves (enfants)
CREATE TABLE IF NOT EXISTS public.class_students (
  class_id uuid NOT NULL REFERENCES public.classes(id) ON DELETE CASCADE,
  student_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  PRIMARY KEY (class_id, student_id)
);

-- RLS sur les élèves des classes
ALTER TABLE public.class_students ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Lect_Class_Students" ON public.class_students;
CREATE POLICY "Lect_Class_Students" ON public.class_students FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.classes 
    WHERE classes.id = class_students.class_id AND (
      classes.teacher_id = auth.uid() OR class_students.student_id = auth.uid()
    )
  )
);

DROP POLICY IF EXISTS "Mod_Class_Students" ON public.class_students;
CREATE POLICY "Mod_Class_Students" ON public.class_students FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.classes 
    WHERE classes.id = class_students.class_id AND classes.teacher_id = auth.uid()
  )
);
