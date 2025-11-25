# 🚀 Script de Configuración Automatizada

Este documento contiene todos los pasos necesarios para configurar y ejecutar la aplicación.

## 📋 Pre-requisitos

Antes de comenzar, asegúrate de tener instalado:

- ✅ Flutter SDK (>= 3.0.0)
- ✅ Dart SDK (>= 3.0.0)
- ✅ Android Studio o Xcode
- ✅ Git

## 🔧 Paso 1: Configurar Supabase

### 1.1 Crear Proyecto

1. Ve a [https://supabase.com](https://supabase.com)
2. Crea una cuenta o inicia sesión
3. Haz clic en "New Project"
4. Completa:
   - **Name**: AirDroidKidsCopy
   - **Database Password**: [Elige una contraseña segura]
   - **Region**: [Selecciona la más cercana]
5. Espera 1-2 minutos a que se cree el proyecto

### 1.2 Ejecutar Schema SQL

1. En el panel de Supabase, ve a **SQL Editor**
2. Haz clic en **New Query**
3. Copia y pega el contenido completo de `supabase/schema.sql`
4. Haz clic en **Run** (o presiona Ctrl/Cmd + Enter)
5. Verifica que aparezca "Success" sin errores

### 1.3 Ejecutar Schema Actualizado (Nuevas Tablas)

1. En el mismo SQL Editor, crea otra **New Query**
2. Copia y pega el contenido de `supabase/schema_updated.sql`
3. Haz clic en **Run**
4. Verifica que se hayan creado las nuevas tablas:
   - streams
   - alerts
   - device_status_history
   - screen_time
   - app_usage

### 1.4 Configurar Storage Buckets

1. Ve a **Storage** en el menú lateral
2. Crea los siguientes buckets (haz clic en "New bucket"):

   **Bucket 1: snapshots**
   - Name: `snapshots`
   - Public: ✅ (marcado)
   - Haz clic en "Create bucket"

   **Bucket 2: audio-recordings**
   - Name: `audio-recordings`
   - Public: ✅ (marcado)
   - Haz clic en "Create bucket"

   **Bucket 3: video-recordings** (opcional)
   - Name: `video-recordings`
   - Public: ✅ (marcado)
   - Haz clic en "Create bucket"

### 1.5 Habilitar Realtime

1. Ve a **Database** > **Replication**
2. Habilita las siguientes tablas (marca el checkbox):
   - ✅ devices
   - ✅ commands
   - ✅ webrtc_sessions
   - ✅ location_history
   - ✅ geofence_events
   - ✅ streams
   - ✅ alerts
   - ✅ device_status_history

### 1.6 Obtener Credenciales

1. Ve a **Settings** > **API**
2. Copia y guarda estos valores:
   ```
   Project URL: https://xxxxx.supabase.co
   anon/public key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

## 📱 Paso 2: Configurar Módulo Niño

### 2.1 Instalar Dependencias

```bash
cd child_module
flutter pub get
```

### 2.2 Configurar Credenciales

Edita el archivo `child_module/lib/config/app_config.dart`:

```dart
class AppConfig {
  static const String supabaseUrl = 'TU_URL_AQUI'; // Pega tu Project URL
  static const String supabaseAnonKey = 'TU_KEY_AQUI'; // Pega tu anon key
  
  // ... resto del archivo sin cambios
}
```

### 2.3 Configurar Android (Opcional)

Si quieres cambiar el ID de la aplicación, edita `child_module/android/app/build.gradle`:

```gradle
defaultConfig {
    applicationId "com.tuempresa.safekids_monitor"
    // ... resto sin cambios
}
```

### 2.4 Verificar Compilación

```bash
flutter analyze
flutter build apk --debug
```

## 📱 Paso 3: Configurar Módulo Padre

### 3.1 Instalar Dependencias

```bash
cd parent_module
flutter pub get
```

### 3.2 Configurar Credenciales

Edita el archivo `parent_module/lib/config/app_config.dart`:

```dart
class AppConfig {
  static const String supabaseUrl = 'TU_URL_AQUI'; // Pega tu Project URL
  static const String supabaseAnonKey = 'TU_KEY_AQUI'; // Pega tu anon key
  
  // ... resto del archivo sin cambios
}
```

### 3.3 Configurar Android (Opcional)

Si quieres cambiar el ID de la aplicación, edita `parent_module/android/app/build.gradle`:

```gradle
defaultConfig {
    applicationId "com.tuempresa.safekids_control"
    // ... resto sin cambios
}
```

### 3.4 Verificar Compilación

```bash
flutter analyze
flutter build apk --debug
```

## 🧪 Paso 4: Probar la Aplicación

### 4.1 Preparar Dispositivos

Necesitarás 2 dispositivos Android o emuladores:
- **Dispositivo 1**: Para el módulo niño
- **Dispositivo 2**: Para el módulo padre

### 4.2 Ejecutar Módulo Niño

```bash
cd child_module

# Listar dispositivos conectados
flutter devices

# Ejecutar en dispositivo específico
flutter run -d [DEVICE_ID]
```

**En la app:**
1. Acepta el consentimiento
2. Otorga TODOS los permisos
3. Registra el dispositivo:
   - Nombre: "Teléfono de Juan"
   - Email: juan@test.com
   - Contraseña: test123
4. **IMPORTANTE**: Guarda el código de 8 dígitos que aparece

### 4.3 Ejecutar Módulo Padre

```bash
cd parent_module

# Ejecutar en otro dispositivo
flutter run -d [DEVICE_ID_2]
```

**En la app:**
1. Regístrate:
   - Nombre: "Padre Test"
   - Email: padre@test.com
   - Contraseña: test123
2. En el dashboard, toca "Vincular dispositivo"
3. Ingresa el código del módulo niño
4. ¡Listo! Ahora puedes monitorear

### 4.4 Probar Funcionalidades

1. **Tomar Foto**:
   - Selecciona el dispositivo
   - Toca "Tomar foto"
   - Verifica que aparezca en el historial

2. **Video en Vivo**:
   - Toca "Cámara frontal"
   - Espera a que se establezca la conexión
   - Verifica el streaming

3. **Audio Ambiente**:
   - Toca "Escuchar ambiente"
   - Verifica que se escuche el audio

4. **Ubicación**:
   - Toca "Obtener ubicación"
   - Ve a la pestaña "Ubicación"
   - Verifica el mapa

## 🐛 Solución de Problemas

### Error: "Supabase connection failed"

**Solución:**
1. Verifica que las credenciales sean correctas
2. Comprueba tu conexión a internet
3. Verifica que el proyecto de Supabase esté activo

### Error: "Permission denied"

**Solución:**
1. Ve a Configuración del dispositivo > Apps > SafeKids Monitor
2. Otorga todos los permisos manualmente
3. Reinicia la app

### Error: "Device not found"

**Solución:**
1. Verifica que el código sea correcto (8 caracteres)
2. Comprueba que el dispositivo niño esté registrado
3. Ve a Supabase > Table Editor > devices y verifica que exista

### Video/Audio no funciona

**Solución:**
1. Verifica que ambos dispositivos estén en línea
2. Comprueba los permisos de cámara/micrófono
3. Revisa la configuración de WebRTC en app_config.dart

## 📊 Verificar en Supabase

### Ver Dispositivos Registrados

1. Ve a **Table Editor** > **devices**
2. Deberías ver tu dispositivo con:
   - device_name
   - device_code
   - is_online = true

### Ver Comandos Enviados

1. Ve a **Table Editor** > **commands**
2. Verifica que los comandos tengan:
   - status = 'executed'
   - response con datos

### Ver Archivos Multimedia

1. Ve a **Storage** > **snapshots**
2. Deberías ver las fotos tomadas

## 🎉 ¡Configuración Completa!

Si llegaste hasta aquí y todo funciona, ¡felicidades! 🎊

Tu aplicación de control parental está completamente configurada y funcionando.

## 📚 Próximos Pasos

1. **Personalizar**: Cambia colores, iconos y textos
2. **Mejorar**: Agrega más funcionalidades
3. **Optimizar**: Mejora el rendimiento
4. **Publicar**: Prepara para producción

## 🆘 Necesitas Ayuda?

Si tienes problemas:

1. Revisa los logs de Flutter: `flutter logs`
2. Revisa los logs de Supabase: Dashboard > Logs
3. Consulta la documentación en README.md
4. Abre un issue con detalles completos

---

**¡Disfruta tu aplicación de control parental!** 🚀


