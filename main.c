#define DEVELOPER 1

#include "basic.h"

static u16 platform_screen_width;
static u16 platform_screen_height;

#if TARGET_OS_WINDOWS
#include "windows.min.h"
static HINSTANCE platform_hinstance;
static HWND platform_hwnd;
static HDC platform_hdc;
#include "platform_windows.c"
#endif
