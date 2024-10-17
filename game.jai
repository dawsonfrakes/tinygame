ascii_to_utf16le_string_literal :: ($s: string) -> []u16 {
	utf16le : [s.count + 1]u16;
	for 0..s.count - 1 utf16le[it] = s[it];
	return utf16le;
}

#if OS == .WINDOWS {
	kernel32 :: #system_library "kernel32";

	HINSTANCE :: #type,distinct *void;

	GetModuleHandleW :: (_: *u16) -> HINSTANCE #foreign kernel32;
	Sleep :: (_: u32) #foreign kernel32;
	ExitProcess :: (_: u32) #foreign kernel32;

	user32 :: #system_library "user32";

	IDI_WARNING :: cast(*void) 32515;
	IDC_CROSS :: cast(*void) 32515;
	CS_OWNDC :: 0x0020;
	WS_MAXIMIZEBOX :: 0x00010000;
	WS_MINIMIZEBOX :: 0x00020000;
	WS_THICKFRAME :: 0x00040000;
	WS_SYSMENU :: 0x00080000;
	WS_CAPTION :: 0x00C00000;
	WS_VISIBLE :: 0x10000000;
	WS_OVERLAPPEDWINDOW :: WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX;
	CW_USEDEFAULT :: 0x80000000;
	PM_REMOVE :: 0x0001;
	WM_CREATE :: 0x0001;
	WM_DESTROY :: 0x0002;
	WM_QUIT :: 0x0012;

	HDC :: #type,distinct *void;
	HWND :: #type,distinct *void;
	HMENU :: #type,distinct *void;
	HICON :: #type,distinct *void;
	HBRUSH :: #type,distinct *void;
	HCURSOR :: #type,distinct *void;
	HMONITOR :: #type,distinct *void;
	WNDPROC :: #type (HWND, u32, u64, s64) -> s64 #c_call;
	POINT :: struct {
		x : s32;
		y : s32;
	}
	RECT :: struct {
		left : s32;
		top : s32;
		right : s32;
		bottom : s32;
	}
	WNDCLASSEXW :: struct {
		cbSize : u32;
		style : u32;
		lpfnWndProc : WNDPROC;
		cbClsExtra : s32;
		cbWndExtra : s32;
		hInstance : HINSTANCE;
		hIcon : HICON;
		hCursor : HCURSOR;
		hbrBackground : HBRUSH;
		lpszMenuName : *u16;
		lpszClassName : *u16;
		hIconSm : HICON;
	}
	MSG :: struct {
		hwnd : HWND;
		message : u32;
		wParam : u64;
		lParam : s64;
		time : u32;
		pt : POINT;
		lPrivate : u32;
	}

	SetProcessDPIAware :: () -> s32 #foreign user32;
	LoadIconW :: (_: HINSTANCE, _: *u16) -> HICON #foreign user32;
	LoadCursorW :: (_: HINSTANCE, _: *u16) -> HCURSOR #foreign user32;
	RegisterClassExW :: (_: *WNDCLASSEXW) -> u16 #foreign user32;
	CreateWindowExW :: (_: u32, _: *u16, _: *u16, _: u32, _: s32, _: s32, _: s32, _: s32, _: HWND, _: HMENU, _: HINSTANCE, _: *void) -> HWND #foreign user32;
	PeekMessageW :: (_: *MSG, _: HWND, _: u32, _: u32, _: u32) -> s32 #foreign user32;
	TranslateMessage :: (_: *MSG) -> s32 #foreign user32;
	DispatchMessageW :: (_: *MSG) -> s64 #foreign user32;
	DefWindowProcW :: (_: HWND, _: u32, _: u64, _: s64) -> s64 #foreign user32;
	PostQuitMessage :: (_: s32) #foreign user32;
	GetDC :: (_: HWND) -> HDC #foreign user32;

	dwmapi :: #system_library "dwmapi";

	DWMWA_USE_IMMERSIVE_DARK_MODE :: 20;
	DWMWA_WINDOW_CORNER_PREFERENCE :: 33;
	DWMWCP_DONOTROUND :: 1;

	DwmSetWindowAttribute :: (_: HWND, _: u32, _: *void, _: u32) -> s32 #foreign dwmapi;

	winmm :: #system_library "winmm";

	TIMERR_NOERROR :: 0;

	timeBeginPeriod :: (_: u32) -> u32 #foreign winmm;
}

#if OS == .WINDOWS {
	platform_hinstance : HINSTANCE = ---;
	platform_hwnd : HWND = ---;
	platform_hdc : HDC = ---;

	#scope_file

	window_proc :: (hwnd: HWND, message: u32, wParam: u64, lParam: s64) -> s64 #c_call {
		if message == {
		case WM_CREATE;
			platform_hwnd = hwnd;
			platform_hdc = GetDC(hwnd);

			dark_mode : s32 = xx true;
			DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, *dark_mode, size_of(type_of(dark_mode)));
			round_mode : s32 = DWMWCP_DONOTROUND;
			DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, *round_mode, size_of(type_of(round_mode)));
		case WM_DESTROY;
			PostQuitMessage(0);
		case;
			return DefWindowProcW(hwnd, message, wParam, lParam);
		}
		return 0;
	}

	entry :: () {
		platform_hinstance = GetModuleHandleW(null);

		sleep_is_granular := timeBeginPeriod(1) == TIMERR_NOERROR;

		SetProcessDPIAware();
		wndclass : WNDCLASSEXW;
		wndclass.cbSize = size_of(WNDCLASSEXW);
		wndclass.style = CS_OWNDC;
		wndclass.lpfnWndProc = window_proc;
		wndclass.hInstance = platform_hinstance;
		wndclass.hIcon = LoadIconW(xx null, IDI_WARNING);
		wndclass.hCursor = LoadCursorW(xx null, IDC_CROSS);
		wndclass.lpszClassName = (#run ascii_to_utf16le_string_literal("A")).data;
		RegisterClassExW(*wndclass);
		CreateWindowExW(0, wndclass.lpszClassName, (#run ascii_to_utf16le_string_literal("Colliders")).data,
			WS_OVERLAPPEDWINDOW | WS_VISIBLE,
			CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
			xx null, xx null, platform_hinstance, null);

		while game_loop := true {
			msg : MSG = ---;
			while PeekMessageW(*msg, xx null, 0, 0, PM_REMOVE) {
				using msg;
				TranslateMessage(*msg);
				if message == {
				case WM_QUIT;
					break game_loop;
				case;
					DispatchMessageW(*msg);
				}
			}

			if sleep_is_granular {
				Sleep(1);
			}
		}
	}

	RawEntryPoint :: () #c_call #elsewhere {
		first_thread_context : type_of(context);
		push_context first_thread_context {
			entry();
		}

		ExitProcess(0);
	}
}
