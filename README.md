# AirDroid Kids Copy - Sistema de Control Parental

## 📱 Descripción

Sistema de control parental dividido en dos módulos:
- **Módulo Niño**: Aplicación instalada en el dispositivo a monitorear
- **Módulo Padre**: Aplicación de control remoto para padres/tutores

## ⚠️ AVISO LEGAL Y ÉTICO

**IMPORTANTE**: Este sistema debe usarse únicamente con el consentimiento explícito del usuario del dispositivo monitoreado. El uso sin consentimiento puede violar leyes de privacidad locales e internacionales.

- ✅ Uso legal: Monitoreo parental con consentimiento
- ❌ Uso ilegal: Vigilancia sin consentimiento, espionaje

## 🚀 Características

### Videovigilancia Remota
- Streaming en tiempo real de cámara frontal/trasera
- Calidad adaptativa según ancho de banda
- Capturas instantáneas (snapshots)
- Encriptación de transmisión

### Audio Ambiente
- Activación remota del micrófono
- Escucha en tiempo real
- Grabación con almacenamiento seguro

### Ubicación GPS
- Seguimiento en tiempo real
- Historial de ubicaciones
- Geocercas con alertas

### Seguridad
- Autenticación robusta con Supabase
- Cifrado E2E en transmisiones
- Tokens temporales para comandos críticos
- Auditoría de accesos

## 🛠️ Stack Tecnológico

- **Frontend/Backend**: Flutter (multiplataforma)
- **Base de datos**: Supabase (PostgreSQL)
- **Realtime**: Supabase Realtime + WebRTC
- **Storage**: Supabase Storage
- **Auth**: Supabase Auth

## 📋 Requisitos Previos

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Cuenta de Supabase (gratuita)
- Android Studio / Xcode (para desarrollo móvil)

## 🔧 Instalación

### 1. Clonar el repositorio

```bash
git clone <repository-url>
cd airdroidKidsCopy
```

### 2. Configurar Supabase

1. Crear proyecto en [Supabase](https://supabase.com)
2. Ejecutar el script SQL en `supabase/schema.sql`
3. Copiar las credenciales (URL y anon key)
4. Crear archivo `.env` en cada módulo:

```env
SUPABASE_URL=tu_url_de_supabase
SUPABASE_ANON_KEY=tu_anon_key
```

### 3. Instalar dependencias

#### Módulo Niño
```bash
cd child_module
flutter pub get
```

#### Módulo Padre
```bash
cd parent_module
flutter pub get
```

### 4. Ejecutar aplicaciones

#### Módulo Niño
```bash
cd child_module
flutter run
```

#### Módulo Padre
```bash
cd parent_module
flutter run
```

## 📱 Flujo de Uso

1. **Instalación Módulo Niño**
   - Instalar app en dispositivo del niño
   - Otorgar todos los permisos requeridos
   - Generar código de vinculación

2. **Vinculación desde Módulo Padre**
   - Registrar cuenta de padre/tutor
   - Escanear QR o ingresar código
   - Vincular dispositivo

3. **Monitoreo**
   - Seleccionar dispositivo vinculado
   - Activar video/audio/ubicación
   - Ver transmisión en tiempo real
   - Tomar capturas o grabar

4. **Configuración**
   - Ajustar notificaciones
   - Configurar geocercas
   - Revisar auditoría de accesos

## 🔒 Seguridad y Privacidad

### Permisos Requeridos (Módulo Niño)

**Android:**
- `CAMERA` - Acceso a cámara
- `RECORD_AUDIO` - Acceso a micrófono
- `ACCESS_FINE_LOCATION` - Ubicación precisa
- `ACCESS_COARSE_LOCATION` - Ubicación aproximada
- `FOREGROUND_SERVICE` - Servicio en primer plano
- `SYSTEM_ALERT_WINDOW` - Overlay de pantalla
- `READ_EXTERNAL_STORAGE` - Lectura de almacenamiento
- `WRITE_EXTERNAL_STORAGE` - Escritura de almacenamiento

**iOS:**
- `NSCameraUsageDescription` - Acceso a cámara
- `NSMicrophoneUsageDescription` - Acceso a micrófono
- `NSLocationWhenInUseUsageDescription` - Ubicación en uso
- `NSLocationAlwaysUsageDescription` - Ubicación siempre

### Cifrado

- TLS 1.3 para todas las comunicaciones
- WebRTC con DTLS-SRTP para streaming
- Tokens JWT con expiración corta
- Hashing seguro de credenciales

### Transparencia

- Notificaciones configurables cuando se activa monitoreo
- Registro completo de accesos
- Consentimiento explícito en primera ejecución

## 📁 Estructura del Proyecto

```
airdroidKidsCopy/
├── child_module/          # Módulo Niño
│   ├── lib/
│   │   ├── main.dart
│   │   ├── services/      # Servicios de cámara, audio, ubicación
│   │   ├── screens/       # Pantallas UI
│   │   ├── models/        # Modelos de datos
│   │   └── utils/         # Utilidades y helpers
│   └── pubspec.yaml
├── parent_module/         # Módulo Padre
│   ├── lib/
│   │   ├── main.dart
│   │   ├── services/      # Servicios de comunicación
│   │   ├── screens/       # Pantallas UI
│   │   ├── models/        # Modelos de datos
│   │   └── utils/         # Utilidades y helpers
│   └── pubspec.yaml
├── supabase/
│   └── schema.sql         # Esquema de base de datos
└── README.md
```

## 🧪 Testing

```bash
# Módulo Niño
cd child_module
flutter test

# Módulo Padre
cd parent_module
flutter test
```

## 📦 Build para Producción

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contribuciones

Este es un proyecto educativo. Las contribuciones son bienvenidas siguiendo las mejores prácticas de seguridad y privacidad.

## 📄 Licencia

Este proyecto es de código abierto para fines educativos. Úsalo responsablemente.

## ⚖️ Consideraciones Legales

- Cumple con GDPR (Europa), COPPA (USA) y leyes locales
- Requiere consentimiento explícito
- No usar para vigilancia ilegal
- El desarrollador no se hace responsable del uso indebido

## 📞 Soporte

Para preguntas o problemas, abrir un issue en el repositorio.

---

**Desarrollado con Flutter 💙 y Supabase 🟢**

