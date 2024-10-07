#define DEVELOPER 1
#define RENDERER_OPENGL 1

#define COMPILER_MSVC 1
#define TARGET_CPU_ARCH_AMD64 1
#define TARGET_OS_WINDOWS 1

#define cast(T) (T)
#define size_of(T) sizeof(T)
#define offset_of(T, F) (cast(u64) &(cast(T*) 0)->F)

#define null (cast(void*) 0)
#define true (cast(_Bool) 1)
#define false (cast(_Bool) 0)

#if TARGET_CPU_ARCH_AMD64
typedef signed char s8;
typedef short s16;
typedef int s32;
typedef long long s64;

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;
#endif

typedef u8 bool;

typedef float f32;
typedef double f64;

#if RENDERER_OPENGL
void opengl_init(void);
void opengl_deinit(void);
void opengl_resize(void);
void opengl_present(void);
#endif

u16 platform_screen_width;
u16 platform_screen_height;

#if TARGET_OS_WINDOWS
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
#include "opengl.min.h"
#include "renderer_opengl.c"
#endif
