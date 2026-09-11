@echo off
:: Este archivo es un acceso directo. Toda la logica real vive en unificacion.bat
:: para no mantener dos scripts distintos que puedan desincronizarse.
cd /d "%~dp0"
call "%~dp0unificacion.bat"
