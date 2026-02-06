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
echo Listando los directorios en: %RUTA_JAVADK%
echo ---------------------------------------------------------------------------

if not exist "%RUTA_JAVADK%" (
    echo [ERROR] La ruta configurada no existe: %RUTA_JAVADK%
    goto :fin
)

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
            rem Limpiar la clave de espacios y comillas para la comparación
            set "k=!k: =!"
            set "k=!k:"=!"
            
            if /i "!k!"=="IMPLEMENTOR_VERSION" set "IV=!v!"
            if /i "!k!"=="IMPLEMENTOR"         set "IM=!v!"
            if /i "!k!"=="JAVA_VERSION"        set "JV=!v!"
        )
        
        rem Solo listamos e incrementamos si se encontró la clave obligatoria JAVA_VERSION
        if not "!JV!"=="" (
            set /a CONTADOR+=1
            if not "!IV!"=="" (
                echo [ ] !IV!
            ) else (
                if not "!IM!"=="" (
                    echo [ ] !IM! - !JV!
                ) else (
                    echo [ ] !JV!
                )
            )
        )
    )
)

if !CONTADOR!==0 (
    echo [I] No se encontraron JDK en la ruta especificada.
) else (
    echo.
    echo Total: !CONTADOR! JDK encontradas.
)

:fin
echo.
