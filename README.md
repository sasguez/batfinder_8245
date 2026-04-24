# BatFinder — Seguridad Ciudadana Colombiana

Aplicación móvil Flutter de reporte y visualización de incidentes de seguridad en tiempo real. Permite a los ciudadanos reportar incidentes, ver alertas cercanas en el mapa y gestionar contactos de emergencia.

---

## Requisitos previos

Antes de clonar el repositorio asegúrate de tener instalado:

| Herramienta | Versión mínima | Descarga |
|---|---|---|
| Flutter SDK | 3.9.0 | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Dart SDK | 3.9.0 | Incluido con Flutter |
| Android Studio | Cualquiera reciente | [developer.android.com](https://developer.android.com/studio) |
| Xcode (solo macOS/iOS) | 14+ | App Store de macOS |
| Git | Cualquiera | [git-scm.com](https://git-scm.com) |

Verifica tu instalación de Flutter:

```bash
flutter doctor
```

Todos los ítems deben estar en verde antes de continuar.

---

## 1. Clonar el repositorio

```bash
git clone https://github.com/sasguez/batfinder_8245.git
cd batfinder_8245
```

---

## 2. Instalar dependencias

```bash
flutter pub get
```

---

## 3. Configurar las API keys (obligatorio)

El proyecto usa un archivo `env.json` para gestionar las credenciales. **Este archivo no está en el repositorio por seguridad.** Debes crearlo manualmente.

### 3.1 Crear `env.json`

En la raíz del proyecto crea el archivo `env.json` copiando la plantilla:

```bash
cp env.json.example env.json
```

O créalo manualmente con este contenido:

```json
{
  "GOOGLE_MAPS_API_KEY": "AIzaSy...TU_KEY_AQUI",
  "SUPABASE_URL": "https://xxxx.supabase.co",
  "SUPABASE_ANON_KEY": "eyJ...",
  "ANTHROPIC_API_KEY": "sk-ant-..."
}
```

> **Importante:** `env.json` está en `.gitignore`. Nunca lo subas al repositorio.

---

## 4. Configurar Google Maps

Necesitas una API key de Google Maps para que el mapa funcione. Si el equipo ya tiene una, pídela al encargado del proyecto. Si necesitas crear una:

1. Ve a [Google Cloud Console](https://console.cloud.google.com)
2. Crea un proyecto o selecciona el existente
3. En el menú ve a **APIs & Services → Library**
4. Habilita **Maps SDK for Android**
5. Habilita **Maps SDK for iOS** (si desarrollas en macOS)
6. Ve a **APIs & Services → Credentials → + Create Credentials → API Key**
7. Copia la key generada (empieza con `AIzaSy...`)

### 4.1 Android

Abre el archivo `android/local.properties` y agrega tu key al final:

```properties
GOOGLE_MAPS_API_KEY=AIzaSy...TU_KEY_AQUI
```

> `local.properties` está en `.gitignore`. Nunca lo subas al repositorio.

### 4.2 iOS (solo macOS)

Abre `ios/Runner/Info.plist` y agrega dentro del bloque `<dict>` principal:

```xml
<key>GOOGLE_MAPS_API_KEY</key>
<string>AIzaSy...TU_KEY_AQUI</string>
```

---

## 5. Configurar Supabase

El proyecto ya tiene la URL y la anon key del backend del equipo configuradas en `lib/services/supabase_service.dart`. Si vas a usar tu propio proyecto Supabase:

1. Crea un proyecto en [supabase.com](https://supabase.com)
2. Ve a **Settings → API**
3. Copia la **Project URL** y la **anon public key**
4. Pégalas en `env.json` en los campos `SUPABASE_URL` y `SUPABASE_ANON_KEY`
5. Actualiza `lib/services/supabase_service.dart` para leer desde `String.fromEnvironment`

---

## 6. Ejecutar la aplicación

### Desde la terminal

```bash
flutter run --dart-define-from-file=env.json
```

### Desde VS Code

Crea el archivo `.vscode/launch.json` con este contenido:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "BatFinder (debug)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define-from-file",
        "env.json"
      ]
    }
  ]
}
```

Luego presiona `F5` o ve a **Run → Start Debugging**.

### Desde Android Studio / IntelliJ

1. Ve a **Run → Edit Configurations**
2. Selecciona tu configuración Flutter o crea una nueva
3. En **Additional arguments** agrega:
   ```
   --dart-define-from-file=env.json
   ```
4. Guarda y ejecuta con el botón ▶

---

## 7. Estructura del proyecto

```
batfinder_8245/
├── android/
│   ├── app/
│   │   └── src/main/AndroidManifest.xml   # Config Android (API key via placeholder)
│   └── local.properties                   # Keys locales — NO subir a git
├── ios/
│   └── Runner/
│       ├── AppDelegate.swift              # Inicialización Google Maps iOS
│       └── Info.plist                    # Config iOS (agregar API key aquí)
├── lib/
│   ├── core/                             # Exportaciones globales y utilidades
│   ├── presentation/                     # Pantallas de la app
│   │   ├── alert_dashboard/              # Dashboard principal
│   │   ├── interactive_safety_map/       # Mapa de seguridad
│   │   ├── login_screen/                 # Pantalla de login
│   │   ├── splash_screen/                # Splash screen
│   │   └── user_profile_settings/        # Perfil y configuración
│   ├── routes/
│   │   └── app_routes.dart               # Rutas nombradas
│   ├── services/
│   │   ├── supabase_service.dart         # Cliente Supabase (auth, DB, storage)
│   │   └── map_service.dart              # Servicio de mapa e incidentes
│   ├── theme/
│   │   └── app_theme.dart                # Temas claro y oscuro
│   ├── widgets/                          # Widgets reutilizables globales
│   └── main.dart                         # Punto de entrada
├── assets/
│   └── images/                           # Imágenes y logo
├── env.json                              # Keys locales — NO subir a git (gitignored)
├── env.json.example                      # Plantilla de keys para nuevos devs
└── pubspec.yaml                          # Dependencias
```

---

## 8. Archivos que NO están en el repositorio

Por seguridad estos archivos están en `.gitignore`. Cada desarrollador debe crearlos localmente:

| Archivo | Qué contiene | Cómo obtenerlo |
|---|---|---|
| `env.json` | API keys de todos los servicios | Copiar `env.json.example` y llenar |
| `android/local.properties` | Google Maps API key para Android | Crearlo con tu key (ver paso 4.1) |
| `ios/Runner/Info.plist` → `GOOGLE_MAPS_API_KEY` | Google Maps API key para iOS | Editar manualmente (ver paso 4.2) |

---

## 9. Compilar para producción

```bash
# Android APK
flutter build apk --release --dart-define-from-file=env.json

# Android App Bundle (recomendado para Play Store)
flutter build appbundle --release --dart-define-from-file=env.json

# iOS (requiere macOS y Xcode)
flutter build ios --release --dart-define-from-file=env.json
```

---

## 10. Tecnologías utilizadas

| Tecnología | Uso |
|---|---|
| Flutter 3.9+ | Framework UI multiplataforma |
| Supabase | Base de datos, autenticación y tiempo real |
| Google Maps Flutter | Mapa interactivo de incidentes |
| Geolocator | Ubicación del usuario |
| SharedPreferences | Persistencia local de preferencias |
| Sizer | Sistema de diseño responsivo |
| Google Fonts | Tipografía |

---

## 11. Convenciones del proyecto

- **Estado:** `StatefulWidget` + `setState` (sin BLoC ni Riverpod)
- **Colores:** siempre vía `Theme.of(context).colorScheme` — nunca hardcodeados
- **Tamaños:** siempre con `sizer` (`.w`, `.h`, `.sp`) — nunca píxeles fijos
- **Servicios:** la UI nunca llama a Supabase directamente, siempre a través de `SupabaseService`
- **Idioma del código:** variables y métodos en inglés; textos de UI en español

---

## Soporte

Para dudas sobre el proyecto abre un issue en el repositorio o contacta al equipo a través del canal de comunicación del proyecto.
