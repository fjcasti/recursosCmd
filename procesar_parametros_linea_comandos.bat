@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
chcp 65001 > nul
SET NLS_LANG=AMERICAN_AMERICA.UTF8 

REM Guion de ejemplo para procesar parámetros
REM Opciones y valores deben ir seguidos (ej. /opcion valor)
REM El orden de los pares opcion-valor no importa.


REM Guardar los parametros originales para mostrarlos, ya que SHIFT los modifica
SET "ORIGINAL_PARAMS=%*"

IF "%1"=="" goto ayuda


REM Inicializar variables para las opciones
SET "Archivo="
SET "ValorOpcional="
SET "ParametrosPosicionales="
SET "count_posicional=0"


REM --------------- PROCESAMIENTO DE PARAMETROS CON NOMBRE (ind ependiente de posicion) ---------------
:ParseParamsLoop
REM Comprobar si quedan parametros para procesar
IF "%~1"=="" GOTO EndParseParams

IF /I "%~1"=="/f" (

    IF NOT "%~2"=="" (
        IF NOT "%~2:~0,1%"=="/" (
            SET "Archivo=%~2"
            SHIFT
            SHIFT
            GOTO ParseParamsLoop
        ) ELSE (
            echo [^^!] No se proporcionó dato para /f
            echo.
            goto ayuda
            rem esto es por si quieres seguir procesando el resto de parámetros. Quitar lo anterior
            echo [Parse] ADVERTENCIA: Opcion /f seguida por otra opcion ^(%2^) en lugar de un valor. /f no tendra valor.
            SHIFT
            GOTO ParseParamsLoop
        )
    ) ELSE (
        echo [^^!] No se proporcionó dato para /f
        echo.
        goto ayuda
        rem esto es por si quieres seguir procesando el resto de parámetros. Quitar lo anterior
        echo [Parse] ADVERTENCIA: Opcion /f al final de los parametros, sin valor.
        SHIFT
        GOTO ParseParamsLoop
    )
)
echo aquí
REM La opción puede ser de mas de una letra
IF /I "%~1"=="/opcional" (
    IF NOT "%~2"=="" (
        IF NOT "%~2:~0,1%"=="/" (
            SET "ValorOpcional=%~2"
            SHIFT
            SHIFT
            GOTO ParseParamsLoop
        ) ELSE (
            echo [^^!] No se proporcionó dato para /opcional
            echo.
            goto ayuda
        )
    ) ELSE (
        echo [^^!] No se proporcionó dato para /opcional
        echo.
        goto ayuda
    )
)

REM El parámetro no es una opción. Se procesa normalmente.

SET /A count_posicional+=1
SET "ParamPosicional_!count_posicional!=%~1"
SHIFT
GOTO ParseParamsLoop

:EndParseParams

echo.
echo [ ] Resumen de opciones y parámetros 
IF DEFINED Archivo (
    echo [ ] Archivo especificado ^(/f^): %Archivo%
)

IF DEFINED ValorOpcional (
    echo [ ] Valor Opcional ^(/opcional^): %ValorOpcional%
)

IF %count_posicional% GTR 0 (
    FOR /L %%i IN (1,1,%count_posicional%) DO (
        echo [ ] Parámetro %%i: !ParamPosicional_%%i!
    )
)
echo.

REM Limpiar variables usadas para el parseo de posicionales si se desea
FOR /L %%i IN (1,1,%count_posicional%) DO (
    SET "ParamPosicional_%%i="
)

ENDLOCAL
GOTO :EOF


:ayuda
    echo.
    echo Modo de uso: %0 [/f RUTA_ARCHIVO] [/opcional VALOR] [otros_params...]
    echo     Ejemplo: %0 /opcional dato_opcional /f fichero.txt datos_adicionales
    GOTO :EOF