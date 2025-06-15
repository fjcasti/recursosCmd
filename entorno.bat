@echo off
set NLS_LANG=AMERICAN_AMERICA.UTF8
chcp 65001 > nul
SETLOCAL ENABLEDELAYEDEXPANSION

rem CONFIGURACION
set DIR=c:\ruta\del\fichero\de\configuración
set INI=%DIR%\config.ini 
SET BAK=%DIR%\config.bak
set TMP=%DIR%\config.tmp 
SET NPP=C:\Desarrollo\Apps\Notepad++\notepad++.exe
SET CONSOLA=1
SET DIALOGO=0
SET NUEVO=VACIO
SET ENTORNO= 
SET FUNCIONALIDAD= 
SET CD_UCO=
SET GRABAR_CAMBIOS=0


FOR /F %%A IN ('leer_fichero_ini.bat %ini% entorno') DO set ENTORNO=%%A
FOR /F %%A IN ('leer_fichero_ini.bat %ini% fun')     DO set FUNCIONALIDAD=%%A
FOR /F %%A IN ('leer_fichero_ini.bat %ini% uco')     DO set CD_UCO=%%A

rem elimina temporales
del /F /Q %TMP% >NUL 2>&1


REM PROCESAMIENTO DE LOS PARÁMETROS.
:bucleParametros
IF "%~1"=="" GOTO :inicio
SET GRABAR_CAMBIOS=1

if /I  "%1"=="/?" GOTO :AYUDA
if /I  "%1"=="/H" GOTO :AYUDA
if /I  "%1"=="/E" GOTO :editarIni
If /I  "%1"=="/V" set CONSOLA=0 & set DIALOGO=1 & shift
If /I  "%1"=="/C" set CONSOLA=1 & shift 
IF /I  "%1"=="/T" set ENTORNO=trunk & shift
IF /I  "%1"=="/D" set ENTORNO=desarrollo & shift
IF /I "%~1"=="/F" (
    set temp=%2
    IF NOT "!temp!"=="" (
        IF NOT "!temp:~0,1!"=="/" (
            SET "FUNCIONALIDAD=%~2"
            SET "FUN_OK=NO"
            FOR %%K IN (1,2,3,4,5) DO (
                IF %%K==!FUNCIONALIDAD! SET "FUN_OK=SI"
            )
            IF !FUN_OK!==NO (
                echo.
                ECHO [ERROR] El valor pasado no es válido. FUNCIONALIDAD 1,2,3,4,5.
                goto :ayuda
            )
            SHIFT
            SHIFT
            GOTO :bucleParametros
        ) ELSE (
            echo.
            echo [ERROR] /F No se indicó ninguna funcionalidad.
            goto ayuda
        )
    ) ELSE (
        echo.
        echo [ERROR] /F No se indicó ninguna funcionalidad.
        goto ayuda
    )
)
IF /I "%~1"=="/U" (
    set temp=%2
    IF NOT "!temp!"=="" (
        IF NOT "!temp:~0,1!"=="/" (
            SET "CD_UCO=%~2"
            SHIFT
            SHIFT
            GOTO :bucleParametros
        ) ELSE (
            echo.
            echo [ERROR] /F No se indicó ninguna UCO.
            goto ayuda
        )
    ) ELSE (
        echo.
        echo [ERROR] /F No se indicó ninguna UCO.
        goto ayuda
    )
)

goto :bucleParametros


:inicio
if !GRABAR_CAMBIOS! EQU 0 GOTO mostar_informacion

FOR /F %%B IN (%INI%) DO (
 	SET LINEA=%%B
    if /i "!linea:~0,8!"=="entorno=" set linea=entorno=%ENTORNO%
    if /i "!linea:~0,4!"=="fun="     set linea=fun=%FUNCIONALIDAD%
    if /i "!linea:~0,4!"=="uco="     set linea=uco=%CD_UCO%
    ECHO !LINEA! >> %TMP%
)
rem 
del /F /Q %BAK%  >NUL 2>&1 
REN  %INI% %BAK%
copy %TMP% %INI% >NUL 2>&1 
del /F /Q %TMP%  >NUL 2>&1 

:mostar_informacion

if %CONSOLA% equ 1 (
	echo [ ] Entorno activo: %ENTORNO%
    echo [ ] UCO:            %CD_UCO%
    ECHO [ ] Funcionalidad:  %FUNCIONALIDAD%
	echo.
)
if %DIALOGO% equ 1 (
    rem Funcionalidad está mal sangrado porque es necesario para poner un retorno de carro al mensaje. 
    rem Los espacios no son espacios, sino no guarda las distancias.
    rem ¡¡¡¡NO TOCAR!!!!
    msg %username% /time:5 Entorno activo:  %ENTORNO%^

UCO:                   %CD_UCO% ^

funcionalidad:   %FUNCIONALIDAD%  
)
goto fin 

:editarIni
    start %NPP% %INI%
    GOTO :fin




:ayuda
echo.
echo Modo de Uso:  ENTORNO [/W] [/C] [/T] [/D] [/F xxx] [/U yyyyy] [/E] [/? ^| /H]
echo.
echo   Configura el fichero  "%INI%"  mostrando o cambiando los valores.
echo   donde:
ECHO          C    Muestra la información por consola.     (Opción por defecto)
echo          V    Muestra la información en un diálogo.
ECHO          T    Establece el entorno en TRUNK.
ECHO          D    Establece el entorno en DESARROLLO.
ECHO          F    Establece la funcionalidad al valor 'xxx'. Solo admite 1,2,3,4 ó 5
ECHO          U    Establece la UCO al valor 'yyyyy'.
echo          E    Abre en el Notepad++ el fichero %INI%.
ECHO          ?^|H  Muestra este diálogo de ayuda.
echo.

:fin




