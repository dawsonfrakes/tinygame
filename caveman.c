#define TARGET_CPU_ARCH_AMD64 1
#define TARGET_OS_WINDOWS 1
#define RENDERER_OPENGL 1
#define DEVELOPER 1

#define true 1
#define false 0
#define null (cast(void*) 0)

#define size_of(T) sizeof(T)
#define offset_of(T, F) ((u64) &(cast(T*) 0)->F)
#define cast(T) (T)
#define len(X) (size_of(X) / size_of((X)[0]))
#define str(X) (cast(string) {len(X) - 1, (X)})
#define min(X, Y) ((X) < (Y) ? (X) : (Y))
#define max(X, Y) ((X) > (Y) ? (X) : (Y))

typedef signed char s8;
typedef short s16;
typedef int s32;
typedef long long s64;

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;

typedef float float32;
typedef double float64;

typedef u8 bool;

typedef struct {
    u64 count;
    u8* data;
} string;

#if RENDERER_OPENGL
static void opengl_init(void);
static void opengl_deinit(void);
static void opengl_resize(void);
static void opengl_present(void);
#endif

#if TARGET_OS_WINDOWS
/* kernel32 */
#define GENERIC_READ 0x80000000
#define OPEN_EXISTING 3
#define FILE_ATTRIBUTE_NORMAL 0x80
#define INVALID_HANDLE_VALUE (cast(HANDLE) -1)
#define MEM_COMMIT 0x00001000
#define MEM_RESERVE 0x00002000
#define MEM_RELEASE 0x00008000
#define PAGE_READWRITE 0x04

typedef void* HANDLE;
typedef struct HINSTANCE__* HINSTANCE;
typedef s64 (*PROC)(void);

HINSTANCE GetModuleHandleW(u16*);
HANDLE CreateFileA(u8*, u32, u32, void*, u32, u32, HANDLE);
s32 CloseHandle(HANDLE);
s32 GetFileSizeEx(HANDLE, u64*);
s32 ReadFile(HANDLE, void*, u32, u32*, void*);
void* VirtualAlloc(void*, u64, u32, u32);
s32 VirtualFree(void*, u64, u32);
void Sleep(u32);
void ExitProcess(u32);

/* user32 */
#define IDI_WARNING (cast(void*) cast(u64) 32515)
#define IDC_CROSS (cast(void*) cast(u64) 32515)
#define CS_OWNDC 0x0020
#define WS_MAXIMIZEBOX 0x00010000
#define WS_MINIMIZEBOX 0x00020000
#define WS_THICKFRAME 0x00040000
#define WS_SYSMENU 0x00080000
#define WS_CAPTION 0x00C00000
#define WS_VISIBLE 0x10000000
#define WS_OVERLAPPEDWINDOW (WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)
#define CW_USEDEFAULT (cast(s32) 0x80000000)
#define PM_REMOVE 0x0001
#define WM_CREATE 0x0001
#define WM_DESTROY 0x0002
#define WM_SIZE 0x0005
#define WM_PAINT 0x000F
#define WM_QUIT 0x0012
#define WM_ERASEBKGND 0x0014
#define WM_ACTIVATEAPP 0x001C
#define WM_KEYDOWN 0x0100
#define WM_KEYUP 0x0101
#define WM_SYSKEYDOWN 0x0104
#define WM_SYSKEYUP 0x0105
#define WM_SYSCOMMAND 0x0112
#define SC_KEYMENU 0xF100
#define GWL_STYLE (-16)
#define HWND_TOP (cast(HWND) 0)
#define SWP_NOSIZE 0x0001
#define SWP_NOMOVE 0x0002
#define SWP_NOZORDER 0x0004
#define SWP_FRAMECHANGED 0x0020
#define MONITOR_DEFAULTTOPRIMARY 0x00000001
#define VK_RETURN 0x0D
#define VK_ESCAPE 0x1B
#define VK_F4 0x73
#define VK_F10 0x79
#define VK_F11 0x7A

typedef struct HDC__* HDC;
typedef struct HWND__* HWND;
typedef struct HICON__* HICON;
typedef struct HMENU__* HMENU;
typedef struct HBRUSH__* HBRUSH;
typedef struct HCURSOR__* HCURSOR;
typedef struct HMONITOR__* HMONITOR;
typedef s64 (*WNDPROC)(HWND, u32, u64, s64);
typedef struct {
    s32 x;
    s32 y;
} POINT;
typedef struct {
    s32 left;
    s32 top;
    s32 right;
    s32 bottom;
} RECT;
typedef struct {
    u32 cbSize;
    u32 style;
    WNDPROC lpfnWndProc;
    s32 cbClsExtra;
    s32 cbWndExtra;
    HINSTANCE hInstance;
    HICON hIcon;
    HCURSOR hCursor;
    HBRUSH hbrBackground;
    u16* lpszMenuName;
    u16* lpszClassName;
    HICON hIconSm;
} WNDCLASSEXW;
typedef struct {
    HWND hwnd;
    u32 message;
    u64 wParam;
    s64 lParam;
    u32 time;
    POINT pt;
    u32 lPrivate;
} MSG;
typedef struct {
    u32 length;
    u32 flags;
    u32 showCmd;
    POINT ptMinPosition;
    POINT ptMaxPosition;
    RECT rcNormalPosition;
    RECT rcDevice;
} WINDOWPLACEMENT;
typedef struct {
  u32 cbSize;
  RECT rcMonitor;
  RECT rcWork;
  u32 dwFlags;
} MONITORINFO;

s32 SetProcessDPIAware(void);
HICON LoadIconW(HINSTANCE, u16*);
HCURSOR LoadCursorW(HINSTANCE, u16*);
u16 RegisterClassExW(WNDCLASSEXW*);
HWND CreateWindowExW(u32, u16*, u16*, u32, s32, s32, s32, s32, HWND, HMENU, HINSTANCE, void*);
s32 PeekMessageW(MSG*, HWND, u32, u32, u32);
s32 TranslateMessage(MSG*);
s64 DispatchMessageW(MSG*);
HDC GetDC(HWND);
s64 DefWindowProcW(HWND, u32, u64, s64);
void PostQuitMessage(s32);
s32 ValidateRect(HWND, RECT*);
s32 DestroyWindow(HWND);
s64 GetWindowLongPtrW(HWND, s32);
s64 SetWindowLongPtrW(HWND, s32, s64);
s32 GetWindowPlacement(HWND, WINDOWPLACEMENT*);
s32 SetWindowPlacement(HWND, WINDOWPLACEMENT*);
HMONITOR MonitorFromWindow(HWND, u32);
s32 GetMonitorInfoW(HMONITOR, MONITORINFO*);
s32 SetWindowPos(HWND, HWND, s32, s32, s32, s32, u32);

/* gdi32 */
#define PFD_DOUBLEBUFFER 0x00000001
#define PFD_DRAW_TO_WINDOW 0x00000004
#define PFD_SUPPORT_OPENGL 0x00000020
#define PFD_DEPTH_DONTCARE 0x20000000

typedef struct {
    u16 nSize;
    u16 nVersion;
    u32 dwFlags;
    u8 iPixelType;
    u8 cColorBits;
    u8 cRedBits;
    u8 cRedShift;
    u8 cGreenBits;
    u8 cGreenShift;
    u8 cBlueBits;
    u8 cBlueShift;
    u8 cAlphaBits;
    u8 cAlphaShift;
    u8 cAccumBits;
    u8 cAccumRedBits;
    u8 cAccumGreenBits;
    u8 cAccumBlueBits;
    u8 cAccumAlphaBits;
    u8 cDepthBits;
    u8 cStencilBits;
    u8 cAuxBuffers;
    u8 iLayerType;
    u8 bReserved;
    u32 dwLayerMask;
    u32 dwVisibleMask;
    u32 dwDamageMask;
} PIXELFORMATDESCRIPTOR;

s32 ChoosePixelFormat(HDC, PIXELFORMATDESCRIPTOR*);
s32 SetPixelFormat(HDC, s32, PIXELFORMATDESCRIPTOR*);
s32 SwapBuffers(HDC);

/* opengl32 */
typedef struct HGLRC__* HGLRC;

HGLRC wglCreateContext(HDC);
s32 wglDeleteContext(HGLRC);
s32 wglMakeCurrent(HDC, HGLRC);
PROC wglGetProcAddress(u8*);

/* dwmapi */
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#define DWMWA_WINDOW_CORNER_PREFERENCE 33
#define DWMWCP_DONOTROUND 1

/* winmm */
u32 timeBeginPeriod(u32);

u32 DwmSetWindowAttribute(HWND, u32, void*, u32);

static HINSTANCE platform_hinstance;
static HWND platform_hwnd;
static HDC platform_hdc;
static u16 platform_screen_width;
static u16 platform_screen_height;

static void update_cursor_clip(void) {

}

static void toggle_fullscreen(void) {
    static WINDOWPLACEMENT save_placement = {size_of(WINDOWPLACEMENT)};

    u32 style = cast(u32) GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
    if (style & WS_OVERLAPPEDWINDOW) {
        MONITORINFO mi = {size_of(MONITORINFO)};
        GetMonitorInfoW(MonitorFromWindow(platform_hwnd, MONITOR_DEFAULTTOPRIMARY), &mi);

        GetWindowPlacement(platform_hwnd, &save_placement);
        SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style & ~cast(u32) WS_OVERLAPPEDWINDOW);
        SetWindowPos(platform_hwnd, HWND_TOP,
            mi.rcMonitor.left, mi.rcMonitor.top,
            mi.rcMonitor.right - mi.rcMonitor.left,
            mi.rcMonitor.bottom - mi.rcMonitor.top,
            SWP_FRAMECHANGED);
    } else {
        SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style | WS_OVERLAPPEDWINDOW);
        SetWindowPlacement(platform_hwnd, &save_placement);
        SetWindowPos(platform_hwnd, null, 0, 0, 0, 0, SWP_NOSIZE |
            SWP_NOMOVE | SWP_NOZORDER | SWP_FRAMECHANGED);
    }
}

static s64 window_proc(HWND hwnd, u32 message, u64 wParam, s64 lParam) {
    switch (message) {
        case WM_PAINT: {
            ValidateRect(hwnd, null);
            return 0;
        }
        case WM_ERASEBKGND: {
            return 1;
        }
        case WM_ACTIVATEAPP: {
            if (wParam != 0) update_cursor_clip();
            return 0;
        }
        case WM_SIZE: {
            platform_screen_width = cast(u16) cast(u64) lParam;
            platform_screen_height = cast(u16) (cast(u64) lParam >> 16);

            opengl_resize();
            return 0;
        }
        case WM_CREATE: {
            platform_hwnd = hwnd;
            platform_hdc = GetDC(hwnd);

            s32 dark_mode = true;
            DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, 4);
            s32 round_mode = DWMWCP_DONOTROUND;
            DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, 4);

            opengl_init();
            return 0;
        }
        case WM_DESTROY: {
            opengl_deinit();

            PostQuitMessage(0);
            return 0;
        }
        default: {
            if (message == WM_SYSCOMMAND && wParam == SC_KEYMENU) return 0;
            return DefWindowProcW(hwnd, message, wParam, lParam);
        }
    }
}

void WinMainCRTStartup(void) {
    platform_hinstance = GetModuleHandleW(null);

    bool sleep_is_granular = timeBeginPeriod(1) == 0;

    SetProcessDPIAware();
    WNDCLASSEXW wndclass = {0};
    wndclass.cbSize = size_of(WNDCLASSEXW);
    wndclass.style = CS_OWNDC;
    wndclass.lpfnWndProc = window_proc;
    wndclass.hInstance = platform_hinstance;
    wndclass.hIcon = LoadIconW(null, IDI_WARNING);
    wndclass.hCursor = LoadCursorW(null, IDC_CROSS);
    wndclass.lpszClassName = L"A";
    RegisterClassExW(&wndclass);
    CreateWindowExW(0, wndclass.lpszClassName, L"Caveman Goes Ooga Booga",
        WS_OVERLAPPEDWINDOW | WS_VISIBLE,
        CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
        null, null, platform_hinstance, null);

    for (;;) {
        MSG msg;
        while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE)) {
            TranslateMessage(&msg);
            switch (msg.message) {
                case WM_KEYDOWN:
                case WM_KEYUP:
                case WM_SYSKEYDOWN:
                case WM_SYSKEYUP: {
                    bool pressed = (cast(u64) msg.lParam & cast(u64) 1 << 31) == 0;
                    bool repeat = pressed && (cast(u64) msg.lParam & cast(u64) 1 << 30) != 0;
                    bool sys = msg.message == WM_SYSKEYDOWN || msg.message == WM_SYSKEYUP;
                    bool alt = sys && (cast(u64) msg.lParam & cast(u64) 1 << 29) != 0;

                    if (!repeat && (!sys || alt || msg.wParam == VK_F10)) {
                        if (pressed) {
                            if (msg.wParam == VK_F4 && alt) DestroyWindow(platform_hwnd);
                            if (msg.wParam == VK_F11 || (msg.wParam == VK_RETURN && alt)) toggle_fullscreen();
                            if (DEVELOPER && msg.wParam == VK_ESCAPE) DestroyWindow(platform_hwnd);
                        }
                    }
                    break;
                }
                case WM_QUIT: {
                    goto game_loop_end;
                }
                default: {
                    DispatchMessageW(&msg);
                    break;
                }
            }
        }

        opengl_present();

        if (sleep_is_granular) {
            Sleep(1);
        }
    }
game_loop_end:

    ExitProcess(0);
}

int _fltused;
#endif

#if RENDERER_OPENGL
/* 1.0 */
#define GL_COLOR_BUFFER_BIT 0x00004000
#define GL_TRIANGLES 0x0004
#define GL_GEQUAL 0x0206
#define GL_SRC_ALPHA 0x0302
#define GL_ONE_MINUS_SRC_ALPHA 0x0303
#define GL_FRONT_AND_BACK 0x0408
#define GL_CULL_FACE 0x0B44
#define GL_DEPTH_TEST 0x0B71
#define GL_BLEND 0x0BE2
#define GL_TEXTURE_2D 0x0DE1
#define GL_UNSIGNED_BYTE 0x1401
#define GL_UNSIGNED_SHORT 0x1403
#define GL_UNSIGNED_INT 0x1405
#define GL_FLOAT 0x1406
#define GL_COLOR 0x1800
#define GL_DEPTH 0x1801
#define GL_ALPHA 0x1906
#define GL_RGB 0x1907
#define GL_RGBA 0x1908
#define GL_POINT 0x1B00
#define GL_LINE 0x1B01
#define GL_FILL 0x1B02
#define GL_NEAREST 0x2600
#define GL_LINEAR 0x2601
#define GL_NEAREST_MIPMAP_NEAREST 0x2700
#define GL_LINEAR_MIPMAP_NEAREST 0x2701
#define GL_NEAREST_MIPMAP_LINEAR 0x2702
#define GL_LINEAR_MIPMAP_LINEAR 0x2703
#define GL_TEXTURE_MAG_FILTER 0x2800
#define GL_TEXTURE_MIN_FILTER 0x2801
#define GL_TEXTURE_WRAP_S 0x2802
#define GL_TEXTURE_WRAP_T 0x2803
#define GL_REPEAT 0x2901

#define GL10_FUNCTIONS \
    X(void, glEnable, u32) \
    X(void, glDisable, u32) \
    X(void, glGetIntegerv, u32, s32*) \
    X(void, glDepthFunc, u32) \
    X(void, glBlendFunc, u32, u32) \
    X(void, glViewport, s32, s32, u32, u32) \
    X(void, glClear, u32) \
    X(void, glDrawArrays, u32, s32, u32)

/* 1.1 */
#define GL_RGBA8 0x8058

/* 1.2 */
#define GL_BGR 0x80E0
#define GL_BGRA 0x80E1

/* 1.5 */
#define GL_STREAM_DRAW 0x88E0
#define GL_STATIC_DRAW 0x88E4

/* 2.0 */
#define GL_FRAGMENT_SHADER 0x8B30
#define GL_VERTEX_SHADER 0x8B31
#define GL_LOWER_LEFT 0x8CA1

#define GL20_FUNCTIONS \
    X(u32, glCreateProgram, void) \
    X(void, glAttachShader, u32, u32) \
    X(void, glDetachShader, u32, u32) \
    X(void, glLinkProgram, u32) \
    X(void, glUseProgram, u32) \
    X(u32, glCreateShader, u32) \
    X(void, glDeleteShader, u32) \
    X(void, glShaderSource, u32, u32, u8**, s32*) \
    X(void, glCompileShader, u32)

/* 3.0 */
#define GL_RGBA16F 0x881A
#define GL_DEPTH_COMPONENT32F 0x8CAC
#define GL_COLOR_ATTACHMENT0 0x8CE0
#define GL_DEPTH_ATTACHMENT 0x8D00
#define GL_FRAMEBUFFER 0x8D40
#define GL_RENDERBUFFER 0x8D41
#define GL_FRAMEBUFFER_SRGB 0x8DB9

#define GL30_FUNCTIONS \
    X(void, glBindFramebuffer, u32, u32) \
    X(void, glBindVertexArray, u32)

/* 3.2 */
#define GL_MAX_COLOR_TEXTURE_SAMPLES 0x910E
#define GL_MAX_DEPTH_TEXTURE_SAMPLES 0x910F

/* 4.5 */
#define GL_ZERO_TO_ONE 0x935F

#define GL45_FUNCTIONS \
    X(void, glClipControl, u32, u32) \
    X(void, glCreateFramebuffers, u32, u32*) \
    X(void, glNamedFramebufferRenderbuffer, u32, u32, u32, u32) \
    X(void, glClearNamedFramebufferfv, u32, u32, s32, float32*) \
    X(void, glBlitNamedFramebuffer, u32, u32, s32, s32, s32, s32, s32, s32, s32, s32, u32, u32) \
    X(void, glCreateRenderbuffers, u32, u32*) \
    X(void, glNamedRenderbufferStorageMultisample, u32, u32, u32, u32, u32) \
    X(void, glCreateVertexArrays, u32, u32*) \
    X(void, glVertexArrayVertexBuffer, u32, u32, u32, s64, u32) \
    X(void, glEnableVertexArrayAttrib, u32, u32) \
    X(void, glVertexArrayAttribBinding, u32, u32, u32) \
    X(void, glVertexArrayAttribFormat, u32, u32, s32, u32, bool, u32) \
    X(void, glCreateBuffers, u32, u32*) \
    X(void, glNamedBufferData, u32, u64, void*, u32) \
    X(void, glCreateTextures, u32, u32, u32*) \
    X(void, glTextureStorage2D, u32, u32, u32, u32, u32) \
    X(void, glTextureSubImage2D, u32, s32, s32, s32, u32, u32, u32, u32, void*) \
    X(void, glTextureParameteri, u32, u32, s32) \
    X(void, glBindTextureUnit, u32, u32) \
    X(void, glProgramUniformMatrix4fv, u32, s32, u32, bool, float32*)

#if TARGET_OS_WINDOWS
#define WGL_CONTEXT_MAJOR_VERSION_ARB 0x2091
#define WGL_CONTEXT_MINOR_VERSION_ARB 0x2092
#define WGL_CONTEXT_FLAGS_ARB 0x2094
#define WGL_CONTEXT_PROFILE_MASK_ARB 0x9126
#define WGL_CONTEXT_DEBUG_BIT_ARB 0x0001
#define WGL_CONTEXT_CORE_PROFILE_BIT_ARB 0x00000001

#define X(RET, NAME, ...) RET NAME(__VA_ARGS__);
GL10_FUNCTIONS
#undef X

static HGLRC opengl_ctx;
#define X(RET, NAME, ...) static RET (*NAME)(__VA_ARGS__);
GL20_FUNCTIONS
GL30_FUNCTIONS
GL45_FUNCTIONS
#undef X

static void opengl_platform_init(void) {
    PIXELFORMATDESCRIPTOR pfd = {0};
    pfd.nSize = size_of(PIXELFORMATDESCRIPTOR);
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL |
        PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
    pfd.cColorBits = 24;
    s32 format = ChoosePixelFormat(platform_hdc, &pfd);
    SetPixelFormat(platform_hdc, format, &pfd);

    HGLRC temp_ctx = wglCreateContext(platform_hdc);
    wglMakeCurrent(platform_hdc, temp_ctx);

    HGLRC (*wglCreateContextAttribsARB)(HDC, HGLRC, s32*) =
        cast(HGLRC (*)(HDC, HGLRC, s32*))
        wglGetProcAddress(cast(u8*) "wglCreateContextAttribsARB");

    s32 attribs[] = {
        WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
        WGL_CONTEXT_MINOR_VERSION_ARB, 6,
        WGL_CONTEXT_FLAGS_ARB, WGL_CONTEXT_DEBUG_BIT_ARB,
        WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
        0,
    };
    opengl_ctx = wglCreateContextAttribsARB(platform_hdc, null, attribs);
    wglMakeCurrent(platform_hdc, opengl_ctx);

    wglDeleteContext(temp_ctx);

#define X(RET, NAME, ...) NAME = cast(RET (*)(__VA_ARGS__)) wglGetProcAddress(cast(u8*) #NAME);
    GL20_FUNCTIONS
    GL30_FUNCTIONS
    GL45_FUNCTIONS
#undef X
}

static void opengl_platform_deinit(void) {
    if (opengl_ctx) wglDeleteContext(opengl_ctx);
    opengl_ctx = null;
}

static void opengl_platform_present(void) {
    SwapBuffers(platform_hdc);
}
#endif

static u32 opengl_main_fbo;
static u32 opengl_main_fbo_color0;
static u32 opengl_main_fbo_depth;

static float32 triangle_vertices[] = {
    -0.5f, -0.5f, +0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f,
    +0.5f, -0.5f, +0.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f, 0.0f,
    +0.0f, +0.5f, +0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.5f, 1.0f,
};

static u32 opengl_triangle_vao;
static u32 opengl_triangle_shader;
static u32 opengl_triangle_parabola_texture;

static string platform_read_entire_file(u8* filepath) {
    string result = {0};
    HANDLE hfile = CreateFileA(filepath, GENERIC_READ, 0, null, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, null);
    if (hfile != INVALID_HANDLE_VALUE) {
        u64 file_size;
        GetFileSizeEx(hfile, &file_size);
        void* mem = VirtualAlloc(0, file_size, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
        u32 bytes_read;
        ReadFile(hfile, mem, cast(u32) file_size, &bytes_read, null);
        if (file_size == bytes_read) {
            result.data = mem;
            result.count = bytes_read;
        } else {
            VirtualFree(mem, 0, MEM_RELEASE);
        }
        CloseHandle(hfile);
    }
    return result;
}

static void opengl_init(void) {
    opengl_platform_init();

    glDepthFunc(GL_GEQUAL);
    glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE);

    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glCreateFramebuffers(1, &opengl_main_fbo);
    glCreateRenderbuffers(1, &opengl_main_fbo_color0);
    glCreateRenderbuffers(1, &opengl_main_fbo_depth);

    u32 triangles_vbo;
    glCreateBuffers(1, &triangles_vbo);
    glNamedBufferData(triangles_vbo, size_of(float32) * 27, triangle_vertices, GL_STATIC_DRAW);

    glCreateVertexArrays(1, &opengl_triangle_vao);
    u32 vbo_binding = 0;
    glVertexArrayVertexBuffer(opengl_triangle_vao, vbo_binding, triangles_vbo, 0, size_of(float32) * 9);

    u32 position_attrib = 0;
    glEnableVertexArrayAttrib(opengl_triangle_vao, position_attrib);
    glVertexArrayAttribBinding(opengl_triangle_vao, position_attrib, vbo_binding);
    glVertexArrayAttribFormat(opengl_triangle_vao, position_attrib, 3, GL_FLOAT, false, 0);

    u32 color_attrib = 1;
    glEnableVertexArrayAttrib(opengl_triangle_vao, color_attrib);
    glVertexArrayAttribBinding(opengl_triangle_vao, color_attrib, vbo_binding);
    glVertexArrayAttribFormat(opengl_triangle_vao, color_attrib, 4, GL_FLOAT, false, size_of(float32) * 3);

    u32 texcoord_attrib = 2;
    glEnableVertexArrayAttrib(opengl_triangle_vao, texcoord_attrib);
    glVertexArrayAttribBinding(opengl_triangle_vao, texcoord_attrib, vbo_binding);
    glVertexArrayAttribFormat(opengl_triangle_vao, texcoord_attrib, 2, GL_FLOAT, false, size_of(float32) * 7);

    u32 vshader = glCreateShader(GL_VERTEX_SHADER);
    string vsrc = platform_read_entire_file("res/shaders/opengl_triangle.vert");
    if (vsrc.data) {
        s32 vsrc_count = cast(s32) vsrc.count;
        glShaderSource(vshader, 1, &vsrc.data, &vsrc_count);
        VirtualFree(vsrc.data, 0, MEM_RELEASE);
    }
    glCompileShader(vshader);

    u32 fshader = glCreateShader(GL_FRAGMENT_SHADER);
    string fsrc = platform_read_entire_file("res/shaders/opengl_triangle.frag");
    if (fsrc.data) {
        s32 fsrc_count = cast(s32) fsrc.count;
        glShaderSource(fshader, 1, &fsrc.data, &fsrc_count);
        VirtualFree(fsrc.data, 0, MEM_RELEASE);
    }
    glCompileShader(fshader);

    opengl_triangle_shader = glCreateProgram();
    glAttachShader(opengl_triangle_shader, vshader);
    glAttachShader(opengl_triangle_shader, fshader);
    glLinkProgram(opengl_triangle_shader);
    glDetachShader(opengl_triangle_shader, fshader);
    glDetachShader(opengl_triangle_shader, vshader);

    glDeleteShader(fshader);
    glDeleteShader(vshader);

    glCreateTextures(GL_TEXTURE_2D, 1, &opengl_triangle_parabola_texture);
    glTextureStorage2D(opengl_triangle_parabola_texture, 1, GL_RGBA8, 512, 512);
    glTextureParameteri(opengl_triangle_parabola_texture, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    string bmp = platform_read_entire_file("res/textures/triangle_parabolas.bmp");
    if (bmp.data) {
        u8* file_data = cast(u8*) bmp.data;
        u32 pixels_offset = *cast(u32*) (file_data + 10);
        u8* pixels = file_data + pixels_offset;
        glTextureSubImage2D(opengl_triangle_parabola_texture, 0, 0, 0, 512, 512, GL_BGR, GL_UNSIGNED_BYTE, pixels);
        VirtualFree(bmp.data, 0, MEM_RELEASE);
    }
}

static void opengl_deinit(void) {
    opengl_platform_deinit();
}

static void opengl_resize(void) {
    s32 fbo_max_color_samples;
    glGetIntegerv(GL_MAX_COLOR_TEXTURE_SAMPLES, &fbo_max_color_samples);
    s32 fbo_max_depth_samples;
    glGetIntegerv(GL_MAX_DEPTH_TEXTURE_SAMPLES, &fbo_max_depth_samples);
    u32 fbo_samples = cast(u32) min(fbo_max_color_samples, fbo_max_depth_samples);

    glNamedRenderbufferStorageMultisample(opengl_main_fbo_color0, fbo_samples,
        GL_RGBA16F, platform_screen_width, platform_screen_height);
    glNamedFramebufferRenderbuffer(opengl_main_fbo, GL_COLOR_ATTACHMENT0,
        GL_RENDERBUFFER, opengl_main_fbo_color0);

    glNamedRenderbufferStorageMultisample(opengl_main_fbo_depth, fbo_samples,
        GL_DEPTH_COMPONENT32F, platform_screen_width, platform_screen_height);
    glNamedFramebufferRenderbuffer(opengl_main_fbo, GL_DEPTH_ATTACHMENT,
        GL_RENDERBUFFER, opengl_main_fbo_depth);
}

static void opengl_present(void) {
    float32 clear_color0[4] = {0.6f, 0.2f, 0.2f, 1.0f};
    float32 clear_depth = 0.0f;
    glClearNamedFramebufferfv(opengl_main_fbo, GL_COLOR, 0, clear_color0);
    glClearNamedFramebufferfv(opengl_main_fbo, GL_DEPTH, 0, &clear_depth);
    glBindFramebuffer(GL_FRAMEBUFFER, opengl_main_fbo);

    glViewport(0, 0, platform_screen_width, platform_screen_height);

    float32 aspect_ratio = cast(float32) platform_screen_width / cast(float32) platform_screen_height;

    glEnable(GL_BLEND);
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    glUseProgram(opengl_triangle_shader);
    s32 u_transform = 0;
    glBindVertexArray(opengl_triangle_vao);
    glBindTextureUnit(0, opengl_triangle_parabola_texture);

    for (u8 i = 0; i < 5; i += 1) {
        float32 transform[16] = {
            1.0f / aspect_ratio, 0.0f, 0.0f, 0.0f,
            0.0f, 1.0f, 0.0f, 0.0f,
            0.0f, 0.0f, 1.0f, -1.0f,
            i * 0.2f, 0.0f, 1.0f - i * 0.2f, 1.0f,
        };
        glProgramUniformMatrix4fv(opengl_triangle_shader, u_transform, 1, false, transform);
        glDrawArrays(GL_TRIANGLES, 0, len(triangle_vertices));
    }

    for (s8 i = 0; i > -5; i -= 1) {
        float32 transform[16] = {
            1.0f / aspect_ratio, 0.0f, 0.0f, 0.0f,
            0.0f, 1.0f, 0.0f, 0.0f,
            0.0f, 0.0f, 1.0f, -1.0f,
            i * 0.2f, 0.0f, 1.0f + i * 0.2f, 1.0f,
        };
        glProgramUniformMatrix4fv(opengl_triangle_shader, u_transform, 1, false, transform);
        glDrawArrays(GL_TRIANGLES, 0, len(triangle_vertices));
    }

    // note(dfra): fix for intel default framebuffer resize bug
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glClear(0);

    glEnable(GL_FRAMEBUFFER_SRGB);
    glBlitNamedFramebuffer(opengl_main_fbo, 0,
        0, 0, platform_screen_width, platform_screen_height,
        0, 0, platform_screen_width, platform_screen_height,
        GL_COLOR_BUFFER_BIT, GL_NEAREST);
    glDisable(GL_FRAMEBUFFER_SRGB);

    opengl_platform_present();
}
#endif
