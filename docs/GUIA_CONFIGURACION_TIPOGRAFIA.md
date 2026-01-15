# 📝 Guía de Configuración de Tipografía - BatFinder

## 📋 Índice
1. [Fuentes Utilizadas](#fuentes-utilizadas)
2. [Jerarquía de Texto](#jerarquía-de-texto)
3. [Ubicación en el Código](#ubicación-en-el-código)
4. [Cómo Modificar Tipografía](#cómo-modificar-tipografía)
5. [Ejemplos de Uso](#ejemplos-de-uso)
6. [Mejores Prácticas](#mejores-prácticas)

---

## 🎯 Fuentes Utilizadas

BatFinder utiliza dos familias tipográficas de Google Fonts para crear una jerarquía visual clara:

### Roboto (Para Encabezados y Títulos)
- **Uso:** Títulos, encabezados, etiquetas, subtítulos
- **Características:** Geométrica, legible, moderna
- **Pesos utilizados:**
  - Regular (400) - Displays
  - Medium (500) - Títulos y headlines
  - Semi-Bold (600) - Énfasis especial

### Inter (Para Texto de Cuerpo)
- **Uso:** Párrafos, descripciones, texto de entrada
- **Características:** Optimizada para pantallas, alta legibilidad
- **Pesos utilizados:**
  - Light (300) - Hints y placeholders
  - Regular (400) - Cuerpo principal
  - Medium (500) - Énfasis moderado

---

## 📊 Jerarquía de Texto

### Escala Tipográfica Completa

| Nivel | Fuente | Tamaño | Peso | Uso Principal | Ejemplo en App |
|-------|--------|--------|------|---------------|----------------|
| **Display Large** | Roboto | 57sp | 400 | Splash screens | Título de bienvenida |
| **Display Medium** | Roboto | 45sp | 400 | Pantallas principales | Nombre de app en onboarding |
| **Display Small** | Roboto | 36sp | 400 | Secciones grandes | Títulos de módulos |
| **Headline Large** | Roboto | 32sp | 500 | Títulos de sección | "Reportes Recientes" |
| **Headline Medium** | Roboto | 28sp | 500 | Títulos secundarios | "Configuración de Perfil" |
| **Headline Small** | Roboto | 24sp | 500 | Subtítulos destacados | "Notificaciones" |
| **Title Large** | Roboto | 22sp | 500 | Títulos de pantalla | AppBar titles |
| **Title Medium** | Roboto | 16sp | 500 | Títulos de tarjeta | Nombres de sección en cards |
| **Title Small** | Roboto | 14sp | 500 | Etiquetas | Labels en formularios |
| **Body Large** | Inter | 16sp | 400 | Texto principal | Descripciones largas |
| **Body Medium** | Inter | 14sp | 400 | Texto secundario | Texto de listas |
| **Body Small** | Inter | 12sp | 400 | Texto auxiliar | Texto de ayuda |
| **Label Large** | Roboto | 14sp | 500 | Botones | Texto en ElevatedButton |
| **Label Medium** | Roboto | 12sp | 500 | Chips, badges | Etiquetas pequeñas |
| **Label Small** | Roboto | 11sp | 400 | Ayuda, timestamps | Fecha/hora de mensajes |

---

## 📍 Ubicación en el Código

### Configuración Global de Tipografía

**Archivo:** `lib/theme/app_theme.dart`

#### Método _buildTextTheme (Líneas 450-533)

```dart
static TextTheme _buildTextTheme({required bool isLight}) {
  final Color textHighEmphasis = isLight
      ? textHighEmphasisLight
      : textHighEmphasisDark;
  final Color textMediumEmphasis = isLight
      ? textMediumEmphasisLight
      : textMediumEmphasisDark;
  final Color textDisabled = isLight ? textDisabledLight : textDisabledDark;

  return TextTheme(
    // Display styles - Roboto para encabezados
    displayLarge: GoogleFonts.roboto(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      color: textHighEmphasis,
      letterSpacing: -0.25,
    ),
    
    // ... más estilos ...
    
    // Body styles - Inter para texto de cuerpo
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textHighEmphasis,
      letterSpacing: 0.5,
    ),
    
    // ... más estilos ...
  );
}
```

### Colores de Texto (Líneas 48-56)

```dart
// Tema Claro
static const Color textHighEmphasisLight = Color(0xFF1F2937); // Casi negro
static const Color textMediumEmphasisLight = Color(0xFF6B7280); // Gris medio
static const Color textDisabledLight = Color(0xFF9CA3AF); // Gris claro

// Tema Oscuro
static const Color textHighEmphasisDark = Color(0xFFF9FAFB); // Blanco cálido
static const Color textMediumEmphasisDark = Color(0xFFD1D5DB); // Gris claro
static const Color textDisabledDark = Color(0xFF9CA3AF); // Gris
```

---

## 🔧 Cómo Modificar Tipografía

### Cambiar Familia de Fuentes

#### Opción 1: Cambiar Solo los Encabezados

```dart
// En app_theme.dart, dentro de _buildTextTheme
// ANTES (Roboto)
headlineLarge: GoogleFonts.roboto(
  fontSize: 32,
  fontWeight: FontWeight.w500,
),

// DESPUÉS (Ejemplo: Montserrat)
headlineLarge: GoogleFonts.montserrat(
  fontSize: 32,
  fontWeight: FontWeight.w500,
),
```

#### Opción 2: Cambiar Solo el Cuerpo de Texto

```dart
// ANTES (Inter)
bodyLarge: GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w400,
),

// DESPUÉS (Ejemplo: Lato)
bodyLarge: GoogleFonts.lato(
  fontSize: 16,
  fontWeight: FontWeight.w400,
),
```

#### Opción 3: Usar Fuente Personalizada

**Paso 1:** Añade la fuente a `pubspec.yaml`
```yaml
flutter:
  fonts:
    - family: MiFuentePersonalizada
      fonts:
        - asset: fonts/MiFuentePersonalizada-Regular.ttf
        - asset: fonts/MiFuentePersonalizada-Bold.ttf
          weight: 700
```

**Paso 2:** Usa la fuente en el tema
```dart
bodyLarge: TextStyle(
  fontFamily: 'MiFuentePersonalizada',
  fontSize: 16,
  fontWeight: FontWeight.w400,
),
```

### Cambiar Tamaños de Fuente

#### Aumentar Todos los Tamaños Proporcionalmente

```dart
// Multiplica todos los tamaños por 1.2 (20% más grandes)
displayLarge: GoogleFonts.roboto(
  fontSize: 57 * 1.2,  // 68.4sp
  fontWeight: FontWeight.w400,
),

headlineLarge: GoogleFonts.roboto(
  fontSize: 32 * 1.2,  // 38.4sp
  fontWeight: FontWeight.w500,
),

bodyLarge: GoogleFonts.inter(
  fontSize: 16 * 1.2,  // 19.2sp
  fontWeight: FontWeight.w400,
),
```

#### Ajustar Tamaños Individuales

```dart
// Solo aumentar títulos, mantener cuerpo
headlineLarge: GoogleFonts.roboto(
  fontSize: 36,  // ← Era 32
  fontWeight: FontWeight.w500,
),

bodyLarge: GoogleFonts.inter(
  fontSize: 16,  // ← Sin cambios
  fontWeight: FontWeight.w400,
),
```

### Cambiar Peso de Fuentes

```dart
// Hacer títulos más gruesos
headlineLarge: GoogleFonts.roboto(
  fontSize: 32,
  fontWeight: FontWeight.w600,  // ← Era w500 (Medium, ahora Semi-Bold)
),

// Hacer texto de cuerpo más ligero
bodyLarge: GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w300,  // ← Era w400 (Regular, ahora Light)
),
```

### Cambiar Letter Spacing (Espaciado entre Letras)

```dart
// Texto más compacto (menos espaciado)
bodyLarge: GoogleFonts.inter(
  fontSize: 16,
  letterSpacing: 0.2,  // ← Era 0.5 (más compacto)
),

// Texto más espaciado
headlineLarge: GoogleFonts.roboto(
  fontSize: 32,
  letterSpacing: 1.0,  // ← Era 0 (más espaciado)
),
```

### Cambiar Altura de Línea (Line Height)

```dart
bodyLarge: GoogleFonts.inter(
  fontSize: 16,
  height: 1.6,  // 1.6 veces el tamaño de fuente (25.6px)
),

// Más compacto
bodyLarge: GoogleFonts.inter(
  fontSize: 16,
  height: 1.3,  // 1.3 veces el tamaño de fuente (20.8px)
),
```

---

## 💡 Ejemplos de Uso

### Usar Estilos de Texto en Widgets

#### Método 1: Referencia Directa al Tema

```dart
// Título de pantalla
Text(
  'Reportes de Seguridad',
  style: Theme.of(context).textTheme.headlineLarge,
)

// Párrafo de cuerpo
Text(
  'Esta es una descripción detallada del reporte de incidente.',
  style: Theme.of(context).textTheme.bodyLarge,
)

// Etiqueta pequeña
Text(
  'Hace 5 minutos',
  style: Theme.of(context).textTheme.labelSmall,
)
```

#### Método 2: Personalización de Estilo Base

```dart
// Título con color personalizado
Text(
  'Atención Requerida',
  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
    color: Colors.red,
  ),
)

// Cuerpo de texto con énfasis
Text(
  'Información importante',
  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.primary,
  ),
)

// Texto tachado
Text(
  'Texto tachado',
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    decoration: TextDecoration.lineThrough,
  ),
)
```

#### Método 3: Texto Enriquecido (RichText)

```dart
RichText(
  text: TextSpan(
    style: Theme.of(context).textTheme.bodyLarge,
    children: [
      TextSpan(text: 'Reporte creado por '),
      TextSpan(
        text: 'Juan Pérez',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      TextSpan(text: ' hace '),
      TextSpan(
        text: '2 horas',
        style: Theme.of(context).textTheme.labelMedium,
      ),
    ],
  ),
)
```

### Ejemplos por Componente

#### AppBar

```dart
AppBar(
  title: Text(
    'BatFinder',
    style: Theme.of(context).textTheme.titleLarge,
  ),
)
```

#### Tarjetas (Cards)

```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de tarjeta
        Text(
          'Incidente Reportado',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        
        // Descripción
        Text(
          'Descripción detallada del incidente ocurrido en la zona norte.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: 4),
        
        // Timestamp
        Text(
          'Hace 15 minutos',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    ),
  ),
)
```

#### Formularios

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Etiqueta de campo
    Text(
      'Descripción del Incidente',
      style: Theme.of(context).textTheme.titleSmall,
    ),
    SizedBox(height: 8),
    
    // Campo de texto
    TextField(
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Ingresa los detalles aquí',
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).hintColor,
        ),
      ),
    ),
    SizedBox(height: 4),
    
    // Texto de ayuda
    Text(
      'Mínimo 10 caracteres',
      style: Theme.of(context).textTheme.bodySmall,
    ),
  ],
)
```

#### Listas

```dart
ListTile(
  title: Text(
    'Nombre del Reporte',
    style: Theme.of(context).textTheme.titleMedium,
  ),
  subtitle: Text(
    'Descripción breve del contenido',
    style: Theme.of(context).textTheme.bodyMedium,
  ),
  trailing: Text(
    '12:30 PM',
    style: Theme.of(context).textTheme.labelMedium,
  ),
)
```

#### Diálogos

```dart
AlertDialog(
  title: Text(
    '¿Eliminar Reporte?',
    style: Theme.of(context).textTheme.headlineSmall,
  ),
  content: Text(
    'Esta acción no se puede deshacer.',
    style: Theme.of(context).textTheme.bodyLarge,
  ),
  actions: [
    TextButton(
      child: Text('Cancelar'),
      onPressed: () => Navigator.pop(context),
    ),
    ElevatedButton(
      child: Text('Eliminar'),
      onPressed: () {},
    ),
  ],
)
```

---

## ✅ Mejores Prácticas

### 1. Jerarquía Visual Clara

```dart
// ✅ Correcto: Jerarquía clara de títulos
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('Título Principal', 
         style: Theme.of(context).textTheme.headlineLarge),    // Más grande
    SizedBox(height: 8),
    Text('Subtítulo', 
         style: Theme.of(context).textTheme.titleMedium),      // Mediano
    SizedBox(height: 4),
    Text('Descripción detallada aquí', 
         style: Theme.of(context).textTheme.bodyMedium),       // Más pequeño
  ],
)

// ❌ Incorrecto: Todo del mismo tamaño
Column(
  children: [
    Text('Título Principal', style: TextStyle(fontSize: 16)),
    Text('Subtítulo', style: TextStyle(fontSize: 16)),
    Text('Descripción', style: TextStyle(fontSize: 16)),
  ],
)
```

### 2. Usar Estilos del Tema

```dart
// ✅ Correcto: Usa estilos del tema
Text(
  'Título',
  style: Theme.of(context).textTheme.headlineMedium,
)

// ❌ Incorrecto: Estilo hardcoded
Text(
  'Título',
  style: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 28,
    fontWeight: FontWeight.w500,
  ),
)
```

### 3. Contraste y Legibilidad

```dart
// ✅ Correcto: Colores del tema con buen contraste
Text(
  'Texto importante',
  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
    color: Theme.of(context).colorScheme.onSurface,  // Alto contraste
  ),
)

// ❌ Incorrecto: Pobre contraste
Text(
  'Texto difícil de leer',
  style: TextStyle(
    color: Colors.grey.shade400,  // Bajo contraste sobre fondo blanco
  ),
)
```

### 4. Tamaños de Fuente Escalables

```dart
// ✅ Correcto: Usa MediaQuery.textScaleFactor si es necesario
Text(
  'Texto adaptable',
  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
    fontSize: 16 * MediaQuery.of(context).textScaleFactor,
  ),
)

// O mejor aún, deja que Flutter lo maneje automáticamente
Text(
  'Texto adaptable',
  style: Theme.of(context).textTheme.bodyLarge,  // Flutter ajusta automáticamente
)
```

### 5. Overflow Handling

```dart
// ✅ Correcto: Maneja texto largo
Text(
  'Este es un texto muy largo que podría no caber en una línea',
  style: Theme.of(context).textTheme.bodyMedium,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)

// ❌ Incorrecto: Sin manejo de overflow
Text(
  'Este es un texto muy largo que podría no caber en una línea',
  style: Theme.of(context).textTheme.bodyMedium,
  // Sin maxLines ni overflow → puede salirse del contenedor
)
```

### 6. Line Height Apropiado

```dart
// ✅ Correcto: Line height adecuado para legibilidad
Text(
  'Párrafo largo con múltiples líneas que necesita espacio adecuado '
  'entre líneas para mejorar la legibilidad y comodidad visual.',
  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
    height: 1.5,  // 1.5 veces el tamaño de fuente
  ),
)
```

### 7. Alineación Consistente

```dart
// ✅ Correcto: Alineación consistente
Column(
  crossAxisAlignment: CrossAxisAlignment.start,  // Todo alineado a la izquierda
  children: [
    Text('Título', style: Theme.of(context).textTheme.titleLarge),
    Text('Subtítulo', style: Theme.of(context).textTheme.bodyMedium),
    Text('Descripción', style: Theme.of(context).textTheme.bodySmall),
  ],
)

// ❌ Incorrecto: Alineación inconsistente
Column(
  children: [
    Align(alignment: Alignment.centerLeft, 
          child: Text('Título')),
    Align(alignment: Alignment.center, 
          child: Text('Subtítulo')),  // Centrado
    Align(alignment: Alignment.centerRight, 
          child: Text('Descripción')),  // Derecha
  ],
)
```

---

## 🎯 Casos de Uso Comunes

### Pantalla de Splash

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text(
      'BatFinder',
      style: Theme.of(context).textTheme.displayLarge,  // 57sp
    ),
    SizedBox(height: 8),
    Text(
      'Seguridad Comunitaria',
      style: Theme.of(context).textTheme.titleMedium,   // 16sp
    ),
  ],
)
```

### Pantalla de Dashboard

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Título de sección
    Text(
      'Reportes Recientes',
      style: Theme.of(context).textTheme.headlineMedium,  // 28sp
    ),
    SizedBox(height: 16),
    
    // Tarjeta de reporte
    Card(
      child: ListTile(
        title: Text(
          'Incidente en Zona Norte',
          style: Theme.of(context).textTheme.titleMedium,  // 16sp
        ),
        subtitle: Text(
          'Reportado por Juan Pérez hace 2 horas',
          style: Theme.of(context).textTheme.bodyMedium,   // 14sp
        ),
      ),
    ),
  ],
)
```

### Formulario de Entrada

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Etiqueta
    Text(
      'Título del Reporte',
      style: Theme.of(context).textTheme.titleSmall,  // 14sp medium
    ),
    SizedBox(height: 8),
    
    // Campo de texto
    TextField(
      style: Theme.of(context).textTheme.bodyLarge,  // 16sp regular
      decoration: InputDecoration(
        hintText: 'Ingresa un título descriptivo',
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).hintColor,
        ),
      ),
    ),
    SizedBox(height: 4),
    
    // Texto de ayuda
    Text(
      'El título debe tener entre 10 y 50 caracteres',
      style: Theme.of(context).textTheme.bodySmall,   // 12sp
    ),
  ],
)
```

---

## 🔍 Troubleshooting (Solución de Problemas)

### Problema: Fuente no se muestra correctamente

**Solución 1:** Verifica que la fuente esté en `pubspec.yaml`

```yaml
dependencies:
  google_fonts: ^6.1.0  # Verifica la versión
```

**Solución 2:** Reinicia la app (no hot reload)

```bash
flutter clean
flutter pub get
flutter run
```

### Problema: Texto muy pequeño en algunos dispositivos

**Solución:** Usa tamaños relativos con `MediaQuery`

```dart
Text(
  'Título',
  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
    fontSize: MediaQuery.of(context).size.width * 0.06,  // 6% del ancho
  ),
)
```

### Problema: Overflow de texto

**Solución 1:** Usa `maxLines` y `overflow`

```dart
Text(
  'Texto muy largo...',
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

**Solución 2:** Usa `Flexible` o `Expanded`

```dart
Row(
  children: [
    Icon(Icons.info),
    SizedBox(width: 8),
    Expanded(  // ← Permite que el texto se ajuste
      child: Text('Texto que puede ser muy largo'),
    ),
  ],
)
```

### Problema: Letter spacing inconsistente

**Solución:** Establece `letterSpacing` explícitamente

```dart
Text(
  'Título Espaciado',
  style: Theme.of(context).textTheme.titleLarge?.copyWith(
    letterSpacing: 1.2,  // Espaciado consistente
  ),
)
```

---

## 📚 Recursos Adicionales

### Fuentes de Google Fonts
- [Google Fonts - Roboto](https://fonts.google.com/specimen/Roboto)
- [Google Fonts - Inter](https://fonts.google.com/specimen/Inter)
- [Google Fonts - Explorar](https://fonts.google.com/)

### Documentación
- [Flutter Typography](https://api.flutter.dev/flutter/material/Typography-class.html)
- [Material Design Type System](https://material.io/design/typography/the-type-system.html)
- [Google Fonts Package](https://pub.dev/packages/google_fonts)

### Herramientas
- [Type Scale Generator](https://type-scale.com/)
- [Font Pairing Tool](https://fontpair.co/)
- [Modular Scale Calculator](https://www.modularscale.com/)

---

## 📝 Notas Importantes

1. **Roboto** se usa para elementos estructurales (títulos, labels)
2. **Inter** se usa para contenido legible (párrafos, descripciones)
3. Siempre usa estilos del tema en lugar de valores hardcoded
4. Prueba la legibilidad en ambos temas (claro y oscuro)
5. Considera la accesibilidad al elegir tamaños y pesos

---

**Última actualización:** 15 de enero de 2026  
**Versión de BatFinder:** 1.0.0  
**Autor:** Equipo de Desarrollo BatFinder