@echo off

rmdir /s /q .build 2>nul
mkdir .build

where /q cl || call vcvars64.bat || goto :error

cl -Fe.build\caveman.exe -nologo -W4 -WX -Z7 -Oi -J -EHa- -GR- -GS- -Gs0x1000000^
 src\main.c kernel32.lib user32.lib gdi32.lib opengl32.lib ws2_32.lib dwmapi.lib winmm.lib^
 -link -incremental:no -nodefaultlib -subsystem:windows^
 -stack:0x1000000,0x1000000 -heap:0,0 || goto :error

if "%1"=="run" ( start .build\caveman.exe
) else if "%1"=="debug" ( start remedybg .build\caveman.exe
) else if "%1"=="doc" ( start qrenderdoc .build\caveman.exe
) else if not "%1"=="" ( echo command '%1' not found & goto :error )

:end
del *.obj 2>nul
exit /b
:error
call :end
exit /b 1
