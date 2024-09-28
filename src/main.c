#define DEVELOPER 1

#include "basic.h"

u16 platform_screen_width;
u16 platform_screen_height;

#if OS_WINDOWS
#include "windows.min.h"
HINSTANCE windows_hinstance;
HWND windows_hwnd;
HDC windows_hdc;
#include "main_windows.c"
#endif
