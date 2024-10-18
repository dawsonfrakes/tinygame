kernel32 :: #system_library "kernel32";

HINSTANCE :: #type,distinct *void;
PROC :: #type () -> s64 #c_call;

GetModuleHandleW :: (_: *u16) -> HINSTANCE #foreign kernel32;
Sleep :: (_: u32) #foreign kernel32;
ExitProcess :: (_: u32) #foreign kernel32;

user32 :: #system_library "user32";

IDI_WARNING :: cast(*void) 32515;
IDC_CROSS :: cast(*void) 32515;
CS_OWNDC :: 0x0020;
WS_MAXIMIZEBOX :: 0x00010000;
WS_MINIMIZEBOX :: 0x00020000;
WS_THICKFRAME :: 0x00040000;
WS_SYSMENU :: 0x00080000;
WS_CAPTION :: 0x00C00000;
WS_VISIBLE :: 0x10000000;
WS_OVERLAPPEDWINDOW :: WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX;
CW_USEDEFAULT :: 0x80000000;
PM_REMOVE :: 0x0001;
WM_CREATE :: 0x0001;
WM_DESTROY :: 0x0002;
WM_SIZE :: 0x0005;
WM_PAINT :: 0x000F;
WM_QUIT :: 0x0012;
WM_ERASEBKGND :: 0x0014;
WM_ACTIVATEAPP :: 0x001C;
WM_KEYDOWN :: 0x0100;
WM_KEYUP :: 0x0101;
WM_SYSKEYDOWN :: 0x0104;
WM_SYSKEYUP :: 0x0105;
WM_SYSCOMMAND :: 0x0112;
SC_KEYMENU :: 0xF100;
VK_RETURN :: 0x0D;
VK_ESCAPE :: 0x1B;
VK_F4 :: 0x73;
VK_F10 :: 0x79;
VK_F11 :: 0x7A;

HDC :: #type,distinct *void;
HWND :: #type,distinct *void;
HMENU :: #type,distinct *void;
HICON :: #type,distinct *void;
HBRUSH :: #type,distinct *void;
HCURSOR :: #type,distinct *void;
HMONITOR :: #type,distinct *void;
WNDPROC :: #type (HWND, u32, u64, s64) -> s64 #c_call;
POINT :: struct {
    x : s32;
    y : s32;
}
RECT :: struct {
    left : s32;
    top : s32;
    right : s32;
    bottom : s32;
}
WNDCLASSEXW :: struct {
    cbSize : u32;
    style : u32;
    lpfnWndProc : WNDPROC;
    cbClsExtra : s32;
    cbWndExtra : s32;
    hInstance : HINSTANCE;
    hIcon : HICON;
    hCursor : HCURSOR;
    hbrBackground : HBRUSH;
    lpszMenuName : *u16;
    lpszClassName : *u16;
    hIconSm : HICON;
}
MSG :: struct {
    hwnd : HWND;
    message : u32;
    wParam : u64;
    lParam : s64;
    time : u32;
    pt : POINT;
    lPrivate : u32;
}

SetProcessDPIAware :: () -> s32 #foreign user32;
LoadIconW :: (_: HINSTANCE, _: *u16) -> HICON #foreign user32;
LoadCursorW :: (_: HINSTANCE, _: *u16) -> HCURSOR #foreign user32;
RegisterClassExW :: (_: *WNDCLASSEXW) -> u16 #foreign user32;
CreateWindowExW :: (_: u32, _: *u16, _: *u16, _: u32, _: s32, _: s32, _: s32, _: s32, _: HWND, _: HMENU, _: HINSTANCE, _: *void) -> HWND #foreign user32;
PeekMessageW :: (_: *MSG, _: HWND, _: u32, _: u32, _: u32) -> s32 #foreign user32;
TranslateMessage :: (_: *MSG) -> s32 #foreign user32;
DispatchMessageW :: (_: *MSG) -> s64 #foreign user32;
GetDC :: (_: HWND) -> HDC #foreign user32;
ValidateRect :: (_: HWND, _: *RECT) -> s32 #foreign user32;
DefWindowProcW :: (_: HWND, _: u32, _: u64, _: s64) -> s64 #foreign user32;
PostQuitMessage :: (_: s32) #foreign user32;
DestroyWindow :: (_: HWND) -> s32 #foreign user32;

gdi32 :: #system_library "gdi32";

PFD_DOUBLEBUFFER :: 0x00000001;
PFD_DRAW_TO_WINDOW :: 0x00000004;
PFD_SUPPORT_OPENGL :: 0x00000020;
PFD_DEPTH_DONTCARE :: 0x20000000;

PIXELFORMATDESCRIPTOR :: struct {
    nSize : u16;
    nVersion : u16;
    dwFlags : u32;
    iPixelType : u8;
    cColorBits : u8;
    cRedBits : u8;
    cRedShift : u8;
    cGreenBits : u8;
    cGreenShift : u8;
    cBlueBits : u8;
    cBlueShift : u8;
    cAlphaBits : u8;
    cAlphaShift : u8;
    cAccumBits : u8;
    cAccumRedBits : u8;
    cAccumGreenBits : u8;
    cAccumBlueBits : u8;
    cAccumAlphaBits : u8;
    cDepthBits : u8;
    cStencilBits : u8;
    cAuxBuffers : u8;
    iLayerType : u8;
    bReserved : u8;
    dwLayerMask : u32;
    dwVisibleMask : u32;
    dwDamageMask : u32;
}

ChoosePixelFormat :: (_: HDC, _: *PIXELFORMATDESCRIPTOR) -> s32 #foreign gdi32;
SetPixelFormat :: (_: HDC, _: s32, _: *PIXELFORMATDESCRIPTOR) -> s32 #foreign gdi32;
SwapBuffers :: (_: HDC) -> s32 #foreign gdi32;

opengl32 :: #system_library "opengl32";

HGLRC :: #type,distinct *void;

wglCreateContext :: (_: HDC) -> HGLRC #foreign opengl32;
wglDeleteContext :: (_: HGLRC) -> s32 #foreign opengl32;
wglMakeCurrent :: (_: HDC, _: HGLRC) -> s32 #foreign opengl32;
wglGetProcAddress :: (_: *u8) -> PROC #foreign opengl32;

dwmapi :: #system_library "dwmapi";

DWMWA_USE_IMMERSIVE_DARK_MODE :: 20;
DWMWA_WINDOW_CORNER_PREFERENCE :: 33;
DWMWCP_DONOTROUND :: 1;

DwmSetWindowAttribute :: (_: HWND, _: u32, _: *void, _: u32) -> s32 #foreign dwmapi;

winmm :: #system_library "winmm";

TIMERR_NOERROR :: 0;

timeBeginPeriod :: (_: u32) -> u32 #foreign winmm;
