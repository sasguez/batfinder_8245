-- Create private bucket for profile photos
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'profile-photos',
    'profile-photos', 
    false,
    5242880,
    ARRAY['image/jpeg', 'image/png', 'image/webp']
);

-- RLS: Users can manage only their own profile photos
CREATE POLICY "users_manage_own_profile_photos" ON storage.objects
FOR ALL TO authenticated
USING (bucket_id = 'profile-photos' AND owner = auth.uid())
WITH CHECK (bucket_id = 'profile-photos' AND owner = auth.uid());