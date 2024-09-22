#define DEBUG 1
#define DEVELOPER 1
#define RENDERER_VULKAN 0
#define RENDERER_OPENGL 1

#include "basic.h"

void vulkan_init(void);
void vulkan_deinit(void);
void vulkan_resize(void);
void vulkan_present(void);

void opengl_init(void);
void opengl_deinit(void);
void opengl_resize(void);
void opengl_present(void);

u16 platform_screen_width;
u16 platform_screen_height;

#if OS_WINDOWS
#include "windows.min.h"
HINSTANCE platform_hinstance;
HWND platform_hwnd;
HDC platform_hdc;
#include "main_windows.c"
#endif

#if RENDERER_OPENGL
#include "opengl.min.h"
#include "renderer_opengl.c"
#endif

#if RENDERER_VULKAN
#include "vulkan.min.h"
#include "renderer_vulkan.c"
#endif
