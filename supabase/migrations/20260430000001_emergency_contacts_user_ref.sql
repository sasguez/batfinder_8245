-- BatFinder: Vincula emergency_contacts con el usuario de BatFinder del contacto
-- Permite que la Edge Function siempre use el FCM token actualizado desde users

ALTER TABLE public.emergency_contacts
  ADD COLUMN IF NOT EXISTS contact_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;

-- Índice para el JOIN en panic-orchestrator
CREATE INDEX IF NOT EXISTS idx_emergency_contacts_contact_user_id
  ON public.emergency_contacts(contact_user_id);
