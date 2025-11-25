# 👨‍👩‍👧 Módulo Padre - Demo de Control Parental

## 🎯 Vista General

El **Módulo Padre** es la aplicación de control parental que permite a los padres monitorear y gestionar los dispositivos de sus hijos de forma remota.

---

## 📱 Pantallas Principales

### 1. Dashboard - Pantalla de Dispositivos
**Función**: Vista principal con todos los dispositivos vinculados

**Características**:
- 📊 Lista de dispositivos vinculados
- 🟢 Estado en tiempo real (En línea / Fuera de línea)
- 🔋 Nivel de batería
- 📍 Última ubicación conocida
- ⏰ Última actividad
- ➕ Botón flotante para vincular nuevos dispositivos

**Elementos visuales**:
```
┌─────────────────────────────────┐
│  SafeKids Control Parental  🔔 👤│
├─────────────────────────────────┤
│  Mis Dispositivos               │
│  2 dispositivos vinculados      │
│                                 │
│  ┌───────────────────────────┐ │
│  │ 📱 Teléfono de María      │ │
│  │ 🟢 En línea              │ │
│  │ ⏰ Ahora | 🔋 85% | 📍 Casa│ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ 📱 Tablet de Juan         │ │
│  │ ⚫ Fuera de línea         │ │
│  │ ⏰ Hace 2h | 🔋 45% | 📍 Esc│ │
│  └───────────────────────────┘ │
│                                 │
│         [+ Vincular Dispositivo]│
└─────────────────────────────────┘
```

---

### 2. Detalle del Dispositivo
**Función**: Controles de monitoreo para un dispositivo específico

**Controles disponibles**:
1. **📷 Cámara Frontal** - Ver transmisión en vivo de la cámara frontal
2. **📷 Cámara Trasera** - Ver transmisión en vivo de la cámara trasera
3. **🎤 Escuchar Audio** - Escuchar el ambiente en tiempo real
4. **📸 Tomar Foto** - Capturar una foto instantánea
5. **🎙️ Grabar Audio** - Iniciar grabación de audio
6. **📍 Ubicación Actual** - Ver ubicación GPS en tiempo real

**Información del dispositivo**:
- Estado de conexión
- Nivel de batería
- Última ubicación
- Última actividad

**Layout**:
```
┌─────────────────────────────────┐
│ ← Teléfono de María             │
├─────────────────────────────────┤
│  Controles de Monitoreo         │
│                                 │
│  ┌──────┐  ┌──────┐            │
│  │  📷  │  │  📷  │            │
│  │Frontal│  │Trasera│           │
│  └──────┘  └──────┘            │
│                                 │
│  ┌──────┐  ┌──────┐            │
│  │  🎤  │  │  📸  │            │
│  │ Audio │  │ Foto │            │
│  └──────┘  └──────┘            │
│                                 │
│  ┌──────┐  ┌──────┐            │
│  │  🎙️  │  │  📍  │            │
│  │Grabar │  │Ubica.│            │
│  └──────┘  └──────┘            │
│                                 │
│  Información del Dispositivo    │
│  ┌───────────────────────────┐ │
│  │ Estado: 🟢 En línea       │ │
│  │ Batería: 🔋 85%           │ │
│  │ Ubicación: 📍 Casa        │ │
│  │ Actividad: ⏰ Hace 2 min  │ │
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

---

### 3. Ubicación y Geocercas
**Función**: Monitoreo de ubicación GPS y gestión de geocercas

**Características**:
- 🗺️ Mapa interactivo con ubicación en tiempo real
- 📍 Historial de ubicaciones
- ⭕ Geocercas (zonas seguras/restringidas)
- 🚨 Alertas al entrar/salir de geocercas

**Elementos**:
```
┌─────────────────────────────────┐
│  Mapa de Ubicaciones            │
│                                 │
│  ┌───────────────────────────┐ │
│  │                           │ │
│  │      🗺️ Mapa             │ │
│  │                           │ │
│  │   📍 Ubicación actual     │ │
│  │   ⭕ Geocercas            │ │
│  │                           │ │
│  └───────────────────────────┘ │
│                                 │
│  Geocercas Activas:             │
│  • Casa (500m)                  │
│  • Escuela (300m)               │
│  • Parque (200m)                │
└─────────────────────────────────┘
```

---

### 4. Galería de Medios
**Función**: Visualización de fotos y grabaciones capturadas

**Secciones**:

#### Fotos Recientes
- Grid de fotos capturadas
- Fecha y hora de captura
- Dispositivo de origen
- Visualización en pantalla completa

#### Grabaciones de Audio
- Lista de grabaciones
- Duración de cada grabación
- Fecha y hora
- Reproductor integrado

**Layout**:
```
┌─────────────────────────────────┐
│  Galería de Medios              │
│                                 │
│  Fotos Recientes                │
│  ┌───┐ ┌───┐ ┌───┐            │
│  │ 📷│ │ 📷│ │ 📷│            │
│  └───┘ └───┘ └───┘            │
│  ┌───┐ ┌───┐ ┌───┐            │
│  │ 📷│ │ 📷│ │ 📷│            │
│  └───┘ └───┘ └───┘            │
│                                 │
│  Grabaciones de Audio           │
│  ┌───────────────────────────┐ │
│  │ 🎵 Grabación 1  2:35  ▶️  │ │
│  │ 24/11/2025 10:30          │ │
│  └───────────────────────────┘ │
│  ┌───────────────────────────┐ │
│  │ 🎵 Grabación 2  1:45  ▶️  │ │
│  │ 24/11/2025 09:15          │ │
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

---

### 5. Configuración
**Función**: Ajustes de la aplicación y cuenta

**Secciones**:

#### Cuenta
- 👤 Perfil - Editar información personal
- 🔒 Seguridad - Cambiar contraseña

#### Notificaciones
- 🔔 Alertas - Configurar notificaciones
- 🔊 Sonidos - Tonos de alerta

#### Privacidad
- 🛡️ Política de Privacidad
- ❓ Ayuda - Centro de soporte

---

## 🎨 Diseño y UX

### Colores Principales
- **Primario**: Azul (`Colors.blue`)
- **Online**: Verde (`Colors.green`)
- **Offline**: Gris (`Colors.grey`)
- **Alertas**: Rojo (`Colors.red`)
- **Advertencias**: Naranja (`Colors.orange`)

### Navegación
- **Bottom Navigation Bar** con 4 secciones:
  1. 📱 Dispositivos
  2. 📍 Ubicación
  3. 📁 Galería
  4. ⚙️ Ajustes

### Interacciones
- **Tap** en tarjeta de dispositivo → Abre detalle
- **Tap** en control → Activa función
- **FAB** (Botón flotante) → Vincular nuevo dispositivo
- **Swipe** para refrescar listas

---

## 🔗 Flujo de Vinculación

### Paso 1: Generar Código
```
Padre presiona "Vincular Dispositivo"
     ↓
Se genera código único (ej: ABC123XYZ)
     ↓
Padre muestra código al niño
```

### Paso 2: Vincular en Dispositivo Hijo
```
Niño ingresa código en su dispositivo
     ↓
Dispositivo se registra en Supabase
     ↓
Vinculación confirmada
```

### Paso 3: Confirmación
```
Dispositivo aparece en lista del padre
     ↓
Estado: "En línea"
     ↓
Controles disponibles
```

---

## 🔐 Seguridad y Privacidad

### Características de Seguridad
- ✅ Autenticación con email/contraseña
- ✅ Tokens temporales para comandos críticos
- ✅ Cifrado de transmisiones (TLS/WebRTC)
- ✅ Row Level Security (RLS) en Supabase

### Privacidad
- 📝 Registro de actividad de acceso
- 🔔 Notificaciones en dispositivo hijo (configurable)
- 📋 Consentimiento informado requerido
- 🗑️ Opción de eliminar datos

---

## 📊 Datos en Tiempo Real

### Información Sincronizada
1. **Estado del Dispositivo**
   - Online/Offline
   - Batería
   - Última actividad

2. **Ubicación GPS**
   - Coordenadas actuales
   - Historial de movimiento
   - Eventos de geocerca

3. **Alertas**
   - Geocercas
   - Batería baja
   - Permisos revocados
   - Actividad inusual

---

## 🎯 Funcionalidades Clave

### Monitoreo en Tiempo Real
- ✅ Video en vivo (cámara frontal/trasera)
- ✅ Audio ambiente en tiempo real
- ✅ Ubicación GPS actualizada
- ✅ Estado de batería

### Captura de Medios
- ✅ Tomar fotos remotamente
- ✅ Grabar audio ambiente
- ✅ Almacenamiento en Supabase Storage
- ✅ Galería organizada por fecha

### Geocercas
- ✅ Crear zonas seguras/restringidas
- ✅ Radio configurable (50m - 5km)
- ✅ Alertas automáticas
- ✅ Visualización en mapa

### Gestión de Dispositivos
- ✅ Múltiples dispositivos por cuenta
- ✅ Nombres personalizados
- ✅ Desvincular dispositivos
- ✅ Historial de actividad

---

## 🚀 Tecnologías Utilizadas

- **Flutter** - Framework multiplataforma
- **Material Design 3** - Sistema de diseño
- **Supabase** - Backend (Auth, Database, Realtime, Storage)
- **WebRTC** - Transmisión de video/audio
- **Google Maps** (futuro) - Mapas interactivos

---

## 📱 Compatibilidad

### Plataformas Soportadas
- ✅ Android
- ✅ iOS
- ✅ Web (demo/visualización)

### Requisitos
- **Android**: 6.0 (API 23) o superior
- **iOS**: 12.0 o superior
- **Web**: Chrome, Firefox, Safari (última versión)

---

## 🎉 Estado Actual

**Versión Demo**: ✅ Funcional en Web  
**UI Completa**: ✅ Todas las pantallas diseñadas  
**Interacciones**: ✅ Navegación y botones funcionando  
**Backend**: ✅ Supabase configurado  
**Funcionalidades reales**: ⏳ Requiere dispositivos móviles

---

## 📝 Próximos Pasos

1. **Probar en dispositivo Android/iOS**
   ```bash
   flutter run -d android
   ```

2. **Implementar funcionalidades reales**
   - Conexión WebRTC
   - Comandos remotos
   - Sincronización en tiempo real

3. **Integrar mapas**
   - Google Maps API
   - Geocercas interactivas

4. **Optimizar rendimiento**
   - Caché de imágenes
   - Lazy loading
   - Compresión de medios

---

**¡La interfaz del módulo padre está lista para explorar!** 🎊

Busca la ventana de Chrome que dice "SafeKids Control - Demo" para ver la aplicación funcionando.

