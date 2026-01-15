# 🧩 Guía de Configuración de Componentes UI - BatFinder

## 📋 Índice
1. [Tarjetas (Cards)](#tarjetas-cards)
2. [Campos de Entrada (TextFields)](#campos-de-entrada-textfields)
3. [Diálogos (Dialogs)](#diálogos-dialogs)
4. [Navegación Inferior (Bottom Navigation)](#navegación-inferior-bottom-navigation)
5. [Hojas Inferiores (Bottom Sheets)](#hojas-inferiores-bottom-sheets)
6. [Barras de Aplicación (AppBar)](#barras-de-aplicación-appbar)
7. [Componentes Adicionales](#componentes-adicionales)

---

## 🃏 Tarjetas (Cards)

### Configuración Actual

**Ubicación:** `lib/theme/app_theme.dart` líneas 111-118

```dart
cardTheme: CardThemeData(
  color: cardLight,                    // #F9FAFB
  elevation: 2.0,                      // Sombra de 2dp
  shadowColor: shadowLight,            // Negro 10% opacidad
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.0)  // Bordes redondeados 12px
  ),
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
),
```

### Propiedades Configurables

| Propiedad | Valor Actual | Descripción | Cómo Modificar |
|-----------|--------------|-------------|----------------|
| **color** | `#F9FAFB` (gris muy claro) | Color de fondo de la tarjeta | Cambia `cardLight` |
| **elevation** | `2.0` | Profundidad de sombra (0-24) | Aumenta/disminuye el valor |
| **shadowColor** | `#000000` (10% opacidad) | Color de la sombra | Cambia `shadowLight` |
| **borderRadius** | `12.0` | Redondeo de esquinas en píxeles | Modifica el valor en `circular()` |
| **margin** | `horizontal: 16, vertical: 8` | Espaciado externo de la tarjeta | Ajusta `EdgeInsets` |

### Ejemplos de Modificación

#### Tarjetas Más Redondeadas

```dart
cardTheme: CardThemeData(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20.0),  // ← Era 12.0
  ),
),
```

#### Tarjetas con Más Elevación

```dart
cardTheme: CardThemeData(
  elevation: 4.0,  // ← Era 2.0 (más profundidad)
),
```

#### Tarjetas con Borde

```dart
cardTheme: CardThemeData(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.0),
    side: BorderSide(
      color: Theme.of(context).colorScheme.primary,
      width: 1.5,
    ),
  ),
),
```

### Uso en Widgets

```dart
// Tarjeta básica con estilo del tema
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Text('Título de Tarjeta'),
        Text('Contenido de la tarjeta'),
      ],
    ),
  ),
)

// Tarjeta personalizada
Card(
  elevation: 8.0,  // Sobrescribe el tema
  color: Colors.blue.shade50,
  child: ListTile(
    title: Text('Tarjeta Personalizada'),
    subtitle: Text('Con propiedades específicas'),
  ),
)
```

---

## 📝 Campos de Entrada (TextFields)

### Configuración Actual

**Ubicación:** `lib/theme/app_theme.dart` líneas 191-232

```dart
inputDecorationTheme: InputDecorationThemeData(
  fillColor: surfaceLight,              // #F9FAFB
  filled: true,                         // Fondo relleno
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  
  // Borde normal
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.0),
    borderSide: BorderSide(color: dividerLight, width: 1.5),
  ),
  
  // Borde cuando está enfocado
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.0),
    borderSide: BorderSide(color: primaryLight, width: 2),
  ),
  
  // Borde de error
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.0),
    borderSide: BorderSide(color: errorLight, width: 1.5),
  ),
  
  // Estilos de texto
  labelStyle: GoogleFonts.inter(fontSize: 16, color: textMediumEmphasisLight),
  hintStyle: GoogleFonts.inter(fontSize: 16, color: textDisabledLight),
  errorStyle: GoogleFonts.inter(fontSize: 12, color: errorLight),
),
```

### Propiedades Configurables

| Propiedad | Valor Actual | Descripción |
|-----------|--------------|-------------|
| **fillColor** | `#F9FAFB` | Color de fondo del campo |
| **contentPadding** | `h:16, v:14` | Espaciado interno del texto |
| **borderRadius** | `12.0` | Redondeo de esquinas |
| **borderWidth (normal)** | `1.5` | Grosor del borde normal |
| **borderWidth (focused)** | `2.0` | Grosor del borde cuando está enfocado |
| **focusedBorderColor** | `#6366F1` (Índigo) | Color del borde al enfocarse |
| **errorBorderColor** | `#EF4444` (Rojo) | Color del borde con error |

### Ejemplos de Modificación

#### Campos Sin Relleno (Outline Only)

```dart
inputDecorationTheme: InputDecorationThemeData(
  filled: false,  // ← Era true
  // ... resto del código
),
```

#### Campos Más Redondeados

```dart
border: OutlineInputBorder(
  borderRadius: BorderRadius.circular(20.0),  // ← Era 12.0
),
focusedBorder: OutlineInputBorder(
  borderRadius: BorderRadius.circular(20.0),  // ← Era 12.0
),
```

#### Campos con Borde Inferior (Underline)

```dart
border: UnderlineInputBorder(
  borderSide: BorderSide(color: dividerLight, width: 1.5),
),
focusedBorder: UnderlineInputBorder(
  borderSide: BorderSide(color: primaryLight, width: 2),
),
```

### Uso en Widgets

```dart
// Campo de texto básico
TextField(
  decoration: InputDecoration(
    labelText: 'Nombre',
    hintText: 'Ingresa tu nombre',
  ),
)

// Campo de texto personalizado
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'ejemplo@correo.com',
    prefixIcon: Icon(Icons.email),
    suffixIcon: Icon(Icons.check_circle, color: Colors.green),
    helperText: 'Ingresa un email válido',
  ),
)

// Campo con validación de error
TextField(
  decoration: InputDecoration(
    labelText: 'Contraseña',
    errorText: 'Contraseña muy corta',
    prefixIcon: Icon(Icons.lock),
  ),
)
```

---

## 💬 Diálogos (Dialogs)

### Configuración Actual

**Ubicación:** `lib/theme/app_theme.dart` líneas 308-324

```dart
dialogTheme: DialogThemeData(
  backgroundColor: dialogLight,        // #FFFFFF
  elevation: 8.0,                      // Sombra profunda
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16.0)
  ),
  titleTextStyle: GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: textHighEmphasisLight,
  ),
  contentTextStyle: GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textHighEmphasisLight,
  ),
),
```

### Propiedades Configurables

| Propiedad | Valor Actual | Descripción |
|-----------|--------------|-------------|
| **backgroundColor** | `#FFFFFF` | Color de fondo del diálogo |
| **elevation** | `8.0` | Profundidad de sombra |
| **borderRadius** | `16.0` | Redondeo de esquinas |
| **titleTextStyle** | Roboto 20sp Medium | Estilo del título |
| **contentTextStyle** | Inter 16sp Regular | Estilo del contenido |

### Ejemplos de Modificación

#### Diálogos Más Redondeados

```dart
dialogTheme: DialogThemeData(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24.0),  // ← Era 16.0
  ),
),
```

#### Diálogos con Borde de Color

```dart
dialogTheme: DialogThemeData(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16.0),
    side: BorderSide(
      color: Theme.of(context).colorScheme.primary,
      width: 2,
    ),
  ),
),
```

### Uso en Widgets

```dart
// Diálogo de alerta simple
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Confirmar Acción'),
    content: Text('¿Estás seguro de que deseas continuar?'),
    actions: [
      TextButton(
        child: Text('Cancelar'),
        onPressed: () => Navigator.pop(context),
      ),
      ElevatedButton(
        child: Text('Confirmar'),
        onPressed: () {
          // Acción aquí
          Navigator.pop(context);
        },
      ),
    ],
  ),
)

// Diálogo personalizado con contenido complejo
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Row(
      children: [
        Icon(Icons.warning, color: Colors.orange),
        SizedBox(width: 8),
        Text('Advertencia'),
      ],
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Este es un diálogo con contenido personalizado.'),
        SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(labelText: 'Campo de entrada'),
        ),
      ],
    ),
    actions: [
      TextButton(
        child: Text('Cancelar'),
        onPressed: () => Navigator.pop(context),
      ),
      ElevatedButton(
        child: Text('Guardar'),
        onPressed: () {},
      ),
    ],
  ),
)
```

---

## 🧭 Navegación Inferior (Bottom Navigation)

### Configuración Actual

**Ubicación:** `lib/theme/app_theme.dart` líneas 120-133

```dart
bottomNavigationBarTheme: BottomNavigationBarThemeData(
  backgroundColor: surfaceLight,               // #F9FAFB
  selectedItemColor: primaryLight,             // #6366F1 (Índigo)
  unselectedItemColor: textMediumEmphasisLight, // #6B7280 (Gris)
  type: BottomNavigationBarType.fixed,
  elevation: 8.0,
  selectedLabelStyle: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500),
  unselectedLabelStyle: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w400),
),
```

### Propiedades Configurables

| Propiedad | Valor Actual | Descripción |
|-----------|--------------|-------------|
| **backgroundColor** | `#F9FAFB` | Color de fondo de la barra |
| **selectedItemColor** | `#6366F1` (Índigo) | Color del ítem seleccionado |
| **unselectedItemColor** | `#6B7280` (Gris) | Color de ítems no seleccionados |
| **elevation** | `8.0` | Elevación de la barra |
| **type** | `fixed` | Tipo de navegación (fixed/shifting) |
| **selectedLabelStyle** | Roboto 12sp Medium | Estilo de etiqueta seleccionada |

### Ejemplos de Modificación

#### Barra con Fondo de Color

```dart
bottomNavigationBarTheme: BottomNavigationBarThemeData(
  backgroundColor: primaryLight,  // ← Fondo índigo
  selectedItemColor: Colors.white,
  unselectedItemColor: Colors.white.withOpacity(0.6),
),
```

#### Barra Transparente

```dart
bottomNavigationBarTheme: BottomNavigationBarThemeData(
  backgroundColor: Colors.transparent,
  elevation: 0,
),
```

### Uso en Widgets

```dart
// Scaffold con BottomNavigationBar
int _currentIndex = 0;

Scaffold(
  body: _pages[_currentIndex],
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: _currentIndex,
    onTap: (index) {
      setState(() => _currentIndex = index);
    },
    items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Inicio',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.map),
        label: 'Mapa',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.report),
        label: 'Reportes',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Perfil',
      ),
    ],
  ),
)
```

---

## 📋 Hojas Inferiores (Bottom Sheets)

### Configuración Actual

**Ubicación:** `lib/theme/app_theme.dart` líneas 298-306

```dart
bottomSheetTheme: BottomSheetThemeData(
  backgroundColor: surfaceLight,     // #F9FAFB
  elevation: 8.0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(20)
    ),
  ),
),
```

### Propiedades Configurables

| Propiedad | Valor Actual | Descripción |
|-----------|--------------|-------------|
| **backgroundColor** | `#F9FAFB` | Color de fondo |
| **elevation** | `8.0` | Profundidad de sombra |
| **topBorderRadius** | `20.0` | Redondeo superior |

### Ejemplos de Modificación

#### Bottom Sheet Más Redondeado

```dart
bottomSheetTheme: BottomSheetThemeData(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(32)  // ← Era 20
    ),
  ),
),
```

### Uso en Widgets

```dart
// Mostrar bottom sheet modal
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle visual
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(height: 16),
        Text('Título del Bottom Sheet'),
        SizedBox(height: 8),
        Text('Contenido aquí'),
        SizedBox(height: 16),
        ElevatedButton(
          child: Text('Acción'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  ),
)
```

---

## 📱 Barras de Aplicación (AppBar)

### Configuración Actual

**Ubicación:** `lib/theme/app_theme.dart` líneas 97-109

```dart
appBarTheme: AppBarThemeData(
  backgroundColor: backgroundLight,     // #FFFFFF
  foregroundColor: onBackgroundLight,   // #1F2937
  elevation: 0,                        // Sin sombra
  centerTitle: false,                  // Título alineado a la izquierda
  titleTextStyle: GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: textHighEmphasisLight,
    letterSpacing: 0.15,
  ),
  iconTheme: IconThemeData(color: textHighEmphasisLight),
),
```

### Propiedades Configurables

| Propiedad | Valor Actual | Descripción |
|-----------|--------------|-------------|
| **backgroundColor** | `#FFFFFF` | Color de fondo |
| **foregroundColor** | `#1F2937` | Color de texto/iconos |
| **elevation** | `0` | Elevación (0 = sin sombra) |
| **centerTitle** | `false` | Centrado del título |
| **titleTextStyle** | Roboto 20sp Medium | Estilo del título |

### Ejemplos de Modificación

#### AppBar con Color de Fondo

```dart
appBarTheme: AppBarThemeData(
  backgroundColor: primaryLight,  // ← Fondo índigo
  foregroundColor: Colors.white,  // ← Texto blanco
  elevation: 4.0,                 // ← Con sombra
),
```

#### AppBar con Título Centrado

```dart
appBarTheme: AppBarThemeData(
  centerTitle: true,  // ← Era false
),
```

### Uso en Widgets

```dart
// AppBar básico
AppBar(
  title: Text('BatFinder'),
  actions: [
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () {},
    ),
    IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () {},
    ),
  ],
)

// AppBar personalizado
AppBar(
  title: Text('Configuración'),
  leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () => Navigator.pop(context),
  ),
  backgroundColor: Colors.transparent,
  elevation: 0,
)
```

---

## 🧩 Componentes Adicionales

### Switches

**Ubicación:** `lib/theme/app_theme.dart` líneas 234-247

```dart
switchTheme: SwitchThemeData(
  thumbColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return primaryLight;  // #6366F1 cuando está activo
    }
    return Color(0xFF9CA3AF);  // Gris cuando está inactivo
  }),
  trackColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return primaryLight.withValues(alpha: 0.5);
    }
    return Color(0xFFE5E7EB);
  }),
),
```

**Uso:**
```dart
Switch(
  value: _isEnabled,
  onChanged: (value) {
    setState(() => _isEnabled = value);
  },
)
```

### Checkboxes

**Ubicación:** `lib/theme/app_theme.dart` líneas 249-261

```dart
checkboxTheme: CheckboxThemeData(
  fillColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return primaryLight;
    }
    return Colors.transparent;
  }),
  checkColor: WidgetStateProperty.all(onPrimaryLight),
  side: BorderSide(color: dividerLight, width: 2),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
),
```

**Uso:**
```dart
Checkbox(
  value: _isChecked,
  onChanged: (value) {
    setState(() => _isChecked = value ?? false);
  },
)
```

### Progress Indicators

**Ubicación:** `lib/theme/app_theme.dart` líneas 271-274

```dart
progressIndicatorTheme: ProgressIndicatorThemeData(
  color: primaryLight,            // Color del indicador
  linearTrackColor: dividerLight, // Color de la pista
),
```

**Uso:**
```dart
// Circular
CircularProgressIndicator()

// Linear
LinearProgressIndicator()

// Con valor específico
CircularProgressIndicator(value: 0.7)  // 70%
```

### Sliders

**Ubicación:** `lib/theme/app_theme.dart` líneas 276-282

```dart
sliderTheme: SliderThemeData(
  activeTrackColor: primaryLight,
  thumbColor: primaryLight,
  overlayColor: primaryLight.withValues(alpha: 0.2),
  inactiveTrackColor: dividerLight,
  trackHeight: 4.0,
),
```

**Uso:**
```dart
Slider(
  value: _currentValue,
  min: 0,
  max: 100,
  divisions: 10,
  label: _currentValue.round().toString(),
  onChanged: (value) {
    setState(() => _currentValue = value);
  },
)
```

---

## 📚 Recursos Adicionales

### Documentación Oficial
- [Material Components](https://docs.flutter.dev/ui/widgets/material)
- [Theme Customization](https://docs.flutter.dev/cookbook/design/themes)
- [Material Design 3](https://m3.material.io/components)

### Herramientas
- [Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)
- [Material Theme Builder](https://m3.material.io/theme-builder)

---

**Última actualización:** 15 de enero de 2026  
**Versión de BatFinder:** 1.0.0  
**Autor:** Equipo de Desarrollo BatFinder