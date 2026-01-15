-- Location: supabase/migrations/20260115195742_batfinder_complete_schema.sql
-- Schema Analysis: Fresh database - creating complete BatFinder security app schema
-- Integration Type: Complete new schema with authentication and role-based access
-- Dependencies: None (fresh project)

-- ==============================================
-- 1. TYPES AND ENUMS
-- ==============================================

-- User role types
CREATE TYPE public.user_role AS ENUM ('ciudadano', 'autoridad', 'ONG');

-- Incident severity levels
CREATE TYPE public.incident_severity AS ENUM ('low', 'medium', 'high', 'critical');

-- Incident status
CREATE TYPE public.incident_status AS ENUM ('pending', 'verified', 'in_progress', 'resolved', 'rejected');

-- Verification status for authority users
CREATE TYPE public.verification_status AS ENUM ('pending', 'verified', 'rejected');

-- ==============================================
-- 2. CORE TABLES
-- ==============================================

-- User profiles (intermediary table for PostgREST compatibility)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone_number TEXT,
    role public.user_role NOT NULL DEFAULT 'ciudadano'::public.user_role,
    organization_name TEXT,
    verification_status public.verification_status DEFAULT 'pending'::public.verification_status,
    verification_document_url TEXT,
    is_verified BOOLEAN DEFAULT false,
    profile_image_url TEXT,
    location_lat DOUBLE PRECISION,
    location_lng DOUBLE PRECISION,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Incidents table
CREATE TABLE public.incidents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    incident_type TEXT NOT NULL,
    severity public.incident_severity NOT NULL DEFAULT 'medium'::public.incident_severity,
    status public.incident_status NOT NULL DEFAULT 'pending'::public.incident_status,
    is_anonymous BOOLEAN DEFAULT false,
    location_lat DOUBLE PRECISION NOT NULL,
    location_lng DOUBLE PRECISION NOT NULL,
    location_address TEXT,
    occurred_at TIMESTAMPTZ NOT NULL,
    reported_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    verified_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    verified_at TIMESTAMPTZ,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Incident media (photos/videos)
CREATE TABLE public.incident_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_id UUID REFERENCES public.incidents(id) ON DELETE CASCADE,
    media_url TEXT NOT NULL,
    media_type TEXT NOT NULL CHECK (media_type IN ('image', 'video')),
    caption TEXT,
    uploaded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Incident comments
CREATE TABLE public.incident_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_id UUID REFERENCES public.incidents(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Chat rooms (community chat)
CREATE TABLE public.chat_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT true,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Chat participants
CREATE TABLE public.chat_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chat_room_id UUID REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(chat_room_id, user_id)
);

-- Chat messages
CREATE TABLE public.chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chat_room_id UUID REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    message_text TEXT NOT NULL,
    sent_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Alert statistics (for dashboard)
CREATE TABLE public.alert_statistics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date DATE NOT NULL UNIQUE,
    total_incidents INTEGER DEFAULT 0,
    pending_incidents INTEGER DEFAULT 0,
    verified_incidents INTEGER DEFAULT 0,
    resolved_incidents INTEGER DEFAULT 0,
    average_response_time_minutes INTEGER DEFAULT 0,
    safety_score DECIMAL(5,2) DEFAULT 0.0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- User activity logs
CREATE TABLE public.user_activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    activity_type TEXT NOT NULL,
    activity_details JSONB,
    ip_address TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================
-- 3. INDEXES FOR PERFORMANCE
-- ==============================================

CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_incidents_reporter_id ON public.incidents(reporter_id);
CREATE INDEX idx_incidents_status ON public.incidents(status);
CREATE INDEX idx_incidents_severity ON public.incidents(severity);
CREATE INDEX idx_incidents_location ON public.incidents(location_lat, location_lng);
CREATE INDEX idx_incidents_occurred_at ON public.incidents(occurred_at);
CREATE INDEX idx_incident_media_incident_id ON public.incident_media(incident_id);
CREATE INDEX idx_incident_comments_incident_id ON public.incident_comments(incident_id);
CREATE INDEX idx_chat_participants_room_id ON public.chat_participants(chat_room_id);
CREATE INDEX idx_chat_participants_user_id ON public.chat_participants(user_id);
CREATE INDEX idx_chat_messages_room_id ON public.chat_messages(chat_room_id);
CREATE INDEX idx_chat_messages_sender_id ON public.chat_messages(sender_id);

-- ==============================================
-- 4. FUNCTIONS (MUST BE BEFORE RLS POLICIES)
-- ==============================================

-- Function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $func$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role, phone_number, organization_name, profile_image_url)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'ciudadano'::public.user_role),
    NEW.raw_user_meta_data->>'phone_number',
    NEW.raw_user_meta_data->>'organization_name',
    NEW.raw_user_meta_data->>'profile_image_url'
  );
  RETURN NEW;
END;
$func$;

-- Function to check if user is authority
CREATE OR REPLACE FUNCTION public.is_authority()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $func$
  SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() 
    AND up.role = 'autoridad'::public.user_role
    AND up.is_verified = true
  )
$func$;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $func$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$func$;

-- ==============================================
-- 5. ENABLE ROW LEVEL SECURITY
-- ==============================================

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.incidents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.incident_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.incident_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alert_statistics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_activity_logs ENABLE ROW LEVEL SECURITY;

-- ==============================================
-- 6. RLS POLICIES
-- ==============================================

-- User profiles policies (Pattern 1: Core user table)
CREATE POLICY "users_view_all_profiles"
ON public.user_profiles
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "users_update_own_profile"
ON public.user_profiles
FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Incidents policies
CREATE POLICY "users_view_all_incidents"
ON public.incidents
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "users_create_own_incidents"
ON public.incidents
FOR INSERT
TO authenticated
WITH CHECK (reporter_id = auth.uid());

CREATE POLICY "users_update_own_incidents"
ON public.incidents
FOR UPDATE
TO authenticated
USING (reporter_id = auth.uid())
WITH CHECK (reporter_id = auth.uid());

CREATE POLICY "authority_verify_incidents"
ON public.incidents
FOR UPDATE
TO authenticated
USING (public.is_authority())
WITH CHECK (public.is_authority());

-- Incident media policies
CREATE POLICY "users_view_incident_media"
ON public.incident_media
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "users_add_media_to_own_incidents"
ON public.incident_media
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.incidents i
    WHERE i.id = incident_id AND i.reporter_id = auth.uid()
  )
);

-- Incident comments policies
CREATE POLICY "users_view_all_comments"
ON public.incident_comments
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "users_create_comments"
ON public.incident_comments
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_update_own_comments"
ON public.incident_comments
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_delete_own_comments"
ON public.incident_comments
FOR DELETE
TO authenticated
USING (user_id = auth.uid());

-- Chat rooms policies
CREATE POLICY "users_view_all_chat_rooms"
ON public.chat_rooms
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "users_create_chat_rooms"
ON public.chat_rooms
FOR INSERT
TO authenticated
WITH CHECK (created_by = auth.uid());

-- Chat participants policies
CREATE POLICY "users_view_chat_participants"
ON public.chat_participants
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "users_join_chat_rooms"
ON public.chat_participants
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- Chat messages policies
CREATE POLICY "participants_view_chat_messages"
ON public.chat_messages
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.chat_participants cp
    WHERE cp.chat_room_id = chat_messages.chat_room_id 
    AND cp.user_id = auth.uid()
  )
);

CREATE POLICY "participants_send_messages"
ON public.chat_messages
FOR INSERT
TO authenticated
WITH CHECK (
  sender_id = auth.uid() AND
  EXISTS (
    SELECT 1 FROM public.chat_participants cp
    WHERE cp.chat_room_id = chat_messages.chat_room_id 
    AND cp.user_id = auth.uid()
  )
);

-- Alert statistics policies (read-only for all authenticated users)
CREATE POLICY "users_view_statistics"
ON public.alert_statistics
FOR SELECT
TO authenticated
USING (true);

-- User activity logs policies
CREATE POLICY "users_view_own_activity"
ON public.user_activity_logs
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "system_create_activity_logs"
ON public.user_activity_logs
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- ==============================================
-- 7. TRIGGERS
-- ==============================================

-- Trigger for new user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Triggers for updated_at columns
CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_incidents_updated_at
  BEFORE UPDATE ON public.incidents
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_incident_comments_updated_at
  BEFORE UPDATE ON public.incident_comments
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- ==============================================
-- 8. MOCK DATA FOR MVP TESTING
-- ==============================================

DO $$
DECLARE
    ciudadano_id UUID := gen_random_uuid();
    autoridad_id UUID := gen_random_uuid();
    ong_id UUID := gen_random_uuid();
    incident1_id UUID := gen_random_uuid();
    incident2_id UUID := gen_random_uuid();
    chat_room_id UUID := gen_random_uuid();
BEGIN
    -- Create mock auth users with complete field structure
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        -- Ciudadano user
        (ciudadano_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'ciudadano@batfinder.com', crypt('ciudadano123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Juan Pérez", "phone_number": "+52 55 1234 5678", "role": "ciudadano"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        
        -- Autoridad user
        (autoridad_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'autoridad@policia.mx', crypt('autoridad123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "María González", "phone_number": "+52 55 8765 4321", "role": "autoridad", "organization_name": "Policía Municipal"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        
        -- ONG user
        (ong_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'contacto@seguridadciudadana.org', crypt('ong123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Carlos Ramírez", "phone_number": "+52 55 2468 1357", "role": "ONG", "organization_name": "Seguridad Ciudadana A.C."}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Update autoridad user as verified
    UPDATE public.user_profiles
    SET is_verified = true, verification_status = 'verified'::public.verification_status
    WHERE id = autoridad_id;

    -- Create mock incidents
    INSERT INTO public.incidents (id, reporter_id, title, description, incident_type, severity, status, location_lat, location_lng, location_address, occurred_at)
    VALUES
        (incident1_id, ciudadano_id, 'Robo en la Colonia Centro', 'Se reporta un robo a mano armada en la esquina de Av. Juárez y Reforma', 'robo', 'high'::public.incident_severity, 'pending'::public.incident_status, 19.4326, -99.1332, 'Av. Juárez esquina con Reforma, Centro', now() - interval '2 hours'),
        (incident2_id, ong_id, 'Alumbrado público dañado', 'Las luces de la calle están apagadas, zona peligrosa por la noche', 'infraestructura', 'medium'::public.incident_severity, 'verified'::public.incident_status, 19.4285, -99.1277, 'Calle Morelos #45, Centro', now() - interval '1 day');

    -- Verify one incident
    UPDATE public.incidents
    SET verified_by = autoridad_id, verified_at = now(), status = 'verified'::public.incident_status
    WHERE id = incident2_id;

    -- Create mock incident media
    INSERT INTO public.incident_media (incident_id, media_url, media_type, caption)
    VALUES
        (incident1_id, 'https://images.unsplash.com/photo-1590736704728-f4730bb30770', 'image', 'Evidencia del lugar del incidente'),
        (incident2_id, 'https://images.unsplash.com/photo-1519677100203-a0e668c92439', 'image', 'Postes de luz dañados');

    -- Create mock comments
    INSERT INTO public.incident_comments (incident_id, user_id, comment_text)
    VALUES
        (incident1_id, autoridad_id, 'Unidad despachada al lugar. Se está investigando.'),
        (incident2_id, ong_id, 'Gracias por el reporte. Hemos contactado al municipio.');

    -- Create community chat room
    INSERT INTO public.chat_rooms (id, name, description, is_public, created_by)
    VALUES (chat_room_id, 'Seguridad Colonia Centro', 'Chat comunitario para reportar y discutir temas de seguridad', true, ong_id);

    -- Add participants to chat room
    INSERT INTO public.chat_participants (chat_room_id, user_id)
    VALUES
        (chat_room_id, ciudadano_id),
        (chat_room_id, autoridad_id),
        (chat_room_id, ong_id);

    -- Add sample messages
    INSERT INTO public.chat_messages (chat_room_id, sender_id, message_text)
    VALUES
        (chat_room_id, ong_id, 'Bienvenidos al chat de seguridad comunitaria'),
        (chat_room_id, ciudadano_id, 'Gracias por crear este espacio'),
        (chat_room_id, autoridad_id, 'Estamos aquí para ayudar a mantener la comunidad segura');

    -- Create initial statistics
    INSERT INTO public.alert_statistics (date, total_incidents, pending_incidents, verified_incidents, safety_score)
    VALUES
        (CURRENT_DATE, 2, 1, 1, 75.5),
        (CURRENT_DATE - interval '1 day', 5, 2, 3, 72.8);

END $$;