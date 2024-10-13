@echo off

rmdir /s /q .out 2>nul
mkdir .out || goto :error

copy vendor\* .out\ >nul
echo 480 >.out\steam_appid.txt

tcc -DWinMainCRTStartup=_start -nostdlib -o .out\game.exe src\platform\main.c -lkernel32 -Wl,-subsystem,windows 

:error
exit /b 1
