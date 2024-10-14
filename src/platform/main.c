#include "../basic.h"

#define TARGET_STORE_STEAM 1
#define TARGET_RENDERER_OPENGL 1

#if TARGET_STORE_STEAM
#include "steam.min.h"

static bool steam_enabled;
static ISteamFriends steam_friends;
static ISteamUtils steam_utils;
#endif

#if TARGET_RENDERER_OPENGL
#include "opengl.min.h"

static void opengl_init(void);
static void opengl_deinit(void);
static void opengl_resize(void);
static void opengl_present(void);
#endif

#if TARGET_OS_WINDOWS
#include "windows.min.h"

#define X(RET, NAME, ...) RET NAME(__VA_ARGS__);
KERNEL32_FUNCTIONS
#undef X

#define X(RET, NAME, ...) static RET (*NAME)(__VA_ARGS__);
USER32_FUNCTIONS
GDI32_FUNCTIONS
OPENGL32_FUNCTIONS
GL10_FUNCTIONS
GL11_FUNCTIONS
DWMAPI_FUNCTIONS
WINMM_FUNCTIONS

GL20_FUNCTIONS
GL30_FUNCTIONS
GL31_FUNCTIONS
GL45_FUNCTIONS

STEAM_FUNCTIONS
#undef X

static u16 platform_screen_width;
static u16 platform_screen_height;
static HINSTANCE platform_hinstance;
static HWND platform_hwnd;
static HDC platform_hdc;

#include "main_windows.c"
#endif

#if TARGET_RENDERER_OPENGL
#include "renderer_opengl.c"
#endif
