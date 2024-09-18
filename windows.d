import utils : AliasOpaque;

// kernel32
mixin AliasOpaque!"HINSTANCE";
alias PROC = extern(Windows) ptrdiff_t function();

extern(Windows) HINSTANCE GetModuleHandleW(const(wchar)*);
extern(Windows) void Sleep(uint);
extern(Windows) noreturn ExitProcess(uint);

// user32
mixin AliasOpaque!"HDC";
mixin AliasOpaque!"HWND";
mixin AliasOpaque!"HMENU";
mixin AliasOpaque!"HICON";
mixin AliasOpaque!"HBRUSH";
mixin AliasOpaque!"HCURSOR";
mixin AliasOpaque!"HMONITOR";
alias WNDPROC = extern(Windows) ptrdiff_t function(HWND, uint, size_t, ptrdiff_t);
struct RECT {
    int x;
    int y;
}
struct POINT {
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
enum VK_RETURN = 0x0D;
enum VK_ESCAPE = 0x1B;
enum VK_F4 = 0x73;
enum VK_F10 = 0x79;
enum VK_F11 = 0x7A;

extern(Windows) int SetProcessDPIAware();
extern(Windows) HICON LoadIconW(HINSTANCE, const(wchar)*);
extern(Windows) HCURSOR LoadCursorW(HINSTANCE, const(wchar)*);
extern(Windows) ushort RegisterClassExW(const(WNDCLASSEXW)*);
extern(Windows) HWND CreateWindowExW(uint, const(wchar)*, const(wchar)*, uint, int, int, int, int, HWND, HMENU, HINSTANCE, void*);
extern(Windows) int PeekMessageW(MSG*, HWND, uint, uint, uint);
extern(Windows) int TranslateMessage(const(MSG)*);
extern(Windows) ptrdiff_t DispatchMessageW(const(MSG)*);
extern(Windows) ptrdiff_t DefWindowProcW(HWND, uint, size_t, ptrdiff_t);
extern(Windows) void PostQuitMessage(int);
extern(Windows) int DestroyWindow(HWND);
extern(Windows) HDC GetDC(HWND);
extern(Windows) int ValidateRect(HWND, const(RECT)*);

// dwmapi
extern(Windows) uint DwmSetWindowAttribute(HWND, uint, const(void)*, uint);

// winmm
enum DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
enum DWMWA_WINDOW_CORNER_PREFERENCE = 33;
enum DWMWCP_DONOTROUND = 1;

extern(Windows) uint timeBeginPeriod(uint);
