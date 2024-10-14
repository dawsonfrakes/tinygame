@echo off

rmdir /s /q .out 2>nul
mkdir .out || goto :error

where /q cl || call vcvars64.bat || goto :error

rc -nologo -fo .out\app.res res\windows\app.rc || goto :error
cl -nologo -Fe.out\game.exe -W4 -WX -Z7 -Oi -J -EHa- -GR- -GS- -Gs0x1000000^
 tinygame.c .out\app.res kernel32.lib^
 -link -incremental:no -nodefaultlib -subsystem:windows^
 -stack:0x1000000,0x1000000 -heap:0,0 || goto :error
echo 480 >.out\steam_appid.txt
copy res\windows\steam_api64.dll .out\ >nul
del .out\*.res >nul

if "%1"=="run" ( start .out\game.exe
) else if "%1"=="debug" ( start remedybg .out\game.exe
) else if "%1"=="doc" ( start qrenderdoc .out\game.exe
) else if "%1"=="test" ( tcc -DWinMainCRTStartup=_start -nologo -o .out\game.exe -lkernel32 -Wl,-subsystem,windows || goto :error
) else if "%1"=="clean" ( rmdir /s /q .out 2>nul
) else if not "%1"=="" ( echo command '%1' not found & goto :error )

:end
del *.obj 2>nul
exit /b
:error
call :end
exit /b 1
