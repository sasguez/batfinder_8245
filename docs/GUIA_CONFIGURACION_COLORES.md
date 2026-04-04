# 🎨 Guía de Configuración de Colores - BatFinder

## 📋 Índice
1. [Visión General](#visión-general)
2. [Ubicación de Colores](#ubicación-de-colores)
3. [Paleta de Colores Completa](#paleta-de-colores-completa)
4. [Cómo Modificar Colores](#cómo-modificar-colores)
5. [Ejemplos de Personalización](#ejemplos-de-personalización)
6. [Mejores Prácticas](#mejores-prácticas)

---

## 🎯 Visión General

BatFinder utiliza un sistema de temas centralizado con una paleta de colores moderna azul/púrpura. Todos los colores están definidos en un único archivo para facilitar la personalización.

**Archivo Principal de Colores:**
```
lib/theme/app_theme.dart
```

---

## 📍 Ubicación de Colores

### Tema Claro (Light Theme)

Los colores del tema claro se encuentran en las líneas **7-26** de `app_theme.dart`:

```dart
// Paleta Moderna Azul/Púrpura - Especificaciones de Color
static const Color primaryLight = Color(0xFF6366F1); // Índigo vibrante
static const Color primaryVariantLight = Color(0xFF4F46E5); // Índigo oscuro
static const Color secondaryLight = Color(0xFF8B5CF6); // Púrpura
static const Color secondaryVariantLight = Color(0xFF7C3AED); // Púrpura oscuro
static const Color successLight = Color(0xFF10B981); // Verde esmeralda
static const Color warningLight = Color(0xFFF59E0B); // Ámbar
static const Color errorLight = Color(0xFFEF4444); // Rojo
static const Color accentLight = Color(0xFFF472B6); // Rosa
```

### Tema Oscuro (Dark Theme)

Los colores del tema oscuro se encuentran en las líneas **28-40** de `app_theme.dart`:

```dart
static const Color primaryDark = Color(0xFF818CF8); // Índigo claro
static const Color primaryVariantDark = Color(0xFF6366F1);
static const Color secondaryDark = Color(0xFFA78BFA); // Púrpura claro
static const Color secondaryVariantDark = Color(0xFF8B5CF6);
static const Color successDark = Color(0xFF34D399); // Verde brillante
static const Color warningDark = Color(0xFFFBBF24); // Ámbar brillante
static const Color errorDark = Color(0xFFF87171); // Rojo brillante
static const Color accentDark = Color(0xFFF9A8D4); // Rosa claro
```

---

## 🎨 Paleta de Colores Completa

### Colores Primarios y Secundarios

| Nombre | Tema Claro | Tema Oscuro | Uso |
|--------|-----------|-------------|-----|
| **Primary** | `#6366F1` (Índigo) | `#818CF8` (Índigo claro) | Botones principales, enlaces, navegación activa |
| **Primary Variant** | `#4F46E5` | `#6366F1` | Variantes de botones, estados hover |
| **Secondary** | `#8B5CF6` (Púrpura) | `#A78BFA` (Púrpura claro) | Botones secundarios, iconos destacados |
| **Secondary Variant** | `#7C3AED` | `#8B5CF6` | Variantes secundarias, estados de enfoque |

### Colores de Estado

| Nombre | Tema Claro | Tema Oscuro | Uso |
|--------|-----------|-------------|-----|
| **Success** | `#10B981` (Verde) | `#34D399` (Verde brillante) | Mensajes de éxito, confirmaciones |
| **Warning** | `#F59E0B` (Ámbar) | `#FBBF24` (Ámbar brillante) | Advertencias, alertas moderadas |
| **Error** | `#EF4444` (Rojo) | `#F87171` (Rojo brillante) | Errores, validaciones fallidas |
| **Accent** | `#F472B6` (Rosa) | `#F9A8D4` (Rosa claro) | Elementos destacados, badges |

### Colores de Superficie

| Nombre | Tema Claro | Tema Oscuro | Uso |
|--------|-----------|-------------|-----|
| **Background** | `#FFFFFF` (Blanco) | `#111827` (Gris oscuro) | Fondo principal de pantallas |
| **Surface** | `#F9FAFB` (Gris muy claro) | `#1F2937` (Gris medio) | Tarjetas, elementos elevados |
| **Card** | `#F9FAFB` | `#1F2937` | Tarjetas específicas |
| **Dialog** | `#FFFFFF` | `#374151` | Cuadros de diálogo, modales |

### Colores de Texto

| Nombre | Tema Claro | Tema Oscuro | Uso |
|--------|-----------|-------------|-----|
| **High Emphasis** | `#1F2937` (Casi negro) | `#F9FAFB` (Blanco cálido) | Títulos, texto principal |
| **Medium Emphasis** | `#6B7280` (Gris medio) | `#D1D5DB` (Gris claro) | Subtítulos, descripciones |
| **Disabled** | `#9CA3AF` (Gris claro) | `#9CA3AF` | Texto deshabilitado |

### Colores Auxiliares

| Nombre | Tema Claro | Tema Oscuro | Uso |
|--------|-----------|-------------|-----|
| **Divider** | `#E5E7EB` | `#4B5563` | Líneas divisoras, bordes |
| **Shadow** | `#000000` (10% opacidad) | `#FFFFFF` (10% opacidad) | Sombras de elevación |

---

## 🔧 Cómo Modificar Colores

### Paso 1: Abrir el Archivo de Tema

```bash
# Navega al archivo de tema
lib/theme/app_theme.dart
```

### Paso 2: Localizar el Color a Cambiar

Busca la constante del color que deseas modificar. Por ejemplo, para cambiar el color primario:

```dart
// ANTES
static const Color primaryLight = Color(0xFF6366F1); // Índigo vibrante

// DESPUÉS (ejemplo: cambiar a azul)
static const Color primaryLight = Color(0xFF2563EB); // Azul
```

### Paso 3: Entender el Formato de Color

Los colores usan formato hexadecimal ARGB:

```dart
Color(0xFFRRGGBB)
// FF = Alpha (opacidad completa)
// RR = Componente Rojo (00-FF)
// GG = Componente Verde (00-FF)
// BB = Componente Azul (00-FF)
```

### Paso 4: Guardar y Verificar

1. Guarda el archivo
2. Reinicia la aplicación (Hot Reload puede no ser suficiente)
3. Verifica que todos los elementos usen el nuevo color

---

## 💡 Ejemplos de Personalización

### Ejemplo 1: Cambiar a Esquema de Colores Verde/Azul

```dart
// Colores Primarios
static const Color primaryLight = Color(0xFF059669); // Verde esmeralda
static const Color primaryVariantLight = Color(0xFF047857); // Verde oscuro
static const Color secondaryLight = Color(0xFF0EA5E9); // Azul cielo
static const Color secondaryVariantLight = Color(0xFF0284C7); // Azul oscuro
```

### Ejemplo 2: Crear Tema Corporativo

```dart
// Usando colores de marca corporativa
static const Color primaryLight = Color(0xFF1E40AF); // Azul corporativo
static const Color primaryVariantLight = Color(0xFF1E3A8A); // Azul oscuro
static const Color secondaryLight = Color(0xFFDC2626); // Rojo corporativo
static const Color accentLight = Color(0xFFFBBF24); // Amarillo dorado
```

### Ejemplo 3: Modo Alto Contraste

```dart
// Para mejor accesibilidad
static const Color primaryLight = Color(0xFF000080); // Azul marino oscuro
static const Color primaryVariantLight = Color(0xFF000050); // Azul muy oscuro
static const Color textHighEmphasisLight = Color(0xFF000000); // Negro puro
static const Color backgroundLight = Color(0xFFFFFFFF); // Blanco puro
```

### Ejemplo 4: Tema Monocromático

```dart
// Usando solo tonos de azul
static const Color primaryLight = Color(0xFF1E40AF); // Azul medio
static const Color primaryVariantLight = Color(0xFF1E3A8A); // Azul oscuro
static const Color secondaryLight = Color(0xFF60A5FA); // Azul claro
static const Color accentLight = Color(0xFF93C5FD); // Azul muy claro
```

---

## ✅ Mejores Prácticas

### 1. Mantener Consistencia

- **Siempre modifica ambos temas** (claro y oscuro) para mantener consistencia
- **Usa colores relacionados** entre tema claro y oscuro (ej: versión más clara/oscura del mismo tono)

```dart
// Correcto: Colores relacionados
static const Color primaryLight = Color(0xFF6366F1); // Índigo
static const Color primaryDark = Color(0xFF818CF8); // Índigo más claro

// Incorrecto: Colores no relacionados
static const Color primaryLight = Color(0xFF6366F1); // Índigo
static const Color primaryDark = Color(0xFFEF4444); // Rojo (no relacionado)
```

### 2. Verificar Contraste

Usa herramientas como [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/) para asegurar:

- **Texto normal**: Mínimo contraste 4.5:1
- **Texto grande**: Mínimo contraste 3:1
- **Elementos UI**: Mínimo contraste 3:1

```dart
// Buen contraste (índigo sobre blanco)
background: Color(0xFFFFFFFF),
text: Color(0xFF6366F1) // ✅ Contraste > 4.5:1

// Mal contraste (gris claro sobre blanco)
background: Color(0xFFFFFFFF),
text: Color(0xFFE5E7EB) // ❌ Contraste < 4.5:1
```

### 3. Usar Variables Semánticas

En lugar de valores directos en widgets, usa las constantes del tema:

```dart
// ✅ Correcto: Usa constantes del tema
Container(
  color: Theme.of(context).colorScheme.primary,
)

// ❌ Incorrecto: Valor hardcoded
Container(
  color: Color(0xFF6366F1),
)
```

### 4. Probar en Ambos Temas

Siempre prueba tu aplicación en:
- Tema claro
- Tema oscuro
- Diferentes tamaños de pantalla
- Con texto en español

```dart
// En main.dart, puedes probar cambiando el tema:
MaterialApp(
  theme: AppTheme.lightTheme,    // Tema claro
  darkTheme: AppTheme.darkTheme,  // Tema oscuro
  themeMode: ThemeMode.system,    // Sigue el sistema
)
```

### 5. Documentar Cambios

Cuando modifiques colores, documenta:
- **Qué color cambiaste**
- **Por qué lo cambiaste**
- **Dónde se usa ese color**

```dart
// Ejemplo de comentario útil
// Cambiado de #6366F1 a #2563EB para mejor visibilidad
// en dispositivos con pantallas antiguas (2026-01-15)
static const Color primaryLight = Color(0xFF2563EB);
```

### 6. Backup Antes de Cambios Grandes

```bash
# Crea un backup del archivo de tema
cp lib/theme/app_theme.dart lib/theme/app_theme_backup.dart
```

---

## 🎯 Casos de Uso Comunes

### Dónde se Usa Cada Color

#### Color Primario (`primaryLight` / `primaryDark`)
- ✅ Botones principales (ElevatedButton)
- ✅ Floating Action Button (FAB)
- ✅ Ítem seleccionado en navegación inferior
- ✅ Enlaces y texto interactivo
- ✅ Indicadores de progreso
- ✅ Sliders y switches activos

**Dónde encontrarlo en el código:**
```dart
// lib/theme/app_theme.dart líneas: 111, 122, 133, 268, 290
floatingActionButtonTheme: FloatingActionButtonThemeData(
  backgroundColor: primaryLight, // ← Color primario aquí
)
```

#### Color Secundario (`secondaryLight` / `secondaryDark`)
- ✅ Botones secundarios (OutlinedButton)
- ✅ Iconos de soporte
- ✅ Badges y etiquetas
- ✅ Encabezados de sección alternos

**Dónde encontrarlo en el código:**
```dart
// En widgets personalizados
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.secondary,
  ),
)
```

#### Color de Éxito (`successLight` / `successDark`)
- ✅ Notificaciones de éxito
- ✅ Iconos de confirmación
- ✅ Indicadores de proceso completado
- ✅ Mensajes de validación positiva

#### Color de Error (`errorLight` / `errorDark`)
- ✅ Mensajes de error
- ✅ Validaciones fallidas en formularios
- ✅ Bordes de campos con error
- ✅ Iconos de advertencia crítica

**Dónde encontrarlo en el código:**
```dart
// lib/theme/app_theme.dart líneas: 189-195
errorBorder: OutlineInputBorder(
  borderSide: BorderSide(color: errorLight, width: 1.5), // ← Color de error
)
```

---

## 🔍 Troubleshooting (Solución de Problemas)

### Problema: Los colores no cambian después de modificar app_theme.dart

**Solución:**
1. Detén la aplicación completamente
2. Ejecuta `flutter clean`
3. Ejecuta `flutter pub get`
4. Reinicia la aplicación (no uses hot reload)

```bash
flutter clean
flutter pub get
flutter run
```

### Problema: Algunos elementos no usan los colores del tema

**Solución:**
Busca valores hardcoded en el código:

```bash
# Busca colores hardcoded en el proyecto
grep -r "Color(0x" lib/
```

Reemplázalos con referencias al tema:

```dart
// Antes
Container(color: Color(0xFF6366F1))

// Después
Container(color: Theme.of(context).colorScheme.primary)
```

### Problema: El contraste es pobre en modo oscuro

**Solución:**
Ajusta los colores del tema oscuro para mayor luminosidad:

```dart
// Incrementa el valor hexadecimal para más brillo
static const Color primaryDark = Color(0xFF818CF8); // Más claro
static const Color textHighEmphasisDark = Color(0xFFF9FAFB); // Casi blanco
```

---

## 📚 Recursos Adicionales

### Herramientas Útiles
- [Coolors.co](https://coolors.co/) - Generador de paletas de colores
- [Material Design Color Tool](https://material.io/resources/color/) - Verificador de accesibilidad
- [Adobe Color](https://color.adobe.com/) - Rueda de colores y armonías
- [Contrast Checker](https://webaim.org/resources/contrastchecker/) - Verificador de contraste WCAG

### Documentación de Referencia
- [Flutter Theme Documentation](https://api.flutter.dev/flutter/material/ThemeData-class.html)
- [Material Design Color System](https://material.io/design/color/the-color-system.html)
- [Guía de Accesibilidad de Color](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)

---

## 📝 Notas Importantes

1. **Siempre modifica ambos temas** (claro y oscuro) para mantener consistencia
2. **Verifica el contraste** de colores para accesibilidad
3. **Prueba en dispositivos reales** antes de desplegar cambios
4. **Documenta todos los cambios** para referencia futura
5. **Crea backups** antes de modificaciones grandes

---

**Última actualización:** 15 de enero de 2026  
**Versión de BatFinder:** 1.0.0  
**Autor:** Equipo de Desarrollo BatFinder