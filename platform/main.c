#define DEVELOPER 1

#include "basic.h"

#if OS_WINDOWS
#include "windows.min.h"
HINSTANCE platform_hinstance;
#include "main_windows.c"
#endif
