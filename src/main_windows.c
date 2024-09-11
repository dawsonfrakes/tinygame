/* kernel32 */
void ExitProcess(u32);

/* user32 */
typedef struct HINSTANCE__* HINSTANCE;

HINSTANCE GetModuleHandleW(u16*);

static HINSTANCE platform_hinstance;

void WinMainCRTStartup(void) {
    platform_hinstance = GetModuleHandleW(null);

    ExitProcess(0);
}
