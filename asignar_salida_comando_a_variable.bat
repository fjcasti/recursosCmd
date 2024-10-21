@echo off
set NLS_LANG=AMERICAN_AMERICA.UTF8
chcp 65001 > nul

REM OPCIÓN 1. esta opción a veces es detectada como maliciosa por los antivirus.
ECHO OPCIÓN 1
TIME /T > FICHERO_TEMPORAL.TMP
SET /P VARIABLE=<FICHERO_TEMPORAL.TMP
ECHO %VARIABLE%
del /F /Q FICHERO_TEMPORAL.TMP


REM OPCIÓN 2
ECHO OPCIÓN 2
FOR /F %%A IN ('TIME /T') DO SET VARIABLE2=%%A
echo %variable2%


rem OPCIÓN 2 MEJORADA
ECHO OPCIÓN 2 mejorada
rem Si quieres usar comillas en el comando puedes usar comillas invertidas para
rem el comando añadiendo la opción "usebackq" a las opciones del FOR
FOR /F "tokens=1,2 delims=: " %%A IN ('time /T') DO (
  SET var1=%%A
  SET var2=%%B
)
ECHO HORAS:   %var1%
ECHO MINUTOS: %var2%

