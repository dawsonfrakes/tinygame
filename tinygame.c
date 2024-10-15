#define TARGET_STORE_STEAM 1
#define TARGET_RENDERER_OPENGL 1

#if !defined(NDEBUG)
#define BUILD_MODE_DEBUG 1
#else
#define BUILD_MODE_DEBUG 0
#endif

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

#if defined(_MSC_VER)
#define COMPILER_MSVC 1
#else
#define COMPILER_MSVC 0
#endif

#if defined(__TINYC__)
#define COMPILER_TCC 1
#else
#define COMPILER_TCC 0
#endif

#define cast(T) (T)
#define size_of(T) sizeof(T)
#define offset_of(T, F) (cast(u64) &(cast(T*) 0)->F)
#define align_of(T) offset_of(struct { u8 x; T t; }, t)
#define len(X) (size_of(X) / size_of((X)[0]))
#define str(X) {len(X) - 1, (X)}
#define min(X, Y) ((X) < (Y) ? (X) : (Y))
#define max(X, Y) ((X) > (Y) ? (X) : (Y))

#if COMPILER_MSVC
#define debug_break __debugbreak()
#elif COMPILER_TCC
#define debug_break __asm__ ("int3")
#endif

#if BUILD_MODE_DEBUG
#define assert(X) do if (!(X)) debug_break(); while (0)
#else
#define assert(X) (cast(void) (X))
#undef debug_break
#endif

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

#if TARGET_STORE_STEAM
typedef u8 SteamErrMsg[1024];
typedef struct ISteamUser__* ISteamUser;
typedef struct ISteamUtils__* ISteamUtils;
typedef struct ISteamFriends__* ISteamFriends;

#define STEAM_FUNCTIONS \
	X(s32, SteamAPI_InitFlat, SteamErrMsg*) \
	X(void, SteamAPI_RunCallbacks, void) \
	X(ISteamUser, SteamAPI_SteamUser_v023, void) \
	X(u64, SteamAPI_ISteamUser_GetSteamID, ISteamUser) \
	X(ISteamUtils, SteamAPI_SteamUtils_v010, void) \
	X(bool, SteamAPI_ISteamUtils_GetImageRGBA, ISteamUtils, s32, u8*, s32) \
	X(ISteamFriends, SteamAPI_SteamFriends_v017, void) \
	X(s32, SteamAPI_ISteamFriends_GetMediumFriendAvatar, ISteamFriends, u64) \
	X(u8*, SteamAPI_ISteamFriends_GetPersonaName, ISteamFriends) \
	X(void, SteamAPI_Shutdown, void)
#endif

#if TARGET_RENDERER_OPENGL
// 1.0
#define GL_COLOR_BUFFER_BIT 0x00004000
#define GL_TRIANGLES 0x0004
#define GL_UNSIGNED_BYTE 0x1401
#define GL_UNSIGNED_INT 0x1405
#define GL_FLOAT 0x1406
#define GL_TEXTURE_2D 0x0DE1
#define GL_RGB 0x1907
#define GL_RGBA 0x1908
#define GL_NEAREST 0x2600
#define GL_LINEAR 0x2601
#define GL_TEXTURE_MIN_FILTER 0x2801
#define GL_TEXTURE_WRAP_S 0x2802
#define GL_TEXTURE_WRAP_T 0x2803

#define GL10_FUNCTIONS \
	X(void, glEnable, u32) \
	X(void, glDisable, u32) \
	X(void, glGetIntegerv, u32, s32*) \
	X(void, glDepthFunc, u32) \
	X(void, glBlendFunc, u32, u32) \
	X(void, glTexParameteri, u32, u32, s32) \
	X(void, glViewport, s32, s32, u32, u32) \
	X(void, glClearColor, f32, f32, f32, f32) \
	X(void, glClear, u32) \
	X(void, glBegin, u32) \
	X(void, glEnd, void) \
	X(void, glTexCoord2f, f32, f32) \
	X(void, glVertex3f, f32, f32, f32)

// 1.1
#define GL_RGB8 0x8051

#define GL11_FUNCTIONS \
	X(void, glGenTextures, u32, u32*) \
	X(void, glBindTexture, u32, u32) \
	X(void, glTexImage2D, u32, s32, s32, u32, u32, s32, u32, u32, void*)
#endif

#if TARGET_OS_WINDOWS
// kernel32
#define MEM_COMMIT 0x00001000
#define MEM_RESERVE 0x00002000
#define PAGE_READWRITE 0x04

typedef struct HINSTANCE__* HINSTANCE;
typedef HINSTANCE HMODULE;
typedef s64 (*PROC)(void);

#define KERNEL32_FUNCTIONS \
	X(HMODULE, GetModuleHandleW, u16*) \
	X(HMODULE, LoadLibraryW, u16*) \
	X(PROC, GetProcAddress, HMODULE, u8*) \
	X(void, Sleep, u32) \
	X(void*, VirtualAlloc, void*, u64, u32, u32) \
	X(void, ExitProcess, u32)

// user32
#define IDI_WARNING (cast(u16*) cast(u64) 32515)
#define IDC_CROSS (cast(u16*) cast(u64) 32515)
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
	X(s64, GetWindowLongPtrW, HWND, s32) \
	X(s64, SetWindowLongPtrW, HWND, s32, s64) \
	X(s32, GetWindowPlacement, HWND, WINDOWPLACEMENT*) \
	X(s32, SetWindowPlacement, HWND, WINDOWPLACEMENT*) \
	X(s32, SetWindowPos, HWND, HWND, s32, s32, s32, s32, u32) \
	X(HMONITOR, MonitorFromWindow, HWND, u32) \
	X(s32, GetMonitorInfoW, HMONITOR, MONITORINFO*) \
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
#define WINMM_FUNCTIONS \
	X(u32, timeBeginPeriod, u32)
#endif

#if TARGET_OS_WINDOWS
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

#if TARGET_STORE_STEAM
STEAM_FUNCTIONS
#endif
#undef X

#if TARGET_STORE_STEAM
static bool steam_enabled;
static ISteamUser steam_user;
static ISteamUtils steam_utils;
static ISteamFriends steam_friends;
static u64 steam_player_id;
static u8* steam_player_name = "[unknown]";
static u8* steam_player_avatar;
#endif

static u16 platform_screen_width;
static u16 platform_screen_height;
static HINSTANCE platform_hinstance;
static HWND platform_hwnd;
static HDC platform_hdc;

static u32 opengl_texture;

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
		return 0;
	}
	case WM_CREATE: {
		platform_hwnd = hwnd;
		platform_hdc = GetDC(hwnd);

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

		glGenTextures(1, &opengl_texture);
		glBindTexture(GL_TEXTURE_2D, opengl_texture);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

		if (DwmSetWindowAttribute) {
			s32 dark_mode = true;
			DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, size_of(dark_mode));
			s32 round_mode = DWMWCP_DONOTROUND;
			DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, size_of(round_mode));
		}
		return 0;
	}
	case WM_DESTROY: {
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
	{
		HMODULE lib;
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

#if TARGET_STORE_STEAM
		lib = LoadLibraryW(L"steam_api64.dll");
		STEAM_FUNCTIONS
#endif
#undef X
	}

	platform_hinstance = GetModuleHandleW(null);

	bool sleep_is_granular = timeBeginPeriod && timeBeginPeriod(1) == 0;

	if (SteamAPI_InitFlat && SteamAPI_InitFlat(null) == 0) {
		steam_enabled = true;
		steam_user = SteamAPI_SteamUser_v023();
		steam_utils = SteamAPI_SteamUtils_v010();
		steam_friends = SteamAPI_SteamFriends_v017();
	}

	if (steam_enabled) {
		steam_player_id = SteamAPI_ISteamUser_GetSteamID(steam_user);
		steam_player_name = SteamAPI_ISteamFriends_GetPersonaName(steam_friends);
		s32 avatar_handle = SteamAPI_ISteamFriends_GetMediumFriendAvatar(steam_friends, steam_player_id);
		steam_player_avatar = VirtualAlloc(0, 64 * 64 * 4, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
		SteamAPI_ISteamUtils_GetImageRGBA(steam_utils, avatar_handle, steam_player_avatar, 64 * 64 * 4);
	}

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
						if (BUILD_MODE_DEBUG && msg.wParam == VK_ESCAPE) DestroyWindow(platform_hwnd);
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

		if (steam_enabled) SteamAPI_RunCallbacks();

		static u32* backbuffer_data;
		if (!backbuffer_data) {
			backbuffer_data = VirtualAlloc(0, platform_screen_width * platform_screen_height * size_of(u32),
				MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
		}

		u16 min_x = 500;
		u16 min_y = 500;
		u32 *row = backbuffer_data + min_y * platform_screen_width + min_x;
		u32 *src_row = cast(u32*) steam_player_avatar + 63 * 64;
		for (u16 y = min_y; y < min_y + 64; y += 1) {
			u32 *pixel = row;
			u32 *src_pixel = src_row;
			for (u16 x = min_x; x < min_x + 64; x += 1) {
				*pixel = *src_pixel;
				pixel += 1;
				src_pixel += 1;
			}
			row += platform_screen_width;
			src_row -= 64;
		}

		glViewport(0, 0, platform_screen_width, platform_screen_height);
		glClearColor(0.6f, 0.2f, 0.2f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT);
		glBindTexture(GL_TEXTURE_2D, opengl_texture);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8,
			platform_screen_width, platform_screen_height,
			0, GL_RGBA, GL_UNSIGNED_BYTE, backbuffer_data);
		glEnable(GL_TEXTURE_2D);
		glBegin(GL_TRIANGLES);
		glTexCoord2f(0.0f, 0.0f);
		glVertex3f(-1.0f, -1.0f, 0.0f);
		glTexCoord2f(1.0f, 0.0f);
		glVertex3f(+1.0f, -1.0f, 0.0f);
		glTexCoord2f(1.0f, 1.0f);
		glVertex3f(+1.0f, +1.0f, 0.0f);
		glTexCoord2f(1.0f, 1.0f);
		glVertex3f(+1.0f, +1.0f, 0.0f);
		glTexCoord2f(0.0f, 1.0f);
		glVertex3f(-1.0f, +1.0f, 0.0f);
		glTexCoord2f(0.0f, 0.0f);
		glVertex3f(-1.0f, -1.0f, 0.0f);
		glEnd();
		SwapBuffers(platform_hdc);

		if (sleep_is_granular) {
			Sleep(1);
		}
	}
game_loop_end:

	if (steam_enabled) SteamAPI_Shutdown();
	ExitProcess(0);
}

#if COMPILER_MSVC
int _fltused;
#endif
#endif
