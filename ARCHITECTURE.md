# Arquitectura del Sistema - AirDroid Kids Copy

## 📐 Visión General

El sistema está dividido en dos módulos principales que se comunican a través de Supabase:

```
┌─────────────────────┐         ┌──────────────┐         ┌─────────────────────┐
│   Módulo Niño       │ ◄─────► │   Supabase   │ ◄─────► │   Módulo Padre      │
│ (Dispositivo        │         │  (Backend)   │         │ (Control Remoto)    │
│  Monitoreado)       │         └──────────────┘         │                     │
└─────────────────────┘                                  └─────────────────────┘
```

## 🏗️ Arquitectura por Capas

### Módulo Niño (Child Module)

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Screens  │  │ Widgets  │  │Providers │              │
│  └──────────┘  └──────────┘  └──────────┘              │
├─────────────────────────────────────────────────────────┤
│                    Business Logic Layer                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Services │  │ Commands │  │  Models  │              │
│  └──────────┘  └──────────┘  └──────────┘              │
├─────────────────────────────────────────────────────────┤
│                    Data Layer                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Supabase │  │  Local   │  │  WebRTC  │              │
│  │  Client  │  │ Storage  │  │          │              │
│  └──────────┘  └──────────┘  └──────────┘              │
├─────────────────────────────────────────────────────────┤
│                    Platform Layer                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │  Camera  │  │  Audio   │  │ Location │              │
│  │  Native  │  │  Native  │  │  Native  │              │
│  └──────────┘  └──────────┘  └──────────┘              │
└─────────────────────────────────────────────────────────┘
```

#### Componentes Principales

**1. Presentation Layer**
- **Screens**: Pantallas de la aplicación (Splash, Setup, Home)
- **Widgets**: Componentes reutilizables de UI
- **Providers**: Gestión de estado con Provider pattern

**2. Business Logic Layer**
- **Services**: Lógica de negocio (CameraService, AudioService, LocationService)
- **Commands**: Procesamiento de comandos remotos
- **Models**: Modelos de datos (DeviceModel, CommandModel, LocationModel)

**3. Data Layer**
- **Supabase Client**: Comunicación con backend
- **Local Storage**: SharedPreferences para datos locales
- **WebRTC**: Streaming de video/audio

**4. Platform Layer**
- **Camera Native**: Acceso a cámara del dispositivo
- **Audio Native**: Acceso a micrófono
- **Location Native**: Acceso a GPS

### Módulo Padre (Parent Module)

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Screens  │  │ Widgets  │  │Providers │              │
│  └──────────┘  └──────────┘  └──────────┘              │
├─────────────────────────────────────────────────────────┤
│                    Business Logic Layer                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Services │  │ Commands │  │  Models  │              │
│  └──────────┘  └──────────┘  └──────────┘              │
├─────────────────────────────────────────────────────────┤
│                    Data Layer                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Supabase │  │  Local   │  │  WebRTC  │              │
│  │  Client  │  │ Storage  │  │  Client  │              │
│  └──────────┘  └──────────┘  └──────────┘              │
└─────────────────────────────────────────────────────────┘
```

## 🔄 Flujo de Datos

### 1. Vinculación de Dispositivos

```
Módulo Niño                    Supabase                    Módulo Padre
    │                              │                              │
    │ 1. Register Device           │                              │
    ├─────────────────────────────►│                              │
    │                              │                              │
    │ 2. Generate Code             │                              │
    │◄─────────────────────────────┤                              │
    │                              │                              │
    │                              │ 3. Link Device (Code)        │
    │                              │◄─────────────────────────────┤
    │                              │                              │
    │                              │ 4. Create Link               │
    │                              ├─────────────────────────────►│
    │                              │                              │
```

### 2. Envío de Comandos

```
Módulo Padre                   Supabase                    Módulo Niño
    │                              │                              │
    │ 1. Send Command              │                              │
    ├─────────────────────────────►│                              │
    │                              │                              │
    │                              │ 2. Realtime Event            │
    │                              ├─────────────────────────────►│
    │                              │                              │
    │                              │ 3. Execute Command           │
    │                              │◄─────────────────────────────┤
    │                              │                              │
    │ 4. Get Response              │                              │
    │◄─────────────────────────────┤                              │
    │                              │                              │
```

### 3. Streaming de Video/Audio

```
Módulo Niño                    WebRTC                    Módulo Padre
    │                              │                              │
    │ 1. Create Offer              │                              │
    ├─────────────────────────────►│                              │
    │                              │                              │
    │                              │ 2. Send Offer                │
    │                              ├─────────────────────────────►│
    │                              │                              │
    │                              │ 3. Create Answer             │
    │                              │◄─────────────────────────────┤
    │                              │                              │
    │ 4. Receive Answer            │                              │
    │◄─────────────────────────────┤                              │
    │                              │                              │
    │ 5. Exchange ICE Candidates   │                              │
    │◄────────────────────────────►│◄────────────────────────────►│
    │                              │                              │
    │ 6. Establish Connection      │                              │
    │◄────────────────────────────────────────────────────────────►│
    │                              │                              │
    │ 7. Stream Media              │                              │
    │══════════════════════════════════════════════════════════════►│
    │                              │                              │
```

## 💾 Modelo de Datos

### Entidades Principales

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│    Users    │         │   Devices   │         │Device Links │
├─────────────┤         ├─────────────┤         ├─────────────┤
│ id (PK)     │         │ id (PK)     │         │ id (PK)     │
│ email       │         │ device_code │         │ parent_id   │
│ role        │         │ device_id   │         │ device_id   │
│ full_name   │         │ child_id(FK)│         │ nickname    │
└─────────────┘         └─────────────┘         └─────────────┘
       │                       │                       │
       └───────────────────────┴───────────────────────┘
```

### Relaciones

- Un **User** (parent) puede tener múltiples **Device Links**
- Un **Device** pertenece a un **User** (child)
- Un **Device Link** conecta un **User** (parent) con un **Device**

## 🔐 Seguridad

### Capas de Seguridad

1. **Autenticación**
   - Supabase Auth con JWT tokens
   - Refresh tokens automáticos
   - Session management

2. **Autorización**
   - Row Level Security (RLS) en Supabase
   - Políticas granulares por tabla
   - Validación de permisos en cada operación

3. **Cifrado**
   - TLS 1.3 para todas las comunicaciones HTTP
   - DTLS-SRTP para streaming WebRTC
   - Tokens JWT firmados

4. **Privacidad**
   - Consentimiento explícito requerido
   - Notificaciones configurables
   - Auditoría completa de accesos

### Políticas RLS

```sql
-- Ejemplo: Solo padres pueden ver sus dispositivos vinculados
CREATE POLICY "Parents can view their linked devices" 
ON device_links FOR SELECT 
USING (auth.uid() = parent_user_id);

-- Ejemplo: Solo dispositivos pueden actualizar sus comandos
CREATE POLICY "Devices can update their commands" 
ON commands FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM devices
    WHERE devices.id = commands.device_id
    AND devices.child_user_id = auth.uid()
  )
);
```

## 🚀 Escalabilidad

### Consideraciones de Escalabilidad

1. **Base de Datos**
   - Índices en columnas frecuentemente consultadas
   - Particionamiento de tablas grandes (location_history)
   - Limpieza automática de datos antiguos

2. **Storage**
   - CDN para archivos multimedia
   - Compresión de imágenes/videos
   - Limpieza automática de archivos antiguos

3. **Realtime**
   - Canales separados por dispositivo
   - Límite de conexiones concurrentes
   - Throttling de eventos

4. **WebRTC**
   - TURN servers para NAT traversal
   - Calidad adaptativa según ancho de banda
   - Fallback a TURN si P2P falla

## 🔧 Patrones de Diseño

### 1. Service Locator Pattern
```dart
final getIt = GetIt.instance;

// Registro
getIt.registerLazySingleton<CameraService>(() => CameraService());

// Uso
final cameraService = getIt<CameraService>();
```

### 2. Provider Pattern (State Management)
```dart
ChangeNotifierProvider(
  create: (_) => DeviceProvider(),
  child: MyApp(),
)
```

### 3. Repository Pattern
```dart
class DeviceRepository {
  final SupabaseService _supabase;
  
  Future<Device> getDevice(String id) async {
    // Abstracción de la fuente de datos
  }
}
```

### 4. Command Pattern
```dart
abstract class Command {
  Future<void> execute();
}

class TakeSnapshotCommand implements Command {
  @override
  Future<void> execute() async {
    // Lógica para tomar snapshot
  }
}
```

## 📊 Monitoreo y Logs

### Eventos Auditados

- Registro de dispositivos
- Vinculación/desvinculación
- Comandos enviados/ejecutados
- Accesos a cámara/micrófono
- Cambios de ubicación
- Eventos de geocercas

### Métricas Clave

- Tiempo de respuesta de comandos
- Tasa de éxito de comandos
- Calidad de streaming (FPS, bitrate)
- Uso de almacenamiento
- Conexiones activas

## 🧪 Testing

### Estrategia de Testing

1. **Unit Tests**
   - Servicios individuales
   - Modelos de datos
   - Utilidades

2. **Widget Tests**
   - Componentes de UI
   - Interacciones básicas

3. **Integration Tests**
   - Flujos completos
   - Comunicación con Supabase
   - WebRTC

## 📱 Plataformas Soportadas

- ✅ Android 5.0+ (API 21+)
- ✅ iOS 11.0+
- ⚠️ Web (limitado, sin acceso a cámara/micrófono nativo)
- ❌ Desktop (no soportado actualmente)

## 🔮 Futuras Mejoras

1. **Funcionalidades**
   - Grabación de video
   - Captura de pantalla
   - Control de apps instaladas
   - Filtrado de contenido web

2. **Técnicas**
   - Migración a arquitectura limpia
   - Implementación de BLoC pattern
   - Mejoras en cifrado E2E
   - Optimización de batería

3. **UX/UI**
   - Modo oscuro completo
   - Personalización de temas
   - Widgets de acceso rápido
   - Notificaciones push mejoradas

