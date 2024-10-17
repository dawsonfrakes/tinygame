version (D_BetterC) {} else pragma(msg, "warning: -betterC recommended");

alias Alias(T) = T;
alias Alias(alias a) = a;
alias AliasSeq(T...) = T;
template Procedure(RT, string name_, Args...) {
    alias ReturnType = RT;
    alias name = name_;
    alias ArgTypes = Args;
}
T min(T, U)(T x, U y) => x < y ? x : y;
T max(T, U)(T x, U y) => x > y ? x : y;

// kernel32
struct HINSTANCE__; alias HINSTANCE = HINSTANCE__*;
alias HMODULE = HINSTANCE;
alias PROC = extern(Windows) ptrdiff_t function();

alias kernel32 = AliasSeq!(
    Procedure!(HMODULE, "GetModuleHandleW", const(wchar)*),
    Procedure!(HMODULE, "LoadLibraryW", const(wchar)*),
    Procedure!(PROC, "GetProcAddress", HMODULE, const(char)*),
    Procedure!(void, "Sleep", uint),
    Procedure!(noreturn, "ExitProcess", uint),
);

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
enum WM_MOUSEWHEEL = 0x020A;
enum WHEEL_DELTA = 120;
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

alias user32 = AliasSeq!(
    Procedure!(int, "SetProcessDPIAware"),
    Procedure!(HICON, "LoadIconW", HINSTANCE, const(wchar)*),
    Procedure!(HCURSOR, "LoadCursorW", HINSTANCE, const(wchar)*),
    Procedure!(ushort, "RegisterClassExW", const(WNDCLASSEXW)*),
    Procedure!(HWND, "CreateWindowExW", uint, const(wchar)*, const(wchar)*, uint, int, int, int, int, HWND, HMENU, HINSTANCE, void*),
    Procedure!(int, "PeekMessageW", MSG*, HWND, uint, uint, uint),
    Procedure!(int, "TranslateMessage", const(MSG)*),
    Procedure!(ptrdiff_t, "DispatchMessageW", const(MSG)*),
    Procedure!(HDC, "GetDC", HWND),
    Procedure!(int, "ValidateRect", HWND, const(RECT)*),
    Procedure!(int, "DestroyWindow", HWND),
    Procedure!(ptrdiff_t, "GetWindowLongPtrW", HWND, int),
    Procedure!(ptrdiff_t, "SetWindowLongPtrW", HWND, int, ptrdiff_t),
    Procedure!(int, "GetWindowPlacement", HWND, WINDOWPLACEMENT*),
    Procedure!(int, "SetWindowPlacement", HWND, const(WINDOWPLACEMENT)*),
    Procedure!(int, "SetWindowPos", HWND, HWND, int, int, int, int, uint),
    Procedure!(HMONITOR, "MonitorFromWindow", HWND, uint),
    Procedure!(int, "GetMonitorInfoW", HMONITOR, MONITORINFO*),
    Procedure!(ptrdiff_t, "DefWindowProcW", HWND, uint, size_t, ptrdiff_t),
    Procedure!(void, "PostQuitMessage", int),
);

// gdi32
enum PFD_DOUBLEBUFFER = 0x00000001;
enum PFD_DRAW_TO_WINDOW = 0x00000004;
enum PFD_SUPPORT_OPENGL = 0x00000020;
enum PFD_DEPTH_DONTCARE = 0x20000000;

struct PIXELFORMATDESCRIPTOR {
    ushort nSize;
    ushort nVersion;
    uint dwFlags;
    byte iPixelType;
    byte cColorBits;
    byte cRedBits;
    byte cRedShift;
    byte cGreenBits;
    byte cGreenShift;
    byte cBlueBits;
    byte cBlueShift;
    byte cAlphaBits;
    byte cAlphaShift;
    byte cAccumBits;
    byte cAccumRedBits;
    byte cAccumGreenBits;
    byte cAccumBlueBits;
    byte cAccumAlphaBits;
    byte cDepthBits;
    byte cStencilBits;
    byte cAuxBuffers;
    byte iLayerType;
    byte bReserved;
    uint dwLayerMask;
    uint dwVisibleMask;
    uint dwDamageMask;
}

alias gdi32 = AliasSeq!(
    Procedure!(int, "ChoosePixelFormat", HDC, const(PIXELFORMATDESCRIPTOR)*),
    Procedure!(int, "SetPixelFormat", HDC, int, const(PIXELFORMATDESCRIPTOR)*),
    Procedure!(int, "SwapBuffers", HDC),
);

// opengl32
enum WGL_CONTEXT_MAJOR_VERSION_ARB = 0x2091;
enum WGL_CONTEXT_MINOR_VERSION_ARB = 0x2092;
enum WGL_CONTEXT_FLAGS_ARB = 0x2094;
enum WGL_CONTEXT_PROFILE_MASK_ARB = 0x9126;
enum WGL_CONTEXT_DEBUG_BIT_ARB = 0x0001;
enum WGL_CONTEXT_CORE_PROFILE_BIT_ARB = 0x00000001;

struct HGLRC__; alias HGLRC = HGLRC__*;
alias PFN_wglCreateContextAttribsARB = extern(Windows) HGLRC function(HDC, HGLRC, const(int)*);

alias opengl32 = AliasSeq!(
    Procedure!(HGLRC, "wglCreateContext", HDC),
    Procedure!(int, "wglDeleteContext", HGLRC),
    Procedure!(int, "wglMakeCurrent", HDC, HGLRC),
    Procedure!(PROC, "wglGetProcAddress", const(char)*),
);

// dwmapi
enum DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
enum DWMWA_WINDOW_CORNER_PREFERENCE = 33;
enum DWMWCP_DONOTROUND = 1;

alias dwmapi = AliasSeq!(
    Procedure!(int, "DwmSetWindowAttribute", HWND, uint, const(void)*, uint),
);

// winmm
enum TIMERR_NOERROR = 0;

alias winmm = AliasSeq!(
    Procedure!(uint, "timeBeginPeriod", uint),
);

// steam_api64
struct ISteamUser__; alias ISteamUser = ISteamUser__*;
struct ISteamUtils__; alias ISteamUtils = ISteamUtils__*;
struct ISteamFriends__; alias ISteamFriends = ISteamFriends__*;
enum SteamAPIInitResult {
    ok,
    failed_generic,
    no_steam_client,
    version_mismatch,
}
enum SteamAPIFriendFlags {
    none = 0x00,
    blocked = 0x01,
    friendship_requested = 0x02,
    immediate = 0x04,
    clan_member = 0x08,
    on_game_server = 0x10,
    requesting_friendship = 0x80,
    requesting_info = 0x100,
    ignored = 0x200,
    ignored_friend = 0x400,
    chat_member = 0x1000,
    all = 0xFFFF,
}

alias steam_api64 = AliasSeq!(
    Procedure!(SteamAPIInitResult, "SteamAPI_InitFlat", const(char)[1024]*),
    Procedure!(void, "SteamAPI_RunCallbacks"),
    Procedure!(ISteamUser, "SteamAPI_SteamUser_v023"),
    Procedure!(ulong, "SteamAPI_ISteamUser_GetSteamID", ISteamUser),
    Procedure!(ISteamUtils, "SteamAPI_SteamUtils_v010"),
    Procedure!(bool, "SteamAPI_ISteamUtils_GetImageRGBA", ISteamUtils, int, ubyte*, int),
    Procedure!(ISteamFriends, "SteamAPI_SteamFriends_v017"),
    Procedure!(int, "SteamAPI_ISteamFriends_GetFriendCount", ISteamFriends, int),
    Procedure!(ulong, "SteamAPI_ISteamFriends_GetFriendByIndex", ISteamFriends, int, int),
    Procedure!(int, "SteamAPI_ISteamFriends_GetMediumFriendAvatar", ISteamFriends, ulong),
    Procedure!(const(char)*, "SteamAPI_ISteamFriends_GetPersonaName", ISteamFriends),
    Procedure!(void, "SteamAPI_Shutdown"),
);

// gl10
enum GL_COLOR_BUFFER_BIT = 0x00004000;
enum GL_TRIANGLES = 0x0004;
enum GL_TEXTURE_2D = 0x0DE1;
enum GL_BYTE = 0x1400;
enum GL_UNSIGNED_BYTE = 0x1401;
enum GL_SHORT = 0x1402;
enum GL_UNSIGNED_SHORT = 0x1403;
enum GL_INT = 0x1404;
enum GL_UNSIGNED_INT = 0x1405;
enum GL_FLOAT = 0x1406;
enum GL_RGBA = 0x1908;
enum GL_NEAREST = 0x2600;
enum GL_LINEAR = 0x2601;
enum GL_TEXTURE_MIN_FILTER = 0x2801;
enum GL_TEXTURE_WRAP_S = 0x2802;
enum GL_TEXTURE_WRAP_T = 0x2803;

alias gl10 = AliasSeq!(
    Procedure!(void, "glEnable", uint),
    Procedure!(void, "glDisable", uint),
    Procedure!(void, "glViewport", int, int, uint, uint),
    Procedure!(void, "glClearColor", float, float, float, float),
    Procedure!(void, "glClear", uint),
);

// gl11
enum GL_RGBA8 = 0x8058;

// gl12
enum GL_CLAMP_TO_EDGE = 0x812F;

// gl15
enum GL_STREAM_DRAW = 0x88E0;
enum GL_STATIC_DRAW = 0x88E4;

// gl20
enum GL_FRAGMENT_SHADER = 0x8B30;
enum GL_VERTEX_SHADER = 0x8B31;
enum GL_LOWER_LEFT = 0x8CA1;

alias gl20 = AliasSeq!(
    Procedure!(uint, "glCreateProgram"),
    Procedure!(void, "glAttachShader", uint, uint),
    Procedure!(void, "glDetachShader", uint, uint),
    Procedure!(void, "glLinkProgram", uint),
    Procedure!(void, "glUseProgram", uint),
    Procedure!(uint, "glCreateShader", uint),
    Procedure!(void, "glDeleteShader", uint),
    Procedure!(void, "glShaderSource", uint, uint, const(char*)*, const(int)*),
    Procedure!(void, "glCompileShader", uint),
);

// gl30
enum GL_FRAMEBUFFER_SRGB = 0x8DB9;

alias gl30 = AliasSeq!(
    Procedure!(void, "glBindFramebuffer", uint, uint),
    Procedure!(void, "glBindVertexArray", uint),
);

// gl42
alias gl42 = AliasSeq!(
    Procedure!(void, "glDrawElementsInstancedBaseVertexBaseInstance", uint, uint, uint, const(void)*, uint, int, uint),
);

// gl45
enum GL_ZERO_TO_ONE = 0x935F;

alias gl45 = AliasSeq!(
    Procedure!(void, "glClipControl", uint, uint),
    Procedure!(void, "glCreateVertexArrays", uint, uint*),
    Procedure!(void, "glVertexArrayElementBuffer", uint, uint),
    Procedure!(void, "glVertexArrayVertexBuffer", uint, uint, uint, ptrdiff_t, uint),
    Procedure!(void, "glVertexArrayBindingDivisor", uint, uint, uint),
    Procedure!(void, "glEnableVertexArrayAttrib", uint, uint),
    Procedure!(void, "glVertexArrayAttribBinding", uint, uint, uint),
    Procedure!(void, "glVertexArrayAttribFormat", uint, uint, int, uint, bool, uint),
    Procedure!(void, "glVertexArrayAttribIFormat", uint, uint, int, uint, uint),
    Procedure!(void, "glCreateBuffers", uint, uint*),
    Procedure!(void, "glNamedBufferData", uint, size_t, const(void)*, uint),
    Procedure!(void, "glCreateTextures", uint, uint, uint*),
    Procedure!(void, "glTextureStorage2D", uint, uint, uint, uint, uint),
    Procedure!(void, "glTextureSubImage2D", uint, int, int, int, uint, uint, uint, uint, const(void)*),
    Procedure!(void, "glTextureParameteri", uint, uint, int),
    Procedure!(void, "glBindTextureUnit", uint, uint),
);

struct OpenGLRenderer {
    enum gl_type(T) = {
        final switch (T.sizeof) {
            case 1: return __traits(isUnsigned, T) ? GL_UNSIGNED_BYTE : GL_BYTE;
            case 2: return __traits(isUnsigned, T) ? GL_UNSIGNED_SHORT : GL_SHORT;
            case 4: return __traits(isUnsigned, T) ? GL_UNSIGNED_INT : GL_INT;
        }
    }();

    version (Windows) {
        static foreach (proc; AliasSeq!(gl10, gl20, gl30, gl42, gl45)) {
            mixin("alias ReturnType_" ~ proc.name ~ " = " ~ proc.ReturnType.stringof ~ ";");
            mixin("__gshared extern(System) ReturnType_" ~ proc.name ~ " function" ~ proc.ArgTypes.stringof ~ " " ~ proc.name ~ ";");
        }

        __gshared HGLRC ctx = null;

        static void platform_init() {
            HMODULE dll = LoadLibraryW("opengl32"w.ptr);
            static foreach (proc; gl10) {
                mixin(proc.name ~ " = cast(typeof(" ~ proc.name ~ ")) GetProcAddress(dll, \"" ~ proc.name ~ "\");");
            }

            PIXELFORMATDESCRIPTOR pfd;
            pfd.nSize = PIXELFORMATDESCRIPTOR.sizeof;
            pfd.nVersion = 1;
            pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL |
                PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
            pfd.cColorBits = 24;
            int format = ChoosePixelFormat(platform_hdc, &pfd);
            SetPixelFormat(platform_hdc, format, &pfd);

            HGLRC temp_ctx = wglCreateContext(platform_hdc);
            wglMakeCurrent(platform_hdc, temp_ctx);

            auto wglCreateContextAttribsARB =
                cast(PFN_wglCreateContextAttribsARB)
                wglGetProcAddress("wglCreateContextAttribsARB");

            immutable int[9] attribs = [
                WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
                WGL_CONTEXT_MINOR_VERSION_ARB, 6,
                WGL_CONTEXT_FLAGS_ARB, DEVELOPER ? WGL_CONTEXT_DEBUG_BIT_ARB : 0,
                WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
                0,
            ];
            ctx = wglCreateContextAttribsARB(platform_hdc, null, attribs.ptr);
            wglMakeCurrent(platform_hdc, ctx);

            wglDeleteContext(temp_ctx);

            static foreach (proc; AliasSeq!(gl20, gl30, gl42, gl45)) {
                mixin(proc.name ~ " = cast(typeof(" ~ proc.name ~ ")) wglGetProcAddress(\"" ~ proc.name ~ "\");");
            }
        }

        static void platform_deinit() {
            if (ctx) wglDeleteContext(ctx);
            ctx = null;
        }

        static void platform_present() {
            SwapBuffers(platform_hdc);
        }
    }

    struct OpenGLRectMesh {
        alias Element = ubyte;

        struct Vertex {
            float[3] position;
        }

        struct Instance {
            uint texture_index;
            uint texture_offset;
        }

        uint vao;
        uint ibo;
        uint shader;
    }

    static immutable OpenGLRectMesh.Element[6] indices = [0, 1, 2, 2, 3, 0];
    static immutable OpenGLRectMesh.Vertex[4] vertices = [
        {[-0.5, -0.5, 0.0]},
        {[+0.5, -0.5, 0.0]},
        {[+0.5, +0.5, 0.0]},
        {[-0.5, +0.5, 0.0]},
    ];

    __gshared OpenGLRectMesh rect_mesh = void;

    static void init() {
        platform_init();

        glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE);

        glEnable(GL_FRAMEBUFFER_SRGB);

        uint ebo = void;
        glCreateBuffers(1, &ebo);
        glNamedBufferData(ebo, indices.sizeof, indices.ptr, GL_STATIC_DRAW);
        uint vbo = void;
        glCreateBuffers(1, &vbo);
        glNamedBufferData(vbo, vertices.sizeof, vertices.ptr, GL_STATIC_DRAW);
        uint ibo = void;
        glCreateBuffers(1, &ibo);

        rect_mesh.ibo = ibo;

        uint vao = void;
        glCreateVertexArrays(1, &vao);
        glVertexArrayElementBuffer(vao, ebo);
        uint vbo_binding = 0;
        glVertexArrayVertexBuffer(vao, vbo_binding, vbo, 0, OpenGLRectMesh.Vertex.sizeof);
        uint ibo_binding = 1;
        glVertexArrayVertexBuffer(vao, ibo_binding, ibo, 0, OpenGLRectMesh.Instance.sizeof);
        glVertexArrayBindingDivisor(vao, ibo_binding, 1);

        uint position_attrib = 0;
        glEnableVertexArrayAttrib(vao, position_attrib);
        glVertexArrayAttribBinding(vao, position_attrib, vbo_binding);
        glVertexArrayAttribFormat(vao, position_attrib, 3, GL_FLOAT, false, OpenGLRectMesh.Vertex.position.offsetof);

        uint texture_index_attrib = 1;
        glEnableVertexArrayAttrib(vao, texture_index_attrib);
        glVertexArrayAttribBinding(vao, texture_index_attrib, ibo_binding);
        glVertexArrayAttribIFormat(vao, texture_index_attrib, 1, GL_UNSIGNED_INT, OpenGLRectMesh.Instance.texture_index.offsetof);

        uint texture_offset_attrib = 2;
        glEnableVertexArrayAttrib(vao, texture_offset_attrib);
        glVertexArrayAttribBinding(vao, texture_offset_attrib, ibo_binding);
        glVertexArrayAttribIFormat(vao, texture_offset_attrib, 1, GL_UNSIGNED_INT, OpenGLRectMesh.Instance.texture_offset.offsetof);

        rect_mesh.vao = vao;

        uint texture = void;
        enum texture_dim = 512;
        glCreateTextures(GL_TEXTURE_2D, 1, &texture);
        glTextureStorage2D(texture, 1, GL_RGBA8, texture_dim, texture_dim);
        glTextureParameteri(texture, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTextureParameteri(texture, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTextureParameteri(texture, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glBindTextureUnit(0, texture);

        enum avatar_dim = 64;
        enum avatar_per_dim = texture_dim / avatar_dim;
        if (platform_steam_enabled) {
            steam_friend_count = steam_friends.SteamAPI_ISteamFriends_GetFriendCount(SteamAPIFriendFlags.all);
            if (steam_friend_count > 0) {
                __gshared ubyte[avatar_dim * avatar_dim * 4] steam_temp_avatar_data = void;

                int i = 0;
                outer: foreach (row; 0..avatar_per_dim) {
                    foreach (col; 0..avatar_per_dim) {
                        ulong friend_id = steam_friends.SteamAPI_ISteamFriends_GetFriendByIndex(i, SteamAPIFriendFlags.all);
                        int avatar = steam_friends.SteamAPI_ISteamFriends_GetMediumFriendAvatar(friend_id);
                        steam_utils.SteamAPI_ISteamUtils_GetImageRGBA(avatar, steam_temp_avatar_data.ptr, steam_temp_avatar_data.sizeof);
                        glTextureSubImage2D(texture, 0, col * avatar_dim, row * avatar_dim, 64, 64, GL_RGBA, GL_UNSIGNED_BYTE, steam_temp_avatar_data.ptr);
                        if (i == steam_friend_count) break outer;
                        i += 1;
                    }
                }
            }
        }

        string vsrc =
        "#version 450

        layout(location = 0) in vec3 a_position;
        layout(location = 1) in uint i_texture_index;
        layout(location = 2) in uint i_texture_offset;

        layout(location = 0) out vec2 f_texcoord;
        layout(location = 1) out uint f_texture_index;

        vec2[] g_texcoords = vec2[](
            vec2(0.0, 1.0 / " ~ avatar_per_dim.stringof ~ "),
            vec2(1.0 / " ~ avatar_per_dim.stringof ~ ", 1.0 / " ~ avatar_per_dim.stringof ~ "),
            vec2(1.0 / " ~ avatar_per_dim.stringof ~ ", 0.0),
            vec2(0.0, 0.0)
        );

        void main() {
            gl_Position = vec4(a_position, 1.0);

            uint row = i_texture_offset / " ~ avatar_per_dim.stringof ~ ";
            uint col = i_texture_offset % " ~ avatar_per_dim.stringof ~ ";
            vec2 texcoord = g_texcoords[gl_VertexID];
            texcoord.x += col / " ~ avatar_per_dim.stringof ~ ".0;
            texcoord.y += row / " ~ avatar_per_dim.stringof ~ ".0;

            f_texcoord = texcoord;
            f_texture_index = i_texture_index;
        }
        ";
        uint vshader = glCreateShader(GL_VERTEX_SHADER);
        immutable(char*)[1] vsrcs = [vsrc.ptr];
        glShaderSource(vshader, 1, vsrcs.ptr, null);
        glCompileShader(vshader);

        string fsrc =
        "#version 450

        layout(location = 0) in vec2 f_texcoord;
        layout(location = 1) flat in uint f_texture_index;

        layout(location = 0) out vec4 color;

        layout(location = 0) uniform sampler2D u_textures[32];

        void main() {
            color = texture(u_textures[f_texture_index], f_texcoord);
        }
        ";
        uint fshader = glCreateShader(GL_FRAGMENT_SHADER);
        immutable(char*)[1] fsrcs = [fsrc.ptr];
        glShaderSource(fshader, 1, fsrcs.ptr, null);
        glCompileShader(fshader);

        uint program = glCreateProgram();
        glAttachShader(program, vshader);
        glAttachShader(program, fshader);
        glLinkProgram(program);
        glDetachShader(program, fshader);
        glDetachShader(program, vshader);

        glDeleteShader(fshader);
        glDeleteShader(vshader);

        rect_mesh.shader = program;
    }

    static void deinit() {
        platform_deinit();
    }

    static void resize() {

    }

    static void present() {
        glViewport(0, 0, platform_screen_width, platform_screen_height);
        glClearColor(0.6, 0.2, 0.2, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);

        steam_friend_index_selected = steam_friend_index_selected.min(steam_friend_count - 1).max(0);
        OpenGLRectMesh.Instance[1] instances = [{
            texture_offset: steam_friend_index_selected,
        }];
        glNamedBufferData(rect_mesh.ibo, instances.sizeof, instances.ptr, GL_STREAM_DRAW);

        glUseProgram(rect_mesh.shader);
        glBindVertexArray(rect_mesh.vao);
        glDrawElementsInstancedBaseVertexBaseInstance(GL_TRIANGLES,
            indices.length, gl_type!(OpenGLRectMesh.Element), cast(void*) 0,
            instances.length, 0, 0);

        platform_present();
    }
}

version (Windows) {
    enum DEVELOPER = true;
    alias Renderer = OpenGLRenderer;

    static foreach (proc; kernel32) {
        mixin("alias ReturnType_" ~ proc.name ~ " = " ~ proc.ReturnType.stringof ~ ";");
        mixin("extern extern(Windows) ReturnType_" ~ proc.name ~ " " ~ proc.name ~ proc.ArgTypes.stringof ~ ";");
    }

    enum dynamic_procedure_modules = ["user32", "gdi32", "opengl32", "dwmapi", "winmm"];
    static foreach (lib; dynamic_procedure_modules) {
        static foreach (proc; mixin(lib)) {
            mixin("alias ReturnType_" ~ proc.name ~ " = " ~ proc.ReturnType.stringof ~ ";");
            mixin("__gshared extern(Windows) ReturnType_" ~ proc.name ~ " function" ~ proc.ArgTypes.stringof ~ " " ~ proc.name ~ ";");
        }
    }

    static foreach (proc; steam_api64) {
        mixin("alias ReturnType_" ~ proc.name ~ " = " ~ proc.ReturnType.stringof ~ ";");
        mixin("__gshared extern(C) ReturnType_" ~ proc.name ~ " function" ~ proc.ArgTypes.stringof ~ " " ~ proc.name ~ ";");
    }

    __gshared ushort platform_screen_width = void;
    __gshared ushort platform_screen_height = void;

    __gshared bool platform_steam_enabled = false;
    __gshared ISteamUser steam_user = void;
    __gshared ISteamUtils steam_utils = void;
    __gshared ISteamFriends steam_friends = void;
    __gshared ulong steam_id = void;
    __gshared const(char)* steam_name = void;
    __gshared int steam_friend_count = 0;
    __gshared int steam_friend_index_selected = 0;

    __gshared HINSTANCE platform_hinstance = void;
    __gshared HWND platform_hwnd = void;
    __gshared HDC platform_hdc = void;

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

    void update_cursor_clip() {

    }

    void clear_held_keys() {

    }

    extern(Windows) noreturn WinMainCRTStartup() {
        HMODULE dll = void;
        static foreach (lib; dynamic_procedure_modules ~ ["steam_api64"]) {
            mixin("dll = LoadLibraryW(\"" ~ lib ~ "\"w.ptr);");
            static foreach (proc; mixin(lib)) {
                mixin(proc.name ~ " = cast(typeof(" ~ proc.name ~ ")) GetProcAddress(dll, \"" ~ proc.name ~ "\");");
            }
        }

        platform_steam_enabled = SteamAPI_InitFlat && SteamAPI_InitFlat(null) == SteamAPIInitResult.ok;

        if (platform_steam_enabled) {
            steam_user = SteamAPI_SteamUser_v023();
            steam_utils = SteamAPI_SteamUtils_v010();
            steam_friends = SteamAPI_SteamFriends_v017();

            steam_id = steam_user.SteamAPI_ISteamUser_GetSteamID();
            steam_name = steam_friends.SteamAPI_ISteamFriends_GetPersonaName();
        }

        platform_hinstance = GetModuleHandleW(null);

        bool sleep_is_granular = timeBeginPeriod && timeBeginPeriod(1) == TIMERR_NOERROR;

        SetProcessDPIAware();
        WNDCLASSEXW wndclass;
        wndclass.cbSize = WNDCLASSEXW.sizeof;
        wndclass.style = CS_OWNDC;
        wndclass.lpfnWndProc = (hwnd, message, wParam, lParam) {
            switch (message) {
                case WM_PAINT:
                    ValidateRect(hwnd, null);
                    return 0;
                case WM_ERASEBKGND:
                    return 1;
                case WM_ACTIVATEAPP:
                    if (wParam != 0) update_cursor_clip();
                    else clear_held_keys();
                    return 0;
                case WM_SYSCOMMAND:
                    if (wParam == SC_KEYMENU) return 0;
                    goto default;
                case WM_SIZE:
                    platform_screen_width = cast(ushort) cast(size_t) lParam;
                    platform_screen_height = cast(ushort) (cast(size_t) lParam >> 16);

                    Renderer.resize();
                    return 0;
                case WM_CREATE:
                    platform_hwnd = hwnd;
                    platform_hdc = GetDC(hwnd);

                    if (DwmSetWindowAttribute) {
                        int dark_mode = true;
                        DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, dark_mode.sizeof);
                        int round_mode = DWMWCP_DONOTROUND;
                        DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, round_mode.sizeof);
                    }

                    Renderer.init();
                    return 0;
                case WM_DESTROY:
                    Renderer.deinit();

                    PostQuitMessage(0);
                    return 0;
                default:
                    return DefWindowProcW(hwnd, message, wParam, lParam);
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

        game_loop: while (true) {
            MSG msg = void;
            while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE)) {
                TranslateMessage(&msg);
                with (msg) switch (message) {
                    case WM_KEYDOWN:
                    case WM_KEYUP:
                    case WM_SYSKEYDOWN:
                    case WM_SYSKEYUP:
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
                        goto default;
                    case WM_MOUSEWHEEL:
                        short delta = cast(short) (wParam >> 16);
                        short physical_delta = delta / WHEEL_DELTA;

                        steam_friend_index_selected -= physical_delta;
                        break;
                    case WM_QUIT:
                        break game_loop;
                    default:
                        DispatchMessageW(&msg);
                }
            }

            if (platform_steam_enabled) SteamAPI_RunCallbacks();

            Renderer.present();

            if (sleep_is_granular) {
                Sleep(1);
            }
        }

        if (platform_steam_enabled) SteamAPI_Shutdown();
        ExitProcess(0);
    }

    extern(C) int _fltused = void;

    pragma(linkerDirective, "-subsystem:windows");
    pragma(lib, "kernel32");
}
