@echo off

where /q cl || call vcvars64.bat || goto :error

cl -nologo -W4 -WX -Z7 -Oi -J -EHa- -GR- -GS- -Gs0x1000000^
 game.c kernel32.lib^
 -link -incremental:no -nodefaultlib -subsystem:windows^
 -stack:0x1000000,0x1000000 -heap:0,0 || goto :error

:end
del *.obj 2>nul
exit /b
:error
call :end
exit /b 1
