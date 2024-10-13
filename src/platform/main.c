#include "../basic.h"

#define TARGET_STORE_STEAM 1
#define TARGET_RENDERER_OPENGL 1

#if TARGET_STORE_STEAM
#include "steam.min.h"
#endif

#if TARGET_RENDERER_OPENGL
#include "opengl.min.h"
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
GL45_FUNCTIONS

STEAM_FUNCTIONS
#undef X

static u16 platform_screen_width;
static u16 platform_screen_height;
static HINSTANCE platform_hinstance;
static HWND platform_hwnd;
static HDC platform_hdc;

static HGLRC opengl_ctx;

static bool steam_enabled;
static ISteamFriends steam_friends;
static ISteamUtils steam_utils;

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
	static WINDOWPLACEMENT save_placement = {size_of(WINDOWPLACEMENT)};

	u32 style = cast(u32) GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
	if (style & WS_OVERLAPPEDWINDOW) {
		static MONITORINFO mi = {size_of(MONITORINFO)};
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

		if (DwmSetWindowAttribute) {
			s32 dark_mode = true;
			DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, size_of(dark_mode));
			s32 round_mode = DWMWCP_DONOTROUND;
			DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, size_of(round_mode));
		}

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
		steam_enabled = true;
		steam_friends = SteamAPI_SteamFriends_v017();
		steam_utils = SteamAPI_SteamUtils_v010();

		s32 count = SteamAPI_ISteamFriends_GetFriendCount(steam_friends, k_EFriendFlagAll);
		for (s32 i = 0; i < count; ++i) {
			u64 id = SteamAPI_ISteamFriends_GetFriendByIndex(steam_friends, i, k_EFriendFlagAll);
			// u8* name = SteamAPI_ISteamFriends_GetFriendPersonaName(steam_friends, id);
			s32 image = SteamAPI_ISteamFriends_GetMediumFriendAvatar(steam_friends, id);
			SteamAPI_ISteamUtils_GetImageRGBA(steam_utils, image, opengl_steam_profile_store, size_of(opengl_steam_profile_store));
		}
	}

	platform_hinstance = GetModuleHandleW(null);

	bool sleep_is_granular = timeBeginPeriod && timeBeginPeriod(1) == TIMERR_NOERROR;

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

				DispatchMessageW(&msg); // @note(dfra): fixes steam overlay
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

		if (steam_enabled) SteamAPI_RunCallbacks();

		if (sleep_is_granular) {
			Sleep(1);
		}
	}
game_loop_end:

	if (steam_enabled) SteamAPI_Shutdown();
	ExitProcess(0);
}

int _fltused;
#endif
