# 🧪 Guía de Pruebas - SafeKids Parental Control

## Preparación para Pruebas

### Requisitos Previos
- ✅ Flutter SDK instalado
- ✅ Dispositivo Android/iOS o emulador configurado
- ✅ Supabase configurado con credenciales
- ✅ Todas las dependencias instaladas

---

## 🔍 Verificación Previa

### 1. Verificar Dispositivos Disponibles
```bash
flutter devices
```

**Resultado esperado**: Debe mostrar al menos un dispositivo conectado o emulador disponible.

### 2. Verificar Conectividad con Supabase
Abre tu navegador y verifica que puedes acceder a:
- `https://carueglqdqdkmvipfufg.supabase.co`

---

## 📱 Prueba del Módulo Child (Dispositivo del Niño)

### Paso 1: Navegar al Módulo
```bash
cd child_module
```

### Paso 2: Ejecutar la Aplicación
```bash
flutter run
```

### Paso 3: Qué Esperar Ver

#### Pantalla 1: Splash Screen
- Logo o nombre de la app
- Animación de carga
- Duración: 2-3 segundos

#### Pantalla 2: Consent Screen (Primera vez)
- **Título**: "Consentimiento Informado"
- **Contenido**: Explicación sobre el monitoreo
- **Opciones**:
  - ✅ Checkbox "He leído y acepto"
  - 🔘 Botón "Continuar"

#### Pantalla 3: Permissions Screen
- Lista de permisos requeridos:
  - 📷 Cámara
  - 🎤 Micrófono
  - 📍 Ubicación
  - 🔔 Notificaciones
  - 📦 Almacenamiento
- Estado de cada permiso (Concedido/Denegado)
- Botón "Solicitar Permisos"

#### Pantalla 4: Registration Screen
- Campo para código de vinculación
- Botón para generar QR
- Botón "Vincular Dispositivo"

#### Pantalla 5: Home Screen (Después de vinculación)
- **Tab 1: Device Info**
  - Nombre del dispositivo
  - ID único
  - Última conexión
  - Estado de batería

- **Tab 2: Monitoring Status**
  - Estado de monitoreo (Activo/Inactivo)
  - Controles de cámara
  - Controles de audio
  - Permisos activos

- **Tab 3: Settings**
  - Configuración de notificaciones
  - Configuración de privacidad
  - Desvincular dispositivo

### Problemas Comunes

#### Error: "Supabase not initialized"
**Solución**: Verifica que las credenciales en `lib/config/app_config.dart` sean correctas.

#### Error: Permisos no se solicitan
**Solución**: En Android, ve a Configuración → Apps → Tu App → Permisos y concédelos manualmente.

#### Error: La app se cierra al abrir
**Solución**: 
```bash
flutter clean
flutter pub get
flutter run
```

---

## 👨‍👩‍👧 Prueba del Módulo Parent (Control Parental)

### Paso 1: Navegar al Módulo
```bash
cd ../parent_module
```

### Paso 2: Ejecutar la Aplicación
```bash
flutter run
```

### Paso 3: Qué Esperar Ver

#### Pantalla 1: Splash Screen
- Logo de control parental
- Verificación de autenticación

#### Pantalla 2: Login/Register Screen
- **Login**:
  - Campo Email
  - Campo Contraseña
  - Botón "Iniciar Sesión"
  
- **Register**:
  - Campo Email
  - Campo Contraseña
  - Campo Confirmar Contraseña
  - Botón "Registrarse"

#### Pantalla 3: Dashboard (Después de login)
- **Header**:
  - Título "Mis Dispositivos"
  - Contador de dispositivos vinculados
  - Botón "Agregar Dispositivo"

- **Lista de Dispositivos**:
  - Tarjetas con información de cada dispositivo
  - Estado online/offline
  - Última actividad
  - Alertas pendientes (si hay)

- **Botón Flotante**: "+" para vincular nuevo dispositivo

#### Pantalla 4: Device Detail Screen (Al seleccionar un dispositivo)
- **Información del Dispositivo**:
  - Nombre
  - Estado
  - Última ubicación
  - Nivel de batería

- **Controles de Monitoreo**:
  - 📷 Ver Cámara Frontal
  - 📷 Ver Cámara Trasera
  - 🎤 Escuchar Ambiente
  - 📸 Tomar Foto
  - 🎙️ Grabar Audio

- **Tabs**:
  - 📊 Dashboard
  - 📍 Ubicación
  - 📁 Galería de Medios
  - ⚙️ Configuración

#### Pantalla 5: Location Screen
- Mapa con ubicación actual del dispositivo
- Historial de ubicaciones
- Geocercas configuradas
- Botón para crear nueva geocerca

#### Pantalla 6: Media Gallery
- **Sección Fotos**:
  - Grid de snapshots tomados
  - Fecha y hora de cada foto

- **Sección Grabaciones**:
  - Lista de grabaciones de audio
  - Duración
  - Botón de reproducción

### Problemas Comunes

#### Error: "Invalid login credentials"
**Solución**: 
1. Verifica que hayas creado un usuario en Supabase
2. O usa el flujo de registro para crear una cuenta nueva

#### Error: No se ven dispositivos vinculados
**Solución**: 
1. Primero vincula el dispositivo child con el código generado
2. Refresca la pantalla (pull to refresh)

#### Error: Comandos no responden
**Solución**: 
1. Verifica que el dispositivo child esté online
2. Comprueba la conexión a internet de ambos dispositivos
3. Verifica que Supabase Realtime esté habilitado

---

## 🔗 Prueba de Vinculación (End-to-End)

### Escenario Completo

1. **En Parent Module**:
   - Inicia sesión o regístrate
   - Presiona "Agregar Dispositivo"
   - Copia el código de vinculación generado (ej: `ABC123XYZ`)

2. **En Child Module**:
   - Completa el flujo de consent y permisos
   - En Registration Screen, ingresa el código copiado
   - Presiona "Vincular Dispositivo"

3. **Verificación**:
   - En Parent Module, deberías ver aparecer el nuevo dispositivo
   - El estado debería mostrar "Online"
   - En Child Module, deberías ver "Dispositivo vinculado exitosamente"

4. **Prueba de Control Remoto**:
   - En Parent Module, selecciona el dispositivo vinculado
   - Presiona "Ver Cámara Frontal"
   - En Child Module, deberías ver una notificación "Cámara activada remotamente"
   - En Parent Module, deberías ver el stream de video

---

## 🐛 Debugging

### Ver Logs en Tiempo Real
```bash
flutter logs
```

### Limpiar Caché
```bash
flutter clean
flutter pub get
```

### Reinstalar Aplicación
```bash
flutter run --uninstall-first
```

### Ver Errores de Supabase
1. Ve a tu Dashboard de Supabase
2. Navega a "Logs" → "API Logs"
3. Busca errores recientes

---

## 📊 Checklist de Pruebas

### Child Module
- [ ] Splash screen se muestra correctamente
- [ ] Consent screen funciona
- [ ] Permisos se solicitan correctamente
- [ ] Código de vinculación se ingresa sin errores
- [ ] Home screen se muestra después de vinculación
- [ ] Tabs de navegación funcionan
- [ ] Notificaciones se reciben cuando hay actividad remota

### Parent Module
- [ ] Splash screen se muestra correctamente
- [ ] Login/Register funciona
- [ ] Dashboard muestra dispositivos vinculados
- [ ] Device cards muestran información correcta
- [ ] Device detail screen se abre al tocar un dispositivo
- [ ] Controles de monitoreo están disponibles
- [ ] Location screen muestra mapa
- [ ] Media gallery carga contenido

### Integración
- [ ] Vinculación de dispositivos funciona
- [ ] Estado online/offline se actualiza en tiempo real
- [ ] Comandos remotos (cámara, audio) funcionan
- [ ] Notificaciones push se reciben
- [ ] Datos se sincronizan entre dispositivos

---

## 🎯 Próximos Tests Recomendados

### Tests Manuales
1. **Prueba de Permisos**: Denegar un permiso y ver cómo reacciona la app
2. **Prueba de Conexión**: Desconectar internet y reconectar
3. **Prueba de Background**: Poner la app en background y verificar que siga funcionando
4. **Prueba de Batería**: Verificar consumo de batería durante uso prolongado

### Tests Automatizados (Futuro)
```bash
# Widget tests
flutter test

# Integration tests
flutter drive --target=test_driver/app.dart
```

---

## 📝 Reportar Problemas

Si encuentras errores durante las pruebas, documenta:

1. **Módulo**: Child o Parent
2. **Pantalla**: Donde ocurrió el error
3. **Acción**: Qué estabas haciendo
4. **Error**: Mensaje de error completo
5. **Logs**: Copia de `flutter logs`
6. **Dispositivo**: Android/iOS, versión del sistema

---

## ✅ Criterios de Éxito

La aplicación está lista para producción cuando:

- ✅ Todos los flujos principales funcionan sin crashes
- ✅ No hay errores críticos en los logs
- ✅ La vinculación de dispositivos es estable
- ✅ Los comandos remotos responden en menos de 2 segundos
- ✅ No hay pérdida de datos durante desconexiones
- ✅ La interfaz es fluida (60 FPS)
- ✅ El consumo de batería es aceptable

---

**¡Buena suerte con las pruebas!** 🚀

*Si todo funciona correctamente, el proyecto está listo para las siguientes fases de desarrollo.*

