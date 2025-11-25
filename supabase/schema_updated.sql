-- ============================================
-- AirDroid Kids Copy - Updated Database Schema
-- Includes: streams, improved alerts, and enhanced features
-- ============================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- UPDATED/NEW TABLES
-- ============================================

-- Streams table (for live video/audio sessions)
CREATE TABLE IF NOT EXISTS public.streams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL REFERENCES public.devices(id) ON DELETE CASCADE,
    parent_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('video_front', 'video_back', 'audio', 'snapshot')),
    url TEXT, -- Supabase Storage Link or WebRTC session ID
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    finished_at TIMESTAMP WITH TIME ZONE,
    is_live BOOLEAN DEFAULT TRUE,
    duration_seconds INTEGER,
    quality TEXT CHECK (quality IN ('low', 'medium', 'high', 'auto')),
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enhanced alerts table
CREATE TABLE IF NOT EXISTS public.alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL REFERENCES public.devices(id) ON DELETE CASCADE,
    parent_user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN (
        'geofence_enter', 'geofence_exit', 
        'permission_denied', 'device_offline', 'device_online',
        'activity_detected', 'stream_started', 'stream_ended',
        'low_battery', 'high_usage'
    )),
    severity TEXT NOT NULL DEFAULT 'info' CHECK (severity IN ('info', 'warning', 'critical')),
    title TEXT NOT NULL,
    message TEXT,
    resolved BOOLEAN DEFAULT FALSE,
    resolved_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Device status history (for tracking online/offline patterns)
CREATE TABLE IF NOT EXISTS public.device_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL REFERENCES public.devices(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('online', 'offline')),
    battery_level INTEGER CHECK (battery_level >= 0 AND battery_level <= 100),
    network_type TEXT, -- 'wifi', '4g', '5g', etc.
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Screen time tracking
CREATE TABLE IF NOT EXISTS public.screen_time (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL REFERENCES public.devices(id) ON DELETE CASCADE,
    app_name TEXT,
    package_name TEXT,
    duration_seconds INTEGER NOT NULL,
    date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(device_id, package_name, date)
);

-- App usage logs
CREATE TABLE IF NOT EXISTS public.app_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL REFERENCES public.devices(id) ON DELETE CASCADE,
    app_name TEXT NOT NULL,
    package_name TEXT NOT NULL,
    event_type TEXT NOT NULL CHECK (event_type IN ('opened', 'closed', 'installed', 'uninstalled')),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX IF NOT EXISTS idx_streams_device_id ON public.streams(device_id);
CREATE INDEX IF NOT EXISTS idx_streams_parent_user_id ON public.streams(parent_user_id);
CREATE INDEX IF NOT EXISTS idx_streams_is_live ON public.streams(is_live);
CREATE INDEX IF NOT EXISTS idx_streams_started_at ON public.streams(started_at);

CREATE INDEX IF NOT EXISTS idx_alerts_device_id ON public.alerts(device_id);
CREATE INDEX IF NOT EXISTS idx_alerts_parent_user_id ON public.alerts(parent_user_id);
CREATE INDEX IF NOT EXISTS idx_alerts_resolved ON public.alerts(resolved);
CREATE INDEX IF NOT EXISTS idx_alerts_severity ON public.alerts(severity);
CREATE INDEX IF NOT EXISTS idx_alerts_created_at ON public.alerts(created_at);

CREATE INDEX IF NOT EXISTS idx_device_status_history_device_id ON public.device_status_history(device_id);
CREATE INDEX IF NOT EXISTS idx_device_status_history_recorded_at ON public.device_status_history(recorded_at);

CREATE INDEX IF NOT EXISTS idx_screen_time_device_id ON public.screen_time(device_id);
CREATE INDEX IF NOT EXISTS idx_screen_time_date ON public.screen_time(date);

CREATE INDEX IF NOT EXISTS idx_app_usage_device_id ON public.app_usage(device_id);
CREATE INDEX IF NOT EXISTS idx_app_usage_timestamp ON public.app_usage(timestamp);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

ALTER TABLE public.streams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.screen_time ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_usage ENABLE ROW LEVEL SECURITY;

-- Streams policies
CREATE POLICY "Parents can view streams from their devices" ON public.streams
    FOR SELECT USING (
        auth.uid() = parent_user_id OR
        EXISTS (
            SELECT 1 FROM public.devices
            WHERE devices.id = streams.device_id
            AND devices.child_user_id = auth.uid()
        )
    );

CREATE POLICY "Parents can insert streams" ON public.streams
    FOR INSERT WITH CHECK (auth.uid() = parent_user_id);

CREATE POLICY "Child devices can insert streams" ON public.streams
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.devices
            WHERE devices.id = streams.device_id
            AND devices.child_user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update their streams" ON public.streams
    FOR UPDATE USING (
        auth.uid() = parent_user_id OR
        EXISTS (
            SELECT 1 FROM public.devices
            WHERE devices.id = streams.device_id
            AND devices.child_user_id = auth.uid()
        )
    );

-- Alerts policies
CREATE POLICY "Parents can view alerts from their devices" ON public.alerts
    FOR SELECT USING (
        auth.uid() = parent_user_id OR
        EXISTS (
            SELECT 1 FROM public.devices
            WHERE devices.id = alerts.device_id
            AND devices.child_user_id = auth.uid()
        )
    );

CREATE POLICY "System can insert alerts" ON public.alerts
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Parents can update their alerts" ON public.alerts
    FOR UPDATE USING (auth.uid() = parent_user_id);

-- Device status history policies
CREATE POLICY "Parents can view device status history" ON public.device_status_history
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.device_links
            WHERE device_links.device_id = device_status_history.device_id
            AND device_links.parent_user_id = auth.uid()
            AND device_links.is_active = TRUE
        )
    );

CREATE POLICY "Child devices can insert status history" ON public.device_status_history
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.devices
            WHERE devices.id = device_status_history.device_id
            AND devices.child_user_id = auth.uid()
        )
    );

-- Screen time policies
CREATE POLICY "Parents can view screen time from their devices" ON public.screen_time
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.device_links
            WHERE device_links.device_id = screen_time.device_id
            AND device_links.parent_user_id = auth.uid()
            AND device_links.is_active = TRUE
        )
    );

CREATE POLICY "Child devices can manage screen time" ON public.screen_time
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.devices
            WHERE devices.id = screen_time.device_id
            AND devices.child_user_id = auth.uid()
        )
    );

-- App usage policies
CREATE POLICY "Parents can view app usage from their devices" ON public.app_usage
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.device_links
            WHERE device_links.device_id = app_usage.device_id
            AND device_links.parent_user_id = auth.uid()
            AND device_links.is_active = TRUE
        )
    );

CREATE POLICY "Child devices can insert app usage" ON public.app_usage
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.devices
            WHERE devices.id = app_usage.device_id
            AND devices.child_user_id = auth.uid()
        )
    );

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to create alert
CREATE OR REPLACE FUNCTION create_alert(
    p_device_id UUID,
    p_parent_user_id UUID,
    p_type TEXT,
    p_severity TEXT,
    p_title TEXT,
    p_message TEXT,
    p_metadata JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    alert_id UUID;
BEGIN
    INSERT INTO public.alerts (
        device_id, parent_user_id, type, severity, title, message, metadata
    )
    VALUES (
        p_device_id, p_parent_user_id, p_type, p_severity, p_title, p_message, p_metadata
    )
    RETURNING id INTO alert_id;
    
    RETURN alert_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to end stream
CREATE OR REPLACE FUNCTION end_stream(p_stream_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.streams
    SET 
        finished_at = NOW(),
        is_live = FALSE,
        duration_seconds = EXTRACT(EPOCH FROM (NOW() - started_at))::INTEGER
    WHERE id = p_stream_id AND is_live = TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to track device status change
CREATE OR REPLACE FUNCTION track_device_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE' AND OLD.is_online != NEW.is_online) THEN
        -- Insert status history
        INSERT INTO public.device_status_history (device_id, status)
        VALUES (NEW.id, CASE WHEN NEW.is_online THEN 'online' ELSE 'offline' END);
        
        -- Create alert for parents
        IF NEW.is_online = FALSE THEN
            PERFORM create_alert(
                NEW.id,
                (SELECT parent_user_id FROM public.device_links WHERE device_id = NEW.id LIMIT 1),
                'device_offline',
                'warning',
                'Dispositivo desconectado',
                'El dispositivo ' || NEW.device_name || ' se ha desconectado',
                jsonb_build_object('device_name', NEW.device_name)
            );
        ELSE
            PERFORM create_alert(
                NEW.id,
                (SELECT parent_user_id FROM public.device_links WHERE device_id = NEW.id LIMIT 1),
                'device_online',
                'info',
                'Dispositivo conectado',
                'El dispositivo ' || NEW.device_name || ' está en línea',
                jsonb_build_object('device_name', NEW.device_name)
            );
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for device status changes
DROP TRIGGER IF EXISTS trigger_device_status_change ON public.devices;
CREATE TRIGGER trigger_device_status_change
    AFTER UPDATE ON public.devices
    FOR EACH ROW
    EXECUTE FUNCTION track_device_status_change();

-- Function to check geofence violations
CREATE OR REPLACE FUNCTION check_geofence_violation(
    p_device_id UUID,
    p_latitude DOUBLE PRECISION,
    p_longitude DOUBLE PRECISION
)
RETURNS VOID AS $$
DECLARE
    geofence RECORD;
    distance DOUBLE PRECISION;
    is_inside BOOLEAN;
    last_event RECORD;
BEGIN
    FOR geofence IN 
        SELECT * FROM public.geofences 
        WHERE device_id = p_device_id AND is_active = TRUE
    LOOP
        -- Calculate distance (simplified Haversine formula)
        distance := 6371000 * acos(
            cos(radians(p_latitude)) * cos(radians(geofence.latitude)) *
            cos(radians(geofence.longitude) - radians(p_longitude)) +
            sin(radians(p_latitude)) * sin(radians(geofence.latitude))
        );
        
        is_inside := distance <= geofence.radius;
        
        -- Get last event for this geofence
        SELECT * INTO last_event
        FROM public.geofence_events
        WHERE geofence_id = geofence.id
        ORDER BY created_at DESC
        LIMIT 1;
        
        -- Check for enter event
        IF is_inside AND (last_event IS NULL OR last_event.event_type = 'exit') THEN
            IF geofence.notify_on_enter THEN
                INSERT INTO public.geofence_events (geofence_id, device_id, event_type, latitude, longitude)
                VALUES (geofence.id, p_device_id, 'enter', p_latitude, p_longitude);
                
                PERFORM create_alert(
                    p_device_id,
                    geofence.parent_user_id,
                    'geofence_enter',
                    'info',
                    'Entrada a zona',
                    'El dispositivo ha entrado en la zona: ' || geofence.name,
                    jsonb_build_object('geofence_name', geofence.name, 'latitude', p_latitude, 'longitude', p_longitude)
                );
            END IF;
        END IF;
        
        -- Check for exit event
        IF NOT is_inside AND (last_event IS NOT NULL AND last_event.event_type = 'enter') THEN
            IF geofence.notify_on_exit THEN
                INSERT INTO public.geofence_events (geofence_id, device_id, event_type, latitude, longitude)
                VALUES (geofence.id, p_device_id, 'exit', p_latitude, p_longitude);
                
                PERFORM create_alert(
                    p_device_id,
                    geofence.parent_user_id,
                    'geofence_exit',
                    'warning',
                    'Salida de zona',
                    'El dispositivo ha salido de la zona: ' || geofence.name,
                    jsonb_build_object('geofence_name', geofence.name, 'latitude', p_latitude, 'longitude', p_longitude)
                );
            END IF;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to check geofences on location update
CREATE OR REPLACE FUNCTION trigger_check_geofences()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM check_geofence_violation(NEW.device_id, NEW.latitude, NEW.longitude);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_location_geofence_check ON public.location_history;
CREATE TRIGGER trigger_location_geofence_check
    AFTER INSERT ON public.location_history
    FOR EACH ROW
    EXECUTE FUNCTION trigger_check_geofences();

-- ============================================
-- VIEWS
-- ============================================

-- View for device summary with latest info
CREATE OR REPLACE VIEW device_summary AS
SELECT 
    d.id,
    d.device_name,
    d.device_code,
    d.device_model,
    d.os_version,
    d.is_online,
    d.last_seen,
    dl.parent_user_id,
    dl.nickname,
    (SELECT COUNT(*) FROM public.alerts WHERE device_id = d.id AND resolved = FALSE) as unresolved_alerts,
    (SELECT latitude FROM public.location_history WHERE device_id = d.id ORDER BY recorded_at DESC LIMIT 1) as last_latitude,
    (SELECT longitude FROM public.location_history WHERE device_id = d.id ORDER BY recorded_at DESC LIMIT 1) as last_longitude,
    (SELECT recorded_at FROM public.location_history WHERE device_id = d.id ORDER BY recorded_at DESC LIMIT 1) as last_location_time
FROM public.devices d
LEFT JOIN public.device_links dl ON d.id = dl.device_id AND dl.is_active = TRUE;

-- ============================================
-- REALTIME CONFIGURATION
-- ============================================

-- Note: Enable these tables in Supabase Dashboard > Database > Replication
-- Tables to enable for Realtime:
-- - streams
-- - alerts
-- - device_status_history
-- - app_usage


