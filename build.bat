@echo off

rem tcc -impdef {kernel32,user32,gdi32,...}.dll
tcc -DWinMainCRTStartup=_start -nostdlib platform\main.c^
 -lkernel32 -luser32 -lgdi32 -lopengl32 -ldwmapi -lwinmm^
 -Wl,-subsystem=windows || goto :error

if "%1"=="test" (
    where /q cl || call vcvars64.bat || goto :error
    cl -nologo -W4 -WX -Z7 -Oi -J -EHa- -GR- -GS- -Gs0x1000000^
     platform\main.c kernel32.lib user32.lib gdi32.lib opengl32.lib dwmapi.lib winmm.lib^
     -link -incremental:no -nodefaultlib -subsystem:windows^
     -stack:0x1000000,0x1000000 -heap:0,0 || goto :error
) else if "%1"=="run" ( start main.exe
) else if "%1"=="debug" ( start remedybg main.exe
) else if "%1"=="doc" ( start qrenderdoc main.exe
) else if "%1"=="clean" ( del *.exe *.pdb *.obj 2>nul
) else if not "%1"=="" ( echo command '%1' not found & goto :error )

:end
del *.obj 2>nul
exit /b
:error
call :end
exit /b 1
