-- BatFinder: FCM token en perfil de usuario
-- Permite registrar el token propio y que contactos lo busquen por email

-- Columna fcm_token en users
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- Política: el propio usuario puede actualizar su fcm_token
DROP POLICY IF EXISTS "users_update_own_fcm" ON public.users;
CREATE POLICY "users_update_own_fcm" ON public.users
  FOR UPDATE TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Política: usuarios autenticados pueden leer el fcm_token de otros por email
-- (necesario para el lookup al agregar contactos de pánico)
DROP POLICY IF EXISTS "users_read_fcm_by_email" ON public.users;
CREATE POLICY "users_read_fcm_by_email" ON public.users
  FOR SELECT TO authenticated
  USING (true);
