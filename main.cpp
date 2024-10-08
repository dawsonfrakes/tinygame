#include "basic.hpp"

u16 platform_screen_width;
u16 platform_screen_height;

#if TARGET_OS_WINDOWS
#include "windows.hpp"
HINSTANCE windows_hinstance;
HWND windows_hwnd;
HDC windows_hdc;
#include "main_windows.cpp"
#endif
