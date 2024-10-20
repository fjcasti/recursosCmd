@echo off
set calenda=%date:~6,4%
set mes=%date:~3,2%
set dia=%date:~0,2%
set hora=%time:~0,2%
set minuto=%time:~3,2%
set segundo=%time:~6,2%

set ahora=%calenda%%mes%%dia%%hora%%minuto%%segundo%
echo sin formato %ahora%

set ahora=%dia%/%mes%/%calenda% %hora%:%minuto%:%segundo%
echo con formato: %ahora%


