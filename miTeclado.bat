@echo off
set "INSTANCE_ID=HID\VID_04D9&PID_A0F8&MI_00\7&2b3d7e1b&0&0000"

:: Ejecuta pnputil y busca el ID de instancia
pnputil /enum-devices /class keyboard /connected | findstr /C:"%INSTANCE_ID%" >nul

if %errorlevel% equ 0 (
    echo blanquito conectado
) else (
    echo sin blanquito
)
