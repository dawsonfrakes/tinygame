#import "Bit_Operations";

CPU_Endianness :: enum u32 {
	LITTLE :: 0;
	BIG :: 1;
}

ENDIAN :: #run ifx CPU == .X64 || CPU == .ARM64 CPU_Endianness.LITTLE else .BIG;

native_to_little :: inline (x: $T) -> T {
	return ifx ENDIAN == .LITTLE x else byte_swap(x);
}

native_to_big :: inline (x: $T) -> T {
	return ifx ENDIAN == .BIG x else byte_swap(x);
}

ascii_to_utf16le_string_literal :: ($s: string) -> []u16 {
	utf16le : [s.count + 1]u16;
	for 0..s.count - 1 utf16le[it] = native_to_little(cast(u16) s[it]);
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
	WM_SIZE :: 0x0005;
	WM_PAINT :: 0x000F;
	WM_QUIT :: 0x0012;
	WM_ERASEBKGND :: 0x0014;
	WM_ACTIVATEAPP :: 0x001C;
	WM_KEYDOWN :: 0x0100;
	WM_KEYUP :: 0x0101;
	WM_SYSKEYDOWN :: 0x0104;
	WM_SYSKEYUP :: 0x0105;
	WM_SYSCOMMAND :: 0x0112;
	SC_KEYMENU :: 0xF100;
	VK_RETURN :: 0x0D;
	VK_ESCAPE :: 0x1B;
	VK_F4 :: 0x73;
	VK_F10 :: 0x79;
	VK_F11 :: 0x7A;

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
	GetDC :: (_: HWND) -> HDC #foreign user32;
	ValidateRect :: (_: HWND, _: *RECT) -> s32 #foreign user32;
	DefWindowProcW :: (_: HWND, _: u32, _: u64, _: s64) -> s64 #foreign user32;
	PostQuitMessage :: (_: s32) #foreign user32;
	DestroyWindow :: (_: HWND) -> s32 #foreign user32;

	dwmapi :: #system_library "dwmapi";

	DWMWA_USE_IMMERSIVE_DARK_MODE :: 20;
	DWMWA_WINDOW_CORNER_PREFERENCE :: 33;
	DWMWCP_DONOTROUND :: 1;

	DwmSetWindowAttribute :: (_: HWND, _: u32, _: *void, _: u32) -> s32 #foreign dwmapi;

	winmm :: #system_library "winmm";

	TIMERR_NOERROR :: 0;

	timeBeginPeriod :: (_: u32) -> u32 #foreign winmm;
}

DEVELOPER :: true;

platform_screen_width : u16 = ---;
platform_screen_height : u16 = ---;
#if OS == .WINDOWS {
	platform_hinstance : HINSTANCE = ---;
	platform_hwnd : HWND = ---;
	platform_hdc : HDC = ---;
}

#scope_file

#if OS == .WINDOWS {
	toggle_fullscreen :: () {

	}

	update_cursor_clip :: () #no_context {

	}

	clear_held_keys :: () #no_context {

	}

	window_proc :: (hwnd: HWND, message: u32, wParam: u64, lParam: s64) -> s64 #c_call {
		if message == {
		case WM_PAINT;
			ValidateRect(hwnd, null);
		case WM_ERASEBKGND;
			return 1;
		case WM_ACTIVATEAPP;
			if wParam != 0 update_cursor_clip();
			else clear_held_keys();
		case WM_SIZE;
			platform_screen_width = cast,no_check(u16) cast,no_check(u64) lParam;
			platform_screen_height = cast,no_check(u16) (cast,no_check(u64) lParam >> 16);
		case WM_CREATE;
			platform_hwnd = hwnd;
			platform_hdc = GetDC(hwnd);

			dark_mode : s32 = xx true;
			DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, *dark_mode, size_of(type_of(dark_mode)));
			round_mode : s32 = DWMWCP_DONOTROUND;
			DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, *round_mode, size_of(type_of(round_mode)));
		case WM_DESTROY;
			PostQuitMessage(0);
		case WM_SYSCOMMAND;
			if (wParam == SC_KEYMENU) return 0;
			#through;
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
				case WM_KEYDOWN; #through;
				case WM_KEYUP; #through;
				case WM_SYSKEYDOWN; #through;
				case WM_SYSKEYUP;
					pressed := lParam & (1 << 31) == 0;
					repeat  := pressed && lParam & (1 << 30) != 0;
					sys     := message == WM_SYSKEYDOWN || message == WM_SYSKEYUP;
					alt     := sys && lParam & (1 << 29) != 0;

					if !repeat && (!sys || alt || wParam == VK_F10) {
						if pressed {
							if wParam == VK_F4 && alt DestroyWindow(platform_hwnd);
							if wParam == VK_F11 || (wParam == VK_RETURN && alt) toggle_fullscreen();
							if DEVELOPER && wParam == VK_ESCAPE DestroyWindow(platform_hwnd);
						}
					}

					DispatchMessageW(*msg); // @hack steam overlay needs input.
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
