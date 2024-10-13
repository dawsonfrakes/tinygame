#if defined(__x86_64__) || defined(_M_AMD64)
#define TARGET_CPU_ARCH_AMD64 1
#else
#define TARGET_CPU_ARCH_AMD64 0
#endif

#if defined(_WIN32) || defined(_WIN64) || defined(__WIN32__)
#define TARGET_OS_WINDOWS 1
#else
#define TARGET_OS_WINDOWS 0
#endif

#define cast(T) (T)
#define size_of(T) sizeof(T)
#define offset_of(T, F) (cast(u64) &(cast(T*) 0)->F)
#define align_of(T) offset_of(struct { u8 x; T t; }, t)

#define min(X, Y) ((X) < (Y) ? (X) : (Y))
#define max(X, Y) ((X) > (Y) ? (X) : (Y))
#define len(X) (size_of(X) / size_of((X)[0]))
#define str(X) {len(X) - 1, (X)}

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

typedef struct {
	u64 count;
	u8* data;
} string;

typedef struct {
	f32 x;
	f32 y;
} v2;

typedef struct {
	f32 x;
	f32 y;
	f32 z;
} v3;

typedef struct {
	f32 x;
	f32 y;
	f32 z;
	f32 w;
} v4;

#if TARGET_OS_WINDOWS
// kernel32
typedef struct HINSTANCE__* HINSTANCE;
typedef s64 (*PROC)(void);

#define KERNEL32_FUNCTIONS \
	X(HINSTANCE, GetModuleHandleW, u16*) \
	X(HINSTANCE, LoadLibraryW, u16*) \
	X(PROC, GetProcAddress, HINSTANCE, u8*) \
	X(void, Sleep, u32) \
	X(void, ExitProcess, u32)

// user32
#define IDI_WARNING (cast(u16*) cast(u64) 32515)
#define IDC_CROSS (cast(u16*) cast(u64) 32515)
#define CS_OWNDC 0x0020
#define WS_CAPTION 0x00C00000
#define WS_MAXIMIZEBOX 0x00010000
#define WS_MINIMIZEBOX 0x00020000
#define WS_THICKFRAME 0x00040000
#define WS_SYSMENU 0x00080000
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
#define VK_RETURN 0x0D
#define VK_ESCAPE 0x1B
#define VK_F4 0x73
#define VK_F10 0x79
#define VK_F11 0x7A

typedef struct HDC__* HDC;
typedef struct HWND__* HWND;
typedef struct HMENU__* HMENU;
typedef struct HICON__* HICON;
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

#define USER32_FUNCTIONS \
	X(s32, SetProcessDPIAware, void) \
	X(HICON, LoadIconW, HINSTANCE, u16*) \
	X(HCURSOR, LoadCursorW, HINSTANCE, u16*) \
	X(u16, RegisterClassExW, WNDCLASSEXW*) \
	X(HWND, CreateWindowExW, u32, u16*, u16*, u32, s32, s32, s32, s32, HWND, HMENU, HINSTANCE, void*) \
	X(s32, PeekMessageW, MSG*, HWND, u32, u32, u32) \
	X(s32, TranslateMessage, MSG*) \
	X(s64, DispatchMessageW, MSG*) \
	X(HDC, GetDC, HWND) \
	X(s32, ValidateRect, HWND, RECT*) \
	X(s32, DestroyWindow, HWND) \
	X(s64, DefWindowProcW, HWND, u32, u64, s64) \
	X(void, PostQuitMessage, s32)

// gdi32
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

#define GDI32_FUNCTIONS \
	X(s32, ChoosePixelFormat, HDC, PIXELFORMATDESCRIPTOR*) \
	X(s32, SetPixelFormat, HDC, s32, PIXELFORMATDESCRIPTOR*) \
	X(s32, SwapBuffers, HDC)

// opengl32
typedef struct HGLRC__* HGLRC;

#define OPENGL32_FUNCTIONS \
	X(HGLRC, wglCreateContext, HDC) \
	X(s32, wglDeleteContext, HGLRC) \
	X(s32, wglMakeCurrent, HDC, HGLRC) \
	X(PROC, wglGetProcAddress, u8*)

// dwmapi
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#define DWMWA_WINDOW_CORNER_PREFERENCE 33
#define DWMWCP_DONOTROUND 1

#define DWMAPI_FUNCTIONS \
	X(s32, DwmSetWindowAttribute, HWND, u32, void*, u32)

// winmm
#define TIMERR_NOERROR 0

#define WINMM_FUNCTIONS \
	X(u32, timeBeginPeriod, u32)
#endif

// steam
#define k_EFriendFlagAll 0xFFFF

typedef char SteamErrMsg[1024];
typedef struct ISteamFriends__* ISteamFriends;
typedef struct ISteamUtils__* ISteamUtils;

#define STEAM_FUNCTIONS \
	X(s32, SteamAPI_InitFlat, SteamErrMsg*) \
	X(void, SteamAPI_RunCallbacks, void) \
	X(ISteamFriends, SteamAPI_SteamFriends_v017, void) \
	X(u64, SteamAPI_ISteamFriends_GetFriendByIndex, ISteamFriends, s32, s32) \
	X(s32, SteamAPI_ISteamFriends_GetFriendCount, ISteamFriends, s32) \
	X(s32, SteamAPI_ISteamFriends_GetMediumFriendAvatar, ISteamFriends, u64) \
	X(u8*, SteamAPI_ISteamFriends_GetPersonaName, ISteamFriends) \
	X(u8*, SteamAPI_ISteamFriends_GetFriendPersonaName, ISteamFriends, u64) \
	X(ISteamUtils, SteamAPI_SteamUtils_v010, void) \
	X(bool, SteamAPI_ISteamUtils_GetImageRGBA, ISteamUtils, s32, u8*, s32) \
	X(void, SteamAPI_Shutdown, void)

#if TARGET_OS_WINDOWS
#define X(RET, NAME, ...) RET NAME(__VA_ARGS__);
KERNEL32_FUNCTIONS
#undef X
#define X(RET, NAME, ...) static RET (*NAME)(__VA_ARGS__);
USER32_FUNCTIONS
GDI32_FUNCTIONS
OPENGL32_FUNCTIONS
DWMAPI_FUNCTIONS
WINMM_FUNCTIONS

STEAM_FUNCTIONS
#undef X

static u16 platform_screen_width;
static u16 platform_screen_height;
static HINSTANCE platform_hinstance;
static HWND platform_hwnd;
static HDC platform_hdc;
static bool platform_steam_enabled;

static ISteamFriends steam_friends;
static ISteamUtils steam_utils;
static u8* steam_player_name;

// 1.0
#define GL_COLOR_BUFFER_BIT 0x00004000
#define GL_TRIANGLES 0x0004
#define GL_UNSIGNED_BYTE 0x1401
#define GL_FLOAT 0x1406
#define GL_TEXTURE_2D 0x0DE1
#define GL_RGB 0x1907
#define GL_RGBA 0x1908
#define GL_LINEAR 0x2601
#define GL_TEXTURE_MIN_FILTER 0x2801

#define GL10_FUNCTIONS \
	X(void, glEnable, u32) \
	X(void, glDisable, u32) \
	X(void, glGetIntegerv, u32, s32*) \
	X(void, glDepthFunc, u32) \
	X(void, glBlendFunc, u32, u32) \
	X(void, glViewport, s32, s32, u32, u32) \
	X(void, glClearColor, f32, f32, f32, f32) \
	X(void, glClear, u32)

// 1.1
#define GL_RGB8 0x8051

#define GL11_FUNCTIONS \
	X(void, glDrawElements, u32, u32, u32, void*)

// 1.5
#define GL_STATIC_DRAW 0x88E4

// 2.0
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

// 3.0
#define GL_FRAMEBUFFER_SRGB 0x8DB9

// 3.0
#define GL30_FUNCTIONS \
	X(void, glBindFramebuffer, u32, u32) \
	X(void, glBindVertexArray, u32)

// 4.5
#define GL_ZERO_TO_ONE 0x935F

#define GL45_FUNCTIONS \
	X(void, glClipControl, u32, u32) \
	X(void, glCreateVertexArrays, u32, u32*) \
	X(void, glVertexArrayElementBuffer, u32, u32) \
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
	X(void, glBindTextureUnit, u32, u32)

// WGL_ARB_create_context
#define WGL_CONTEXT_MAJOR_VERSION_ARB 0x2091
#define WGL_CONTEXT_MINOR_VERSION_ARB 0x2092
#define WGL_CONTEXT_FLAGS_ARB 0x2094
#define WGL_CONTEXT_PROFILE_MASK_ARB 0x9126
#define WGL_CONTEXT_DEBUG_BIT_ARB 0x0001
#define WGL_CONTEXT_CORE_PROFILE_BIT_ARB 0x00000001

#define X(RET, NAME, ...) static RET (*NAME)(__VA_ARGS__);
GL10_FUNCTIONS
GL11_FUNCTIONS
GL20_FUNCTIONS
GL30_FUNCTIONS
GL45_FUNCTIONS
#undef X

static HGLRC opengl_ctx;

static void opengl_platform_init(void) {
	static PIXELFORMATDESCRIPTOR pfd = {0};
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
		wglGetProcAddress("wglCreateContextAttribsARB");

	static s32 attribs[] = {
		WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
		WGL_CONTEXT_MINOR_VERSION_ARB, 6,
		WGL_CONTEXT_FLAGS_ARB, WGL_CONTEXT_DEBUG_BIT_ARB,
		WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
		0,
	};
	opengl_ctx = wglCreateContextAttribsARB(platform_hdc, null, attribs);
	wglMakeCurrent(platform_hdc, opengl_ctx);

	wglDeleteContext(temp_ctx);

#define X(RET, NAME, ...) NAME = cast(RET (*)(__VA_ARGS__)) wglGetProcAddress(#NAME);
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

typedef struct {
	v3 position;
	v2 texcoord;
} OpenGLRectVertex;

static OpenGLRectVertex rect_vertices[] = {
	{.position = {-0.5f, -0.5f, 0.0f}, .texcoord = {0.0f, 0.0f}},
	{.position = {+0.5f, -0.5f, 0.0f}, .texcoord = {1.0f, 0.0f}},
	{.position = {+0.5f, +0.5f, 0.0f}, .texcoord = {1.0f, 1.0f}},
	{.position = {-0.5f, +0.5f, 0.0f}, .texcoord = {0.0f, 1.0f}},
};
static u8 rect_indices[] = {0, 1, 2, 2, 3, 0};
static u32 opengl_rect_vao;
static u32 opengl_rect_shader;
static u32 opengl_rect_texture;
static u8 opengl_steam_profile_store[64*64*4];

static void opengl_init(void) {
	opengl_platform_init();

	glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE);

	{
	u32 vbo;
	glCreateBuffers(1, &vbo);
	glNamedBufferData(vbo, size_of(rect_vertices), rect_vertices, GL_STATIC_DRAW);

	u32 ebo;
	glCreateBuffers(1, &ebo);
	glNamedBufferData(ebo, size_of(rect_indices), rect_indices, GL_STATIC_DRAW);

	u32 vao;
	glCreateVertexArrays(1, &vao);
	glVertexArrayElementBuffer(vao, ebo);
	u32 vbo_binding = 0;
	glVertexArrayVertexBuffer(vao, vbo_binding, vbo, 0, size_of(OpenGLRectVertex));

	u32 position_attrib = 0;
	glEnableVertexArrayAttrib(vao, position_attrib);
	glVertexArrayAttribBinding(vao, position_attrib, vbo_binding);
	glVertexArrayAttribFormat(vao, position_attrib, 3, GL_FLOAT, false, offset_of(OpenGLRectVertex, position));

	u32 texcoord_attrib = 1;
	glEnableVertexArrayAttrib(vao, texcoord_attrib);
	glVertexArrayAttribBinding(vao, texcoord_attrib, vbo_binding);
	glVertexArrayAttribFormat(vao, texcoord_attrib, 2, GL_FLOAT, false, offset_of(OpenGLRectVertex, texcoord));

	opengl_rect_vao = vao;
	}

	{
	u8* vsrc =
		"#version 450\n"
		"layout(location = 0) in vec3 a_position;\n"
		"layout(location = 1) in vec2 a_texcoord;\n"
		"layout(location = 1) out vec2 f_texcoord;\n"
		"void main() {\n"
		"	gl_Position = vec4(a_position, 1.0);\n"
		"	f_texcoord = a_texcoord;\n"
		"}\n";
	u32 vshader = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vshader, 1, &vsrc, null);
	glCompileShader(vshader);

	u8* fsrc =
		"#version 450\n"
		"layout(location = 1) in vec2 f_texcoord;\n"
		"layout(location = 0) out vec4 color;\n"
		"layout(location = 0) uniform sampler2D u_texture;\n"
		"void main() {\n"
		"	color = texture(u_texture, vec2(f_texcoord.x, 1.0 - f_texcoord.y));\n"
		"}\n";
	u32 fshader = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(fshader, 1, &fsrc, null);
	glCompileShader(fshader);

	u32 program = glCreateProgram();
	glAttachShader(program, vshader);
	glAttachShader(program, fshader);
	glLinkProgram(program);
	glDetachShader(program, fshader);
	glDetachShader(program, vshader);

	glDeleteShader(fshader);
	glDeleteShader(vshader);

	opengl_rect_shader = program;
	}

	{
	u32 texture;
	glCreateTextures(GL_TEXTURE_2D, 1, &texture);
	glTextureStorage2D(texture, 1, GL_RGB8, 64, 64);
	glTextureSubImage2D(texture, 0, 0, 0, 64, 64, GL_RGBA, GL_UNSIGNED_BYTE, opengl_steam_profile_store);

	glTextureParameteri(texture, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	opengl_rect_texture = texture;
	}
}

static void opengl_deinit(void) {
	opengl_platform_deinit();
}

static void opengl_resize(void) {

}

static void opengl_present(void) {
	glEnable(GL_FRAMEBUFFER_SRGB);
	glViewport(0, 0, platform_screen_width, platform_screen_height);
	glClearColor(0.6f, 0.2f, 0.2f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);

	glBindTextureUnit(0, opengl_rect_texture);
	glUseProgram(opengl_rect_shader);
	glBindVertexArray(opengl_rect_vao);
	glDrawElements(GL_TRIANGLES, len(rect_indices), GL_UNSIGNED_BYTE, cast(void*) 0);

	opengl_platform_present();
}

static void toggle_fullscreen(void) {

}

static void update_cursor_clip(void) {

}

static void clear_held_keys(void) {

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
		else clear_held_keys();
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
		DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, size_of(dark_mode));
		s32 round_mode = DWMWCP_DONOTROUND;
		DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, size_of(round_mode));

		opengl_init();
		return 0;
	}
	case WM_DESTROY: {
		opengl_deinit();

		PostQuitMessage(0);
		return 0;
	}
	case WM_SYSCOMMAND: {
		if (wParam == SC_KEYMENU) return 0;
		// fallthrough
	}
	default: {
		return DefWindowProcW(hwnd, message, wParam, lParam);
	}
	}
}

void WinMainCRTStartup(void) {
	HINSTANCE lib;
#define X(RET, NAME, ...) NAME = cast(RET (*)(__VA_ARGS__)) GetProcAddress(lib, #NAME);
	lib = LoadLibraryW(L"USER32");
	USER32_FUNCTIONS
	lib = LoadLibraryW(L"GDI32");
	GDI32_FUNCTIONS
	lib = LoadLibraryW(L"OPENGL32");
	OPENGL32_FUNCTIONS
	GL10_FUNCTIONS
	GL11_FUNCTIONS
	lib = LoadLibraryW(L"DWMAPI");
	DWMAPI_FUNCTIONS
	lib = LoadLibraryW(L"WINMM");
	WINMM_FUNCTIONS

	lib = LoadLibraryW(L"steam_api64");
	STEAM_FUNCTIONS
#undef X

	if (SteamAPI_InitFlat && SteamAPI_InitFlat(null) == 0) {
		platform_steam_enabled = true;
		steam_friends = SteamAPI_SteamFriends_v017();
		steam_utils = SteamAPI_SteamUtils_v010();

		steam_player_name = SteamAPI_ISteamFriends_GetPersonaName(steam_friends);

		s32 count = SteamAPI_ISteamFriends_GetFriendCount(steam_friends, k_EFriendFlagAll);
		for (s32 i = 0; i < count; ++i) {
			u64 id = SteamAPI_ISteamFriends_GetFriendByIndex(steam_friends, i, k_EFriendFlagAll);
			u8* name = SteamAPI_ISteamFriends_GetFriendPersonaName(steam_friends, id);
			if (name[0] == 'm') {
				s32 image = SteamAPI_ISteamFriends_GetMediumFriendAvatar(steam_friends, id);
				SteamAPI_ISteamUtils_GetImageRGBA(steam_utils, image, opengl_steam_profile_store, size_of(opengl_steam_profile_store));
				break;
			}
		}
	}

	platform_hinstance = GetModuleHandleW(null);

	bool sleep_is_granular = timeBeginPeriod(1) == TIMERR_NOERROR;

	SetProcessDPIAware();
	static WNDCLASSEXW wndclass = {0};
	wndclass.cbSize = size_of(WNDCLASSEXW);
	wndclass.style = CS_OWNDC;
	wndclass.lpfnWndProc = window_proc;
	wndclass.hInstance = platform_hinstance;
	wndclass.hIcon = LoadIconW(null, IDI_WARNING);
	wndclass.hCursor = LoadCursorW(null, IDC_CROSS);
	wndclass.lpszClassName = L"A";
	RegisterClassExW(&wndclass);
	CreateWindowExW(0, wndclass.lpszClassName, L"Game",
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
				bool pressed = (msg.lParam & 1U << 31) == 0;
				bool repeat = pressed && (msg.lParam & 1 << 30) != 0;
				bool sys = msg.message == WM_SYSKEYDOWN || msg.message == WM_SYSKEYUP;
				bool alt = sys && (msg.lParam & 1 << 29) != 0;

				if (!repeat && (!sys || alt || msg.wParam == VK_F10)) {
					if (pressed) {
						if (msg.wParam == VK_F4 && alt) DestroyWindow(platform_hwnd);
						if (msg.wParam == VK_F11 || (msg.wParam == VK_RETURN && alt)) toggle_fullscreen();
						if (msg.wParam == VK_ESCAPE) DestroyWindow(platform_hwnd);
					}
				}
				DispatchMessageW(&msg); // @note(dfra): temp fix for steam overlay
				break;
			}
			case WM_QUIT: {
				goto game_loop_end;
			}
			default: {
				DispatchMessageW(&msg);
			}
			}
		}

		opengl_present();

		if (platform_steam_enabled) SteamAPI_RunCallbacks();

		if (sleep_is_granular) {
			Sleep(1);
		}
	}
game_loop_end:

	if (platform_steam_enabled) SteamAPI_Shutdown();
	ExitProcess(0);
}

int _fltused;
#endif
