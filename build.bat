tcc -DWinMainCRTStartup=_start -nostdlib game.c -lkernel32 -luser32 -lgdi32 -lopengl32 -ldwmapi -lwinmm -Wl,-subsystem=windows
@rem cl -nologo -W4 -WX -Z7 -Oi -J -EHa- -GR- -GS- -Gs0x1000000 game.c kernel32.lib user32.lib gdi32.lib opengl32.lib ws2_32.lib dwmapi.lib winmm.lib -link -incremental:no -nodefaultlib -subsystem:windows -stack:0x1000000,0x1000000 -heap:0,0
