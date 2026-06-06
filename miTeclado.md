# miTeclado.bat

Script de Windows Batch que selecciona y aplica la configuración de PowerToys Keyboard Manager según el teclado externo que esté conectado en ese momento.

## Propósito

Detectar qué teclado externo está enchufado, copiar el perfil JSON correspondiente como `default.json` y (re)arrancar `PowerToys.KeyboardManagerEngine` con esa configuración. Si no hay ningún teclado externo, aplica la configuración del portátil. Pensado para ejecutarse al conectar/desconectar un dispositivo USB mediante el Programador de tareas de Windows.

## Configuración

| Variable | Descripción |
|---|---|
| `PROCESS_NAME` | Nombre del proceso a buscar en `tasklist` |
| `INSTANCE_ID_<NOMBRE>` | Instance ID del dispositivo en el Administrador de dispositivos de Windows |
| `LAUNCH_CMD` | Ruta completa al ejecutable `PowerToys.KeyboardManagerEngine.exe` |
| `POWERTOYS_CONF_FOLDER` | Carpeta donde PowerToys almacena los perfiles de teclado |

## Perfiles de configuración

Cada teclado tiene su propio fichero `.json` en `POWERTOYS_CONF_FOLDER`. El script copia el fichero correspondiente sobre `default.json` antes de arrancar el proceso.

| Teclado | Variable de detección | Fichero de perfil |
|---|---|---|
| Teclado blanco | `INSTANCE_ID_BLANCO` | `blanco.json` |
| *(ejemplo/plantilla)* | `INSTANCE_ID_XXX` | `xxx.json` |
| Portátil (sin teclado externo) | — | `portail.json` |

## Lógica

```
┌──────────────────────────────────────────────┐
│ ¿Está el proceso en ejecución? (tasklist)    │
│           → guarda PID en %PID%              │
└─────────────────────┬────────────────────────┘
                      │
┌─────────────────────▼────────────────────────┐
│ Detecta teclados conectados (pnputil)        │
│ Evalúa INSTANCE_ID_* uno a uno               │
└────────┬──────────────────────┬──────────────┘
         │ Teclado externo       │ Ninguno
   ┌─────▼──────────┐      ┌────▼───────────────┐
   │ Mata proceso   │      │ Mata proceso       │
   │ (si PID)       │      │ (si PID)           │
   │ Copia <name>   │      │ Copia portail.json │
   │ .json →        │      │ → default.json     │
   │ default.json   │      │ Arranca PowerToys  │
   │ Arranca        │      └────────────────────┘
   │ PowerToys      │
   └────────────────┘
```

### Paso 1 — Detección del proceso

```bat
for /f "tokens=2" %%a in ('tasklist ^| find /I "%PROCESS_NAME%"') do set "PID=%%a"
```

Filtra `tasklist` buscando el proceso. El token 2 de cada línea es el PID. Si no existe, `%PID%` queda sin definir.

### Paso 2 — Detección de teclados

```bat
for /f "tokens=2 delims=:" %%a in ('pnputil /enum-devices /class keyboard /connected ^| findstr /C:"%INSTANCE_ID_BLANCO%"') do set "RAW_ID=%%a"
if defined RAW_ID set "ID_BLANCO=!RAW_ID: =!"
```

Enumera los teclados HID conectados y busca el Instance ID configurado. Si lo encuentra, almacena el ID limpio (sin espacios) en la variable correspondiente.

### Paso 3 — Selección de perfil y arranque

1. Si hay un proceso corriendo, se mata con `taskkill /PID %PID% /F`.
2. Se evalúa en orden qué teclado externo está presente (`IF defined ID_BLANCO`, `ELSE IF defined ID_XXX`, …).
3. Se copia el `.json` correspondiente sobre `default.json`.
4. Se arranca `PowerToys.KeyboardManagerEngine.exe`.
5. Si no hay ningún teclado externo, se aplica el perfil del portátil (`portail.json`).

## Cómo añadir un nuevo teclado

1. Obtener el Instance ID (ver sección siguiente).
2. Declarar las variables al inicio del script:
   ```bat
   set "INSTANCE_ID_NUEVO=HID\VID_XXXX&PID_XXXX&MI_00\..."
   SET ID_NUEVO=
   ```
3. Añadir el bloque de detección:
   ```bat
   for /f "tokens=2 delims=:" %%a in ('pnputil /enum-devices /class keyboard /connected ^| findstr /C:"%INSTANCE_ID_NUEVO%"') do (
       set "RAW_ID=%%a"
   )
   if defined RAW_ID set "ID_NUEVO=!RAW_ID: =!"
   ```
4. Crear el fichero `nuevo.json` en `POWERTOYS_CONF_FOLDER`.
5. Insertar un bloque `ELSE IF` en la sección de selección:
   ```bat
   ELSE IF defined ID_NUEVO (
       echo [ ] Teclado nuevo detectado.
       copy /Y "%POWERTOYS_CONF_FOLDER%\nuevo.json" "%POWERTOYS_CONF_FOLDER%\default.json" >nul 2>&1
       start "" "%LAUNCH_CMD%"
   )
   ```

## Requisitos

| Requisito | Detalle |
|---|---|
| **Sistema operativo** | Windows 10 / 11 (`pnputil`, `tasklist`, `taskkill` son nativos) |
| **Privilegios** | El script debe ejecutarse **como Administrador**. `pnputil /enum-devices /connected` requiere elevación; sin ella ningún teclado se detecta como presente |
| **PowerToys instalado** | Debe existir el ejecutable indicado en `LAUNCH_CMD`. La ruta por defecto asume instalación de usuario en `%LOCALAPPDATA%\PowerToys` |
| **Perfiles JSON creados** | Debe existir un `.json` en `POWERTOYS_CONF_FOLDER` por cada teclado definido, incluido `portail.json` para el portátil |
| **Instance IDs correctos** | Cada `INSTANCE_ID_*` debe coincidir exactamente con el identificador que Windows asigna al teclado |
| **Teclado HID** | El dispositivo debe enumerarse bajo la clase `keyboard`. Teclados con drivers propietarios pueden aparecer en otra clase y no ser detectados |

## Cómo obtener el Instance ID de tu teclado

1. Abre el **Administrador de dispositivos**.
2. Despliega **Teclados** y haz doble clic en el dispositivo.
3. Pestaña **Detalles** → Propiedad **Id. de instancia del dispositivo**.
4. Copia el valor y úsalo en la variable `INSTANCE_ID_<NOMBRE>`.

Alternativamente, desde PowerShell (como Administrador):

```powershell
pnputil /enum-devices /class keyboard /connected
```

## Uso recomendado — Programador de tareas

Crear una tarea que se dispare al **conectar o desconectar un dispositivo USB** (evento `DeviceArrival` / `DeviceRemoveComplete`) y ejecute este script. Así la configuración cambia automáticamente en cuanto se enchufa o desenchufa un teclado, sin necesidad de un bucle de sondeo.
