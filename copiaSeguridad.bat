@echo off
chcp 65001 > nul
SET NLS_LANG=AMERICAN_AMERICA.UTF8 
setlocal ENABLEEXTENSIONS
setlocal ENABLEDELAYEDEXPANSION 


rem [x] sin parámetros mostar la ayuda NO. hace una copia y punto.
rem [x] emitir un pequeño mensaje y hablar del parámetro de ayuda
rem [x] añadir /h y /? como parámetros para mostar la ayuda.
REM [x] parámetro para funcionar en modo silencioso.
rem [x] opción que muestre la configuración
rem [x] que hacer si se seleccionan mostar configuración y modo silencioso
rem [x] si no existe el fichero copiaSeguridad.bat y no se proporciona como parámetro  mostar error / ayuda
rem [x] verificar la configuración para comprobar el correcto funcionamiento.
rem [ ] añadir parámetro con un fichero de datos diferente al de por defecto.
rem [ ] añadir parámetro con una ubicación destino diferente
rem [ ] añadir parámetro para cambiar el nombre de la copia de seguridad.
rem [ ] Copiar el fichero de datos de outlook
rem [ ] Duplicar la copia en una segunda ubicación.


set VERSION=0.1
set ahora=%date:~6,4%%date:~3,2%%date:~0,2%%time:~0,2%%time:~3,2%%time:~6,2%
set ahora=%ahora: =0%
rem aquí se hace la compresión
set RUTACOPIA=.\
set FICHCOPIA=copiaSeguridad%ahora%.7z
SET FICHERO_DATOS=copiaSeguridad.dat
rem empaquetador. Este guión usa 7z.exe
set COMPRESOR=c:\Program Files\7-Zip\7z.exe
SET VERCONFIGURACION=FALSE
SET SILENCIOSO=FALSE
set TODO_BIEN=TRUE
set outlook=NO


rem vericar los parámetros pasados
rem bucle parametros
:bucleParametros
IF "%~1"=="" GOTO :inicio

IF /I "%~1"=="/config" (
    set VERCONFIGURACION=TRUE
    SHIFT 
    GOTO :bucleParametros
)
IF /I "%~1"=="/S" (
    set SILENCIOSO=TRUE
    set VERCONFIGURACION=FALSE
    SHIFT 
    GOTO :bucleParametros
)
IF /I "%~1"=="/H"  GOTO :AYUDA
IF /I "%~1"=="/?"  GOTO :AYUDA



goto :bucleParametros

:inicio
    IF %SILENCIOSO% == FALSE (
        echo.
        call :muestra_nombre
        echo     Realizando copia.  /h o /^? muestra opciones disponibles.
    )

if %VERCONFIGURACION%==FALSE GOTO :hacerCopia
    echo [ ] Configuración:
    echo [ ]     Compresor:           %COMPRESOR%d
    ECHO [ ]     Fichero de datos:    %FICHERO_DATOS%
    echo [ ]     Copia de seguridad:  %RUTACOPIA%%FICHCOPIA%

:hacerCopia

IF %SILENCIOSO% == FALSE (
    if %VERCONFIGURACION%==FALSE (
        ECHO [ ] Fichero de datos:    %FICHERO_DATOS%
        echo [ ] Copia de seguridad:  %RUTACOPIA%%FICHCOPIA%
    )
)

REM verificando configuración

IF NOT EXIST "%COMPRESOR%" (
    ECHO [E] No encuentro el compresor: %COMPRESOR%
    SET TODO_BIEN=FALSE
)
if NOT exist "%FICHERO_DATOS%" (
    echo [E] No encuentro fichero de datos: %FICHERO_DATOS%. 
    SET TODO_BIEN=FALSE
)
IF NOT EXIST "%RUTACOPIA%" (
    echo [E] No encuentro la ruta destino: %RUTACOPIA%
    set TODO_BIEN=FALSE
)
IF %TODO_BIEN% == FALSE SET SILENCIOSO=FALSE & GOTO :salir


REM tasklist | find "OUTLOOK.EXE" > nul
REM if %errorlevel% == 0  ( 
REM 	ECHO [D] OUTLOOK encontrado, matando proceso
REM 	set outlook=SI
REM 	taskkill /F /IM OUTLOOK.EXE > NUL
REM 	WAITFOR /T 1 CASTICOPIASEGURIDAD 2> NUL 
REM )
IF %SILENCIOSO% == FALSE echo [=] Procesando datos:
for /F "tokens=* EOL=#" %%X in (%FICHERO_DATOS%) do (
	set elto=%%X
    IF %SILENCIOSO% == FALSE echo [-]     !elto!
    "%COMPRESOR%" a -r -bso0 -bsp0 "%RUTACOPIA%%FICHCOPIA%" !elto!

REM 	if exist !elto! (
rem 	set ATRIB=%%~aX
rem		ECHO atrib !ATRIB!
rem		SET TIPO=!ATRIB:~0,1!
rem		IF NOT !TIPO!==d SET TIPO=!ATRIB:~2,1!
rem 		ECHO TIPO: !TIPO!
REM	)
)

REM ECHO [D] Duplicando la copia
REM xcopy /Q /R %DIR1%\* %DIR2%\*
REM 
REM if %outlook% == SI (
REM "c:\Users\fdello3\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Outlook 2016.lnk" 
REM )

goto :salir
:muestra_nombre
    echo CopiaSeguridad. v%VERSION%. 
    goto :EOF

:ayuda
    CALL :muestra_nombre
    echo  lee una lista de ficheros y/o carpetas los comprime y copia.
    echo  Modo de Uso:
    echo     CopiaSeguridad  [/config] [/h ^| /^?] [/s]
    echo             /config        muestra la configuración de la aplicación. 
    echo                            No aplica con la opción /s
    echo             /h ^| /^?        muestra la ayuda y termina.
    echo                            No aplican más opciones.
    echo             /s             modo silencioso. Suprime la emisión de mensajes.
    goto :fin
    
:salir
IF %SILENCIOSO% == FALSE (
    echo [ ] Terminado.
    echo.
)

:fin