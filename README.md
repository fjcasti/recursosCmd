# recursosCmd

Colección de scripts de Windows Batch reutilizables que cubren tareas habituales de administración, configuración de entorno y automatización del escritorio.

## Contenido

| Script | Descripción |
|---|---|
| [`asignar_salida_comando_a_variable.bat`](#asignar_salida_comando_a_variablebat) | Tres técnicas para capturar la salida de un comando en una variable |
| [`bloquear_sesión.bat`](#bloquear_sesiónbat) | Bloquea la sesión de Windows con una sola línea |
| [`control_cursor_en_consola.bat`](#control_cursor_en_consolabat) | Secuencias ANSI para mover y repintar el cursor en consola |
| [`copiaSeguridad.bat`](#copiaseguridadbat) | Copia de seguridad comprimida con 7-Zip, configurable por parámetros |
| [`entorno.bat`](#entornobat) | Lee y modifica valores de un fichero `.ini` de configuración de entorno |
| [`estado_de_bloq_num.bat`](#estado_de_bloq_numbat) | Detecta si Bloq Mayús está activo o no |
| [`fecha_y_hora_en_variable.bat`](#fecha_y_hora_en_variablebat) | Extrae partes de la fecha y hora del sistema en variables |
| [`javadk.bat`](#javadkbat) | Selecciona un JDK instalado y configura `JAVA_HOME` y `PATH` |
| [`gitperf.bat`](#gitperfbat) | Mantiene distintos perfiles para usar con Git |
| [`jira.bat`](#jirabat) | Gestión de tareas locales con integración en Firefox y Total Commander |
| [`lee_fichero_ini.bat`](#lee_fichero_inibat) | Lector genérico de ficheros `.ini` por sección y clave |
| [`miTeclado.bat`](#mitecladobat) | Arranca o detiene PowerToys Keyboard Manager según el teclado que esté conectado |
| [`procesar_parametros_linea_comandos.bat`](#procesar_parametros_linea_comandosbat) | Patrón para procesar parámetros con nombre y posicionales |
| [`todo.bat`](#todobat) | Gestion de notas/tareas para hacer |
| [`usar_UTF8_en_consola.bat`](#usar_utf8_en_consolabat) | Configura la consola para mostrar caracteres UTF-8 correctamente |

---

## Descripción de cada script

### `asignar_salida_comando_a_variable.bat`
Demuestra tres métodos distintos para capturar la salida de un comando en una variable Batch: `FOR /F`, `SET /P` con redirección y fichero temporal.

### `bloquear_sesión.bat`
Llama a `rundll32.exe user32.dll LockWorkStation` para bloquear la sesión del usuario actual. Útil como atajo o como paso dentro de un flujo mayor.

### `control_cursor_en_consola.bat`
Muestra cómo usar secuencias de escape ANSI (movimiento de cursor, borrado de línea, reescritura en sitio) para crear salidas de consola más limpias e interactivas.

### `copiaSeguridad.bat`
Realiza copias de seguridad comprimidas usando 7-Zip. Lee la configuración (origen, destino, nombre, niveles de compresión) desde un fichero `.dat` y acepta sobreescrituras por parámetro.

**Requisito:** 7-Zip instalado y accesible en el PATH.

### `entorno.bat`
Envuelve a `lee_fichero_ini.bat` para leer y modificar un fichero `.ini` de configuración de entorno. Soporta los parámetros `/C`, `/V`, `/T`, `/D`, `/F`, `/U` y `/E` para seleccionar entorno, funcionalidad y UCO.

### `estado_de_bloq_num.bat`
Usa `klocks.exe` para determinar si la tecla Bloq Mayús está activa. Devuelve el estado como texto y como `%ERRORLEVEL%`.

**Requisito:** `klocks.exe` disponible en el PATH.

### `fecha_y_hora_en_variable.bat`
Extrae año, mes, día, hora, minuto y segundo del sistema en variables individuales usando manipulación de subcadenas sobre `%date%` y `%time%`. No depende de herramientas externas.

### `javadk.bat`
Lista los JDKs presentes en un directorio configurable, permite seleccionar uno de forma interactiva y actualiza `JAVA_HOME` y `PATH` en el entorno de la sesión actual.

### `gitperf.bat`
Gestiona **$home/.gitconfig**.  Busca ficheros .gitconfig.xxx en la carpeta HOME. Cada fichero encontrado es tratado como un perfil y su extensión (xxx) como nombre del perfil.
Sin parámetros numera y muestra los encontrados; con un número selecciona el perfíl de ese número como perfil activo.

### `jira.bat`
Sistema de gestión de tareas basado en el sistema de ficheros. Permite crear, abrir, cerrar y buscar tareas, con apertura automática en Firefox y navegación en Total Commander.

### `lee_fichero_ini.bat`
Subrutina reutilizable que recibe como parámetros la ruta al fichero `.ini`, la sección y la clave, y devuelve el valor en una variable. Maneja comentarios (`;`) y espacios en blanco.

### `miTeclado.bat`
Detecta si alguno de los teclados USB se se tengan configurados está conectado, identificado por su Instance ID.
En función de ello arranca el perfil de teclado que se desee o incluso detener el `PowerToys.KeyboardManagerEngine`.

Consulta [`miTeclado.md`](miTeclado.md) para la documentación completa.

**Requisitos:** Windows 10/11, ejecución como Administrador, PowerToys instalado.

### `procesar_parametros_linea_comandos.bat`
Plantilla comentada para procesar parámetros con nombre (`/flag valor`) y posicionales en scripts Batch, usando `SHIFT` y `ENABLEDELAYEDEXPANSION`.

### `todo.bat`
Gestiona pequeñas notas de recordatorio para hacer. Permite crearlas, añadirles notas, aumentar o bajar su prioridad, completarlas y borrarlas.

### `usar_UTF8_en_consola.bat`
Ejecuta `chcp 65001` y configura `NLS_LANG` para que la consola de Windows muestre correctamente caracteres UTF-8 sin necesidad de cambiar la configuración regional del sistema.

---

## Requisitos generales

- Windows 10 / 11
- Los scripts que llaman a herramientas externas (`7z.exe`, `klocks.exe`, `pnputil`, etc.) requieren que dichas herramientas estén instaladas y en el PATH, o que la ruta esté configurada dentro del propio script.
- Algunos scripts requieren **ejecución como Administrador** (indicado en su descripción).

## Licencia

Uso libre. Sin garantías.
