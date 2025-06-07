@echo off
chcp 65001 > nul
SET NLS_LANG=AMERICAN_AMERICA.UTF8 
setlocal ENABLEEXTENSIONS
setlocal ENABLEDELAYEDEXPANSION 
echo.

rem sin parámetros mostar la ayuda NO. hace una copia y punto.
rem emitir un pequeño mensaje y hablar del parámetro de ayuda
rem añadir /h y /? como parámetros para mostar la ayuda.
REM parámetro para funcionar en modo silencioso.
rem si no existe el fichero copiaSeguridad.bat y no se proporciona como parámetro  mostar error / ayuda
rem opción que muestre la configuración
rem comprobar si un dato dado es fichero o directorio

set VERSION=0.1
set ahora=%date:~6,4%%date:~3,2%%date:~0,2%%time:~0,2%%time:~3,2%%time:~6,2%
set ahora=%ahora: =0%
rem aquí se hace la compresión
set RUTACOPIA=.\
set FICHCOPIA=copiaSeguridad%ahora%.7z
set outlook=NO
rem empaquetador. Este guión usa 7z.exe
set COMPRESOR=c:\Program Files\7-Zip\7z.exe
set FICHERO_DATOS=
SET VERCONFIGURACION=FALSE


if exist copiaSeguridad.dat SET FICHERO_DATOS=copiaSeguridad.dat


rem vericar los parámetros pasados
rem bucle parametros
:bucleParametros
IF "%~1"=="" GOTO :inicio

IF /I "%~1"=="/config" (
    set VERCONFIGURACION=TRUE
    SHIFT 
    GOTO :bucleParametros
)
IF /I "%~1"=="/H"  GOTO :AYUDA
IF /I "%~1"=="/?"  GOTO :AYUDA


goto :bucleParametros




:inicio

if %VERCONFIGURACION%==FALSE GOTO :hacerCopia
    echo [ ] Mostrar configuración

:hacerCopia


echo [ ] Leyendo  "%FICHERO_DATOS%"
ECHO [ ] Creando una copia: %RUTACOPIA%%FICHCOPIA%


REM tasklist | find "OUTLOOK.EXE" > nul
REM if %errorlevel% == 0  ( 
REM 	ECHO [D] OUTLOOK encontrado, matando proceso
REM 	set outlook=SI
REM 	taskkill /F /IM OUTLOOK.EXE > NUL
REM 	WAITFOR /T 1 CASTICOPIASEGURIDAD 2> NUL 
REM )

for /F "tokens=* EOL=#" %%X in (copiaSeguridad.dat) do (
	set elto=%%X
    echo [=] Elto: !elto!
rem     "%COMPRESOR%" a -r -bso0 -bsp0 "%RUTACOPIA%%FICHCOPIA%" !elto!

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

:ayuda
    echo  CopiaSeguridad. v%VERSION%. 
    echo  lee una lista de ficheros y/o carpetas los comprime y copia.
    echo  Modo de Uso:
    echo     CopiaSeguridad  [/config] [/h ^| /^?]
    echo             /config        muestra la configuración de la aplicación.
    echo             /h ^| /^?        muestra la ayuda y termina.
    goto :fin
    
:salir
echo [ ] Terminado.
echo.

:fin