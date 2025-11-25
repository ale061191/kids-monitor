# Guía de Configuración - AirDroid Kids Copy

Esta guía te ayudará a configurar y ejecutar la aplicación de control parental.

## 📋 Requisitos Previos

### Software Necesario

1. **Flutter SDK** (>= 3.0.0)
   ```bash
   # Verificar instalación
   flutter --version
   ```

2. **Dart SDK** (>= 3.0.0)
   ```bash
   dart --version
   ```

3. **Android Studio** o **Xcode** (para desarrollo móvil)
   - Android Studio para desarrollo Android
   - Xcode para desarrollo iOS (solo macOS)

4. **Cuenta de Supabase** (gratuita)
   - Regístrate en [https://supabase.com](https://supabase.com)

## 🔧 Configuración de Supabase

### Paso 1: Crear Proyecto en Supabase

1. Inicia sesión en [Supabase](https://supabase.com)
2. Haz clic en "New Project"
3. Completa los datos:
   - **Name**: AirDroidKidsCopy
   - **Database Password**: Elige una contraseña segura
   - **Region**: Selecciona la más cercana
4. Espera a que el proyecto se cree (1-2 minutos)

### Paso 2: Ejecutar Script SQL

1. Ve a **SQL Editor** en el panel izquierdo
2. Haz clic en **New Query**
3. Copia y pega el contenido de `supabase/schema.sql`
4. Haz clic en **Run** para ejecutar el script
5. Verifica que todas las tablas se hayan creado correctamente

### Paso 3: Configurar Storage Buckets

1. Ve a **Storage** en el panel izquierdo
2. Crea los siguientes buckets:
   - **snapshots**: Para capturas de fotos
   - **audio-recordings**: Para grabaciones de audio
   - **video-recordings**: Para grabaciones de video (opcional)

3. Para cada bucket, configura las políticas de acceso:
   ```sql
   -- Policy para snapshots
   CREATE POLICY "Allow authenticated users to upload snapshots"
   ON storage.objects FOR INSERT
   TO authenticated
   WITH CHECK (bucket_id = 'snapshots');

   CREATE POLICY "Allow users to view their snapshots"
   ON storage.objects FOR SELECT
   TO authenticated
   USING (bucket_id = 'snapshots');
   ```

### Paso 4: Habilitar Realtime

1. Ve a **Database** > **Replication**
2. Habilita las siguientes tablas para Realtime:
   - `devices`
   - `commands`
   - `webrtc_sessions`
   - `location_history`
   - `geofence_events`

### Paso 5: Obtener Credenciales

1. Ve a **Settings** > **API**
2. Copia los siguientes valores:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon/public key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

## 📱 Configuración de los Módulos

### Módulo Niño (Child Module)

#### 1. Instalar Dependencias

```bash
cd child_module
flutter pub get
```

#### 2. Configurar Credenciales

Crea un archivo `.env` en `child_module/`:

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=tu_anon_key_aqui
```

O edita `child_module/lib/config/app_config.dart`:

```dart
static const String supabaseUrl = 'https://xxxxx.supabase.co';
static const String supabaseAnonKey = 'tu_anon_key_aqui';
```

#### 3. Configurar Android

Edita `child_module/android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.tuempresa.safekids_monitor"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

#### 4. Ejecutar en Dispositivo

```bash
# Conecta un dispositivo Android o inicia un emulador
flutter devices

# Ejecuta la aplicación
flutter run
```

### Módulo Padre (Parent Module)

#### 1. Instalar Dependencias

```bash
cd parent_module
flutter pub get
```

#### 2. Configurar Credenciales

Crea un archivo `.env` en `parent_module/`:

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=tu_anon_key_aqui
```

O edita `parent_module/lib/config/app_config.dart`:

```dart
static const String supabaseUrl = 'https://xxxxx.supabase.co';
static const String supabaseAnonKey = 'tu_anon_key_aqui';
```

#### 3. Configurar Android

Edita `parent_module/android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.tuempresa.safekids_control"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

#### 4. Ejecutar en Dispositivo

```bash
# Conecta un dispositivo Android o inicia un emulador
flutter devices

# Ejecuta la aplicación
flutter run
```

## 🧪 Prueba del Sistema

### 1. Configurar Módulo Niño

1. Abre la app en el dispositivo del niño
2. Acepta el consentimiento informado
3. Otorga todos los permisos solicitados
4. Registra el dispositivo con:
   - Nombre del dispositivo: "Teléfono de Juan"
   - Email: juan@ejemplo.com
   - Contraseña: (mínimo 6 caracteres)
5. Guarda el código de vinculación generado

### 2. Configurar Módulo Padre

1. Abre la app en el dispositivo del padre
2. Regístrate con:
   - Nombre: "Padre/Madre"
   - Email: padre@ejemplo.com
   - Contraseña: (mínimo 6 caracteres)
3. En la pantalla principal, toca "Vincular dispositivo"
4. Ingresa el código de vinculación del módulo niño
5. Confirma la vinculación

### 3. Probar Funcionalidades

#### Videovigilancia
1. En el módulo padre, selecciona el dispositivo
2. Toca "Iniciar video"
3. Verifica que se muestre el stream de video

#### Audio Ambiente
1. Toca "Iniciar audio"
2. Verifica que se escuche el audio del dispositivo

#### Ubicación GPS
1. Toca "Obtener ubicación"
2. Verifica que se muestre la ubicación en el mapa

#### Capturas
1. Toca "Tomar foto"
2. Verifica que la foto se guarde y aparezca en el historial

## 🔒 Seguridad

### Mejores Prácticas

1. **Nunca** commits credenciales al repositorio
2. Usa variables de entorno en producción
3. Habilita autenticación de dos factores en Supabase
4. Revisa regularmente los logs de actividad
5. Actualiza las dependencias periódicamente

### Configuración de Producción

Para producción, considera:

1. **Cifrado E2E**: Implementar cifrado adicional para streams
2. **Rate Limiting**: Limitar comandos por minuto
3. **Monitoreo**: Configurar alertas en Supabase
4. **Backup**: Configurar backups automáticos de la base de datos

## 🐛 Solución de Problemas

### Error: "Failed to connect to Supabase"

**Solución:**
- Verifica que las credenciales sean correctas
- Comprueba tu conexión a internet
- Verifica que el proyecto de Supabase esté activo

### Error: "Permission denied"

**Solución:**
- Verifica que todos los permisos estén otorgados
- En Android 11+, algunos permisos requieren configuración adicional
- Revisa las políticas RLS en Supabase

### Error: "Device not found"

**Solución:**
- Verifica que el código de vinculación sea correcto
- Comprueba que el dispositivo esté registrado en la base de datos
- Revisa los logs en Supabase

### Video/Audio no funciona

**Solución:**
- Verifica que los permisos de cámara/micrófono estén otorgados
- Comprueba que WebRTC esté configurado correctamente
- Revisa la configuración de ICE servers

## 📚 Recursos Adicionales

- [Documentación de Flutter](https://flutter.dev/docs)
- [Documentación de Supabase](https://supabase.com/docs)
- [WebRTC Documentation](https://webrtc.org/getting-started/overview)
- [Flutter WebRTC Plugin](https://pub.dev/packages/flutter_webrtc)

## 🆘 Soporte

Si encuentras problemas:

1. Revisa esta guía completa
2. Consulta los logs de la aplicación
3. Revisa los logs de Supabase
4. Abre un issue en el repositorio con:
   - Descripción del problema
   - Pasos para reproducir
   - Logs relevantes
   - Versión de Flutter y dependencias

## ⚖️ Consideraciones Legales

**IMPORTANTE**: Esta aplicación debe usarse únicamente con el consentimiento explícito del usuario del dispositivo monitoreado. El uso sin consentimiento puede violar leyes de privacidad locales e internacionales.

- ✅ Uso legal: Monitoreo parental con consentimiento
- ❌ Uso ilegal: Vigilancia sin consentimiento, espionaje

Asegúrate de cumplir con:
- GDPR (Europa)
- COPPA (USA)
- Leyes locales de privacidad y protección de datos

