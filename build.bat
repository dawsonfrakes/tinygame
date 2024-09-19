@echo off

rmdir /s /q .bin 2>nul
mkdir .bin

where /q cl || call vcvars64.bat || goto :error

cl -Fe.bin\caveman.exe -nologo -W4 -WX -Z7 -Oi -J -EHa- -GR- -GS- -Gs0x1000000^
 platform\main.c kernel32.lib user32.lib gdi32.lib opengl32.lib ws2_32.lib dwmapi.lib winmm.lib^
 -link -incremental:no -nodefaultlib -subsystem:windows^
 -stack:0x1000000,0x1000000 -heap:0,0 || goto :error

if "%1"=="run" ( start .bin\caveman.exe
) else if not "%1"=="" ( echo command '%1' not found & goto :error )

:end
del *.obj 2>nul
exit /b
:error
call :end
exit /b 1
