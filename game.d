#!dmd -betterC -run game

version (Windows) {
	// kernel32
	struct HINSTANCE__;
	alias HINSTANCE = HINSTANCE__*;
	alias HMODULE = HINSTANCE;
	alias PROC = extern(Windows) ptrdiff_t function();

	extern extern(Windows) HMODULE GetModuleHandleW(const(wchar)*);
	extern extern(Windows) noreturn ExitProcess(uint);

	// user32
	enum IDI_WARNING = cast(const(wchar)*) 32515;
	enum IDC_CROSS = cast(const(wchar)*) 32515;
	enum CS_OWNDC = 0x0020;
	enum WS_CAPTION = 0x00C00000;
	enum WS_MAXIMIZEBOX = 0x00010000;
	enum WS_MINIMIZEBOX = 0x00020000;
	enum WS_THICKFRAME = 0x00040000;
	enum WS_SYSMENU = 0x00080000;
	enum WS_VISIBLE = 0x10000000;
	enum WS_OVERLAPPEDWINDOW = WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX;
	enum CW_USEDEFAULT = 0x80000000;
	enum PM_REMOVE = 0x0001;
	enum WM_CREATE = 0x0001;
	enum WM_DESTROY = 0x0002;
	enum WM_SIZE = 0x0005;
	enum WM_PAINT = 0x000F;
	enum WM_QUIT = 0x0012;
	enum WM_ERASEBKGND = 0x0014;
	enum WM_ACTIVATEAPP = 0x001C;
	enum WM_KEYDOWN = 0x0100;
	enum WM_KEYUP = 0x0101;
	enum WM_SYSKEYDOWN = 0x0104;
	enum WM_SYSKEYUP = 0x0105;
	enum WM_SYSCOMMAND = 0x0112;
	enum SC_KEYMENU = 0xF100;
	enum VK_RETURN = 0x0D;
	enum VK_ESCAPE = 0x1B;
	enum VK_F4 = 0x73;
	enum VK_F10 = 0x79;
	enum VK_F11 = 0x7A;

	struct HDC__;
	alias HDC = HDC__*;
	struct HWND__;
	alias HWND = HWND__*;
	struct HICON__;
	alias HICON = HICON__*;
	struct HMENU__;
	alias HMENU = HMENU__*;
	struct HBRUSH__;
	alias HBRUSH = HBRUSH__*;
	struct HCURSOR__;
	alias HCURSOR = HCURSOR__*;
	struct HMONITOR__;
	alias HMONITOR = HMONITOR__*;
	alias WNDPROC = extern(Windows) ptrdiff_t function(HWND, uint, size_t, ptrdiff_t);
	struct POINT {
		int x;
		int y;
	}
	struct RECT {
		int left;
		int top;
		int right;
		int bottom;
	}
	struct WNDCLASSEXW {
		uint cbSize;
		uint style;
		WNDPROC lpfnWndProc;
		int cbClsExtra;
		int cbWndExtra;
		HINSTANCE hInstance;
		HICON hIcon;
		HCURSOR hCursor;
		HBRUSH hbrBackground;
		const(wchar)* lpszMenuName;
		const(wchar)* lpszClassName;
		HICON hIconSm;
	}
	struct MSG {
		HWND hwnd;
		uint message;
		size_t wParam;
		ptrdiff_t lParam;
		uint time;
		POINT pt;
		uint lPrivate;
	}

	extern extern(Windows) int SetProcessDPIAware();
	extern extern(Windows) HICON LoadIconW(HINSTANCE, const(wchar)*);
	extern extern(Windows) HCURSOR LoadCursorW(HINSTANCE, const(wchar)*);
	extern extern(Windows) ushort RegisterClassExW(const(WNDCLASSEXW)*);
	extern extern(Windows) HWND CreateWindowExW(uint, const(wchar)*, const(wchar)*, uint, int, int, int, int, HWND, HMENU, HINSTANCE, void*);
	extern extern(Windows) int PeekMessageW(MSG*, HWND, uint, uint, uint);
	extern extern(Windows) int TranslateMessage(const(MSG)*);
	extern extern(Windows) ptrdiff_t DispatchMessageW(const(MSG)*);
	extern extern(Windows) ptrdiff_t DefWindowProcW(HWND, uint, size_t, ptrdiff_t);
	extern extern(Windows) void PostQuitMessage(int);
	extern extern(Windows) int DestroyWindow(HWND);
	extern extern(Windows) HDC GetDC(HWND);
	extern extern(Windows) int ValidateRect(HWND, const(RECT)*);

	// dwmapi
	enum DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
	enum DWMWA_WINDOW_CORNER_PREFERENCE = 33;
	enum DWMWCP_DONOTROUND = 1;

	extern extern(Windows) int DwmSetWindowAttribute(HWND, uint, const(void)*, uint);

	// winmm
	extern extern(Windows) uint timeBeginPeriod(uint);
}

version (Windows) {
	__gshared ushort platform_screen_width;
	__gshared ushort platform_screen_height;
	__gshared HINSTANCE platform_hinstance;
	__gshared HWND platform_hwnd;
	__gshared HDC platform_hdc;

	void toggle_fullscreen() {

	}

	void update_cursor_clip() {

	}

	void clear_held_keys() {

	}

	extern(Windows) noreturn WinMainCRTStartup() {
		platform_hinstance = GetModuleHandleW(null);

		SetProcessDPIAware();
		WNDCLASSEXW wndclass;
		wndclass.cbSize = WNDCLASSEXW.sizeof;
		wndclass.style = CS_OWNDC;
		wndclass.lpfnWndProc = (hwnd, message, wParam, lParam) {
			switch (message) {
				case WM_PAINT:
					ValidateRect(hwnd, null);
					return 0;
				case WM_ERASEBKGND:
					return 1;
				case WM_ACTIVATEAPP:
					if (wParam != 0) update_cursor_clip();
					else clear_held_keys();
					return 0;
				case WM_SIZE:
					platform_screen_width = cast(ushort) lParam;
					platform_screen_height = cast(ushort) (cast(size_t) lParam >> 16);
					return 0;
				case WM_CREATE:
					platform_hwnd = hwnd;
					platform_hdc = GetDC(hwnd);

					int dark_mode = true;
					DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, dark_mode.sizeof);
					int round_mode = DWMWCP_DONOTROUND;
					DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, round_mode.sizeof);
					return 0;
				case WM_DESTROY:
					PostQuitMessage(0);
					return 0;
				case WM_SYSCOMMAND:
					if (wParam == SC_KEYMENU) return 0;
					goto default;
				default:
					return DefWindowProcW(hwnd, message, wParam, lParam);
			}
		};
		wndclass.hInstance = platform_hinstance;
		wndclass.hIcon = LoadIconW(null, IDI_WARNING);
		wndclass.hCursor = LoadCursorW(null, IDC_CROSS);
		wndclass.lpszClassName = "A"w.ptr;
		RegisterClassExW(&wndclass);
		CreateWindowExW(0, wndclass.lpszClassName, "Game"w.ptr,
			WS_OVERLAPPEDWINDOW | WS_VISIBLE,
			CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
			null, null, platform_hinstance, null);

		game_loop: while (true) {
			MSG msg = void;
			while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE)) {
				TranslateMessage(&msg);
				with (msg) switch (message) {
					case WM_KEYDOWN:
					case WM_KEYUP:
					case WM_SYSKEYDOWN:
					case WM_SYSKEYUP:
						bool pressed = (lParam & 1 << 31) == 0;
						bool repeat = pressed && (lParam & 1 << 30) != 0;
						bool sys = message == WM_SYSKEYDOWN || message == WM_SYSKEYUP;
						bool alt = sys && (lParam & 1 << 29) != 0;

						if (!repeat && (!sys || alt || wParam == VK_F10)) {
							if (pressed) {
								if (wParam == VK_F4 && alt) DestroyWindow(platform_hwnd);
								if (wParam == VK_F11 || (wParam == VK_RETURN && alt)) toggle_fullscreen();
								if (wParam == VK_ESCAPE) DestroyWindow(platform_hwnd);
							}
						}
						break;
					case WM_QUIT:
						break game_loop;
					default:
						DispatchMessageW(&msg);
				}
			}
		}

		ExitProcess(0);
	}

	extern(C) int _fltused;

	pragma(linkerDirective, "-subsystem:windows");
	pragma(lib, "kernel32");
	pragma(lib, "user32");
	pragma(lib, "dwmapi");
	pragma(lib, "winmm");
}
