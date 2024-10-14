static void toggle_fullscreen(void) {
	static WINDOWPLACEMENT save_placement = {size_of(WINDOWPLACEMENT)};

	u32 style = cast(u32) GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
	if (style & WS_OVERLAPPEDWINDOW) {
		static MONITORINFO mi = {size_of(MONITORINFO)};
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

static void update_cursor_clip(void) {

}

static void clear_held_keys(void) {

}

static s64 window_proc(HWND hwnd, u32 message, u64 wParam, s64 lParam) {
	switch (message) {
	case WM_PAINT: {
		ValidateRect(hwnd, null);
		return 0;
	}
	case WM_ERASEBKGND: {
		return 1;
	}
	case WM_ACTIVATEAPP: {
		if (wParam != 0) update_cursor_clip();
		else clear_held_keys();
		return 0;
	}
	case WM_SIZE: {
		platform_screen_width = cast(u16) cast(u64) lParam;
		platform_screen_height = cast(u16) (cast(u64) lParam >> 16);

		opengl_resize();
		return 0;
	}
	case WM_CREATE: {
		platform_hwnd = hwnd;
		platform_hdc = GetDC(hwnd);

		if (DwmSetWindowAttribute) {
			s32 dark_mode = true;
			DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, size_of(dark_mode));
			s32 round_mode = DWMWCP_DONOTROUND;
			DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, size_of(round_mode));
		}

		opengl_init();
		return 0;
	}
	case WM_DESTROY: {
		opengl_deinit();

		PostQuitMessage(0);
		return 0;
	}
	case WM_SYSCOMMAND: {
		if (wParam == SC_KEYMENU) return 0;
		// fallthrough
	}
	default: {
		return DefWindowProcW(hwnd, message, wParam, lParam);
	}
	}
}

void WinMainCRTStartup(void) {
	HINSTANCE lib;
#define X(RET, NAME, ...) NAME = cast(RET (*)(__VA_ARGS__)) GetProcAddress(lib, #NAME);
	lib = LoadLibraryW(L"USER32");
	USER32_FUNCTIONS
	lib = LoadLibraryW(L"GDI32");
	GDI32_FUNCTIONS
	lib = LoadLibraryW(L"OPENGL32");
	OPENGL32_FUNCTIONS
	GL10_FUNCTIONS
	GL11_FUNCTIONS
	lib = LoadLibraryW(L"DWMAPI");
	DWMAPI_FUNCTIONS
	lib = LoadLibraryW(L"WINMM");
	WINMM_FUNCTIONS

	lib = LoadLibraryW(L"steam_api64");
	STEAM_FUNCTIONS
#undef X

	if (SteamAPI_InitFlat && SteamAPI_InitFlat(null) == 0) {
		steam_enabled = true;
		steam_friends = SteamAPI_SteamFriends_v017();
		steam_utils = SteamAPI_SteamUtils_v010();
	}

	platform_hinstance = GetModuleHandleW(null);

	bool sleep_is_granular = timeBeginPeriod && timeBeginPeriod(1) == TIMERR_NOERROR;

	SetProcessDPIAware();
	static WNDCLASSEXW wndclass = {0};
	wndclass.cbSize = size_of(WNDCLASSEXW);
	wndclass.style = CS_OWNDC;
	wndclass.lpfnWndProc = window_proc;
	wndclass.hInstance = platform_hinstance;
	wndclass.hIcon = LoadIconW(null, IDI_WARNING);
	wndclass.hCursor = LoadCursorW(null, IDC_CROSS);
	wndclass.lpszClassName = L"A";
	RegisterClassExW(&wndclass);
	CreateWindowExW(0, wndclass.lpszClassName, L"Game",
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
				bool pressed = (msg.lParam & 1U << 31) == 0;
				bool repeat = pressed && (msg.lParam & 1 << 30) != 0;
				bool sys = msg.message == WM_SYSKEYDOWN || msg.message == WM_SYSKEYUP;
				bool alt = sys && (msg.lParam & 1 << 29) != 0;

				if (!repeat && (!sys || alt || msg.wParam == VK_F10)) {
					if (pressed) {
						if (msg.wParam == VK_F4 && alt) DestroyWindow(platform_hwnd);
						if (msg.wParam == VK_F11 || (msg.wParam == VK_RETURN && alt)) toggle_fullscreen();
						if (msg.wParam == VK_ESCAPE) DestroyWindow(platform_hwnd);
					}
				}

				DispatchMessageW(&msg); // @note(dfra): fixes steam overlay
				break;
			}
			case WM_QUIT: {
				goto game_loop_end;
			}
			default: {
				DispatchMessageW(&msg);
			}
			}
		}

		opengl_present();

		if (steam_enabled) SteamAPI_RunCallbacks();

		if (sleep_is_granular) {
			Sleep(1);
		}
	}
game_loop_end:

	if (steam_enabled) SteamAPI_Shutdown();
	ExitProcess(0);
}

int _fltused;
