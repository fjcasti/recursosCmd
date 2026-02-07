@echo off
rem Proceso para lanzar un comando cuando está presente un disposivo.
rem Si el disposivo no está presente, se cierra el proceso si está en ejecución.

set "PROCESS_NAME=PowerToys.KeyboardManager"
set "INSTANCE_ID=HID\VID_04D9&PID_A0F8&MI_00\7&2b3d7e1b&0&0000"
set "LAUNCH_CMD=c:\Users\dars\AppData\Local\PowerToys\KeyboardManagerEngine\PowerToys.KeyboardManagerEngine.exe"

:: Comprobar si PowerToys Keyboard Manager está en ejecución y obtener su PID
set "PID="
for /f "tokens=2" %%a in ('tasklist ^| find /I "%PROCESS_NAME%"') do (
    set "PID=%%a"
)


:: Ejecuta pnputil y busca el ID de instancia
pnputil /enum-devices /class keyboard /connected | findstr /C:"%INSTANCE_ID%" >nul

if %errorlevel% equ 0 (
    if not defined PID (
        echo [*] Lanzando PowerToys Keyboard Manager...
        start "" "%LAUNCH_CMD%"
    ) else (
        echo [ ] Teclado presente, proceso corriendo. Nada que hacer
    )
) else (
    if defined PID (
        echo [*] Matando PowerToys Keyboard Manager PID: %PID%
        taskkill /PID %PID% /F >nul 2>&1
    ) else (
        echo [ ] Teclado no presente y proceso no corriendo. Nada que hacer
    )
)
