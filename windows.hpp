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
#define WM_PAINT 0x000F
#define WM_QUIT 0x0012
#define WM_ERASEBKGND 0x0014

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
	X(s64, DefWindowProcW, HWND, u32, u64, s64) \
	X(void, PostQuitMessage, s32)

// dwmapi
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#define DWMWA_WINDOW_CORNER_PREFERENCE 33
#define DWMWCP_DONOTROUND 1

#define DWMAPI_FUNCTIONS \
	X(s32, DwmSetWindowAttribute, HWND, u32, void*, u32)

// winmm
#define WINMM_FUNCTIONS \
	X(u32, timeBeginPeriod, u32)
