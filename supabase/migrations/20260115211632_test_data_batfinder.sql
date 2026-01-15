-- BatFinder Test Data Migration
-- Purpose: Add comprehensive test data for maps, alerts, and user profiles
-- Created: 2026-01-15
-- Fix: Resolved ON CONFLICT error by removing invalid constraint reference

-- =============================================
-- SECTION 1: Create Auth Users First (Required for FK Constraint)
-- =============================================

DO $$
DECLARE
    maria_id UUID := 'd8b2c4e5-9a7f-4d2b-8c3e-1f6a5b9d7e2c';
    roberto_id UUID := 'f3a1b5c7-2d4e-6f8a-9b1c-3e5d7f9a2c4b';
    comandante_id UUID := 'e5d7c9a2-4b6f-8e1a-3c5d-7f9b2a4c6e8d';
    director_id UUID := 'a7c9b3d5-6e8f-1a2b-4c6d-8e9f2a3b5c7d';
    ana_id UUID := 'c2d4e6f8-9a1b-3c5d-7e9f-2a4b6c8d9e1f';
BEGIN
    -- Create auth users first (this triggers user_profiles creation via trigger)
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        -- Maria Garcia - Ciudadano
        (maria_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'maria.garcia@example.com', crypt('maria123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "María García López", "phone_number": "+52 55 9876 5432", "role": "ciudadano"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        
        -- Roberto Martinez - Ciudadano
        (roberto_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'roberto.martinez@example.com', crypt('roberto123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Roberto Martínez", "phone_number": "+52 55 3456 7890", "role": "ciudadano"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        
        -- Comandante Lopez - Autoridad
        (comandante_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'policia.cdmx@gobierno.mx', crypt('comandante123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Comandante López", "phone_number": "+52 55 0800 1234", "role": "autoridad", "organization_name": "Policía CDMX"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        
        -- Director Garcia - Autoridad
        (director_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'proteccion.civil@gobierno.mx', crypt('director123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Director García", "phone_number": "+52 55 0800 5678", "role": "autoridad", "organization_name": "Protección Civil"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        
        -- Ana Rodriguez - ONG
        (ana_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'info@seguridadcomunitaria.org', crypt('ana123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Ana Rodríguez", "phone_number": "+52 55 7890 1234", "role": "ONG", "organization_name": "Seguridad Comunitaria MX"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null)
    ON CONFLICT (id) DO NOTHING;

    -- Update user profiles with additional location data
    UPDATE public.user_profiles
    SET 
        location_lat = 19.4200,
        location_lng = -99.1400,
        is_verified = true,
        verification_status = 'verified'::public.verification_status
    WHERE id = maria_id;

    UPDATE public.user_profiles
    SET 
        location_lat = 19.4500,
        location_lng = -99.1200,
        is_verified = true,
        verification_status = 'verified'::public.verification_status
    WHERE id = roberto_id;

    UPDATE public.user_profiles
    SET 
        location_lat = 19.4326,
        location_lng = -99.1332,
        is_verified = true,
        verification_status = 'verified'::public.verification_status
    WHERE id = comandante_id;

    UPDATE public.user_profiles
    SET 
        location_lat = 19.4285,
        location_lng = -99.1277,
        is_verified = true,
        verification_status = 'verified'::public.verification_status
    WHERE id = director_id;

    UPDATE public.user_profiles
    SET 
        location_lat = 19.4400,
        location_lng = -99.1300,
        is_verified = true,
        verification_status = 'verified'::public.verification_status
    WHERE id = ana_id;

END $$;

-- =============================================
-- SECTION 2: More Incidents with Diverse Locations
-- =============================================

INSERT INTO public.incidents (
  title,
  description,
  incident_type,
  severity,
  status,
  location_lat,
  location_lng,
  location_address,
  occurred_at,
  reported_at,
  reporter_id,
  is_anonymous,
  verified_by,
  verified_at
)
VALUES
  -- Recent critical incidents
  (
    'Asalto armado en zona comercial',
    'Grupo de personas armadas asaltó tienda departamental. Varios heridos reportados.',
    'asalto',
    'critical',
    'verified',
    19.4350,
    -99.1250,
    'Plaza Comercial Centro, Av. Insurgentes',
    NOW() - INTERVAL '2 hours',
    NOW() - INTERVAL '2 hours',
    'd8b2c4e5-9a7f-4d2b-8c3e-1f6a5b9d7e2c',
    false,
    'e5d7c9a2-4b6f-8e1a-3c5d-7f9b2a4c6e8d',
    NOW() - INTERVAL '1 hour'
  ),
  (
    'Vandalismo en transporte público',
    'Autobús vandalizado con grafiti. Vidrios rotos.',
    'vandalismo',
    'medium',
    'in_progress',
    19.4280,
    -99.1350,
    'Parada de autobús, Calle Morelos',
    NOW() - INTERVAL '5 hours',
    NOW() - INTERVAL '4 hours',
    'f3a1b5c7-2d4e-6f8a-9b1c-3e5d7f9a2c4b',
    false,
    'e5d7c9a2-4b6f-8e1a-3c5d-7f9b2a4c6e8d',
    NOW() - INTERVAL '3 hours'
  ),
  (
    'Fuga de agua en calle principal',
    'Tubería rota causando inundación. Tráfico afectado.',
    'infraestructura',
    'high',
    'verified',
    19.4400,
    -99.1280,
    'Av. Reforma esquina con Insurgentes',
    NOW() - INTERVAL '6 hours',
    NOW() - INTERVAL '6 hours',
    'd8b2c4e5-9a7f-4d2b-8c3e-1f6a5b9d7e2c',
    false,
    'a7c9b3d5-6e8f-1a2b-4c6d-8e9f2a3b5c7d',
    NOW() - INTERVAL '5 hours'
  ),
  -- Pending incidents
  (
    'Robo de vehículo',
    'Automóvil sustraído durante la madrugada. Placas reportadas.',
    'robo',
    'high',
    'pending',
    19.4450,
    -99.1320,
    'Estacionamiento Colonia Roma',
    NOW() - INTERVAL '12 hours',
    NOW() - INTERVAL '10 hours',
    'f3a1b5c7-2d4e-6f8a-9b1c-3e5d7f9a2c4b',
    false,
    NULL,
    NULL
  ),
  (
    'Accidente de tránsito menor',
    'Choque entre dos vehículos. Sin heridos graves.',
    'accidente',
    'low',
    'resolved',
    19.4380,
    -99.1380,
    'Crucero Av. Universidad',
    NOW() - INTERVAL '8 hours',
    NOW() - INTERVAL '8 hours',
    'd8b2c4e5-9a7f-4d2b-8c3e-1f6a5b9d7e2c',
    false,
    'e5d7c9a2-4b6f-8e1a-3c5d-7f9b2a4c6e8d',
    NOW() - INTERVAL '6 hours'
  ),
  -- Anonymous reports
  (
    'Sospechosa actividad nocturna',
    'Grupo de personas con comportamiento sospechoso en la zona.',
    'otro',
    'medium',
    'pending',
    19.4320,
    -99.1420,
    'Parque Central, Área Norte',
    NOW() - INTERVAL '1 day',
    NOW() - INTERVAL '1 day',
    NULL,
    true,
    NULL,
    NULL
  ),
  (
    'Iluminación deficiente',
    'Múltiples postes de luz sin funcionar. Zona oscura y peligrosa.',
    'infraestructura',
    'medium',
    'pending',
    19.4260,
    -99.1260,
    'Calle Hidalgo entre 5 de Mayo y Juárez',
    NOW() - INTERVAL '2 days',
    NOW() - INTERVAL '2 days',
    'c2d4e6f8-9a1b-3c5d-7e9f-2a4b6c8d9e1f',
    false,
    NULL,
    NULL
  );

-- =============================================
-- SECTION 3: Incident Media for New Incidents
-- =============================================

-- Get incident IDs for media insertion
DO $$
DECLARE
  v_incident_id UUID;
BEGIN
  -- Add media to recent incidents
  SELECT id INTO v_incident_id FROM public.incidents WHERE title = 'Asalto armado en zona comercial';
  IF v_incident_id IS NOT NULL THEN
    INSERT INTO public.incident_media (incident_id, media_url, media_type, caption)
    VALUES 
      (v_incident_id, 'https://images.pexels.com/photos/8460157/pexels-photo-8460157.jpeg', 'image', 'Evidencia del lugar del incidente'),
      (v_incident_id, 'https://images.pexels.com/photos/6802042/pexels-photo-6802042.jpeg', 'image', 'Vista general de la zona');
  END IF;

  SELECT id INTO v_incident_id FROM public.incidents WHERE title = 'Vandalismo en transporte público';
  IF v_incident_id IS NOT NULL THEN
    INSERT INTO public.incident_media (incident_id, media_url, media_type, caption)
    VALUES 
      (v_incident_id, 'https://images.pexels.com/photos/3671151/pexels-photo-3671151.jpeg', 'image', 'Daños en el autobús');
  END IF;

  SELECT id INTO v_incident_id FROM public.incidents WHERE title = 'Fuga de agua en calle principal';
  IF v_incident_id IS NOT NULL THEN
    INSERT INTO public.incident_media (incident_id, media_url, media_type, caption)
    VALUES 
      (v_incident_id, 'https://images.pixabay.com/photo/2016/03/27/18/47/water-1283795_1280.jpg', 'image', 'Inundación en la calle');
  END IF;
END $$;

-- =============================================
-- SECTION 4: Additional Hotspots
-- =============================================

INSERT INTO public.incident_hotspots (
  time_period,
  hotspot_type,
  location_lat,
  location_lng,
  location_address,
  radius_meters,
  incident_count,
  severity_score,
  prediction_score,
  last_incident_at
)
VALUES
  ('morning', 'robo', 19.4350, -99.1250, 'Zona Comercial Centro', 300, 8, 62.5, 68.0, NOW() - INTERVAL '2 hours'),
  ('afternoon', 'vandalismo', 19.4280, -99.1350, 'Zona de Transporte Público', 250, 12, 55.0, 60.5, NOW() - INTERVAL '5 hours'),
  ('night', 'asalto', 19.4450, -99.1320, 'Zona Residencial Norte', 400, 6, 70.0, 75.5, NOW() - INTERVAL '1 day'),
  ('evening', 'infraestructura', 19.4260, -99.1260, 'Centro Histórico Sur', 350, 10, 48.0, 52.3, NOW() - INTERVAL '2 days');

-- =============================================
-- SECTION 5: Comments on Incidents
-- =============================================

DO $$
DECLARE
  v_incident_id UUID;
BEGIN
  -- Add comments to verified incidents
  SELECT id INTO v_incident_id FROM public.incidents WHERE title = 'Asalto armado en zona comercial';
  IF v_incident_id IS NOT NULL THEN
    INSERT INTO public.incident_comments (incident_id, user_id, comment_text)
    VALUES 
      (v_incident_id, 'e5d7c9a2-4b6f-8e1a-3c5d-7f9b2a4c6e8d', 'Unidad policial desplegada en el área. Situación bajo control.'),
      (v_incident_id, 'd8b2c4e5-9a7f-4d2b-8c3e-1f6a5b9d7e2c', 'Gracias por la rápida respuesta. Todos están a salvo.');
  END IF;

  SELECT id INTO v_incident_id FROM public.incidents WHERE title = 'Fuga de agua en calle principal';
  IF v_incident_id IS NOT NULL THEN
    INSERT INTO public.incident_comments (incident_id, user_id, comment_text)
    VALUES 
      (v_incident_id, 'a7c9b3d5-6e8f-1a2b-4c6d-8e9f2a3b5c7d', 'Equipo técnico trabajando en la reparación. Estimado 4 horas.'),
      (v_incident_id, 'c2d4e6f8-9a1b-3c5d-7e9f-2a4b6c8d9e1f', 'Recomendamos rutas alternas por Av. Chapultepec.');
  END IF;
END $$;

-- =============================================
-- SECTION 6: Response Time Benchmarks
-- =============================================

-- First delete existing benchmarks to avoid conflicts
DELETE FROM public.response_time_benchmarks 
WHERE (incident_type, severity, region) IN (
  ('asalto', 'critical', 'CDMX'),
  ('robo', 'high', 'CDMX'),
  ('vandalismo', 'medium', 'CDMX'),
  ('infraestructura', 'high', 'CDMX'),
  ('accidente', 'critical', 'CDMX')
);

INSERT INTO public.response_time_benchmarks (
  incident_type,
  severity,
  region,
  target_response_minutes,
  industry_average_minutes,
  best_practice_minutes
)
VALUES
  ('asalto', 'critical', 'CDMX', 5, 8, 3),
  ('robo', 'high', 'CDMX', 10, 15, 7),
  ('vandalismo', 'medium', 'CDMX', 30, 45, 20),
  ('infraestructura', 'high', 'CDMX', 60, 120, 45),
  ('accidente', 'critical', 'CDMX', 5, 10, 3);

-- =============================================
-- SECTION 7: Authority Notification Preferences
-- =============================================

INSERT INTO public.authority_notification_preferences (
  authority_id,
  email_enabled,
  sms_enabled,
  notify_on_critical,
  notify_on_urgent,
  notify_on_moderate,
  notify_on_warning,
  auto_escalate_after_minutes,
  escalation_recipients
)
VALUES
  (
    'e5d7c9a2-4b6f-8e1a-3c5d-7f9b2a4c6e8d',
    true,
    true,
    true,
    true,
    false,
    false,
    30,
    ARRAY['a7c9b3d5-6e8f-1a2b-4c6d-8e9f2a3b5c7d']::UUID[]
  ),
  (
    'a7c9b3d5-6e8f-1a2b-4c6d-8e9f2a3b5c7d',
    true,
    true,
    true,
    true,
    true,
    false,
    60,
    ARRAY['e5d7c9a2-4b6f-8e1a-3c5d-7f9b2a4c6e8d']::UUID[]
  )
ON CONFLICT (authority_id) DO NOTHING;

-- =============================================
-- SECTION 8: Alert Statistics
-- =============================================

INSERT INTO public.alert_statistics (
  date,
  total_incidents,
  pending_incidents,
  verified_incidents,
  resolved_incidents,
  average_response_time_minutes,
  safety_score
)
VALUES
  (CURRENT_DATE, 25, 8, 12, 5, 45.5, 72.3),
  (CURRENT_DATE - INTERVAL '1 day', 30, 10, 15, 5, 52.0, 68.5),
  (CURRENT_DATE - INTERVAL '2 days', 28, 9, 14, 5, 48.2, 70.1)
ON CONFLICT (date) DO UPDATE
SET
  total_incidents = alert_statistics.total_incidents + EXCLUDED.total_incidents,
  pending_incidents = EXCLUDED.pending_incidents,
  verified_incidents = EXCLUDED.verified_incidents,
  resolved_incidents = EXCLUDED.resolved_incidents,
  average_response_time_minutes = EXCLUDED.average_response_time_minutes,
  safety_score = EXCLUDED.safety_score;

-- =============================================
-- SECTION 9: Community Engagement Metrics
-- =============================================

INSERT INTO public.community_engagement_metrics (
  date,
  active_users,
  total_reports,
  verified_reports,
  volunteer_participants,
  report_quality_score,
  community_feedback_count,
  citizen_satisfaction_score,
  average_response_time_minutes
)
VALUES
  (CURRENT_DATE, 150, 25, 12, 8, 78.5, 45, 4.2, 45.5),
  (CURRENT_DATE - INTERVAL '1 day', 145, 30, 15, 10, 80.0, 50, 4.3, 52.0),
  (CURRENT_DATE - INTERVAL '2 days', 140, 28, 14, 7, 76.0, 42, 4.1, 48.2)
ON CONFLICT (date) DO UPDATE
SET
  active_users = EXCLUDED.active_users,
  total_reports = EXCLUDED.total_reports,
  verified_reports = EXCLUDED.verified_reports,
  volunteer_participants = EXCLUDED.volunteer_participants,
  report_quality_score = EXCLUDED.report_quality_score,
  community_feedback_count = EXCLUDED.community_feedback_count,
  citizen_satisfaction_score = EXCLUDED.citizen_satisfaction_score,
  average_response_time_minutes = EXCLUDED.average_response_time_minutes;