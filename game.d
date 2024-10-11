enum DEVELOPER = true;
version = OpenGL;

version (D_BetterC) {} else pragma(msg, "warning: -betterC recommended");

alias AliasSeq(TList...) = TList;
enum FnsToFnPtrs(T) = {
    string result;
    static foreach (name; __traits(allMembers, T)) {{
        alias Fn = typeof(__traits(getMember, T, name));
        result ~= "__gshared " ~ (Fn*).stringof ~ " " ~ name ~ ";\n";
    }}
    return result;
}();

version (Windows) {
    // kernel32
    struct HINSTANCE__; alias HINSTANCE = HINSTANCE__*;
    alias HMODULE = HINSTANCE;
    alias PROC = extern(Windows) ptrdiff_t function();

    extern extern(Windows) HMODULE GetModuleHandleW(const(wchar)*);
    extern extern(Windows) void Sleep(uint);
    extern extern(Windows) noreturn ExitProcess(uint);

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
    alias WNDPROC = extern(Windows) ptrdiff_t function(HWND, uint, size_t, ptrdiff_t);
    struct POINT {
        int x;
        int y;
    }
    struct RECT {
        int left;
        int top;
        int right;
        int bottom;
    }
    struct WNDCLASSEXW {
        uint cbSize;
        uint style;
        WNDPROC lpfnWndProc;
        int cbClsExtra;
        int cbWndExtra;
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
        uint message;
        size_t wParam;
        ptrdiff_t lParam;
        uint time;
        POINT pt;
        uint lPrivate;
    }
    struct WINDOWPLACEMENT {
        uint length;
        uint flags;
        uint showCmd;
        POINT ptMinPosition;
        POINT ptMaxPosition;
        RECT rcNormalPosition;
        RECT rcDevice;
    }
    struct MONITORINFO {
        uint cbSize;
        RECT rcMonitor;
        RECT rcWork;
        uint dwFlags;
    }

    extern extern(Windows) int SetProcessDPIAware();
    extern extern(Windows) HICON LoadIconW(HINSTANCE, const(wchar)*);
    extern extern(Windows) HCURSOR LoadCursorW(HINSTANCE, const(wchar)*);
    extern extern(Windows) ushort RegisterClassExW(const(WNDCLASSEXW)*);
    extern extern(Windows) HWND CreateWindowExW(uint, const(wchar)*, const(wchar)*, uint, int, int, int, int, HWND, HMENU, HINSTANCE, void*);
    extern extern(Windows) int PeekMessageW(MSG*, HWND, uint, uint, uint);
    extern extern(Windows) int TranslateMessage(const(MSG)*);
    extern extern(Windows) ptrdiff_t DispatchMessageW(const(MSG)*);
    extern extern(Windows) HDC GetDC(HWND);
    extern extern(Windows) int ValidateRect(HWND, const(RECT)*);
    extern extern(Windows) int DestroyWindow(HWND);
    extern extern(Windows) ptrdiff_t DefWindowProcW(HWND, uint, size_t, ptrdiff_t);
    extern extern(Windows) void PostQuitMessage(int);
    extern extern(Windows) long GetWindowLongPtrW(HWND, int);
    extern extern(Windows) long SetWindowLongPtrW(HWND, int, long);
    extern extern(Windows) int GetWindowPlacement(HWND, WINDOWPLACEMENT*);
    extern extern(Windows) int SetWindowPlacement(HWND, const(WINDOWPLACEMENT)*);
    extern extern(Windows) int SetWindowPos(HWND, HWND, int, int, int, int, uint);
    extern extern(Windows) HMONITOR MonitorFromWindow(HWND, uint);
    extern extern(Windows) int GetMonitorInfoW(HMONITOR, MONITORINFO*);

    // gdi32
    enum PFD_DOUBLEBUFFER = 0x00000001;
    enum PFD_DRAW_TO_WINDOW = 0x00000004;
    enum PFD_SUPPORT_OPENGL = 0x00000020;
    enum PFD_DEPTH_DONTCARE = 0x20000000;

    struct PIXELFORMATDESCRIPTOR {
        ushort nSize;
        ushort nVersion;
        uint dwFlags;
        ubyte iPixelType;
        ubyte cColorBits;
        ubyte cRedBits;
        ubyte cRedShift;
        ubyte cGreenBits;
        ubyte cGreenShift;
        ubyte cBlueBits;
        ubyte cBlueShift;
        ubyte cAlphaBits;
        ubyte cAlphaShift;
        ubyte cAccumBits;
        ubyte cAccumRedBits;
        ubyte cAccumGreenBits;
        ubyte cAccumBlueBits;
        ubyte cAccumAlphaBits;
        ubyte cDepthBits;
        ubyte cStencilBits;
        ubyte cAuxBuffers;
        ubyte iLayerType;
        ubyte bReserved;
        uint dwLayerMask;
        uint dwVisibleMask;
        uint dwDamageMask;
    }

    extern extern(Windows) int ChoosePixelFormat(HDC, const(PIXELFORMATDESCRIPTOR)*);
    extern extern(Windows) int SetPixelFormat(HDC, int, const(PIXELFORMATDESCRIPTOR)*);
    extern extern(Windows) int SwapBuffers(HDC);

    // opengl32
    struct HGLRC__; alias HGLRC = HGLRC__*;

    extern extern(Windows) HGLRC wglCreateContext(HDC);
    extern extern(Windows) int wglDeleteContext(HGLRC);
    extern extern(Windows) int wglMakeCurrent(HDC, HGLRC);
    extern extern(Windows) PROC wglGetProcAddress(const(char)*);

    // dwmapi
    enum DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
    enum DWMWA_WINDOW_CORNER_PREFERENCE = 33;
    enum DWMWCP_DONOTROUND = 1;

    extern extern(Windows) uint DwmSetWindowAttribute(HWND, uint, const(void)*, uint);

    // winmm
    extern extern(Windows) uint timeBeginPeriod(uint);
}

version (OpenGL) {
    // 1.0
    enum GL_COLOR_BUFFER_BIT = 0x00004000;
    enum GL_TRIANGLES = 0x0004;
    enum GL_UNSIGNED_BYTE = 0x1401;
    enum GL_FLOAT = 0x1406;

    extern extern(System) void glEnable(uint);
    extern extern(System) void glDisable(uint);
    extern extern(System) void glGetIntegerv(uint, int*);
    extern extern(System) void glDepthFunc(uint);
    extern extern(System) void glBlendFunc(uint, uint);
    extern extern(System) void glViewport(int, int, uint, uint);
    extern extern(System) void glClearColor(float, float, float, float);
    extern extern(System) void glClear(uint);

    // 1.1
    extern extern(System) void glDrawArrays(uint, int, uint);
    extern extern(System) void glDrawElements(uint, uint, uint, const(void)*);

    // 1.5
    enum GL_STATIC_DRAW = 0x88E4;

    // 2.0
    enum GL_FRAGMENT_SHADER = 0x8B30;
    enum GL_VERTEX_SHADER = 0x8B31;
    enum GL_LOWER_LEFT = 0x8CA1;

    struct GL20 {
        extern extern(System) uint glCreateProgram();
        extern extern(System) void glAttachShader(uint, uint);
        extern extern(System) void glDetachShader(uint, uint);
        extern extern(System) void glLinkProgram(uint);
        extern extern(System) void glUseProgram(uint);
        extern extern(System) uint glCreateShader(uint);
        extern extern(System) void glDeleteShader(uint);
        extern extern(System) void glShaderSource(uint, uint, const(char*)*, const(int)*);
        extern extern(System) void glCompileShader(uint);
    }

    // 3.0
    enum GL_FRAMEBUFFER_SRGB = 0x8DB9;

    struct GL30 {
        extern extern(System) void glBindFramebuffer(uint, uint);
        extern extern(System) void glBindVertexArray(uint);
    }

    // 4.5
    enum GL_ZERO_TO_ONE = 0x935F;

    struct GL45 {
        extern extern(System) void glClipControl(uint, uint);
        extern extern(System) void glCreateVertexArrays(uint, uint*);
        extern extern(System) void glVertexArrayElementBuffer(uint, uint);
        extern extern(System) void glVertexArrayVertexBuffer(uint, uint, uint, int, uint);
        extern extern(System) void glEnableVertexArrayAttrib(uint, uint);
        extern extern(System) void glVertexArrayAttribBinding(uint, uint, uint);
        extern extern(System) void glVertexArrayAttribFormat(uint, uint, int, uint, bool, uint);
        extern extern(System) void glCreateBuffers(uint, uint*);
        extern extern(System) void glNamedBufferData(uint, size_t, const(void)*, uint);
        extern extern(System) void glProgramUniformMatrix4fv(uint, int, uint, bool, const(float)*);
    }

    // WGL_ARB_create_context
    alias PFN_wglCreateContextAttribsARB = extern(Windows) HGLRC function(HDC, HGLRC, const(int)*);

    enum WGL_CONTEXT_MAJOR_VERSION_ARB = 0x2091;
    enum WGL_CONTEXT_MINOR_VERSION_ARB = 0x2092;
    enum WGL_CONTEXT_FLAGS_ARB = 0x2094;
    enum WGL_CONTEXT_PROFILE_MASK_ARB = 0x9126;
    enum WGL_CONTEXT_DEBUG_BIT_ARB = 0x0001;
    enum WGL_CONTEXT_CORE_PROFILE_BIT_ARB = 0x00000001;
}

version (Windows) {
    version (OpenGL) {
        mixin(FnsToFnPtrs!GL20);
        mixin(FnsToFnPtrs!GL30);
        mixin(FnsToFnPtrs!GL45);
    }

    __gshared HINSTANCE platform_hinstance = void;
    __gshared HWND platform_hwnd = void;
    __gshared HDC platform_hdc = void;
    __gshared ushort platform_screen_width = void;
    __gshared ushort platform_screen_height = void;

    extern(Windows) noreturn WinMainCRTStartup() {
        void toggle_fullscreen() {
            __gshared WINDOWPLACEMENT save_placement = {WINDOWPLACEMENT.sizeof};

            uint style = cast(uint) GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
            if (style & WS_OVERLAPPEDWINDOW) {
                MONITORINFO mi = {MONITORINFO.sizeof};
                GetMonitorInfoW(MonitorFromWindow(platform_hwnd, MONITOR_DEFAULTTOPRIMARY), &mi);

                GetWindowPlacement(platform_hwnd, &save_placement);
                SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style & ~cast(uint) WS_OVERLAPPEDWINDOW);
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

        platform_hinstance = GetModuleHandleW(null);

        bool sleep_is_granular = timeBeginPeriod(1) == 0;

        SetProcessDPIAware();
        WNDCLASSEXW wndclass;
        wndclass.cbSize = WNDCLASSEXW.sizeof;
        wndclass.style = CS_OWNDC;
        wndclass.lpfnWndProc = (hwnd, message, wParam, lParam) {
            switch (message) {
                case WM_PAINT: {
                    ValidateRect(hwnd, null);
                    return 0;
                }
                case WM_ERASEBKGND: {
                    return 1;
                }
                case WM_ACTIVATEAPP: {
                    // if (wParam) update_cursor_clip();
                    // else clear_held_keys();
                    return 0;
                }
                case WM_SIZE: {
                    platform_screen_width = cast(ushort) lParam;
                    platform_screen_height = cast(ushort) (lParam >> 16);
                    return 0;
                }
                case WM_CREATE: {
                    platform_hwnd = hwnd;
                    platform_hdc = GetDC(hwnd);

                    int dark_mode = true;
                    DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, dark_mode.sizeof);
                    int round_mode = DWMWCP_DONOTROUND;
                    DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, round_mode.sizeof);

                    PIXELFORMATDESCRIPTOR pfd;
                    pfd.nSize = PIXELFORMATDESCRIPTOR.sizeof;
                    pfd.nVersion = 1;
                    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL |
                        PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
                    pfd.cColorBits = 24;
                    int format = ChoosePixelFormat(platform_hdc, &pfd);
                    SetPixelFormat(platform_hdc, format, &pfd);

                    HGLRC temp_ctx = wglCreateContext(platform_hdc);
                    scope(exit) wglDeleteContext(temp_ctx);
                    wglMakeCurrent(platform_hdc, temp_ctx);

                    PFN_wglCreateContextAttribsARB wglCreateContextAttribsARB =
                        cast(PFN_wglCreateContextAttribsARB)
                        wglGetProcAddress("wglCreateContextAttribsARB");

                    int[9] attribs = [
                        WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
                        WGL_CONTEXT_MINOR_VERSION_ARB, 6,
                        WGL_CONTEXT_FLAGS_ARB, DEVELOPER ? WGL_CONTEXT_DEBUG_BIT_ARB : 0,
                        WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
                        0,
                    ];
                    HGLRC ctx = wglCreateContextAttribsARB(platform_hdc, null, attribs.ptr);
                    wglMakeCurrent(platform_hdc, ctx);

                    static foreach (T; AliasSeq!(GL20, GL30, GL45)) {
                        static foreach (name; __traits(allMembers, T)) {
                            mixin(name ~ " = " ~ "cast(typeof(" ~ name ~ ")) wglGetProcAddress(\"" ~ name ~ "\");\n");
                        }
                    }
                    return 0;
                }
                case WM_DESTROY: {
                    PostQuitMessage(0);
                    return 0;
                }
                default: {
                    if (message == WM_SYSCOMMAND && wParam == SC_KEYMENU) return 0;
                    return DefWindowProcW(hwnd, message, wParam, lParam);
                }
            }
        };
        wndclass.hInstance = platform_hinstance;
        wndclass.hIcon = LoadIconW(null, IDI_WARNING);
        wndclass.hCursor = LoadCursorW(null, IDC_CROSS);
        wndclass.lpszClassName = "A"w.ptr;
        RegisterClassExW(&wndclass);
        CreateWindowExW(0, wndclass.lpszClassName, "Game"w.ptr,
            WS_OVERLAPPEDWINDOW | WS_VISIBLE,
            CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
            null, null, platform_hinstance, null);

        bool initted = false;
        uint vao = void;
        uint program = void;
        game_loop: while (true) {
            MSG msg = void;
            while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE)) {
                TranslateMessage(&msg);
                with (msg) switch (message) {
                    case WM_KEYDOWN:
                    case WM_KEYUP:
                    case WM_SYSKEYDOWN:
                    case WM_SYSKEYUP: {
                        bool pressed = (lParam & 1 << 31) == 0;
                        bool repeat = pressed && (lParam & 1 << 30) != 0;
                        bool sys = message == WM_SYSKEYDOWN || message == WM_SYSKEYUP;
                        bool alt = sys && (lParam & 1 << 29) != 0;

                        if (!repeat && (!sys || alt || wParam == VK_F10)) {
                            if (pressed) {
                                if (wParam == VK_F4 && alt) DestroyWindow(platform_hwnd);
                                if (wParam == VK_F11 || (wParam == VK_RETURN && alt)) toggle_fullscreen();
                                if (DEVELOPER && wParam == VK_ESCAPE) DestroyWindow(platform_hwnd);
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

            struct Vertex {
                float[3] position;
                float[4] color;
            }

            __gshared Vertex[3] vertices = [
                {[-0.5f, -0.5f, 0.0f], [1.0f, 0.0f, 0.0f, 1.0f]},
                {[ 0.5f, -0.5f, 0.0f], [0.0f, 1.0f, 0.0f, 1.0f]},
                {[ 0.0f,  0.5f, 0.0f], [0.0f, 0.0f, 1.0f, 1.0f]},
            ];
            __gshared ubyte[3] indices = [0, 1, 2];

            if (!initted) {
                initted = true;

                glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE);

                uint vbo = void;
                glCreateBuffers(1, &vbo);
                glNamedBufferData(vbo, vertices.length * Vertex.sizeof, vertices.ptr, GL_STATIC_DRAW);

                uint ebo = void;
                glCreateBuffers(1, &ebo);
                glNamedBufferData(ebo, indices.length * typeof(indices[0]).sizeof, indices.ptr, GL_STATIC_DRAW);

                glCreateVertexArrays(1, &vao);
                glVertexArrayElementBuffer(vao, ebo);
                uint vbo_binding = 0;
                glVertexArrayVertexBuffer(vao, vbo_binding, vbo, 0, Vertex.sizeof);

                uint position_attrib = 0;
                glEnableVertexArrayAttrib(vao, position_attrib);
                glVertexArrayAttribBinding(vao, position_attrib, vbo_binding);
                glVertexArrayAttribFormat(vao, position_attrib, 3, GL_FLOAT, false, Vertex.position.offsetof);

                uint color_attrib = 1;
                glEnableVertexArrayAttrib(vao, color_attrib);
                glVertexArrayAttribBinding(vao, color_attrib, vbo_binding);
                glVertexArrayAttribFormat(vao, color_attrib, 4, GL_FLOAT, false, Vertex.color.offsetof);

                string vsrc =
                    "#version 450
                    layout(location = 0) in vec3 a_position;
                    layout(location = 1) in vec4 a_color;
                    layout(location = 0) uniform mat4 u_projection;

                    out vec4 f_color;
                    void main() {
                        gl_Position = u_projection * vec4(a_position, 1.0f);
                        f_color = a_color;
                    }";
                uint vshader = glCreateShader(GL_VERTEX_SHADER);
                const(char*)[1] vsrc_arr = [vsrc.ptr];
                glShaderSource(vshader, 1, vsrc_arr.ptr, null);
                glCompileShader(vshader);

                string fsrc =
                    "#version 450
                    in vec4 f_color;
                    out vec4 color;
                    void main() {
                        color = f_color;
                    }";
                uint fshader = glCreateShader(GL_FRAGMENT_SHADER);
                const(char*)[1] fsrc_arr = [fsrc.ptr];
                glShaderSource(fshader, 1, fsrc_arr.ptr, null);
                glCompileShader(fshader);

                program = glCreateProgram();
                glAttachShader(program, vshader);
                glAttachShader(program, fshader);
                glLinkProgram(program);
                glDetachShader(program, vshader);
                glDetachShader(program, fshader);
                glDeleteShader(vshader);
                glDeleteShader(fshader);
            }

            glViewport(0, 0, platform_screen_width, platform_screen_height);
            glEnable(GL_FRAMEBUFFER_SRGB);
            glClearColor(0.6f, 0.2f, 0.2f, 1.0f);
            glClear(GL_COLOR_BUFFER_BIT);
            glBindVertexArray(vao);

            float[16] projection = 0.0f;
            projection[0 * 4 + 0] = 1.0f;
            projection[1 * 4 + 1] = 1.0f;
            projection[2 * 4 + 2] = 1.0f;
            projection[3 * 4 + 0] = 0.5f;
            projection[3 * 4 + 1] = 0.5f;
            projection[3 * 4 + 3] = 1.0f;
            uint projection_uniform = 0;
            glProgramUniformMatrix4fv(program, projection_uniform, 1, false, projection.ptr);

            glUseProgram(program);
            glDrawElements(GL_TRIANGLES, indices.length, GL_UNSIGNED_BYTE, cast(void*) 0);
            SwapBuffers(platform_hdc);

            if (sleep_is_granular) {
                Sleep(1);
            }
        }

        ExitProcess(0);
    }

    pragma(linkerDirective, "-subsystem:windows");
    pragma(lib, "kernel32");
    pragma(lib, "user32");
    pragma(lib, "gdi32");
    pragma(lib, "opengl32");
    pragma(lib, "dwmapi");
    pragma(lib, "winmm");
    extern(C) int _fltused;
}
