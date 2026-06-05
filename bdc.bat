@echo off
set NLS_LANG=AMERICAN_AMERICA.UTF8
chcp 65001 > nul
setlocal enabledelayedexpansion

set "DATAFILE=%~dp0bdc.dat"
set "NPP=c:\Users\dars\bin\Npp\notepad++.exe"

if /i "%~1"=="/?" goto :show_help
if /i "%~1"=="/e" goto :edit_file
if /i "%~1"=="/b" goto :search_text
if "%~1"==""      goto :show_help
goto :add_text

:: ============================================================
:show_help
echo.
echo  BDC.BAT 1.0 - Base de Conocimiento
echo.
echo  Uso: BDC [opcion] [texto]
echo.
echo( /?                 Muestra esta ayuda
echo  /e                 Abre el fichero de datos en Notepad++
echo  /b XXX             Busca el texto XXX en el fichero de datos
echo  XXX                Añade el texto XXX al fichero de datos
echo.
goto :end

:: ============================================================
:edit_file
if not exist "%DATAFILE%" type nul > "%DATAFILE%"
if not exist "%NPP%" (
    echo Error: No se encuentra el editor configurado.
    echo        %NPP%
    goto :end
)
start "" "%NPP%" "%DATAFILE%"
goto :end

:: ============================================================
:search_text
if "%~2"=="" (
    echo Error: Especifique el texto a buscar.
    echo Uso: BDC /b ^<texto^>
    goto :end
)
set "_search=%~2"
:_loop_search
shift /2
if "%~2"=="" goto :_do_search
set "_search=!_search! %~2"
goto :_loop_search

:_do_search
if not exist "%DATAFILE%" (
    echo No hay datos. El fichero %DATAFILE% no existe aun.
    goto :end
)
echo.
findstr /i /n "!_search!" "%DATAFILE%"
if errorlevel 1 echo No se encontraron coincidencias para: !_search!
echo.
goto :end

:: ============================================================
:add_text
set "_text=%~1"
:_loop_add
shift /1
if "%~1"=="" goto :_do_add
set "_text=!_text! %~1"
goto :_loop_add

:_do_add
echo !_text!>> "%DATAFILE%"
echo Añadido: !_text!
goto :end

:: ============================================================
:end
endlocal
