#!dmd -betterC -run game.d

enum DEVELOPER = true;
enum RENDERER_OPENGL = true;

alias s8 = byte;
alias s16 = short;
alias s32 = int;
alias s64 = long;

alias u8 = ubyte;
alias u16 = ushort;
alias u32 = uint;
alias u64 = ulong;

alias f32 = float;
alias f64 = double;

T min(T)(T a, T b) { return a < b ? a : b; }

version (Windows) {
__gshared HINSTANCE platform_hinstance;
__gshared HWND platform_hwnd;
__gshared HDC platform_hdc;
__gshared u16 platform_screen_width;
__gshared u16 platform_screen_height;

// kernel32
struct HINSTANCE__; alias HINSTANCE = HINSTANCE__*;
alias PROC = extern(Windows) s64 function();

extern extern(Windows) HINSTANCE GetModuleHandleW(const(wchar)*);
extern extern(Windows) void Sleep(u32);
extern extern(Windows) noreturn ExitProcess(u32);

// user32
enum IDI_WARNING = cast(const(wchar)*) 32515;
enum IDC_CROSS = cast(const(wchar)*) 32515;
enum CS_OWNDC = 0x0020;
enum WS_MAXIMIZEBOX = 0x00010000;
enum WS_MINIMIZEBOX = 0x00020000;
enum WS_THICKFRAME = 0x00040000;
enum WS_SYSMENU = 0x00080000;
enum WS_CAPTION = 0x00C00000;
enum WS_VISIBLE = 0x10000000;
enum WS_OVERLAPPEDWINDOW = WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX;
enum CW_USEDEFAULT = 0x80000000;
enum PM_REMOVE = 0x0001;
enum WM_CREATE = 0x0001;
enum WM_DESTROY = 0x0002;
enum WM_SIZE = 0x0005;
enum WM_PAINT = 0x000F;
enum WM_QUIT = 0x0012;
enum WM_ERASEBKGND = 0x0014;
enum WM_ACTIVATEAPP = 0x001C;
enum WM_KEYDOWN = 0x0100;
enum WM_KEYUP = 0x0101;
enum WM_SYSKEYDOWN = 0x0104;
enum WM_SYSKEYUP = 0x0105;
enum WM_SYSCOMMAND = 0x0112;
enum SC_KEYMENU = 0xF100;
enum GWL_STYLE = -16;
enum HWND_TOP = cast(HWND) 0;
enum SWP_NOSIZE = 0x0001;
enum SWP_NOMOVE = 0x0002;
enum SWP_NOZORDER = 0x0004;
enum SWP_FRAMECHANGED = 0x0020;
enum MONITOR_DEFAULTTOPRIMARY = 0x00000001;
enum VK_RETURN = 0x0D;
enum VK_ESCAPE = 0x1B;
enum VK_F4 = 0x73;
enum VK_F10 = 0x79;
enum VK_F11 = 0x7A;

struct HDC__; alias HDC = HDC__*;
struct HWND__; alias HWND = HWND__*;
struct HMENU__; alias HMENU = HMENU__*;
struct HICON__; alias HICON = HICON__*;
struct HBRUSH__; alias HBRUSH = HBRUSH__*;
struct HCURSOR__; alias HCURSOR = HCURSOR__*;
struct HMONITOR__; alias HMONITOR = HMONITOR__*;
alias WNDPROC = extern(Windows) s64 function(HWND, u32, u64, s64);
struct POINT {
    s32 x;
    s32 y;
}
struct RECT {
    s32 left;
    s32 top;
    s32 right;
    s32 bottom;
}
struct WNDCLASSEXW {
    u32 cbSize;
    u32 style;
    WNDPROC lpfnWndProc;
    s32 cbClsExtra;
    s32 cbWndExtra;
    HINSTANCE hInstance;
    HICON hIcon;
    HCURSOR hCursor;
    HBRUSH hbrBackground;
    const(wchar)* lpszMenuName;
    const(wchar)* lpszClassName;
    HICON hIconSm;
}
struct MSG {
    HWND hwnd;
    u32 message;
    u64 wParam;
    s64 lParam;
    u32 time;
    POINT pt;
    u32 lPrivate;
}
struct WINDOWPLACEMENT {
    u32 length;
    u32 flags;
    u32 showCmd;
    POINT ptMinPosition;
    POINT ptMaxPosition;
    RECT rcNormalPosition;
    RECT rcDevice;
}
struct MONITORINFO {
    u32 cbSize;
    RECT rcMonitor;
    RECT rcWork;
    u32 dwFlags;
}

extern extern(Windows) s32 SetProcessDPIAware();
extern extern(Windows) HICON LoadIconW(HINSTANCE, const(wchar)*);
extern extern(Windows) HCURSOR LoadCursorW(HINSTANCE, const(wchar)*);
extern extern(Windows) s64 DefWindowProcW(HWND, u32, u64, s64);
extern extern(Windows) u16 RegisterClassExW(const(WNDCLASSEXW)*);
extern extern(Windows) HWND CreateWindowExW(u32, const(wchar)*, const(wchar)*, u32, s32, s32, s32, s32, HWND, HMENU, HINSTANCE, void*);
extern extern(Windows) s32 PeekMessageW(MSG*, HWND, u32, u32, u32);
extern extern(Windows) s32 TranslateMessage(const(MSG)*);
extern extern(Windows) s64 DispatchMessageW(const(MSG)*);
extern extern(Windows) HDC GetDC(HWND);
extern extern(Windows) s32 ValidateRect(HWND, RECT*);
extern extern(Windows) void PostQuitMessage(s32);
extern extern(Windows) s32 DestroyWindow(HWND);
extern extern(Windows) s64 GetWindowLongPtrW(HWND, s32);
extern extern(Windows) s64 SetWindowLongPtrW(HWND, s32, s64);
extern extern(Windows) s32 GetWindowPlacement(HWND, WINDOWPLACEMENT*);
extern extern(Windows) s32 SetWindowPlacement(HWND, WINDOWPLACEMENT*);
extern extern(Windows) s32 SetWindowPos(HWND, HWND, s32, s32, s32, s32, u32);
extern extern(Windows) HMONITOR MonitorFromWindow(HWND, u32);
extern extern(Windows) s32 GetMonitorInfoW(HMONITOR, MONITORINFO*);

// gdi32
enum PFD_DOUBLEBUFFER = 0x00000001;
enum PFD_DRAW_TO_WINDOW = 0x00000004;
enum PFD_SUPPORT_OPENGL = 0x00000020;
enum PFD_DEPTH_DONTCARE = 0x20000000;

struct PIXELFORMATDESCRIPTOR {
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
}

extern extern(Windows) s32 ChoosePixelFormat(HDC, const(PIXELFORMATDESCRIPTOR)*);
extern extern(Windows) s32 SetPixelFormat(HDC, s32, const(PIXELFORMATDESCRIPTOR)*);
extern extern(Windows) s32 SwapBuffers(HDC);

// opengl32
struct HGLRC__; alias HGLRC = HGLRC__*;

extern extern(Windows) HGLRC wglCreateContext(HDC);
extern extern(Windows) s32 wglDeleteContext(HGLRC);
extern extern(Windows) s32 wglMakeCurrent(HDC, HGLRC);
extern extern(Windows) PROC wglGetProcAddress(const(char)*);

extern extern(Windows) void glEnable(u32);
extern extern(Windows) void glDisable(u32);
extern extern(Windows) void glViewport(s32, s32, u32, u32);
extern extern(Windows) void glGetIntegerv(u32, s32*);
extern extern(Windows) void glClear(u32);

// dwmapi
enum DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
enum DWMWA_WINDOW_CORNER_PREFERENCE = 33;
enum DWMWCP_DONOTROUND = 1;

extern extern(Windows) u32 DwmSetWindowAttribute(HWND, u32, const(void)*, u32);

// winmm
extern extern(Windows) u32 timeBeginPeriod(u32);

void update_cursor_clip() {

}

void toggle_fullscreen() {
    __gshared WINDOWPLACEMENT save_placement = {WINDOWPLACEMENT.sizeof};

    u32 style = cast(u32) GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
    if (style & WS_OVERLAPPEDWINDOW) {
        MONITORINFO mi = {MONITORINFO.sizeof};
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

extern(Windows) s64 window_proc(HWND hwnd, u32 message, u64 wParam, s64 lParam) {
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

            s32 dark_mode = 1;
            DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, dark_mode.sizeof);
            s32 round_mode = DWMWCP_DONOTROUND;
            DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, round_mode.sizeof);

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

extern(Windows) noreturn WinMainCRTStartup() {
    platform_hinstance = GetModuleHandleW(null);

    bool sleep_is_granular = timeBeginPeriod(1) == 0;

    SetProcessDPIAware();
    WNDCLASSEXW wndclass;
    wndclass.cbSize = WNDCLASSEXW.sizeof;
    wndclass.style = CS_OWNDC;
    wndclass.lpfnWndProc = &window_proc;
    wndclass.hInstance = platform_hinstance;
    wndclass.hIcon = LoadIconW(null, IDI_WARNING);
    wndclass.hCursor = LoadCursorW(null, IDC_CROSS);
    wndclass.lpszClassName = "A"w.ptr;
    RegisterClassExW(&wndclass);
    CreateWindowExW(0, wndclass.lpszClassName, "game"w.ptr,
        WS_OVERLAPPEDWINDOW | WS_VISIBLE,
        CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
        null, null, platform_hinstance, null);

    game_loop: while (true) {
        MSG msg = void;
        while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE)) {
            TranslateMessage(&msg);
            switch (msg.message) {
                case WM_KEYDOWN:
                case WM_KEYUP:
                case WM_SYSKEYDOWN:
                case WM_SYSKEYUP: {
                    bool pressed = (msg.lParam & 1 << 31) == 0;
                    bool repeat = pressed && (msg.lParam & 1 << 30) != 0;
                    bool sys = msg.message == WM_SYSKEYDOWN || msg.message == WM_SYSKEYUP;
                    bool alt = sys && (msg.lParam & 1 << 29) != 0;

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
                    break game_loop;
                }
                default: {
                    DispatchMessageW(&msg);
                }
            }
        }

        opengl_present();

        if (sleep_is_granular) {
            Sleep(1);
        }
    }

    ExitProcess(0);
}

extern(Windows) s32 _fltused = 0;
pragma(linkerDirective, "-subsystem:windows");
pragma(lib, "kernel32");
pragma(lib, "user32");
pragma(lib, "gdi32");
pragma(lib, "opengl32");
pragma(lib, "ws2_32");
pragma(lib, "dwmapi");
pragma(lib, "winmm");
}

static if (RENDERER_OPENGL) {
// 1.0
enum GL_COLOR_BUFFER_BIT = 0x00004000;
enum GL_TRIANGLES = 0x0004;
enum GL_GEQUAL = 0x0206;
enum GL_SRC_ALPHA = 0x0302;
enum GL_ONE_MINUS_SRC_ALPHA = 0x0303;
enum GL_FRONT_AND_BACK = 0x0408;
enum GL_CULL_FACE = 0x0B44;
enum GL_DEPTH_TEST = 0x0B71;
enum GL_BLEND = 0x0BE2;
enum GL_TEXTURE_2D = 0x0DE1;
enum GL_UNSIGNED_BYTE = 0x1401;
enum GL_UNSIGNED_SHORT = 0x1403;
enum GL_UNSIGNED_INT = 0x1405;
enum GL_FLOAT = 0x1406;
enum GL_COLOR = 0x1800;
enum GL_DEPTH = 0x1801;
enum GL_ALPHA = 0x1906;
enum GL_RGB = 0x1907;
enum GL_RGBA = 0x1908;
enum GL_POINT = 0x1B00;
enum GL_LINE = 0x1B01;
enum GL_FILL = 0x1B02;
enum GL_NEAREST = 0x2600;
enum GL_LINEAR = 0x2601;
enum GL_NEAREST_MIPMAP_NEAREST = 0x2700;
enum GL_LINEAR_MIPMAP_NEAREST = 0x2701;
enum GL_NEAREST_MIPMAP_LINEAR = 0x2702;
enum GL_LINEAR_MIPMAP_LINEAR = 0x2703;
enum GL_TEXTURE_MAG_FILTER = 0x2800;
enum GL_TEXTURE_MIN_FILTER = 0x2801;
enum GL_TEXTURE_WRAP_S = 0x2802;
enum GL_TEXTURE_WRAP_T = 0x2803;
enum GL_REPEAT = 0x2901;

// 3.0
enum GL_RGBA16F = 0x881A;
enum GL_DEPTH_COMPONENT32F = 0x8CAC;
enum GL_COLOR_ATTACHMENT0 = 0x8CE0;
enum GL_DEPTH_ATTACHMENT = 0x8D00;
enum GL_FRAMEBUFFER = 0x8D40;
enum GL_RENDERBUFFER = 0x8D41;
enum GL_FRAMEBUFFER_SRGB = 0x8DB9;

// 3.2
enum GL_MAX_COLOR_TEXTURE_SAMPLES = 0x910E;
enum GL_MAX_DEPTH_TEXTURE_SAMPLES = 0x910F;

struct OpenGLProcs {
    // 3.0
    void function(u32, u32) glBindFramebuffer;
    // 4.5
    void function(u32, u32*) glCreateFramebuffers;
    void function(u32, u32, s32, const(f32)*) glClearNamedFramebufferfv;
    void function(u32, u32, u32, u32) glNamedFramebufferRenderbuffer;
    void function(u32, u32, s32, s32, s32, s32, s32, s32, s32, s32, u32, u32) glBlitNamedFramebuffer;
    void function(u32, u32*) glCreateRenderbuffers;
    void function(u32, u32, u32, u32, u32) glNamedRenderbufferStorageMultisample;
}

version (Windows) {
enum WGL_CONTEXT_MAJOR_VERSION_ARB = 0x2091;
enum WGL_CONTEXT_MINOR_VERSION_ARB = 0x2092;
enum WGL_CONTEXT_FLAGS_ARB = 0x2094;
enum WGL_CONTEXT_PROFILE_MASK_ARB = 0x9126;
enum WGL_CONTEXT_DEBUG_BIT_ARB = 0x0001;
enum WGL_CONTEXT_CORE_PROFILE_BIT_ARB = 0x00000001;

__gshared HGLRC opengl_ctx;
static foreach (member_name; __traits(allMembers, OpenGLProcs)) {
    mixin("__gshared extern(System) " ~ typeof(__traits(getMember, OpenGLProcs, member_name)).stringof ~ " " ~ member_name ~ ";");
}

void opengl_platform_init() {
    PIXELFORMATDESCRIPTOR pfd;
    pfd.nSize = PIXELFORMATDESCRIPTOR.sizeof;
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL |
        PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
    pfd.cColorBits = 24;
    s32 format = ChoosePixelFormat(platform_hdc, &pfd);
    SetPixelFormat(platform_hdc, format, &pfd);

    HGLRC temp_ctx = wglCreateContext(platform_hdc);
    wglMakeCurrent(platform_hdc, temp_ctx);

    extern(Windows) HGLRC function(HDC, HGLRC, const(s32)*) wglCreateContextAttribsARB =
        cast(HGLRC function(HDC, HGLRC, const(s32)*)) wglGetProcAddress("wglCreateContextAttribsARB");

    s32[9] attribs = [
        WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
        WGL_CONTEXT_MINOR_VERSION_ARB, 6,
        WGL_CONTEXT_FLAGS_ARB, DEVELOPER ? WGL_CONTEXT_DEBUG_BIT_ARB : 0,
        WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
        0,
    ];
    opengl_ctx = wglCreateContextAttribsARB(platform_hdc, null, attribs.ptr);
    wglMakeCurrent(platform_hdc, opengl_ctx);

    wglDeleteContext(temp_ctx);

    static foreach (member_name; __traits(allMembers, OpenGLProcs)) {
        mixin(member_name ~ " = cast(typeof(" ~ member_name ~ ")) wglGetProcAddress(\"" ~ member_name ~ "\");");
    }
}

void opengl_platform_deinit() {

}

void opengl_platform_present() {
    SwapBuffers(platform_hdc);
}
}

__gshared u32 opengl_main_fbo;
__gshared u32 opengl_main_fbo_color0;
__gshared u32 opengl_main_fbo_depth;

void opengl_init() {
    opengl_platform_init();

    glCreateFramebuffers(1, &opengl_main_fbo);
    glCreateRenderbuffers(1, &opengl_main_fbo_color0);
    glCreateRenderbuffers(1, &opengl_main_fbo_depth);
}

void opengl_deinit() {
    opengl_platform_deinit();
}

void opengl_resize() {
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

void opengl_present() {
    f32[4] clear_color0 = [0.6, 0.2, 0.2, 1.0];
    f32 clear_depth = 0.0;
    glClearNamedFramebufferfv(opengl_main_fbo, GL_COLOR, 0, clear_color0.ptr);
    glClearNamedFramebufferfv(opengl_main_fbo, GL_DEPTH, 0, &clear_depth);
    glBindFramebuffer(GL_FRAMEBUFFER, opengl_main_fbo);

    glViewport(0, 0, platform_screen_width, platform_screen_height);

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
}

version (D_BetterC) {
// https://github.com/dlang/dmd/blob/master/druntime/src/rt/memset.d
extern(C) float *_memsetFloat(float *p, float value, size_t count)
{
    float *pstart = p;
    float *ptop;

    for (ptop = &p[count]; p < ptop; p++)
        *p = value;
    return pstart;
}
}
