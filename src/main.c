#define DEVELOPER 1
#define RENDERER_OPENGL 1

#include "basic.h"

static u16 platform_screen_width;
static u16 platform_screen_height;

#if RENDERER_OPENGL
static void opengl_init(void);
static void opengl_deinit(void);
static void opengl_resize(void);
static void opengl_present(void);
#endif

#if TARGET_OS_WINDOWS
#include "platform/windows.h"
static HINSTANCE platform_hinstance;
static HWND platform_hwnd;
static HDC platform_hdc;
#include "platform/main_windows.c"
#endif

#if RENDERER_OPENGL
#include "platform/opengl.h"
#include "platform/renderer_opengl.c"
#endif
