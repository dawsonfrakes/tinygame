#define X(RET, NAME, ...) extern "C" RET NAME(__VA_ARGS__);
KERNEL32_FUNCTIONS
#undef X
#define X(RET, NAME, ...) RET (*NAME)(__VA_ARGS__);
USER32_FUNCTIONS
// optional
WINMM_FUNCTIONS
#undef X

s64 window_proc(HWND hwnd, u32 message, u64 wParam, s64 lParam) {
	switch (message) {
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

	if (sleep_is_granular) {
		Sleep(1);
	}

	ExitProcess(0);
}
