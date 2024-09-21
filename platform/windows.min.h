// kernel32
typedef struct HINSTANCE__* HINSTANCE;

HINSTANCE GetModuleHandleW(u16*);
void ExitProcess(u32);

// user32
#define WM_QUIT 0x0012

typedef struct HWND__* HWND;
typedef s64 (*WNDPROC)(HWND, u32, u64, s64);

s32 SetProcessDPIAware(void);
s64 DefWindowProcW(HWND, u32, u64, s64);
void PostQuitMessage(s32);
