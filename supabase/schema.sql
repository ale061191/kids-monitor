-- ============================================
-- AirDroid Kids Copy - Supabase Database Schema
-- ============================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- TABLES
-- ============================================

-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    role TEXT NOT NULL CHECK (role IN ('parent', 'child')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Devices table (child devices)
CREATE TABLE public.devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_name TEXT NOT NULL,
    device_code TEXT UNIQUE NOT NULL, -- Código de vinculación
    device_id TEXT UNIQUE NOT NULL, -- ID único del dispositivo
    child_user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    device_model TEXT,
    os_version TEXT,
    app_version TEXT,
    is_online BOOLEAN DEFAULT FALSE,
    last_seen TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Device links (parent-child relationships)
CREATE TABLE public.device_links (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    device_id UUID NOT NULL REFERENCES public.devices(id) ON DELETE CASCADE,
    nickname TEXT, -- Nombre personalizado del dispositivo
    is_active BOOLEAN DEFAULT TRUE,
    linked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(parent_user_id, device_id)
);

-- Commands table (remote commands from parent to child)
CREATE TABLE public.commands (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL REFERENCES public.devices(id) ON DELETE CASCADE,
    parent_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    command_type TEXT NOT NULL CHECK (command_type IN (
        'start_video', 'stop_video', 'switch_camera',
        'start_audio', 'stop_audio', 'take_snapshot',
        'start_recording', 'stop_recording',
        'get_location', 'get_device_info'
    )),
    parameters JSONB, -- Parámetros adicionales del comando
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'executed', 'failed')),
    response JSONB, -- Respuesta del dispositivo
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    executed_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() + INTERVAL '5 minutes'
);

-- Media files (snapshots, recordings)
CREATE TABLE public.media_files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL REFERENCES public.devices(id) ON DELETE CASCADE,
    parent_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    file_type TEXT NOT NULL CHECK (file_type IN ('snapshot', 'audio_recording', 'video_recording')),
    file_path TEXT NOT NULL, -- Path en Supabase Storage
    file_size BIGINT,
    duration INTEGER, -- Duración en segundos (para audio/video)
    metadata JSONB, -- Metadatos adicionales
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Location history
CREATE TABLE public.location_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL REFERENCES public.devices(id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    accuracy DOUBLE PRECISION,
    altitude DOUBLE PRECISION,
    speed DOUBLE PRECISION,
    heading DOUBLE PRECISION,
    address TEXT, -- Dirección geocodificada (opcional)
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Geofences (geocercas)
CREATE TABLE public.geofences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL REFERENCES public.devices(id) ON DELETE CASCADE,
    parent_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    radius DOUBLE PRECISION NOT NULL, -- Radio en metros
    is_active BOOLEAN DEFAULT TRUE,
    notify_on_enter BOOLEAN DEFAULT TRUE,
    notify_on_exit BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Geofence events
CREATE TABLE public.geofence_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    geofence_id UUID NOT NULL REFERENCES public.geofences(id) ON DELETE CASCADE,
    device_id UUID NOT NULL REFERENCES public.devices(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL CHECK (event_type IN ('enter', 'exit')),
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activity log (auditoría)
CREATE TABLE public.activity_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    device_id UUID REFERENCES public.devices(id) ON DELETE CASCADE,
    activity_type TEXT NOT NULL,
    description TEXT,
    metadata JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Device settings
CREATE TABLE public.device_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID UNIQUE NOT NULL REFERENCES public.devices(id) ON DELETE CASCADE,
    show_notifications BOOLEAN DEFAULT TRUE, -- Mostrar notificaciones cuando se active monitoreo
    video_quality TEXT DEFAULT 'medium' CHECK (video_quality IN ('low', 'medium', 'high', 'auto')),
    audio_quality TEXT DEFAULT 'medium' CHECK (audio_quality IN ('low', 'medium', 'high')),
    location_update_interval INTEGER DEFAULT 300, -- Segundos
    battery_optimization BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- WebRTC sessions (para streaming)
CREATE TABLE public.webrtc_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL REFERENCES public.devices(id) ON DELETE CASCADE,
    parent_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    session_type TEXT NOT NULL CHECK (session_type IN ('video', 'audio')),
    offer_sdp TEXT,
    answer_sdp TEXT,
    ice_candidates JSONB,
    status TEXT NOT NULL DEFAULT 'initializing' CHECK (status IN ('initializing', 'connecting', 'connected', 'disconnected', 'failed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    connected_at TIMESTAMP WITH TIME ZONE,
    disconnected_at TIMESTAMP WITH TIME ZONE
);

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX idx_devices_child_user_id ON public.devices(child_user_id);
CREATE INDEX idx_devices_device_code ON public.devices(device_code);
CREATE INDEX idx_devices_is_online ON public.devices(is_online);

CREATE INDEX idx_device_links_parent_user_id ON public.device_links(parent_user_id);
CREATE INDEX idx_device_links_device_id ON public.device_links(device_id);

CREATE INDEX idx_commands_device_id ON public.commands(device_id);
CREATE INDEX idx_commands_status ON public.commands(status);
CREATE INDEX idx_commands_created_at ON public.commands(created_at);

CREATE INDEX idx_media_files_device_id ON public.media_files(device_id);
CREATE INDEX idx_media_files_parent_user_id ON public.media_files(parent_user_id);
CREATE INDEX idx_media_files_created_at ON public.media_files(created_at);

CREATE INDEX idx_location_history_device_id ON public.location_history(device_id);
CREATE INDEX idx_location_history_recorded_at ON public.location_history(recorded_at);

CREATE INDEX idx_geofences_device_id ON public.geofences(device_id);
CREATE INDEX idx_geofences_is_active ON public.geofences(is_active);

CREATE INDEX idx_activity_log_user_id ON public.activity_log(user_id);
CREATE INDEX idx_activity_log_device_id ON public.activity_log(device_id);
CREATE INDEX idx_activity_log_created_at ON public.activity_log(created_at);

CREATE INDEX idx_webrtc_sessions_device_id ON public.webrtc_sessions(device_id);
CREATE INDEX idx_webrtc_sessions_status ON public.webrtc_sessions(status);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commands ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.media_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.location_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.geofences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.geofence_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.webrtc_sessions ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Devices policies
CREATE POLICY "Child users can view their own devices" ON public.devices
    FOR SELECT USING (auth.uid() = child_user_id);

CREATE POLICY "Child users can insert their own devices" ON public.devices
    FOR INSERT WITH CHECK (auth.uid() = child_user_id);

CREATE POLICY "Child users can update their own devices" ON public.devices
    FOR UPDATE USING (auth.uid() = child_user_id);

-- Device links policies
CREATE POLICY "Parents can view their linked devices" ON public.device_links
    FOR SELECT USING (auth.uid() = parent_user_id);

CREATE POLICY "Parents can insert device links" ON public.device_links
    FOR INSERT WITH CHECK (auth.uid() = parent_user_id);

CREATE POLICY "Parents can update their device links" ON public.device_links
    FOR UPDATE USING (auth.uid() = parent_user_id);

CREATE POLICY "Parents can delete their device links" ON public.device_links
    FOR DELETE USING (auth.uid() = parent_user_id);

-- Commands policies
CREATE POLICY "Parents can insert commands for their devices" ON public.commands
    FOR INSERT WITH CHECK (
        auth.uid() = parent_user_id AND
        EXISTS (
            SELECT 1 FROM public.device_links
            WHERE device_links.parent_user_id = auth.uid()
            AND device_links.device_id = commands.device_id
            AND device_links.is_active = TRUE
        )
    );

CREATE POLICY "Parents can view commands for their devices" ON public.commands
    FOR SELECT USING (auth.uid() = parent_user_id);

CREATE POLICY "Child devices can view their commands" ON public.commands
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.devices
            WHERE devices.id = commands.device_id
            AND devices.child_user_id = auth.uid()
        )
    );

CREATE POLICY "Child devices can update their commands" ON public.commands
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.devices
            WHERE devices.id = commands.device_id
            AND devices.child_user_id = auth.uid()
        )
    );

-- Media files policies
CREATE POLICY "Parents can view media from their devices" ON public.media_files
    FOR SELECT USING (auth.uid() = parent_user_id);

CREATE POLICY "Parents can insert media files" ON public.media_files
    FOR INSERT WITH CHECK (auth.uid() = parent_user_id);

CREATE POLICY "Child devices can insert media files" ON public.media_files
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.devices
            WHERE devices.id = media_files.device_id
            AND devices.child_user_id = auth.uid()
        )
    );

-- Location history policies
CREATE POLICY "Parents can view location history of their devices" ON public.location_history
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.device_links
            WHERE device_links.device_id = location_history.device_id
            AND device_links.parent_user_id = auth.uid()
            AND device_links.is_active = TRUE
        )
    );

CREATE POLICY "Child devices can insert location history" ON public.location_history
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.devices
            WHERE devices.id = location_history.device_id
            AND devices.child_user_id = auth.uid()
        )
    );

-- Geofences policies
CREATE POLICY "Parents can manage geofences for their devices" ON public.geofences
    FOR ALL USING (auth.uid() = parent_user_id);

-- Activity log policies
CREATE POLICY "Users can view their own activity" ON public.activity_log
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own activity" ON public.activity_log
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Device settings policies
CREATE POLICY "Child devices can view their settings" ON public.device_settings
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.devices
            WHERE devices.id = device_settings.device_id
            AND devices.child_user_id = auth.uid()
        )
    );

CREATE POLICY "Child devices can update their settings" ON public.device_settings
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.devices
            WHERE devices.id = device_settings.device_id
            AND devices.child_user_id = auth.uid()
        )
    );

-- WebRTC sessions policies
CREATE POLICY "Parents can manage WebRTC sessions for their devices" ON public.webrtc_sessions
    FOR ALL USING (auth.uid() = parent_user_id);

CREATE POLICY "Child devices can manage their WebRTC sessions" ON public.webrtc_sessions
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.devices
            WHERE devices.id = webrtc_sessions.device_id
            AND devices.child_user_id = auth.uid()
        )
    );

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to generate unique device code
CREATE OR REPLACE FUNCTION generate_device_code()
RETURNS TEXT AS $$
DECLARE
    code TEXT;
    exists BOOLEAN;
BEGIN
    LOOP
        code := upper(substring(md5(random()::text) from 1 for 8));
        SELECT EXISTS(SELECT 1 FROM public.devices WHERE device_code = code) INTO exists;
        EXIT WHEN NOT exists;
    END LOOP;
    RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to log activity
CREATE OR REPLACE FUNCTION log_activity(
    p_user_id UUID,
    p_device_id UUID,
    p_activity_type TEXT,
    p_description TEXT,
    p_metadata JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    activity_id UUID;
BEGIN
    INSERT INTO public.activity_log (user_id, device_id, activity_type, description, metadata)
    VALUES (p_user_id, p_device_id, p_activity_type, p_description, p_metadata)
    RETURNING id INTO activity_id;
    RETURN activity_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger to update updated_at on users
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger to update updated_at on devices
CREATE TRIGGER update_devices_updated_at BEFORE UPDATE ON public.devices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger to update updated_at on geofences
CREATE TRIGGER update_geofences_updated_at BEFORE UPDATE ON public.geofences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger to update updated_at on device_settings
CREATE TRIGGER update_device_settings_updated_at BEFORE UPDATE ON public.device_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- STORAGE BUCKETS
-- ============================================

-- Note: These need to be created via Supabase Dashboard or API
-- Buckets needed:
-- - snapshots: For photo captures
-- - audio-recordings: For audio files
-- - video-recordings: For video files (if needed)

-- ============================================
-- REALTIME
-- ============================================

-- Enable realtime for critical tables
-- Note: Configure in Supabase Dashboard under Database > Replication
-- Tables to enable:
-- - devices (for online status)
-- - commands (for real-time command delivery)
-- - webrtc_sessions (for WebRTC signaling)
-- - location_history (for real-time location)
-- - geofence_events (for alerts)

