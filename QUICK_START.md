# ⚡ Inicio Rápido - 5 Minutos

Esta guía te llevará de 0 a 100 en solo 5 minutos.

## 🎯 Lo Que Necesitas Hacer

### ✅ Paso 1: Crear Cuenta en Supabase (2 minutos)

1. Abre [https://supabase.com](https://supabase.com)
2. Haz clic en "Start your project"
3. Regístrate con GitHub o email
4. Crea un nuevo proyecto:
   - Name: `AirDroidKidsCopy`
   - Password: [Elige una]
   - Region: [La más cercana]
5. ⏱️ Espera 1-2 minutos...

### ✅ Paso 2: Configurar Base de Datos (1 minuto)

1. En el panel de Supabase, ve a **SQL Editor**
2. Haz clic en **New Query**
3. Abre el archivo `supabase/schema.sql` en tu editor
4. **Copia TODO el contenido** (Ctrl+A, Ctrl+C)
5. **Pega** en el SQL Editor de Supabase (Ctrl+V)
6. Haz clic en **Run** (o Ctrl+Enter)
7. ✅ Verifica que diga "Success"

8. Repite con `supabase/schema_updated.sql`:
   - New Query
   - Copia y pega
   - Run
   - ✅ Success

### ✅ Paso 3: Crear Buckets de Storage (30 segundos)

1. Ve a **Storage** en el menú lateral
2. Haz clic en **New bucket**
3. Crea 3 buckets (marca "Public" en todos):
   - `snapshots`
   - `audio-recordings`
   - `video-recordings`

### ✅ Paso 4: Habilitar Realtime (30 segundos)

1. Ve a **Database** > **Replication**
2. Busca y habilita estas tablas (marca el checkbox):
   - devices
   - commands
   - webrtc_sessions
   - location_history
   - geofence_events
   - streams
   - alerts

### ✅ Paso 5: Copiar Credenciales (30 segundos)

1. Ve a **Settings** > **API**
2. Copia estos dos valores:

```
Project URL: https://xxxxx.supabase.co
anon/public key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### ✅ Paso 6: Configurar Apps (1 minuto)

**Módulo Niño:**

Abre `child_module/lib/config/app_config.dart` y reemplaza:

```dart
static const String supabaseUrl = 'PEGA_TU_PROJECT_URL_AQUI';
static const String supabaseAnonKey = 'PEGA_TU_ANON_KEY_AQUI';
```

**Módulo Padre:**

Abre `parent_module/lib/config/app_config.dart` y reemplaza:

```dart
static const String supabaseUrl = 'PEGA_TU_PROJECT_URL_AQUI';
static const String supabaseAnonKey = 'PEGA_TU_ANON_KEY_AQUI';
```

### ✅ Paso 7: Instalar Dependencias (30 segundos)

```bash
# Terminal 1 - Módulo Niño
cd child_module
flutter pub get

# Terminal 2 - Módulo Padre
cd parent_module
flutter pub get
```

## 🚀 ¡Listo para Ejecutar!

### Ejecutar Módulo Niño

```bash
cd child_module
flutter run
```

### Ejecutar Módulo Padre

```bash
cd parent_module
flutter run
```

## 🎮 Primer Uso

### En el Módulo Niño:

1. Acepta el consentimiento
2. Otorga TODOS los permisos
3. Registra:
   - Nombre: "Test Device"
   - Email: child@test.com
   - Password: test123
4. **GUARDA EL CÓDIGO** que aparece (8 caracteres)

### En el Módulo Padre:

1. Regístrate:
   - Nombre: "Parent Test"
   - Email: parent@test.com
   - Password: test123
2. Toca "Vincular dispositivo"
3. Ingresa el código del módulo niño
4. ¡Selecciona el dispositivo y empieza a monitorear!

## 🎯 Probar Funcionalidades

### 1. Tomar Foto
- Selecciona dispositivo
- Toca "Tomar foto"
- Ve a tab "Historial" > "Fotos"

### 2. Video en Vivo
- Toca "Cámara frontal"
- Espera conexión
- ¡Mira el streaming!

### 3. Ubicación
- Toca "Obtener ubicación"
- Ve a tab "Ubicación"
- Verifica el mapa

## 🐛 Problemas Comunes

### "Supabase connection failed"
**Solución**: Verifica que copiaste bien las credenciales (URL y key)

### "Permission denied"
**Solución**: Ve a Configuración > Apps > SafeKids > Permisos y otorga todos

### "Device not found"
**Solución**: Verifica que el código sea exacto (8 caracteres, sin espacios)

## 📊 Verificar en Supabase

Para ver que todo funciona:

1. Ve a **Table Editor** > **devices**
   - Deberías ver tu dispositivo registrado

2. Ve a **Table Editor** > **commands**
   - Verás los comandos enviados

3. Ve a **Storage** > **snapshots**
   - Verás las fotos tomadas

## 🎉 ¡Felicidades!

Si llegaste hasta aquí, tu aplicación está funcionando perfectamente.

## 📚 Documentación Completa

Para más detalles, consulta:

- **README.md** - Visión general
- **SETUP_GUIDE.md** - Guía detallada
- **CONFIGURATION_SCRIPT.md** - Paso a paso completo
- **ARCHITECTURE.md** - Arquitectura técnica
- **IMPROVEMENTS_SUMMARY.md** - Nuevas funcionalidades

## 💡 Tips

1. **Mantén las credenciales seguras**: Nunca las subas a Git
2. **Usa .env en producción**: Para mayor seguridad
3. **Revisa los logs**: `flutter logs` para debugging
4. **Monitorea Supabase**: Dashboard > Logs para ver actividad

## 🆘 ¿Necesitas Ayuda?

Si algo no funciona:

1. Revisa este documento
2. Consulta CONFIGURATION_SCRIPT.md
3. Verifica los logs de Flutter
4. Revisa los logs de Supabase
5. Abre un issue con detalles

---

**¡Disfruta tu aplicación de control parental!** 🚀

**Tiempo total de configuración: ~5 minutos** ⏱️


