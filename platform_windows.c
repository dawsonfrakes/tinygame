static void (*platform_renderer_init)(void);
static void (*platform_renderer_deinit)(void);
static void (*platform_renderer_resize)(void);
static void (*platform_renderer_present)(void);

static void platform_select_renderer(void) {
    if (RENDERER_OPENGL) {
        platform_renderer_init = opengl_init;
        platform_renderer_deinit = opengl_deinit;
        platform_renderer_resize = opengl_resize;
        platform_renderer_present = opengl_present;
        return;
    }
    assert(0);
}

static void platform_update_cursor_clip(void) {

}

static void platform_toggle_fullscreen(void) {
    static WINDOWPLACEMENT save_placement = {size_of(WINDOWPLACEMENT)};

    u32 style = cast(u32) GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
    if (style & WS_OVERLAPPEDWINDOW) {
        MONITORINFO mi = {size_of(MONITORINFO)};
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

static s64 platform_window_proc(HWND hwnd, u32 message, u64 wParam, s64 lParam) {
    switch (message) {
        case WM_PAINT: ValidateRect(hwnd, null); return 0;
        case WM_ERASEBKGND: return 1;
        case WM_ACTIVATEAPP: if (wParam != 0) platform_update_cursor_clip(); return 0;
        case WM_SIZE:
            platform_screen_width = cast(u16) cast(u64) lParam;
            platform_screen_height = cast(u16) (cast(u64) lParam >> 16);

            platform_renderer_resize();
            return 0;
        case WM_CREATE:
            platform_hwnd = hwnd;
            platform_hdc = GetDC(hwnd);

            s32 dark_mode = 1;
            DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, 4);
            s32 round_mode = DWMWCP_DONOTROUND;
            DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, 4);

            platform_renderer_init();
            return 0;
        case WM_DESTROY: platform_renderer_deinit(); PostQuitMessage(0); return 0;
        case WM_SYSCOMMAND: if (wParam == SC_KEYMENU) return 0; else {} /* fallthrough */
        default: return DefWindowProcW(hwnd, message, wParam, lParam);
    }
}

void WinMainCRTStartup(void) {
    platform_hinstance = GetModuleHandleW(null);

    bool sleep_is_granular = timeBeginPeriod(1) == 0;

    platform_select_renderer();

    SetProcessDPIAware();
    WNDCLASSEXW wndclass = {0};
    wndclass.cbSize = size_of(WNDCLASSEXW);
    wndclass.style = CS_OWNDC;
    wndclass.lpfnWndProc = platform_window_proc;
    wndclass.hInstance = platform_hinstance;
    wndclass.hIcon = LoadIconW(null, IDI_WARNING);
    wndclass.hCursor = LoadCursorW(null, IDC_CROSS);
    wndclass.lpszClassName = L"A";
    RegisterClassExW(&wndclass);
    CreateWindowExW(0, wndclass.lpszClassName, L"game",
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
                    bool pressed = (msg.lParam & cast(u32) 1 << 31) == 0;
                    bool repeat = pressed && (msg.lParam & 1 << 30) != 0;
                    bool sys = msg.message == WM_SYSKEYDOWN || msg.message == WM_SYSKEYUP;
                    bool alt = sys && (msg.lParam & 1 << 29) != 0;

                    if (!repeat && (!sys || alt || msg.wParam == VK_F10)) {
                        if (pressed) {
                            if (msg.wParam == VK_F4 && alt) DestroyWindow(platform_hwnd);
                            if (msg.wParam == VK_F11 || (msg.wParam == VK_RETURN && alt)) platform_toggle_fullscreen();
                            if (DEVELOPER && msg.wParam == VK_ESCAPE) DestroyWindow(platform_hwnd);
                        }
                    }
                    break;
                }
                case WM_QUIT: goto game_loop_end;
                default: DispatchMessageW(&msg);
            }
        }

        platform_renderer_present();

        if (sleep_is_granular) {
            Sleep(1);
        }
    }
game_loop_end:

    ExitProcess(0);
}

#if COMPILER_MSVC
int _fltused;
#endif
