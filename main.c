#define DEVELOPER 1
#define BUILD_MODE_DEBUG 1
#define RENDERER_OPENGL 1

#include "basic.h"

#if RENDERER_OPENGL
static void opengl_init(void);
static void opengl_deinit(void);
static void opengl_resize(void);
static void opengl_present(void);
#endif

static u16 platform_screen_width;
static u16 platform_screen_height;

#if TARGET_OS_WINDOWS
#include "windows.min.h"
static HINSTANCE platform_hinstance;
static HWND platform_hwnd;
static HDC platform_hdc;
#include "platform_windows.c"
#endif

#if RENDERER_OPENGL
#include "renderer_opengl.c"
#endif
