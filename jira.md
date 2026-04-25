# Análisis de jira.bat

## Descripción General
Script de Windows Batch (v1.3) para gestionar tareas de desarrollo. Permite crear, abrir, cerrar y organizar tareas en directorios, integrándose con Notepad++, Total Commander y Firefox para acceder a un sistema Mantis.

## Configuración Principal

### Variables de Entorno
- **RUTA_BASE**: `c:\Users\dars\Desktop\Casti\tareas` - Directorio principal de tareas
- **RUTA_LOG**: Subdirectorio para logs
- **RUTA_CERR**: `CERRADAS` - Subdirectorio para tareas cerradas
- **NPP**: Ruta a Notepad++ para editar archivos (`c:\Users\dars\bin\Npp\notepad++.exe`)
- **FF**: Ruta a Firefox para abrir URLs de Mantis (`C:\Program Files\Mozilla Firefox\firefox.exe`)
- **TC**: Ruta a Total Commander para navegar archivos (`C:\Program Files\totalcmd\TOTALCMD64.EXE`)
- **URL Mantis**: `https://mantis.dars.es/view.php?id=`

### Estructura de Directorios
```
RUTA_BASE/
├── log/              (logs del sistema)
├── CERRADAS/         (tareas finalizadas)
└── [CODIGO] TITULO/  (tareas activas)
    └── [CODIGO].leeme (notas de la tarea)
```

## Funcionalidades Principales

### 1. Abrir/Crear Tarea (`/A`)
- **Sintaxis**: `jira /A CODIGO [TEXTO]`
- Crea una nueva carpeta con nombre `CODIGO TEXTO`
- Genera archivo `.leeme` con notas de la tarea
- Abre Notepad++ con el archivo de notas
- Abre Total Commander en el panel izquierdo mostrando el directorio de la tarea
- Abre Firefox con la URL del ticket en Mantis (solo si el código NO comienza con `0x`)
- Si la tarea existe (abierta o cerrada), la reabre

### 2. Cerrar Tarea (`/C`)
- **Sintaxis**: `jira /C CODIGO`
- Mueve la carpeta de la tarea al directorio CERRADAS
- Mantiene toda la información de la tarea

### 3. Listar Tareas (`/L` o sin parámetros)
- Muestra todas las tareas abiertas
- Excluye directorios especiales (CERRADAS, log)
- Si no hay tareas, indica "No hay tareas pendientes"

### 4. Buscar Código Máximo (`/M`)
- Busca el código numérico más alto con formato `0xNNN`
- Busca en tareas abiertas y cerradas
- Útil para tareas sin código oficial o tareas personales

### 5. Buscar en Cerradas (`/B`)
- **Sintaxis**: `jira /B TEXTO`
- Busca texto en los nombres de carpetas de tareas cerradas
- Búsqueda insensible a mayúsculas/minúsculas

### 6. Mostrar Pendientes (`/P`)
- **Sintaxis**: `jira /P [CODIGO]`
- Sin código: busca marcas `/HACER:` en todos los archivos `.leeme` de tareas abiertas
- Con código: muestra solo los pendientes de esa tarea específica
- Muestra número de línea donde aparece cada marca

### 7. Ayuda (`/H` o `/?`)
- Muestra información de uso completa
- Lista todos los parámetros disponibles

## Parámetros

| Parámetro | Descripción |
|-----------|-------------|
| `/H` o `/?` | Muestra ayuda |
| `/L` | Lista tareas abiertas |
| `/M` | Busca código máximo (0xNNN) |
| `/A` | Abre/crea tarea |
| `/C` | Cierra tarea |
| `/B` | Busca en tareas cerradas |
| `/P` | Muestra marcas /HACER: |
| `CODIGO` | Identificador de la tarea |
| `TEXTO` | Descripción adicional (se concatena todo lo que no sea parámetro) |

## Características Técnicas

### Validaciones
- Verifica existencia de directorios configurados
- Verifica existencia de Notepad++, Firefox y Total Commander
- Crea directorios log y CERRADAS si no existen
- Manejo de errores en operaciones de movimiento de carpetas

### Tipos de Tareas
- **Tareas con código numérico**: Tareas vinculadas a tickets de Mantis (ej: `12345`)
  - Al abrirse, lanzan el navegador con el ticket correspondiente
- **Tareas con código 0x**: Tareas personales sin ticket de Mantis (ej: `0x001`, `0x123`)
  - No lanzan el navegador
  - Útiles para tareas internas, experimentación o tareas sin código oficial

### Sistema de Logging
- Genera logs con formato: `AAAAMM.log`
- Registra fecha y hora: `AAAA/MM/DD HH:MM:SS`

### Procesamiento de Parámetros
- Usa delayed expansion para manejo robusto de variables
- Los parámetros pueden pasarse en cualquier orden
- El texto descriptivo se concatena automáticamente aunque haya parámetros intercalados
- Orden de ejecución fijo independiente del orden de entrada

### Funciones Auxiliares
- `:extraer_numero`: Extrae y compara números de formato 0xNNN
- `:comparar_num`: Compara números eliminando ceros a la izquierda

## Flujo de Trabajo Típico

1. **Iniciar nueva tarea**: `jira /A 12345 Implementar nueva funcionalidad`
2. **Trabajar en la tarea**: Editar el archivo `.leeme`, añadir marcas `/HACER:` para pendientes
3. **Ver pendientes**: `jira /P` o `jira /P 12345`
4. **Cerrar tarea**: `jira /C 12345`
5. **Reabrir si necesario**: `jira /A 12345` (recupera automáticamente de CERRADAS)
6. **Buscar tarea antigua**: `jira /B funcionalidad`

## Integraciones

### Mantis (Sistema de Tickets)
- Cada tarea numérica se vincula con un ticket en el sistema Mantis
- Al abrir una tarea con código numérico, automáticamente se abre el navegador con el ticket correspondiente
- URL construida dinámicamente: `https://mantis.dars.es/view.php?id=[CODIGO]`
- Las tareas con código `0x` no abren Mantis (son tareas personales)

### Total Commander (Gestor de Archivos)
- Se abre automáticamente al crear o abrir una tarea
- Muestra el directorio de la tarea en el panel izquierdo
- Usa nueva pestaña si Total Commander ya está abierto (parámetros: `/O /T /L=`)
- Permite acceso rápido a todos los archivos de la tarea

### Notepad++ (Editor)
- Se abre automáticamente con el archivo `.leeme` de la tarea
- Archivo `.leeme` contiene notas y marcas `/HACER:` para seguimiento de pendientes

## Configuración Personalizable

Todas las rutas y aplicaciones se configuran mediante variables al inicio del script (líneas 8-14):

```batch
SET VERSION=1.3
SET RUTA_BASE=c:\Users\dars\Desktop\Casti\tareas
SET RUTA_LOG=%RUTA_BASE%\log
SET RUTA_CERR=%RUTA_BASE%\CERRADAS
SET NPP=c:\Users\dars\bin\Npp\notepad++.exe
SET FF="C:\Program Files\Mozilla Firefox\firefox.exe"
SET TC="C:\Program Files\totalcmd\TOTALCMD64.EXE"
```

Para adaptar el script a otro entorno, solo es necesario modificar estas variables con las rutas correspondientes.

## Notas Adicionales
- Cambia temporalmente al directorio de trabajo (RUTA_BASE)
- Compatible con códigos numéricos estándar y códigos personalizados (0xNNN)
- Sistema robusto para reabrir tareas cerradas
- Búsqueda flexible e insensible a mayúsculas
- Diseño modular con todas las rutas configurables mediante variables

### TotalCommander
Parámetros Clave de Total Commander

Los parámetros más relevantes son:

- /L=ruta - Abre la ruta en el panel izquierdo
- /R=ruta - Abre la ruta en el panel derecho
- /O - Envía el comando a una instancia ya abierta (en lugar de abrir una nueva ventana)
- /T - Abre la ruta en una nueva pestaña (si usas pestañas)
- /P=L o /P=R - Hace que el panel izquierdo o derecho sea el activo
