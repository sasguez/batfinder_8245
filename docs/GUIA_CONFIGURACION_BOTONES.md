# 🔘 Guía de Configuración de Botones - BatFinder

## 📋 Índice
1. [Tipos de Botones](#tipos-de-botones)
2. [Estilos de Botones](#estilos-de-botones)
3. [Ubicación en el Código](#ubicación-en-el-código)
4. [Cómo Modificar Botones](#cómo-modificar-botones)
5. [Ejemplos de Personalización](#ejemplos-de-personalización)
6. [Mejores Prácticas](#mejores-prácticas)

---

## 🎯 Tipos de Botones

BatFinder utiliza tres tipos principales de botones siguiendo Material Design 3:

### 1. ElevatedButton (Botón Elevado)
**Uso:** Acciones primarias de alta prioridad

**Características:**
- Fondo sólido de color primario (#6366F1 - Índigo)
- Texto blanco
- Sombra de elevación (2dp)
- Bordes redondeados (12px)

**Cuándo usarlo:**
- ✅ Acciones principales (Guardar, Enviar, Crear)
- ✅ Llamados a la acción (CTA)
- ✅ Acciones de confirmación

**Ejemplo visual:**
```
┌─────────────────────┐
│   Crear Reporte     │  ← Fondo índigo, texto blanco
└─────────────────────┘
```

### 2. OutlinedButton (Botón Con Contorno)
**Uso:** Acciones secundarias o alternativas

**Características:**
- Sin relleno de fondo
- Borde de 1.5px color primario (#6366F1)
- Texto color primario
- Sin sombra
- Bordes redondeados (12px)

**Cuándo usarlo:**
- ✅ Acciones secundarias (Cancelar, Volver)
- ✅ Acciones menos importantes que el botón elevado
- ✅ Cuando necesitas múltiples botones en la misma pantalla

**Ejemplo visual:**
```
┌─────────────────────┐
│   Cancelar          │  ← Solo borde índigo, texto índigo
└─────────────────────┘
```

### 3. TextButton (Botón de Texto)
**Uso:** Acciones terciarias o de baja prioridad

**Características:**
- Sin relleno ni borde
- Solo texto color primario (#6366F1)
- Sin sombra
- Bordes redondeados (12px)

**Cuándo usarlo:**
- ✅ Acciones opcionales (Omitir, Más tarde)
- ✅ Navegación entre pantallas
- ✅ Enlaces dentro de diálogos

**Ejemplo visual:**
```
   Omitir   ← Solo texto índigo, sin fondo ni borde
```

### 4. FloatingActionButton (FAB)
**Uso:** Acción primaria flotante en la pantalla

**Características:**
- Forma circular o redondeada
- Fondo color primario (#6366F1)
- Icono blanco
- Elevación de 4dp
- Radio de borde de 16px

**Cuándo usarlo:**
- ✅ Acción principal de la pantalla (Agregar, Crear)
- ✅ Acción que flota sobre el contenido
- ✅ Acción accesible desde cualquier punto de scroll

**Ejemplo visual:**
```
    ┌─────┐
    │  +  │  ← Botón circular índigo flotante
    └─────┘
```

---

## 🎨 Estilos de Botones

### Tema Claro (Light Theme)

```dart
// ElevatedButton
backgroundColor: Color(0xFF6366F1)  // Índigo
foregroundColor: Color(0xFFFFFFFF)  // Blanco
borderRadius: 12px
elevation: 2dp
padding: horizontal 24px, vertical 14px
fontSize: 14sp
fontWeight: 500 (Medium)
letterSpacing: 1.25

// OutlinedButton
borderColor: Color(0xFF6366F1)      // Índigo
borderWidth: 1.5px
foregroundColor: Color(0xFF6366F1)  // Índigo
borderRadius: 12px
padding: horizontal 24px, vertical 14px
fontSize: 14sp
fontWeight: 500 (Medium)

// TextButton
foregroundColor: Color(0xFF6366F1)  // Índigo
borderRadius: 12px
padding: horizontal 16px, vertical 12px
fontSize: 14sp
fontWeight: 500 (Medium)
```

### Tema Oscuro (Dark Theme)

```dart
// ElevatedButton
backgroundColor: Color(0xFF818CF8)  // Índigo claro
foregroundColor: Color(0xFF000000)  // Negro
borderRadius: 12px
elevation: 2dp

// OutlinedButton
borderColor: Color(0xFF818CF8)      // Índigo claro
foregroundColor: Color(0xFF818CF8)  // Índigo claro

// TextButton
foregroundColor: Color(0xFF818CF8)  // Índigo claro
```

---

## 📍 Ubicación en el Código

### Configuración Global de Botones

**Archivo:** `lib/theme/app_theme.dart`

#### ElevatedButton (Líneas 133-151)
```dart
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    foregroundColor: onPrimaryLight,
    backgroundColor: primaryLight,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    elevation: 2.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    textStyle: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
    ),
    minimumSize: Size(88, 48),
  ),
),
```

#### OutlinedButton (Líneas 153-170)
```dart
outlinedButtonTheme: OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    foregroundColor: primaryLight,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    side: BorderSide(color: primaryLight, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    textStyle: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
    ),
    minimumSize: Size(88, 48),
  ),
),
```

#### TextButton (Líneas 172-188)
```dart
textButtonTheme: TextButtonThemeData(
  style: TextButton.styleFrom(
    foregroundColor: primaryLight,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    textStyle: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
    ),
    minimumSize: Size(88, 48),
  ),
),
```

#### FloatingActionButton (Líneas 125-131)
```dart
floatingActionButtonTheme: FloatingActionButtonThemeData(
  backgroundColor: primaryLight,
  foregroundColor: onPrimaryLight,
  elevation: 4.0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
),
```

---

## 🔧 Cómo Modificar Botones

### Modificar Estilos Globales

#### Cambiar Colores de Botones

**Paso 1:** Abrir `lib/theme/app_theme.dart`

**Paso 2:** Localizar el tipo de botón a modificar

**Paso 3:** Cambiar las propiedades deseadas

**Ejemplo - Cambiar color de ElevatedButton:**
```dart
// ANTES
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryLight, // Índigo actual
  ),
),

// DESPUÉS (ejemplo: cambiar a verde)
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF10B981), // Verde esmeralda
  ),
),
```

#### Cambiar Tamaño de Botones

```dart
// Modificar padding para botones más grandes
padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18), // ← Era 24, 14

// Modificar tamaño mínimo
minimumSize: Size(120, 56), // ← Era 88, 48
```

#### Cambiar Forma de Botones

```dart
// Botones más redondeados
shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(20.0) // ← Era 12.0
),

// Botones rectangulares (sin redondeo)
shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(4.0)
),

// Botones totalmente circulares (para FAB)
shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(28.0)
),
```

#### Cambiar Tipografía de Botones

```dart
textStyle: GoogleFonts.roboto(
  fontSize: 16,           // ← Era 14 (texto más grande)
  fontWeight: FontWeight.w600, // ← Era w500 (más grueso)
  letterSpacing: 1.5,     // ← Era 1.25 (más espaciado)
),
```

### Modificar Botones Individuales

Si quieres que un botón específico tenga un estilo diferente sin cambiar el tema global:

```dart
// En un widget específico
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red,     // Color personalizado
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: Text('Botón Personalizado'),
)
```

---

## 💡 Ejemplos de Personalización

### Ejemplo 1: Botones con Iconos

```dart
// Botón elevado con icono
ElevatedButton.icon(
  onPressed: () {},
  icon: Icon(Icons.add),
  label: Text('Crear Nuevo'),
)

// Botón con contorno con icono
OutlinedButton.icon(
  onPressed: () {},
  icon: Icon(Icons.cancel),
  label: Text('Cancelar'),
)

// Botón de texto con icono
TextButton.icon(
  onPressed: () {},
  icon: Icon(Icons.arrow_forward),
  label: Text('Siguiente'),
)
```

### Ejemplo 2: Botones de Ancho Completo

```dart
// Botón que ocupa todo el ancho
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () {},
    child: Text('Continuar'),
  ),
)
```

### Ejemplo 3: Botones con Estado de Carga

```dart
// Botón con loading
ElevatedButton(
  onPressed: isLoading ? null : () {},
  child: isLoading
      ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
      : Text('Enviar'),
)
```

### Ejemplo 4: Grupo de Botones

```dart
// Botones en fila
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Expanded(
      child: OutlinedButton(
        onPressed: () {},
        child: Text('Cancelar'),
      ),
    ),
    SizedBox(width: 16),
    Expanded(
      child: ElevatedButton(
        onPressed: () {},
        child: Text('Confirmar'),
      ),
    ),
  ],
)
```

### Ejemplo 5: FAB con Etiqueta

```dart
// FloatingActionButton con texto
FloatingActionButton.extended(
  onPressed: () {},
  icon: Icon(Icons.add),
  label: Text('Nuevo'),
)
```

### Ejemplo 6: Botones de Diferentes Tamaños

```dart
// Botón pequeño
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    minimumSize: Size(60, 36),
  ),
  child: Text('Pequeño', style: TextStyle(fontSize: 12)),
)

// Botón grande
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
    minimumSize: Size(120, 60),
  ),
  child: Text('Grande', style: TextStyle(fontSize: 18)),
)
```

---

## ✅ Mejores Prácticas

### 1. Jerarquía Visual

Usa los tipos de botones según su importancia:

```dart
// ✅ Correcto: Jerarquía clara
Column(
  children: [
    ElevatedButton(          // Acción primaria
      child: Text('Guardar'),
    ),
    OutlinedButton(          // Acción secundaria
      child: Text('Cancelar'),
    ),
    TextButton(              // Acción terciaria
      child: Text('Omitir'),
    ),
  ],
)

// ❌ Incorrecto: Múltiples botones elevados compitiendo
Column(
  children: [
    ElevatedButton(child: Text('Guardar')),
    ElevatedButton(child: Text('Cancelar')),
    ElevatedButton(child: Text('Omitir')),
  ],
)
```

### 2. Tamaños Consistentes

```dart
// ✅ Correcto: Mismo tamaño para botones en grupo
Row(
  children: [
    Expanded(child: OutlinedButton(...)),
    SizedBox(width: 16),
    Expanded(child: ElevatedButton(...)),
  ],
)

// ❌ Incorrecto: Tamaños inconsistentes
Row(
  children: [
    OutlinedButton(...),  // Tamaño automático
    ElevatedButton(...),  // Tamaño diferente
  ],
)
```

### 3. Accesibilidad

```dart
// ✅ Incluye Semantic Label para lectores de pantalla
Semantics(
  button: true,
  label: 'Crear nuevo reporte de incidente',
  child: ElevatedButton(
    child: Text('Crear'),
  ),
)

// Asegura tamaño mínimo táctil de 48dp
minimumSize: Size(88, 48), // ✅ Cumple con WCAG
```

### 4. Estados de Interacción

```dart
// Maneja estados deshabilitados
ElevatedButton(
  onPressed: canSubmit ? _submit : null, // null = deshabilitado
  child: Text('Enviar'),
)

// Proporciona feedback visual durante operaciones
bool _isLoading = false;

ElevatedButton(
  onPressed: _isLoading ? null : () async {
    setState(() => _isLoading = true);
    await _performAction();
    setState(() => _isLoading = false);
  },
  child: _isLoading ? CircularProgressIndicator() : Text('Enviar'),
)
```

### 5. Espaciado y Layout

```dart
// ✅ Correcto: Espaciado consistente
Column(
  children: [
    ElevatedButton(...),
    SizedBox(height: 16), // Espaciado consistente
    OutlinedButton(...),
    SizedBox(height: 16),
    TextButton(...),
  ],
)

// ✅ Correcto: Alineación apropiada
Row(
  mainAxisAlignment: MainAxisAlignment.end, // Botones alineados a la derecha
  children: [
    OutlinedButton(child: Text('Cancelar')),
    SizedBox(width: 16),
    ElevatedButton(child: Text('Confirmar')),
  ],
)
```

### 6. Texto de Botones

```dart
// ✅ Correcto: Texto claro y accionable
ElevatedButton(child: Text('Crear Reporte'))
OutlinedButton(child: Text('Cancelar'))
TextButton(child: Text('Ver Detalles'))

// ❌ Incorrecto: Texto ambiguo
ElevatedButton(child: Text('Aceptar'))  // ¿Aceptar qué?
OutlinedButton(child: Text('No'))       // Demasiado corto
TextButton(child: Text('Clic'))         // No descriptivo
```

---

## 🎯 Casos de Uso por Pantalla

### Pantalla de Login

```dart
// Botón principal de inicio de sesión
ElevatedButton(
  child: Text('Iniciar Sesión'),
  onPressed: _login,
)

// Enlace de registro
TextButton(
  child: Text('¿No tienes cuenta? Regístrate'),
  onPressed: _goToRegister,
)

// Enlace de recuperación de contraseña
TextButton(
  child: Text('¿Olvidaste tu contraseña?'),
  onPressed: _resetPassword,
)
```

### Pantalla de Formulario

```dart
// Botón de envío (acción principal)
ElevatedButton(
  child: Text('Guardar Cambios'),
  onPressed: _saveForm,
)

// Botón de cancelar (acción secundaria)
OutlinedButton(
  child: Text('Cancelar'),
  onPressed: () => Navigator.pop(context),
)

// Botón de restablecer (acción terciaria)
TextButton(
  child: Text('Restablecer Formulario'),
  onPressed: _resetForm,
)
```

### Pantalla de Lista

```dart
// FAB para crear nuevo elemento
FloatingActionButton.extended(
  icon: Icon(Icons.add),
  label: Text('Nuevo Reporte'),
  onPressed: _createNewReport,
)

// Botones de acción en elementos de lista
IconButton(
  icon: Icon(Icons.edit),
  onPressed: _edit,
)

IconButton(
  icon: Icon(Icons.delete),
  onPressed: _delete,
)
```

### Diálogo de Confirmación

```dart
// Botones en diálogo
AlertDialog(
  actions: [
    TextButton(
      child: Text('Cancelar'),
      onPressed: () => Navigator.pop(context),
    ),
    ElevatedButton(
      child: Text('Confirmar'),
      onPressed: _confirm,
    ),
  ],
)
```

---

## 🔍 Troubleshooting (Solución de Problemas)

### Problema: Botones muy pequeños en algunos dispositivos

**Solución:**
Aumenta el `minimumSize` en el tema:

```dart
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    minimumSize: Size(88, 56), // ← Aumentado de 48 a 56
  ),
),
```

### Problema: Texto de botón cortado

**Solución:**
Usa `FittedBox` o reduce el tamaño de fuente:

```dart
// Opción 1: FittedBox
ElevatedButton(
  child: FittedBox(
    child: Text('Texto muy largo que se ajustará'),
  ),
)

// Opción 2: Reducir fontSize
ElevatedButton(
  style: ElevatedButton.styleFrom(
    textStyle: TextStyle(fontSize: 12), // ← Reducido
  ),
  child: Text('Texto largo'),
)
```

### Problema: Botones no responden al tema

**Solución:**
Verifica que no estés usando estilos hardcoded:

```dart
// ❌ Incorrecto
ElevatedButton(
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Colors.blue),
  ),
)

// ✅ Correcto
ElevatedButton(
  // Sin style personalizado, usa el tema
)

// ✅ También correcto (si necesitas personalizar)
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primary,
  ),
)
```

---

## 📚 Recursos Adicionales

### Documentación Oficial
- [Material Buttons - Flutter](https://docs.flutter.dev/cookbook/design/buttons)
- [Material Design 3 Buttons](https://m3.material.io/components/buttons/overview)
- [ButtonStyle Class](https://api.flutter.dev/flutter/material/ButtonStyle-class.html)

### Ejemplos de Código
- [Flutter Gallery - Buttons](https://gallery.flutter.dev/#/)
- [Material Components - Button Examples](https://material.io/components/buttons/flutter)

---

## 📝 Notas Importantes

1. **Cambios globales** en `app_theme.dart` afectan todos los botones de la app
2. **Estilos personalizados** en widgets individuales sobrescriben el tema global
3. **Prueba en ambos temas** (claro y oscuro) después de cambios
4. **Mantén consistencia** de espaciado y tamaños en toda la aplicación
5. **Considera accesibilidad** al modificar tamaños y colores

---

**Última actualización:** 15 de enero de 2026  
**Versión de BatFinder:** 1.0.0  
**Autor:** Equipo de Desarrollo BatFinder