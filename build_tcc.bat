tcc -DWinMainCRTStartup=_start -nostdlib game.c -lkernel32 -Wl,-subsystem,windows 
