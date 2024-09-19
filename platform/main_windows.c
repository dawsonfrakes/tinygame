static s64 platform_window_proc(HWND hwnd, u32 message, u64 wParam, s64 lParam) {
    switch (message) {
        case WM_DESTROY: PostQuitMessage(0); return 0;
        default: return DefWindowProcW(hwnd, message, wParam, lParam);
    }
}

void WinMainCRTStartup(void) {
    platform_hinstance = GetModuleHandleW(null);

    bool sleep_is_granular = timeBeginPeriod(1) == 0;

    SetProcessDPIAware();
    WNDCLASSEXW wndclass = {0};
    wndclass.cbSize = size_of(WNDCLASSEXW);
    wndclass.style = CS_OWNDC;
    wndclass.lpfnWndProc = platform_window_proc;
    wndclass.hInstance = platform_hinstance;
    wndclass.hIcon = LoadIconW(null, IDI_WARNING);
    wndclass.hCursor = LoadCursorW(null, IDI_WARNING);
    wndclass.lpszClassName = L"A";
    RegisterClassExW(&wndclass);
    CreateWindowExW(0, wndclass.lpszClassName, L"caveman",
        WS_OVERLAPPEDWINDOW | WS_VISIBLE,
        CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
        null, null, platform_hinstance, null);

    for (;;) {
        MSG msg;
        while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE)) {
            TranslateMessage(&msg);
            switch (msg.message) {
                case WM_QUIT: goto game_loop_end;
                default: DispatchMessageW(&msg);
            }
        }

        if (sleep_is_granular) {
            Sleep(1);
        }
    }
game_loop_end:

    ExitProcess(0);
}
