@echo off

rmdir /s /q .build 2>nul
mkdir .build || goto :error

where /q cl || call vcvars64.bat || goto :error

cl -Fe.build\game.exe -nologo -W4 -WX -Z7 -Oi -J -EHa- -GR- -GS- -Gs0x1000000^
 src\main.c kernel32.lib^
 -link -incremental:no -nodefaultlib -subsystem:windows^
 -stack:0x1000000,0x1000000 -heap:0,0 || goto :error

if "%1"=="run" ( start .build\game.exe
) else if "%1"=="debug" ( start remedybg .build\game.exe
) else if "%1"=="doc" ( start qrenderdoc .build\game.exe
) else if "%1"=="clean" ( rmdir /s /q .build 2>nul
) else if not "%1"=="" ( echo command '%1' not found & goto :error )

:end
del *.obj 2>nul
exit /b
:error
call :end
exit /b 1
