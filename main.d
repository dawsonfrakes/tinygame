#!dmd -betterC -run main

enum DEVELOPER = true;

version (Windows) {
import windows;

__gshared HINSTANCE platform_hinstance = void;
__gshared HWND platform_hwnd = void;
__gshared HDC platform_hdc = void;
__gshared ushort platform_screen_width = void;
__gshared ushort platform_screen_height = void;

extern(Windows) noreturn WinMainCRTStartup() {
    platform_hinstance = GetModuleHandleW(null);

    bool sleep_is_granular = timeBeginPeriod(1) == 0;

    SetProcessDPIAware();
    WNDCLASSEXW wndclass;
    wndclass.cbSize = WNDCLASSEXW.sizeof;
    wndclass.style = CS_OWNDC;
    wndclass.lpfnWndProc = (hwnd, message, wParam, lParam) {
        void update_cursor_clip() {}

        switch (message) {
            case WM_PAINT: ValidateRect(hwnd, null); return 0;
            case WM_ERASEBKGND: return 1;
            case WM_ACTIVATEAPP: if (wParam) update_cursor_clip(); return 0;
            case WM_SIZE:
                platform_screen_width = cast(ushort) cast(size_t) lParam;
                platform_screen_height = cast(ushort) (cast(size_t) lParam >> 16);
                return 0;
            case WM_CREATE:
                platform_hwnd = hwnd;
                platform_hdc = GetDC(hwnd);

                int dark_mode = 1;
                DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, dark_mode.sizeof);
                int round_mode = DWMWCP_DONOTROUND;
                DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, round_mode.sizeof);
                return 0;
            case WM_DESTROY: PostQuitMessage(0); return 0;
            case WM_SYSCOMMAND: if (wParam == SC_KEYMENU) return 0; else goto default;
            default: return DefWindowProcW(hwnd, message, wParam, lParam);
        }
    };
    wndclass.hInstance = platform_hinstance;
    wndclass.hIcon = LoadIconW(null, IDI_WARNING);
    wndclass.hCursor = LoadCursorW(null, IDC_CROSS);
    wndclass.lpszClassName = "A"w.ptr;
    RegisterClassExW(&wndclass);
    CreateWindowExW(0, wndclass.lpszClassName, "game"w.ptr,
        WS_OVERLAPPEDWINDOW | WS_VISIBLE,
        CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
        null, null, platform_hinstance, null);

    game_loop: while (true) {
        MSG msg = void;
        while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE)) {
            TranslateMessage(&msg);
            with (msg) switch (message) {
                case WM_KEYDOWN, WM_KEYUP, WM_SYSKEYDOWN, WM_SYSKEYUP:
                    bool pressed = (lParam & 1 << 31) == 0;
                    bool repeat = pressed && (lParam & 1 << 30) != 0;
                    bool sys = message == WM_SYSKEYDOWN || message == WM_SYSKEYUP;
                    bool alt = sys && (lParam & 1 << 29) != 0;

                    if (!repeat && (!sys || alt || wParam == VK_F10)) {
                        if (pressed) {
                            void toggle_fullscreen() {}

                            if (wParam == VK_F4 && alt) DestroyWindow(platform_hwnd);
                            if (wParam == VK_F11 || (wParam == VK_RETURN && alt)) toggle_fullscreen();
                            if (DEVELOPER && wParam == VK_ESCAPE) DestroyWindow(platform_hwnd);
                        }
                    }
                    break;
                case WM_QUIT: break game_loop;
                default: DispatchMessageW(&msg);
            }
        }

        if (sleep_is_granular) {
            Sleep(1);
        }
    }

    ExitProcess(0);
}

pragma(linkerDirective, "-subsystem:windows");
pragma(linkerDirective, "-incremental:no");
pragma(lib, "kernel32");
pragma(lib, "user32");
pragma(lib, "dwmapi");
pragma(lib, "winmm");
}
