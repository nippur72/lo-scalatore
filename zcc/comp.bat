@echo off
call envz.bat
zcc +z80 -clib=classic -c lo_scalatore.c
if %ERRORLEVEL% equ 0 (
    echo [OK] Compilazione completata con successo.
) else (
    echo [ERRORE] Errore durante la compilazione.
)
