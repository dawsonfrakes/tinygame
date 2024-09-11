/* kernel32 */
typedef struct HINSTANCE__* HINSTANCE;

HINSTANCE GetModuleHandleW(u16*);
void ExitProcess(u32);

/* user32 */
typedef struct HDC__* HDC;
typedef struct HWND__* HWND;
typedef struct HMENU__* HMENU;
typedef struct HICON__* HICON;
typedef struct HBRUSH__* HBRUSH;
typedef struct HCURSOR__* HCURSOR;
typedef struct HMONITOR__* HMONITOR;

s32 SetProcessDPIAware(void);

static HINSTANCE platform_hinstance;

void WinMainCRTStartup(void) {
    platform_hinstance = GetModuleHandleW(null);

    SetProcessDPIAware();

    ExitProcess(0);
}
