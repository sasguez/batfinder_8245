-- BatFinder: Panic system tables + emergency_contacts extended schema
-- Run in Supabase SQL Editor (or via: supabase db push)

-- ── Extend emergency_contacts with FCM/WhatsApp fields ───────────────
CREATE TABLE IF NOT EXISTS public.emergency_contacts (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name           TEXT NOT NULL,
  phone          TEXT,
  relation       TEXT,
  phone_wa       TEXT,
  phone_sms      TEXT,
  has_app        BOOLEAN DEFAULT false,
  fcm_token      TEXT,
  priority       INTEGER DEFAULT 1,
  whatsapp_optin BOOLEAN DEFAULT false,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add new columns if table already existed with old schema
ALTER TABLE public.emergency_contacts
  ADD COLUMN IF NOT EXISTS phone_wa       TEXT,
  ADD COLUMN IF NOT EXISTS phone_sms      TEXT,
  ADD COLUMN IF NOT EXISTS has_app        BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS fcm_token      TEXT,
  ADD COLUMN IF NOT EXISTS priority       INTEGER DEFAULT 1,
  ADD COLUMN IF NOT EXISTS whatsapp_optin BOOLEAN DEFAULT false;

-- ── panic_events ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.panic_events (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID NOT NULL REFERENCES auth.users(id),
  status         TEXT NOT NULL DEFAULT 'active'
                 CHECK (status IN ('active', 'resolved', 'false_alarm')),
  trigger_source TEXT NOT NULL
                 CHECK (trigger_source IN ('button', 'power_button', 'wearable')),
  started_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  resolved_at    TIMESTAMPTZ,
  resolved_by    UUID REFERENCES auth.users(id),
  notes          TEXT,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── panic_locations (GPS stream) ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.panic_locations (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id    UUID NOT NULL REFERENCES public.panic_events(id) ON DELETE CASCADE,
  latitude    DOUBLE PRECISION NOT NULL,
  longitude   DOUBLE PRECISION NOT NULL,
  accuracy    DOUBLE PRECISION,
  speed       DOUBLE PRECISION,
  heading     DOUBLE PRECISION,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_panic_loc_event
  ON public.panic_locations(event_id, recorded_at DESC);

-- ── notification_delivery_logs ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.notification_delivery_logs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id        UUID NOT NULL REFERENCES public.panic_events(id),
  contact_id      UUID REFERENCES public.emergency_contacts(id),
  channel         TEXT NOT NULL CHECK (channel IN ('fcm', 'whatsapp', 'sms')),
  status          TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'sent', 'delivered', 'failed')),
  external_sid    TEXT,
  attempts        INTEGER DEFAULT 0,
  last_attempt_at TIMESTAMPTZ,
  error_message   TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Habilitar Realtime ────────────────────────────────────────────────
ALTER TABLE public.panic_events    REPLICA IDENTITY FULL;
ALTER TABLE public.panic_locations REPLICA IDENTITY FULL;

-- ── RLS: panic_events ─────────────────────────────────────────────────
ALTER TABLE public.panic_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "panic_events_insert" ON public.panic_events;
CREATE POLICY "panic_events_insert" ON public.panic_events
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "panic_events_select" ON public.panic_events;
CREATE POLICY "panic_events_select" ON public.panic_events
  FOR SELECT TO authenticated USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "panic_events_update" ON public.panic_events;
CREATE POLICY "panic_events_update" ON public.panic_events
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);

-- ── RLS: panic_locations ──────────────────────────────────────────────
ALTER TABLE public.panic_locations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "panic_locations_select" ON public.panic_locations;
CREATE POLICY "panic_locations_select" ON public.panic_locations
  FOR SELECT TO authenticated
  USING (
    event_id IN (
      SELECT id FROM public.panic_events WHERE user_id = auth.uid()
    )
  );

-- ── RLS: notification_delivery_logs ──────────────────────────────────
ALTER TABLE public.notification_delivery_logs ENABLE ROW LEVEL SECURITY;
