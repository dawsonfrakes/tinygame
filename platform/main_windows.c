s64 windows_window_proc(HWND hwnd, u32 message, u64 wParam, s64 lParam) {
    switch (message) {
        case WM_QUIT: PostQuitMessage(0); return 0;
        default: return DefWindowProcW(hwnd, message, wParam, lParam);
    }
}

void WinMainCRTStartup(void) {
    platform_hinstance = GetModuleHandleW(null);

    SetProcessDPIAware();

    ExitProcess(0);
}
