-- Location: supabase/migrations/20250711070000_quadzen_with_auth.sql
-- Complete Quadzen database schema with authentication

-- 1. Types and Enums
CREATE TYPE public.user_role AS ENUM ('admin', 'student', 'teacher');
CREATE TYPE public.task_type AS ENUM ('task', 'event', 'note');
CREATE TYPE public.task_status AS ENUM ('todo', 'in_progress', 'completed', 'migrated', 'canceled');
CREATE TYPE public.habit_frequency AS ENUM ('daily', 'weekly', 'monthly');
CREATE TYPE public.mood_level AS ENUM ('very_sad', 'sad', 'neutral', 'happy', 'very_happy');
CREATE TYPE public.assignment_status AS ENUM ('pending', 'in_progress', 'submitted', 'graded');
CREATE TYPE public.reflection_period AS ENUM ('daily', 'weekly', 'monthly');

-- 2. User Profiles (Critical intermediary table)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    username TEXT UNIQUE,
    role public.user_role DEFAULT 'student'::public.user_role,
    avatar_url TEXT,
    preferences JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Collections (Custom pages system)
CREATE TABLE public.collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    content TEXT,
    tags TEXT[],
    is_template BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Tasks (Bullet Journal entries)
CREATE TABLE public.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    collection_id UUID REFERENCES public.collections(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    task_type public.task_type DEFAULT 'task'::public.task_type,
    status public.task_status DEFAULT 'todo'::public.task_status,
    priority INTEGER DEFAULT 1 CHECK (priority >= 1 AND priority <= 5),
    due_date TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    migrated_from_date DATE,
    tags TEXT[],
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Habits System
CREATE TABLE public.habits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    frequency public.habit_frequency DEFAULT 'daily'::public.habit_frequency,
    target_count INTEGER DEFAULT 1,
    color_hex TEXT DEFAULT '#6200EE',
    icon_name TEXT DEFAULT 'check_circle',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.habit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    habit_id UUID REFERENCES public.habits(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    count INTEGER DEFAULT 1,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(habit_id, date)
);

-- 6. Mood Tracking
CREATE TABLE public.mood_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    mood_level public.mood_level NOT NULL,
    notes TEXT,
    energy_level INTEGER CHECK (energy_level >= 1 AND energy_level <= 10),
    sleep_hours NUMERIC(4,2),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, date)
);

-- 7. Academic System
CREATE TABLE public.courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    code TEXT,
    instructor TEXT,
    credits INTEGER,
    semester TEXT,
    color_hex TEXT DEFAULT '#2196F3',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    due_date TIMESTAMPTZ,
    submitted_date TIMESTAMPTZ,
    grade TEXT,
    max_points NUMERIC(5,2),
    earned_points NUMERIC(5,2),
    status public.assignment_status DEFAULT 'pending'::public.assignment_status,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 8. Reflection System
CREATE TABLE public.reflections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    period public.reflection_period NOT NULL,
    date DATE NOT NULL,
    prompts JSONB,
    responses JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, period, date)
);

-- 9. Events (Calendar system)
CREATE TABLE public.events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    location TEXT,
    is_all_day BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 10. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_collections_user_id ON public.collections(user_id);
CREATE INDEX idx_tasks_user_id ON public.tasks(user_id);
CREATE INDEX idx_tasks_due_date ON public.tasks(due_date);
CREATE INDEX idx_tasks_status ON public.tasks(status);
CREATE INDEX idx_habits_user_id ON public.habits(user_id);
CREATE INDEX idx_habit_logs_habit_id ON public.habit_logs(habit_id);
CREATE INDEX idx_habit_logs_date ON public.habit_logs(date);
CREATE INDEX idx_mood_entries_user_id ON public.mood_entries(user_id);
CREATE INDEX idx_mood_entries_date ON public.mood_entries(date);
CREATE INDEX idx_courses_user_id ON public.courses(user_id);
CREATE INDEX idx_assignments_course_id ON public.assignments(course_id);
CREATE INDEX idx_assignments_due_date ON public.assignments(due_date);
CREATE INDEX idx_reflections_user_id ON public.reflections(user_id);
CREATE INDEX idx_events_user_id ON public.events(user_id);
CREATE INDEX idx_events_start_time ON public.events(start_time);

-- 11. RLS Setup
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mood_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reflections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

-- 12. Helper Functions
CREATE OR REPLACE FUNCTION public.is_habit_owner(habit_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.habits h
    WHERE h.id = habit_uuid AND h.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.can_access_habit_log(log_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.habit_logs hl
    JOIN public.habits h ON hl.habit_id = h.id
    WHERE hl.id = log_uuid AND h.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.is_course_owner(course_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.courses c
    WHERE c.id = course_uuid AND c.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.can_access_assignment(assignment_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.assignments a
    JOIN public.courses c ON a.course_id = c.id
    WHERE a.id = assignment_uuid AND c.user_id = auth.uid()
)
$$;

-- Function for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'student')::public.user_role
  );
  RETURN NEW;
END;
$$;

-- Trigger for new user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 13. RLS Policies
CREATE POLICY "users_own_profile" ON public.user_profiles FOR ALL
USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

CREATE POLICY "users_manage_collections" ON public.collections FOR ALL
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_manage_tasks" ON public.tasks FOR ALL
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_manage_habits" ON public.habits FOR ALL
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_access_habit_logs" ON public.habit_logs FOR ALL
USING (public.can_access_habit_log(id)) WITH CHECK (public.can_access_habit_log(id));

CREATE POLICY "users_manage_mood_entries" ON public.mood_entries FOR ALL
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_manage_courses" ON public.courses FOR ALL
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_access_assignments" ON public.assignments FOR ALL
USING (public.can_access_assignment(id)) WITH CHECK (public.can_access_assignment(id));

CREATE POLICY "users_manage_reflections" ON public.reflections FOR ALL
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_manage_events" ON public.events FOR ALL
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 14. Complete Mock Data
DO $$
DECLARE
    student_uuid UUID := gen_random_uuid();
    teacher_uuid UUID := gen_random_uuid();
    collection_uuid UUID := gen_random_uuid();
    habit1_uuid UUID := gen_random_uuid();
    habit2_uuid UUID := gen_random_uuid();
    course_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users with complete field structure
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (student_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'student@quadzen.com', crypt('QuadZen2024!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Alex Johnson", "role": "student"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (teacher_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'teacher@quadzen.com', crypt('QuadZen2024!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Dr. Sarah Wilson", "role": "teacher"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create collections
    INSERT INTO public.collections (id, user_id, title, description, tags) VALUES
        (collection_uuid, student_uuid, 'Study Goals', 'My academic goals and progress tracking', 
         ARRAY['academic', 'goals', 'planning']);

    -- Create tasks
    INSERT INTO public.tasks (user_id, collection_id, title, task_type, status, priority, due_date, tags) VALUES
        (student_uuid, collection_uuid, 'Review Flutter documentation', 'task'::public.task_type, 
         'completed'::public.task_status, 2, now() + interval '1 day', ARRAY['flutter', 'study']),
        (student_uuid, collection_uuid, 'Complete math assignment', 'task'::public.task_type, 
         'in_progress'::public.task_status, 3, now() + interval '3 days', ARRAY['math', 'homework']),
        (student_uuid, collection_id, 'Team meeting at 3 PM', 'event'::public.task_type, 
         'todo'::public.task_status, 1, now() + interval '2 hours', ARRAY['meeting', 'team']);

    -- Create habits
    INSERT INTO public.habits (id, user_id, title, description, frequency, target_count, color_hex, icon_name) VALUES
        (habit1_uuid, student_uuid, 'Morning Exercise', 'Daily morning workout routine', 
         'daily'::public.habit_frequency, 1, '#4CAF50', 'fitness_center'),
        (habit2_uuid, student_uuid, 'Read 30 minutes', 'Daily reading habit for personal growth', 
         'daily'::public.habit_frequency, 30, '#2196F3', 'menu_book');

    -- Create habit logs
    INSERT INTO public.habit_logs (habit_id, date, count) VALUES
        (habit1_uuid, CURRENT_DATE, 1),
        (habit1_uuid, CURRENT_DATE - interval '1 day', 1),
        (habit2_uuid, CURRENT_DATE, 30),
        (habit2_uuid, CURRENT_DATE - interval '1 day', 25);

    -- Create mood entries
    INSERT INTO public.mood_entries (user_id, date, mood_level, energy_level, sleep_hours) VALUES
        (student_uuid, CURRENT_DATE, 'happy'::public.mood_level, 8, 7.5),
        (student_uuid, CURRENT_DATE - interval '1 day', 'neutral'::public.mood_level, 6, 6.0);

    -- Create courses
    INSERT INTO public.courses (id, user_id, name, code, instructor, credits, semester, color_hex) VALUES
        (course_uuid, student_uuid, 'Computer Science Fundamentals', 'CS101', 'Dr. Smith', 3, 'Fall 2024', '#9C27B0');

    -- Create assignments
    INSERT INTO public.assignments (course_id, title, description, due_date, max_points, status) VALUES
        (course_uuid, 'Algorithm Analysis Project', 'Analyze time complexity of sorting algorithms', 
         now() + interval '7 days', 100.00, 'pending'::public.assignment_status);

    -- Create events
    INSERT INTO public.events (user_id, title, description, start_time, end_time, location) VALUES
        (student_uuid, 'Study Group Session', 'Weekly study group for CS fundamentals', 
         now() + interval '2 days', now() + interval '2 days' + interval '2 hours', 'Library Room 204');

    -- Create reflections
    INSERT INTO public.reflections (user_id, period, date, prompts, responses) VALUES
        (student_uuid, 'weekly'::public.reflection_period, CURRENT_DATE, 
         '{"questions": ["What did I accomplish this week?", "What challenges did I face?"]}'::jsonb,
         '{"responses": ["Completed Flutter project", "Time management with multiple assignments"]}'::jsonb);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 15. Cleanup function
CREATE OR REPLACE FUNCTION public.cleanup_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    auth_user_ids_to_delete UUID[];
BEGIN
    -- Get auth user IDs first
    SELECT ARRAY_AGG(id) INTO auth_user_ids_to_delete
    FROM auth.users
    WHERE email LIKE '%@quadzen.com';

    -- Delete in dependency order (children first, then auth.users last)
    DELETE FROM public.habit_logs WHERE habit_id IN (
        SELECT id FROM public.habits WHERE user_id = ANY(auth_user_ids_to_delete)
    );
    DELETE FROM public.assignments WHERE course_id IN (
        SELECT id FROM public.courses WHERE user_id = ANY(auth_user_ids_to_delete)
    );
    DELETE FROM public.tasks WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.habits WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.mood_entries WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.courses WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.reflections WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.events WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.collections WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.user_profiles WHERE id = ANY(auth_user_ids_to_delete);

    -- Delete auth.users last (after all references are removed)
    DELETE FROM auth.users WHERE id = ANY(auth_user_ids_to_delete);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;