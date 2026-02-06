@echo off
setlocal EnableDelayedExpansion
set NLS_LANG=AMERICAN_AMERICA.UTF8
chcp 65001 > nul

REM ===========================================================================
REM CONFIGURACION
REM ===========================================================================
set "RUTA_JAVADK=c:\Users\dars\.jdks"
REM ===========================================================================

echo.
echo Listando JDK en: %RUTA_JAVADK%
echo ---------------------------------------------------------------------------

if not exist "%RUTA_JAVADK%" (
    echo [ERROR] La ruta configurada no existe: %RUTA_JAVADK%
    goto :fin
)

set "SELECCION=%1"
set CONTADOR=0

for /d %%D in ("%RUTA_JAVADK%\*") do (
    if exist "%%D\release" if exist "%%D\bin\java.exe" if exist "%%D\bin\javac.exe" (
        set "RELEASE_FILE=%%D\release"
        set "IV="
        set "IM="
        set "JV="
        
        for /f "usebackq tokens=1,2 delims==" %%i in ("!RELEASE_FILE!") do (
            set "k=%%i"
            set "v=%%~j"
            set "k=!k: =!"
            set "k=!k:"=!"
            
            if /i "!k!"=="IMPLEMENTOR_VERSION" set "IV=!v!"
            if /i "!k!"=="IMPLEMENTOR"         set "IM=!v!"
            if /i "!k!"=="JAVA_VERSION"        set "JV=!v!"
        )
        
        if not "!JV!"=="" (
            set /a CONTADOR+=1
            set "JDK_PATH_!CONTADOR!=%%D"
            
            if "%SELECCION%"=="" (
                set "MARCA= "
                set "DIR_ACTUAL=%%D"
                set "JH_COMP=!JAVA_HOME!"
                if "!JH_COMP:~-1!"=="\" set "JH_COMP=!JH_COMP:~0,-1!"
                if "!DIR_ACTUAL:~-1!"=="\" set "DIR_ACTUAL=!DIR_ACTUAL:~0,-1!"
                if /I "!DIR_ACTUAL!"=="!JH_COMP!" set "MARCA=*"
                
                if not "!IV!"=="" (
                    echo [!CONTADOR!]!MARCA!!IV!
                ) else (
                    if not "!IM!"=="" (
                        echo [!CONTADOR!]!MARCA!!IM! - !JV!
                    ) else (
                        echo [!CONTADOR!]!MARCA!!JV!
                    )
                )
            )
        )
    )
)

if "%SELECCION%"=="" (
    if !CONTADOR!==0 (
        echo [I] No se encontraron JDK en la ruta especificada.
    ) else (
        echo.
        echo Total: !CONTADOR! JDK encontradas.
    )
    goto :fin
)

rem --- Proceso de selección ---
set "NUEVO_HOME=!JDK_PATH_%SELECCION%!"

if "!NUEVO_HOME!"=="" (
    echo [ERROR] La opción "%SELECCION%" no es válida.
    goto :fin
)

echo [I] Configurando JAVA_HOME=!NUEVO_HOME!

REM --- Limpiar PATH de antiguos JDKs ---
echo [I] Limpiando PATH de todo rastro en %RUTA_JAVADK%...

set "NEW_PATH_ACC="
REM Obtener longitud del prefijo para comparar
set "PREFIX=%RUTA_JAVADK%"
if "!PREFIX:~-1!"=="\" set "PREFIX=!PREFIX:~0,-1!"
set "temp_p=!PREFIX!"
set "LEN=0"
:count_len
if defined temp_p (set "temp_p=!temp_p:~1!" & set /a LEN+=1 & goto :count_len)

REM Reconstruir el PATH elemento a elemento
for %%A in ("%PATH:;=" "%") do (
    set "EL=%%~A"
    if not "!EL!"=="" (
        set "KEEP=Y"
        set "EL_NORM=!EL!"
        if "!EL_NORM:~-1!"=="\" set "EL_NORM=!EL_NORM:~0,-1!"

        REM Comprobar si EL empieza por el prefijo RUTA_JAVADK
        set "START=!EL_NORM:~0,%LEN%!"
        if /I "!START!"=="!PREFIX!" set "KEEP=N"
        
        if "!KEEP!"=="Y" (
            if "!NEW_PATH_ACC!"=="" (
                set "NEW_PATH_ACC=!EL!"
            ) else (
                set "NEW_PATH_ACC=!NEW_PATH_ACC!;!EL!"
            )
        )
    )
)

echo [I] Estableciendo nueva JDK en el PATH...
set "NUEVO_PATH=!NUEVO_HOME!\bin;!NEW_PATH_ACC!"

REM Exportar las variables al entorno del padre antes de salir
endlocal & set "JAVA_HOME=%NUEVO_HOME%" & set "PATH=%NUEVO_PATH%"
goto :eof

:fin
endlocal
echo.
