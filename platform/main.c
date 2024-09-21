#define DEVELOPER 1

#include "basic.h"

u16 platform_screen_width;
u16 platform_screen_height;

#if OS_WINDOWS
#include "windows.min.h"
HINSTANCE platform_hinstance;
HWND platform_hwnd;
HDC platform_hdc;
#include "main_windows.c"
#endif
