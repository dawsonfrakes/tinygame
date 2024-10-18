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

        #if OPENGL {
            pfd : PIXELFORMATDESCRIPTOR;
            pfd.nSize = size_of(PIXELFORMATDESCRIPTOR);
            pfd.nVersion = 1;
            pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL |
                PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
            pfd.cColorBits = 24;
            format := ChoosePixelFormat(platform_hdc, *pfd);
            SetPixelFormat(platform_hdc, format, *pfd);

            temp_ctx := wglCreateContext(platform_hdc);
            wglMakeCurrent(platform_hdc, temp_ctx);

            dll := LoadLibraryW((#run ascii_to_utf16le_string_literal("opengl32")).data);
            glEnable = xx GetProcAddress(dll, "glEnable");
            glDisable = xx GetProcAddress(dll, "glDisable");
            glViewport = xx GetProcAddress(dll, "glViewport");
            glClearColor = xx GetProcAddress(dll, "glClearColor");
            glClear = xx GetProcAddress(dll, "glClear");

            glClipControl = xx wglGetProcAddress("glClipControl");
        }
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

    #if STEAM {
        platform_steam_enabled := SteamAPI_InitFlat(null) == .OK;
        defer if platform_steam_enabled SteamAPI_Shutdown();
    }

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

        #if STEAM if platform_steam_enabled SteamAPI_RunCallbacks();

        #if OPENGL {
            glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE);
            glClearColor(0.6, 0.2, 0.2, 1.0);
            glClear(GL_COLOR_BUFFER_BIT);
            SwapBuffers(platform_hdc);
        }

        if sleep_is_granular {
            Sleep(1);
        }
    }
}

RawEntryPoint :: () #foreign {
    first_thread_context : type_of(context);
    push_context first_thread_context {
        entry();
    }

    ExitProcess(0);
}
