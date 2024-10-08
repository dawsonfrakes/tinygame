#define X(RET, NAME, ...) extern "C" RET NAME(__VA_ARGS__);
KERNEL32_FUNCTIONS
#undef X
#define X(RET, NAME, ...) RET (*NAME)(__VA_ARGS__);
USER32_FUNCTIONS
// optional
DWMAPI_FUNCTIONS
WINMM_FUNCTIONS
#undef X

s64 window_proc(HWND hwnd, u32 message, u64 wParam, s64 lParam) {
	switch (message) {
	case WM_PAINT: {
		ValidateRect(hwnd, null);
		return 0;
	}
	case WM_ERASEBKGND: {
		return 1;
	}
	case WM_CREATE: {
		windows_hwnd = hwnd;
		windows_hdc = GetDC(hwnd);

		if (DwmSetWindowAttribute) {
			s32 dark_mode = 1;
			DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, size_of(type_of(dark_mode)));
			s32 round_mode = DWMWCP_DONOTROUND;
			DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, size_of(type_of(round_mode)));
		}
		return 0;
	}
	case WM_DESTROY: {
		PostQuitMessage(0);
		return 0;
	}
	default: {
		return DefWindowProcW(hwnd, message, wParam, lParam);
	}
	}
}

extern "C" void WinMainCRTStartup(void) {
	{
		HINSTANCE lib;
#define X(RET, NAME, ...) NAME = cast(RET (*)(__VA_ARGS__)) GetProcAddress(lib, cast(u8*) #NAME);
		// @todo assert required functions loaded
		lib = LoadLibraryW(cast(u16*) L"USER32");
		USER32_FUNCTIONS
		lib = LoadLibraryW(cast(u16*) L"DWMAPI");
		DWMAPI_FUNCTIONS
		lib = LoadLibraryW(cast(u16*) L"WINMM");
		WINMM_FUNCTIONS
#undef X
	}

	windows_hinstance = GetModuleHandleW(null);

	b8 sleep_is_granular = timeBeginPeriod && timeBeginPeriod(1) == 0;

	SetProcessDPIAware();
	WNDCLASSEXW wndclass = {0};
	wndclass.cbSize = size_of(WNDCLASSEXW);
	wndclass.style = CS_OWNDC;
	wndclass.lpfnWndProc = window_proc;
	wndclass.hInstance = windows_hinstance;
	wndclass.hIcon = LoadIconW(null, IDI_WARNING);
	wndclass.hCursor = LoadCursorW(null, IDC_CROSS);
	wndclass.lpszClassName = cast(u16*) L"A";
	RegisterClassExW(&wndclass);
	CreateWindowExW(0, wndclass.lpszClassName, cast(u16*) L"Game",
		WS_OVERLAPPEDWINDOW | WS_VISIBLE,
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
		null, null, windows_hinstance, null);

	for (;;) {
		MSG msg;
		while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE)) {
			TranslateMessage(&msg);
			switch (msg.message) {
			case WM_QUIT: {
				goto game_loop_end;
			}
			default: {
				DispatchMessageW(&msg);
			}
			}
		}

		if (sleep_is_granular) {
			Sleep(1);
		}
	}
game_loop_end:

	ExitProcess(0);
}
