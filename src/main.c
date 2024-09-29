#define DEVELOPER 1
#define RENDERER_OPENGL 1

#include "basic.h"

u16 platform_screen_width;
u16 platform_screen_height;

#if RENDERER_OPENGL
#include "opengl.min.h"
void opengl_init(void);
void opengl_deinit(void);
void opengl_resize(void);
void opengl_present(void);
#endif

#if OS_WINDOWS
#include "windows.min.h"
HINSTANCE windows_hinstance;
HWND windows_hwnd;
HDC windows_hdc;
#include "main_windows.c"

#if COMPILER_MSVC
int _fltused;
#endif
#endif

#if RENDERER_OPENGL
#include "renderer_opengl.c"
#endif
