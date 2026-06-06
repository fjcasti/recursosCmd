@echo off
rem Proceso para lanzar un comando cuando está presente un disposivo.
rem Si el disposivo no está presente, se cierra el proceso si está en ejecución.
REM Verifica los teclados que se deseen. Cada uno puede tener su configuración.
rem si no encuentra ninguno usa la configuración del portatil, que lleva la suya propia.
rem Para añadir otro teclado es necesario crear un perfil en la ruta
rem POWERTOYS_CONF_FOLDER

setlocal enabledelayedexpansion

set "PROCESS_NAME=PowerToys.KeyboardManager"
set "INSTANCE_ID_BLANCO=HID\VID_04D9&PID_A0F8&MI_00\7&2b3d7e1b&0&0000"
set ID_BLANCO=

:: esta es una instancia falsa para pruebas. Aquí irían todos los teclado que quiera conectar. Uno a uno.
set "INSTANCE_ID_XXX=HID\VID_&PID_&MI_\1&2b3c4d5e7f&0&0000"
SET ID_XXX=

set "LAUNCH_CMD=c:\Users\dars\AppData\Local\PowerToys\KeyboardManagerEngine\PowerToys.KeyboardManagerEngine.exe"
set "POWERTOYS_CONF_FOLDER=c:\Users\dars\AppData\Local\Microsoft\PowerToys\Keyboard Manager"


:: Comprobar si PowerToys Keyboard Manager está en ejecución y obtener su PID
set "PID="
for /f "tokens=2" %%a in ('tasklist ^| find /I "%PROCESS_NAME%"') do (
    set "PID=%%a"
)

:: Ejecuta pnputil y busca el ID de instancia
REM pnputil /enum-devices /class keyboard /connected | findstr /C:"%INSTANCE_ID%" >nul

for /f "tokens=2 delims=:" %%a in ('pnputil /enum-devices /class keyboard /connected ^| findstr /C:"%INSTANCE_ID_BLANCO%"') do (
    set "RAW_ID=%%a"
)
if defined RAW_ID set "ID_BLANCO=!RAW_ID: =!"

for /f "tokens=2 delims=:" %%a in ('pnputil /enum-devices /class keyboard /connected ^| findstr /C:"%INSTANCE_ID_XXX%"') do (
    set "RAW_ID=%%a"
)
if defined RAW_ID set "ID_XXX=!RAW_ID: =!"



if defined PID (
    echo [ ] Quitando configuración anterior
    taskkill /PID %PID% /F >nul 2>&1
)

if defined ID_BLANCO (
    echo [ ] Teclado blanco detectado.
    echo [ ] Seleccionando configuración del teclado blanco.
    copy /Y "%POWERTOYS_CONF_FOLDER%\blanco.json" "%POWERTOYS_CONF_FOLDER%\default.json" >nul 2>&1
    
    echo [ ] Configurando PowerToys Keyboard Manager ...
    start "" "%LAUNCH_CMD%"
) ELSE IF defined ID_XXX (
    echo [ ] Teclado xxx detectado.
    echo [ ] Seleccionando configuración del teclado xxx.
    copy /Y "%POWERTOYS_CONF_FOLDER%\xxx.json" "%POWERTOYS_CONF_FOLDER%\default.json" >nul 2>&1
    
    echo [ ] Configurando PowerToys Keyboard Manager ...
    start "" "%LAUNCH_CMD%"

) ELSE (
    echo [ ] Ningún teclado detectado.
    echo [ ] Seleccionando configuración del teclado del portátil.
    copy /Y "%POWERTOYS_CONF_FOLDER%\portail.json" "%POWERTOYS_CONF_FOLDER%\default.json" >nul 2>&1
    
    echo [ ] Configurando PowerToys Keyboard Manager ...
    start "" "%LAUNCH_CMD%"
)


:fin