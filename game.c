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
#define offset_of(T, F) (cast(u64) &(cast(T*)->F))
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
#define WM_QUIT 0x0012

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
	X(s64, DefWindowProcW, HWND, u32, u64, s64) \
	X(void, PostQuitMessage, s32)

// winmm
#define TIMERR_NOERROR 0

#define WINMM_FUNCTIONS \
	X(u32, timeBeginPeriod, u32)
#endif

#if TARGET_OS_WINDOWS
#define X(RET, NAME, ...) RET NAME(__VA_ARGS__);
KERNEL32_FUNCTIONS
#undef X
#define X(RET, NAME, ...) static RET (*NAME)(__VA_ARGS__);
USER32_FUNCTIONS
WINMM_FUNCTIONS
#undef X

static HINSTANCE platform_hinstance;

static s64 window_proc(HWND hwnd, u32 message, u64 wParam, s64 lParam) {
	switch (message) {
	case WM_DESTROY: {
		PostQuitMessage(0);
		return 0;
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
	lib = LoadLibraryW(L"WINMM");
	WINMM_FUNCTIONS
#undef X

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
			case WM_QUIT: {
				goto game_loop_end;
			}
			default: {
				DispatchMessageW(&msg);
			}
			}
		}
	}
game_loop_end:

	if (sleep_is_granular) {
		Sleep(1);
	}

	ExitProcess(0);
}
#endif
