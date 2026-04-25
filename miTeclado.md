# miTeclado.bat

Script de Windows Batch que gestiona el proceso `PowerToys.KeyboardManagerEngine` en función de si un teclado concreto está conectado o no.

## Propósito

Arrancar o detener el motor de remapeo de teclas de PowerToys según la presencia física de un teclado USB específico. Pensado para ejecutarse periódicamente (p. ej. con el Programador de tareas de Windows).

## Configuración

| Variable | Valor por defecto | Descripción |
|---|---|---|
| `PROCESS_NAME` | `PowerToys.KeyboardManager` | Nombre del proceso a buscar en `tasklist` |
| `INSTANCE_ID` | `HID\VID_04D9&PID_A0F8&MI_00\7&2b3d7e1b&0&0000` | Instance ID del dispositivo en el gestor de dispositivos de Windows |
| `LAUNCH_CMD` | `…\PowerToys.KeyboardManagerEngine.exe` | Ruta completa al ejecutable que se lanza si el teclado está presente |

Para adaptar el script a otro teclado o proceso, basta con cambiar estas tres variables.

## Lógica

```
┌─────────────────────────────────────────────┐
│ ¿Está el proceso en ejecución? (tasklist)   │
│          → guarda PID en %PID%              │
└────────────────────┬────────────────────────┘
                     │
┌────────────────────▼────────────────────────┐
│ ¿Está el teclado conectado? (pnputil)       │
└──────┬──────────────────────┬───────────────┘
       │ SÍ                   │ NO
  ┌────▼────┐            ┌────▼────┐
  │ PID?    │            │ PID?    │
  └──┬───┬──┘            └──┬───┬──┘
  NO │   │ SÍ            SÍ │   │ NO
     │   │                  │   │
 Arranca └No hace nada   Mata   └No hace nada
 proceso                 proceso
```

### Paso 1 — Detección del proceso

```bat
for /f "tokens=2" %%a in ('tasklist ^| find /I "%PROCESS_NAME%"') do set "PID=%%a"
```

Filtra la salida de `tasklist` buscando el nombre del proceso (sin distinción de mayúsculas). El token 2 de cada línea es el PID. Si el proceso no existe, `%PID%` queda sin definir.

### Paso 2 — Detección del teclado

```bat
pnputil /enum-devices /class keyboard /connected | findstr /C:"%INSTANCE_ID%" >nul
```

Enumera solo los teclados HID conectados en este momento y busca el Instance ID configurado. El resultado se descarta; lo que importa es el `%errorlevel%`:

- `0` → teclado presente
- distinto de `0` → teclado ausente

### Paso 3 — Acción

| Teclado | Proceso | Acción |
|---|---|---|
| Presente | No corre | `start "" "<LAUNCH_CMD>"` — arranca el proceso |
| Presente | Corriendo | No hace nada |
| Ausente  | Corriendo | `taskkill /PID %PID% /F` — mata el proceso |
| Ausente  | No corre  | No hace nada |

## Requisitos

| Requisito | Detalle |
|---|---|
| **Sistema operativo** | Windows 10 / 11 (los comandos `pnputil`, `tasklist`, `taskkill` y `findstr` son nativos de Windows) |
| **Privilegios** | El script debe ejecutarse **como Administrador**. `pnputil /enum-devices /connected` requiere elevación; sin ella devuelve error y el teclado nunca se detecta como presente |
| **PowerToys instalado** | Debe existir el ejecutable indicado en `LAUNCH_CMD`. La ruta por defecto asume una instalación de usuario estándar en `%LOCALAPPDATA%\PowerToys` |
| **Instance ID correcto** | La variable `INSTANCE_ID` debe coincidir exactamente con el identificador que Windows asigna al teclado (ver sección siguiente) |
| **Teclado HID** | El dispositivo debe enumerarse bajo la clase `keyboard` en el gestor de dispositivos. Teclados con drivers propietarios pueden aparecer en otra clase y no ser detectados |

## Cómo obtener el Instance ID de tu teclado

1. Abre el **Administrador de dispositivos**.
2. Despliega **Teclados** y haz doble clic en el dispositivo.
3. Pestaña **Detalles** → Propiedad **Id. de instancia del dispositivo**.
4. Copia el valor y pégalo en `INSTANCE_ID`.

Alternativamente, desde PowerShell:

```powershell
pnputil /enum-devices /class keyboard /connected
```

## Uso recomendado — Programador de tareas

Crear una tarea que se dispare al **conectar o desconectar un dispositivo USB** (evento `DeviceArrival` / `DeviceRemoveComplete`) y ejecute este script. Así el proceso arranca en cuanto se conecta el teclado y se mata en cuanto se desconecta, sin necesidad de un bucle de sondeo.
