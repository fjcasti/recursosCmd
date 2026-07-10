@echo off
rem Proceso para lanzar un comando cuando está presente un disposivo.
rem Si el disposivo no está presente, se cierra el proceso si está en ejecución.
REM Verifica los teclados que se deseen. Cada uno puede tener su configuración.
rem si no encuentra ninguno usa la configuración del portatil, que lleva la suya propia.
rem Para añadir otro teclado es necesario crear un perfil en la ruta
rem POWERTOYS_CONF_FOLDER
rem Para seleccionar los ID de instancia no coger todo la cadena, la parte final puede variar, 
rem basta seleccionar hasta PID_. Fíjate en la cadena del teclado blanco  INSTANCE_ID_BLANCO
rem ==========================================
rem el INSTANCE_ID del teclado integrado de mi portatil es: HID\VID_088D&PID_052F este se 
rem se encontrará siempre. Si se quiere no mapear ninguna tecla para un teclado concreto
rem hay que buscar su id y asignarle el perfil "nada.json"
rem ==========================================

setlocal enabledelayedexpansion

rem teclado blanco
set "PROCESS_NAME=PowerToys.KeyboardManager"
set "INSTANCE_ID_BLANCO=HID\VID_04D9&PID_A0F8"
set ID_BLANCO=

rem teclado mars
set "PROCESS_NAME=PowerToys.KeyboardManager"
set "INSTANCE_ID_MARS=HID\VID_258A&PID_002A"
set ID_MARS=

 
REM Esta es una instancia falsa para prueba. Aquí irían todos los teclado que se quieran conectar.
REM set "INSTANCE_ID_XXX=HID\VID_XXXX&PID_XXXX"
REM SET ID_XXX=

set "LAUNCH_CMD=c:\Users\dars\AppData\Local\PowerToys\KeyboardManagerEngine\PowerToys.KeyboardManagerEngine.exe"
set "POWERTOYS_CONF_FOLDER=c:\Users\dars\AppData\Local\Microsoft\PowerToys\Keyboard Manager"


:: Comprobar si PowerToys Keyboard Manager está en ejecución y obtener su PID
set "PID="
for /f "tokens=2" %%a in ('tasklist ^| find /I "%PROCESS_NAME%"') do (
    set "PID=%%a"
)
if defined PID (
    echo [ ] Quitando configuración anterior
    taskkill /PID %PID% /F >nul 2>&1
)


:: Ejecuta pnputil y busca el ID de instancia
REM pnputil /enum-devices /class keyboard /connected | findstr /C:"%INSTANCE_ID%" >nul

for /f "tokens=2 delims=:" %%a in ('pnputil /enum-devices /class keyboard /connected ^| findstr /C:"%INSTANCE_ID_BLANCO%"') do (
    set "RAW_ID=%%a"
)
if defined RAW_ID set "ID_BLANCO=!RAW_ID: =!"

for /f "tokens=2 delims=:" %%a in ('pnputil /enum-devices /class keyboard /connected ^| findstr /C:"%INSTANCE_ID_MARS%"') do (
    set "RAW_ID=%%a"
)
if defined RAW_ID set "ID_MARS=!RAW_ID: =!"


REM for /f "tokens=2 delims=:" %%a in ('pnputil /enum-devices /class keyboard /connected ^| findstr /C:"%INSTANCE_ID_XXX%"') do (
REM     set "RAW_ID=%%a"
REM )
REM if defined RAW_ID set "ID_XXX=!RAW_ID: =!"





if defined ID_BLANCO (
    echo [ ] Teclado blanco detectado.
    echo [ ] Seleccionando configuración del teclado blanco.
    copy /Y "%POWERTOYS_CONF_FOLDER%\blanco.json" "%POWERTOYS_CONF_FOLDER%\default.json" >nul 2>&1
    
    echo [ ] Configurando PowerToys Keyboard Manager ...
    start "" "%LAUNCH_CMD%"
) ELSE IF defined ID_MARS (
    echo [ ] Teclado MARS detectado.
    echo [ ] Seleccionando configuración del teclado xxx.
    copy /Y "%POWERTOYS_CONF_FOLDER%\nada.json" "%POWERTOYS_CONF_FOLDER%\default.json" >nul 2>&1
    
    echo [ ] Configurando PowerToys Keyboard Manager ...
    start "" "%LAUNCH_CMD%"

) ELSE (
    echo [ ] Ningún teclado detectado.
    echo [ ] Seleccionando configuración del teclado del portátil.
    copy /Y "%POWERTOYS_CONF_FOLDER%\portatil.json" "%POWERTOYS_CONF_FOLDER%\default.json" >nul 2>&1
    
    echo [ ] Configurando PowerToys Keyboard Manager ...
    start "" "%LAUNCH_CMD%"
)


:fin