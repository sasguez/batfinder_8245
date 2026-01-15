# 🏗️ Guía de Estructura del Proyecto - BatFinder

## 📋 Índice
1. [Visión General](#visión-general)
2. [Estructura de Carpetas](#estructura-de-carpetas)
3. [Arquitectura de la Aplicación](#arquitectura-de-la-aplicación)
4. [Convenciones de Nomenclatura](#convenciones-de-nomenclatura)
5. [Patrones de Diseño](#patrones-de-diseño)
6. [Flujo de Datos](#flujo-de-datos)

---

## 🎯 Visión General

BatFinder sigue una arquitectura limpia y modular basada en las mejores prácticas de Flutter. La aplicación está organizada en capas claramente definidas que separan la lógica de negocio, la presentación y los datos.

### Principios Arquitectónicos

- **Separación de Responsabilidades**: Cada capa tiene un propósito específico
- **Modularidad**: Componentes reutilizables e independientes
- **Escalabilidad**: Fácil de extender con nuevas funcionalidades
- **Mantenibilidad**: Código organizado y fácil de entender

---

## 📁 Estructura de Carpetas

```
batfinder/
├── lib/                          # Código fuente principal
│   ├── main.dart                # Punto de entrada de la aplicación
│   ├── core/                    # Funcionalidades centrales
│   │   └── app_export.dart      # Exportaciones globales
│   ├── presentation/            # Capa de presentación (UI)
│   │   ├── splash_screen/
│   │   ├── login_screen/
│   │   ├── alert_dashboard/
│   │   ├── incident_reporting/
│   │   └── [otras_pantallas]/
│   ├── services/                # Capa de servicios (lógica de negocio)
│   │   ├── supabase_service.dart
│   │   ├── auth_service.dart
│   │   └── [otros_servicios]/
│   ├── theme/                   # Configuración de temas
│   │   └── app_theme.dart
│   ├── widgets/                 # Widgets reutilizables
│   │   ├── custom_app_bar.dart
│   │   ├── custom_bottom_bar.dart
│   │   └── [otros_widgets]/
│   └── routes/                  # Configuración de navegación
│       └── app_routes.dart
├── supabase/                    # Backend Supabase
│   ├── migrations/              # Migraciones de base de datos
│   └── functions/               # Funciones Edge de Supabase
├── docs/                        # Documentación del proyecto
│   ├── GUIA_CONFIGURACION_COLORES.md
│   ├── GUIA_CONFIGURACION_BOTONES.md
│   └── [otras_guias]/
├── assets/                      # Recursos estáticos
│   └── images/
├── android/                     # Configuración Android
├── ios/                         # Configuración iOS
├── web/                         # Configuración Web
├── pubspec.yaml                 # Dependencias y configuración
└── README.md                    # Documentación principal
```

---

## 🏛️ Arquitectura de la Aplicación

### Capas Principales

#### 1. Capa de Presentación (`lib/presentation/`)

**Responsabilidad:** Interfaz de usuario y widgets visuales

**Estructura por Pantalla:**
```
presentation/
├── nombre_pantalla/
│   ├── nombre_pantalla.dart        # Widget principal de la pantalla
│   └── widgets/                    # Widgets específicos de esta pantalla
│       ├── widget_uno.dart
│       ├── widget_dos.dart
│       └── widget_tres.dart
```

**Características:**
- Cada pantalla está en su propia carpeta
- Widgets específicos de una pantalla están en subcarpeta `widgets/`
- Widgets reutilizables globalmente están en `lib/widgets/`

**Ejemplo - Incident Reporting:**
```
presentation/
├── incident_reporting/
│   ├── incident_reporting.dart                    # Pantalla principal
│   └── widgets/
│       ├── incident_type_selector_widget.dart    # Selector de tipo
│       ├── location_selector_widget.dart         # Selector de ubicación
│       ├── media_attachment_widget.dart          # Adjuntar medios
│       └── anonymous_toggle_widget.dart          # Toggle anónimo
```

#### 2. Capa de Servicios (`lib/services/`)

**Responsabilidad:** Lógica de negocio y comunicación con backend

**Tipos de Servicios:**

- **API Services:** Comunicación con Supabase
  - `supabase_service.dart` - Cliente Supabase
  - `auth_service.dart` - Autenticación
  - `incident_management_service.dart` - Gestión de incidentes

- **Business Logic Services:**
  - `dashboard_service.dart` - Lógica del dashboard
  - `notification_service.dart` - Gestión de notificaciones
  - `ai_pattern_analysis_service.dart` - Análisis con IA

- **Utility Services:**
  - `offline_queue_service.dart` - Cola offline
  - `map_service.dart` - Servicios de mapas

**Patrón de Servicio:**
```dart
class NombreService {
  // Instancia única (Singleton)
  static final NombreService _instance = NombreService._internal();
  factory NombreService() => _instance;
  NombreService._internal();

  // Métodos públicos
  Future<Result> obtenerDatos() async {
    // Implementación
  }

  Future<void> guardarDatos(Data data) async {
    // Implementación
  }
}
```

#### 3. Capa de Temas (`lib/theme/`)

**Responsabilidad:** Definición de estilos globales

**Archivo Principal:** `app_theme.dart`

**Contenido:**
- Paleta de colores (claro y oscuro)
- Estilos de tipografía
- Configuración de componentes (botones, cards, inputs)
- Constantes de espaciado y tamaños

#### 4. Capa de Widgets Globales (`lib/widgets/`)

**Responsabilidad:** Componentes reutilizables en toda la aplicación

**Widgets Comunes:**
- `custom_app_bar.dart` - Barra de aplicación personalizada
- `custom_bottom_bar.dart` - Navegación inferior
- `custom_icon_widget.dart` - Widget de iconos
- `custom_image_widget.dart` - Widget de imágenes
- `custom_error_widget.dart` - Widget de error

#### 5. Capa de Navegación (`lib/routes/`)

**Responsabilidad:** Gestión de rutas y navegación

**Archivo Principal:** `app_routes.dart`

**Estructura:**
```dart
class AppRoutes {
  // Constantes de rutas
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  // ...

  // Mapa de rutas
  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
    // ...
  };
}
```

---

## 📝 Convenciones de Nomenclatura

### Archivos y Carpetas

| Tipo | Convención | Ejemplo |
|------|-----------|---------|
| **Pantallas** | `nombre_pantalla.dart` | `incident_reporting.dart` |
| **Widgets** | `nombre_widget.dart` | `incident_type_selector_widget.dart` |
| **Servicios** | `nombre_service.dart` | `incident_management_service.dart` |
| **Carpetas** | `snake_case` | `incident_reporting/` |

### Clases

| Tipo | Convención | Ejemplo |
|------|-----------|---------|
| **Pantallas** | `NombrePantallaScreen` | `IncidentReportingScreen` |
| **Widgets** | `NombreWidget` | `IncidentTypeSelectorWidget` |
| **Servicios** | `NombreService` | `IncidentManagementService` |
| **Modelos** | `NombreModel` | `IncidentModel` |

### Variables y Funciones

```dart
// Variables privadas (solo dentro de la clase)
String _variablePrivada = '';

// Variables públicas
String variablePublica = '';

// Constantes
static const String CONSTANTE = 'valor';

// Funciones privadas
void _funcionPrivada() {}

// Funciones públicas
void funcionPublica() {}

// Funciones asíncronas
Future<void> funcionAsincrona() async {}
```

---

## 🎨 Patrones de Diseño

### 1. Singleton Pattern (Servicios)

**Uso:** Servicios que deben tener una única instancia

```dart
class AuthService {
  // Instancia privada estática
  static final AuthService _instance = AuthService._internal();
  
  // Factory constructor devuelve la instancia única
  factory AuthService() => _instance;
  
  // Constructor privado
  AuthService._internal();
  
  // Métodos del servicio
  Future<User?> getCurrentUser() async {
    // Implementación
  }
}

// Uso
final authService = AuthService(); // Siempre devuelve la misma instancia
```

### 2. Builder Pattern (Configuración)

**Uso:** Configuración compleja de objetos

```dart
class QueryBuilder {
  String? _table;
  Map<String, dynamic>? _filters;
  List<String>? _select;
  
  QueryBuilder table(String table) {
    _table = table;
    return this;
  }
  
  QueryBuilder filter(Map<String, dynamic> filters) {
    _filters = filters;
    return this;
  }
  
  QueryBuilder select(List<String> columns) {
    _select = columns;
    return this;
  }
  
  Future<List<Map<String, dynamic>>> execute() async {
    // Ejecutar query
  }
}

// Uso
final results = await QueryBuilder()
  .table('incidents')
  .filter({'status': 'active'})
  .select(['id', 'title', 'created_at'])
  .execute();
```

### 3. Observer Pattern (Streams)

**Uso:** Notificaciones en tiempo real

```dart
class NotificationService {
  final _notificationController = StreamController<Notification>.broadcast();
  
  Stream<Notification> get notificationStream => _notificationController.stream;
  
  void sendNotification(Notification notification) {
    _notificationController.add(notification);
  }
  
  void dispose() {
    _notificationController.close();
  }
}

// Uso en widget
class NotificationWidget extends StatefulWidget {
  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  late StreamSubscription _subscription;
  
  @override
  void initState() {
    super.initState();
    _subscription = NotificationService().notificationStream.listen((notification) {
      // Manejar notificación
    });
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

### 4. Repository Pattern (Datos)

**Uso:** Abstracción de fuentes de datos

```dart
abstract class IncidentRepository {
  Future<List<Incident>> getIncidents();
  Future<Incident?> getIncidentById(String id);
  Future<void> createIncident(Incident incident);
  Future<void> updateIncident(Incident incident);
  Future<void> deleteIncident(String id);
}

class SupabaseIncidentRepository implements IncidentRepository {
  final SupabaseClient _client;
  
  SupabaseIncidentRepository(this._client);
  
  @override
  Future<List<Incident>> getIncidents() async {
    final response = await _client.from('incidents').select();
    return response.map((json) => Incident.fromJson(json)).toList();
  }
  
  // Implementar otros métodos...
}

// Uso
final repository = SupabaseIncidentRepository(supabaseClient);
final incidents = await repository.getIncidents();
```

---

## 🔄 Flujo de Datos

### Flujo Típico de una Operación

```
Usuario Interactúa
        ↓
    Widget UI
        ↓
    Service Layer
        ↓
    Supabase Backend
        ↓
    Service Layer (procesa respuesta)
        ↓
    Widget UI (actualiza)
        ↓
    Usuario ve resultado
```

### Ejemplo Completo - Crear Incidente

#### 1. Usuario Completa Formulario

```dart
// incident_reporting.dart
class IncidentReportingScreen extends StatefulWidget {
  @override
  _IncidentReportingScreenState createState() => _IncidentReportingScreenState();
}

class _IncidentReportingScreenState extends State<IncidentReportingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _incidentType = '';
  String _description = '';
  Location? _location;
  
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Recopilar datos
      final incident = {
        'incident_type': _incidentType,
        'description': _description,
        'location': _location?.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      };
      
      // Llamar al servicio
      try {
        await IncidentManagementService().createIncident(incident);
        _showSuccessMessage();
        Navigator.pop(context);
      } catch (e) {
        _showErrorMessage(e.toString());
      }
    }
  }
}
```

#### 2. Servicio Procesa la Solicitud

```dart
// incident_management_service.dart
class IncidentManagementService {
  final SupabaseService _supabaseService = SupabaseService();
  
  Future<void> createIncident(Map<String, dynamic> incidentData) async {
    try {
      // Validar datos
      _validateIncidentData(incidentData);
      
      // Enviar a Supabase
      final response = await _supabaseService.client
          .from('incidents')
          .insert(incidentData)
          .select()
          .single();
      
      // Enviar notificación
      await NotificationService().notifyNewIncident(response['id']);
      
      // Registrar en analytics
      await _logIncidentCreation(response['id']);
      
    } catch (e) {
      // Manejar errores
      throw Exception('Error al crear incidente: $e');
    }
  }
  
  void _validateIncidentData(Map<String, dynamic> data) {
    if (data['incident_type'] == null || data['incident_type'].isEmpty) {
      throw Exception('Tipo de incidente requerido');
    }
    // Más validaciones...
  }
}
```

#### 3. Supabase Procesa y Devuelve

```sql
-- Supabase automáticamente:
-- 1. Valida esquema
-- 2. Verifica RLS policies
-- 3. Inserta datos
-- 4. Retorna resultado
-- 5. Dispara triggers si existen
```

#### 4. Widget Actualiza UI

```dart
// Widget muestra mensaje de éxito
void _showSuccessMessage() {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Incidente reportado exitosamente'),
      backgroundColor: Theme.of(context).colorScheme.success,
    ),
  );
}
```

---

## 📱 Organización por Características

### Dashboard Feature

```
presentation/
├── alert_dashboard/
│   ├── alert_dashboard.dart              # Vista principal
│   ├── alert_dashboard_initial_page.dart # Página inicial
│   └── widgets/
│       ├── alert_card_widget.dart        # Tarjeta de alerta
│       ├── safety_score_widget.dart      # Puntuación de seguridad
│       └── quick_action_widget.dart      # Acciones rápidas
services/
├── dashboard_service.dart                # Lógica del dashboard
└── alert_service.dart                    # Gestión de alertas
```

### Incident Reporting Feature

```
presentation/
├── incident_reporting/
│   ├── incident_reporting.dart
│   └── widgets/
│       ├── incident_type_selector_widget.dart
│       ├── location_selector_widget.dart
│       ├── media_attachment_widget.dart
│       ├── description_input_widget.dart
│       ├── datetime_selector_widget.dart
│       ├── severity_slider_widget.dart
│       ├── anonymous_toggle_widget.dart
│       ├── contact_info_widget.dart
│       └── offline_queue_widget.dart
services/
├── incident_management_service.dart
└── offline_queue_service.dart
```

---

## 🔧 Mejores Prácticas

### 1. Separación de Responsabilidades

```dart
// ❌ Incorrecto: Lógica en el widget
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  void saveData() async {
    // Lógica de negocio directamente en el widget
    final data = await Supabase.instance.client
        .from('table')
        .insert({'data': 'value'});
  }
}

// ✅ Correcto: Lógica en servicio
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final _dataService = DataService();
  
  void saveData() async {
    await _dataService.save({'data': 'value'});
  }
}
```

### 2. Reutilización de Widgets

```dart
// ✅ Widget reutilizable con parámetros
class CustomCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;
  
  const CustomCard({
    required this.title,
    required this.description,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        onTap: onTap,
      ),
    );
  }
}
```

### 3. Manejo de Estado

```dart
// ✅ Estado bien organizado
class MyScreenState extends State<MyScreen> {
  // Estado de carga
  bool _isLoading = false;
  
  // Estado de error
  String? _errorMessage;
  
  // Datos
  List<Item> _items = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final items = await _service.fetchItems();
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
}
```

---

## 📚 Recursos Adicionales

### Documentación Oficial
- [Flutter Architecture](https://docs.flutter.dev/app-architecture)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://docs.flutter.dev/perf/best-practices)

### Guías Relacionadas
- [GUIA_CONFIGURACION_COLORES.md](./GUIA_CONFIGURACION_COLORES.md)
- [GUIA_CONFIGURACION_BOTONES.md](./GUIA_CONFIGURACION_BOTONES.md)
- [BATFINDER_PROJECT_DOCUMENTATION.md](../BATFINDER_PROJECT_DOCUMENTATION.md)

---

**Última actualización:** 15 de enero de 2026  
**Versión de BatFinder:** 1.0.0  
**Autor:** Equipo de Desarrollo BatFinder