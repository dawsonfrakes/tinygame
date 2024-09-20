const core = struct {
    const builtin = @import("builtin");

    pub const build_mode = builtin.mode;
    pub const cpu_arch = builtin.target.cpu.arch;
    pub const cpu_bits = builtin.target.ptrBitWidth();
    pub const cpu_endianness = builtin.target.cpu.arch.endian();
    pub const os_tag = builtin.target.os.tag;

    pub const Type = @TypeOf(@typeInfo(type));
    pub const CallingConvention = @TypeOf(@typeInfo(fn () void).@"fn".calling_convention);

    pub fn zeroes(comptime T: type) T {
        return @as(*align(1) const T, @ptrCast(&[_]u8{0} ** @sizeOf(T))).*;
    }

    pub fn zeroInit(comptime T: type, args: anytype) T {
        var result: T = undefined;
        inline for (@typeInfo(T).@"struct".fields) |field| {
            @field(result, field.name) = if (@hasField(@TypeOf(args), field.name))
                switch (@typeInfo(field.type)) {
                    .@"struct" => zeroInit(field.type, @field(args, field.name)),
                    else => @field(args, field.name),
                }
            else if (field.default_value) |default_value|
                @as(*align(1) const field.type, default_value).*
            else
                zeroes(field.type);
        }
        return result;
    }

    pub fn nativeToLittle(comptime T: type, x: T) T {
        return if (cpu_endianness == .little) x else @byteSwap(x);
    }

    pub fn utf8ToUtf16LeStringLiteral(comptime ascii: []const u8) *const [ascii.len:0]u16 {
        return comptime blk: {
            var utf16le: [ascii.len:0]u16 = undefined;
            for (&utf16le, ascii) |*d, s| d.* = nativeToLittle(u16, s);
            const result = utf16le;
            break :blk &result;
        };
    }
};

const w = struct {
    const windows = struct {
        pub const WINAPI: core.CallingConvention = if (core.cpu_arch == .x86) .Stdcall else .C;

        pub const kernel32 = struct {
            pub const HINSTANCE = *opaque {};
            pub const PROC = *const fn () callconv(WINAPI) isize;

            pub extern "kernel32" fn GetModuleHandleW(?[*:0]const u16) callconv(WINAPI) ?HINSTANCE;
            pub extern "kernel32" fn Sleep(c_ulong) callconv(WINAPI) void;
            pub extern "kernel32" fn ExitProcess(c_uint) callconv(WINAPI) noreturn;
        };

        pub const user32 = struct {
            pub const IDI_WARNING: [*:0]align(1) const u16 = @ptrFromInt(32515);
            pub const IDC_CROSS: [*:0]align(1) const u16 = @ptrFromInt(32515);
            pub const CS_OWNDC = 0x0020;
            pub const WS_MAXIMIZEBOX = 0x00010000;
            pub const WS_MINIMIZEBOX = 0x00020000;
            pub const WS_THICKFRAME = 0x00040000;
            pub const WS_SYSMENU = 0x00080000;
            pub const WS_CAPTION = 0x00C00000;
            pub const WS_VISIBLE = 0x10000000;
            pub const WS_OVERLAPPEDWINDOW = WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX;
            pub const CW_USEDEFAULT: c_int = @bitCast(@as(c_uint, 0x80000000));
            pub const PM_REMOVE = 0x0001;
            pub const WM_CREATE = 0x0001;
            pub const WM_DESTROY = 0x0002;
            pub const WM_SIZE = 0x0005;
            pub const WM_PAINT = 0x000F;
            pub const WM_QUIT = 0x0012;
            pub const WM_ERASEBKGND = 0x0014;
            pub const WM_ACTIVATEAPP = 0x001C;
            pub const WM_KEYDOWN = 0x0100;
            pub const WM_KEYUP = 0x0101;
            pub const WM_SYSKEYDOWN = 0x0104;
            pub const WM_SYSKEYUP = 0x0105;
            pub const WM_SYSCOMMAND = 0x0112;
            pub const GWL_STYLE = -16;
            pub const HWND_TOP: ?HWND = @ptrFromInt(0);
            pub const SWP_NOSIZE = 0x0001;
            pub const SWP_NOMOVE = 0x0002;
            pub const SWP_NOZORDER = 0x0004;
            pub const SWP_FRAMECHANGED = 0x0020;
            pub const MONITOR_DEFAULTTOPRIMARY = 0x00000001;
            pub const SC_KEYMENU = 0xF100;
            pub const VK_RETURN = 0x0D;
            pub const VK_ESCAPE = 0x1B;
            pub const VK_F4 = 0x73;
            pub const VK_F10 = 0x79;
            pub const VK_F11 = 0x7A;

            pub const HDC = *opaque {};
            pub const HWND = *opaque {};
            pub const HICON = *opaque {};
            pub const HMENU = *opaque {};
            pub const HBRUSH = *opaque {};
            pub const HCURSOR = *opaque {};
            pub const HMONITOR = *opaque {};
            pub const WNDPROC = *const fn (?HWND, c_uint, usize, isize) callconv(WINAPI) isize;
            pub const POINT = extern struct {
                x: c_long,
                y: c_long,
            };
            pub const RECT = extern struct {
                left: c_long,
                top: c_long,
                right: c_long,
                bottom: c_long,
            };
            pub const WNDCLASSEXW = extern struct {
                cbSize: c_uint,
                style: c_uint,
                lpfnWndProc: ?WNDPROC,
                cbClsExtra: c_int,
                cbWndExtra: c_int,
                hInstance: ?kernel32.HINSTANCE,
                hIcon: ?HICON,
                hCursor: ?HCURSOR,
                hbrBackground: ?HBRUSH,
                lpszMenuName: ?[*:0]const u16,
                lpszClassName: ?[*:0]const u16,
                hIconSm: ?HICON,
            };
            pub const MSG = extern struct {
                hwnd: ?HWND,
                message: c_uint,
                wParam: usize,
                lParam: isize,
                time: c_ulong,
                pt: POINT,
                lPrivate: c_ulong,
            };
            pub const WINDOWPLACEMENT = extern struct {
                length: c_uint,
                flags: c_uint,
                showCmd: c_uint,
                ptMinPosition: POINT,
                ptMaxPosition: POINT,
                rcNormalPosition: RECT,
                rcDevice: RECT,
            };
            pub const MONITORINFO = extern struct {
                cbSize: c_ulong,
                rcMonitor: RECT,
                rcWork: RECT,
                dwFlags: c_ulong,
            };

            pub extern "user32" fn SetProcessDPIAware() callconv(WINAPI) c_int;
            pub extern "user32" fn LoadIconW(?kernel32.HINSTANCE, ?[*:0]align(1) const u16) callconv(WINAPI) ?HICON;
            pub extern "user32" fn LoadCursorW(?kernel32.HINSTANCE, ?[*:0]align(1) const u16) callconv(WINAPI) ?HCURSOR;
            pub extern "user32" fn RegisterClassExW(?*const WNDCLASSEXW) callconv(WINAPI) c_ushort;
            pub extern "user32" fn CreateWindowExW(c_ulong, ?[*:0]const u16, ?[*:0]const u16, c_ulong, c_int, c_int, c_int, c_int, ?HWND, ?HMENU, ?kernel32.HINSTANCE, ?*anyopaque) callconv(WINAPI) ?HWND;
            pub extern "user32" fn PeekMessageW(?*MSG, ?HWND, c_uint, c_uint, c_uint) callconv(WINAPI) c_int;
            pub extern "user32" fn TranslateMessage(?*const MSG) callconv(WINAPI) c_int;
            pub extern "user32" fn DispatchMessageW(?*const MSG) callconv(WINAPI) isize;
            pub extern "user32" fn GetDC(?HWND) callconv(WINAPI) ?HDC;
            pub extern "user32" fn ValidateRect(?HWND, ?*const RECT) callconv(WINAPI) c_int;
            pub extern "user32" fn DestroyWindow(?HWND) callconv(WINAPI) c_int;
            pub extern "user32" fn DefWindowProcW(?HWND, c_uint, usize, isize) callconv(WINAPI) isize;
            pub extern "user32" fn PostQuitMessage(c_int) callconv(WINAPI) void;
            pub extern "user32" fn GetWindowLongPtrW(?HWND, c_int) callconv(WINAPI) isize;
            pub extern "user32" fn SetWindowLongPtrW(?HWND, c_int, isize) callconv(WINAPI) isize;
            pub extern "user32" fn GetWindowPlacement(?HWND, ?*WINDOWPLACEMENT) callconv(WINAPI) c_int;
            pub extern "user32" fn SetWindowPlacement(?HWND, ?*const WINDOWPLACEMENT) callconv(WINAPI) c_int;
            pub extern "user32" fn SetWindowPos(?HWND, ?HWND, c_int, c_int, c_int, c_int, c_uint) callconv(WINAPI) c_int;
            pub extern "user32" fn MonitorFromWindow(?HWND, c_ulong) callconv(WINAPI) ?HMONITOR;
            pub extern "user32" fn GetMonitorInfoW(?HMONITOR, ?*MONITORINFO) callconv(WINAPI) c_int;
        };

        pub const dwmapi = struct {
            pub const DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
            pub const DWMWA_WINDOW_CORNER_PREFERENCE = 33;
            pub const DWMWCP_DONOTROUND = 1;

            pub extern "dwmapi" fn DwmSetWindowAttribute(?user32.HWND, c_ulong, ?*const anyopaque, c_ulong) callconv(WINAPI) c_long;
        };

        pub const winmm = struct {
            pub extern "winmm" fn timeBeginPeriod(c_uint) callconv(WINAPI) c_uint;
        };
    };
    usingnamespace windows;
    usingnamespace windows.kernel32;
    usingnamespace windows.user32;
    usingnamespace windows.dwmapi;
    usingnamespace windows.winmm;
};

pub usingnamespace switch (core.os_tag) {
    .windows => struct {
        pub const platform = struct {
            pub var screen_width: u16 = undefined;
            pub var screen_height: u16 = undefined;

            pub var hinstance: w.HINSTANCE = undefined;
            pub var hwnd: w.HWND = undefined;
            pub var hdc: w.HDC = undefined;
        };

        fn updateCursorClip() void {}

        fn toggleFullscreen() void {
            const S = struct {
                var save_placement = core.zeroInit(w.WINDOWPLACEMENT, .{
                    .length = @sizeOf(w.WINDOWPLACEMENT),
                });
            };

            const style: u32 = @intCast(w.GetWindowLongPtrW(platform.hwnd, w.GWL_STYLE));
            if (style & w.WS_OVERLAPPEDWINDOW != 0) {
                var mi = core.zeroInit(w.MONITORINFO, .{
                    .cbSize = @sizeOf(w.MONITORINFO),
                });
                _ = w.GetMonitorInfoW(w.MonitorFromWindow(platform.hwnd, w.MONITOR_DEFAULTTOPRIMARY), &mi);

                _ = w.GetWindowPlacement(platform.hwnd, &S.save_placement);
                _ = w.SetWindowLongPtrW(platform.hwnd, w.GWL_STYLE, style & ~@as(u32, w.WS_OVERLAPPEDWINDOW));
                _ = w.SetWindowPos(
                    platform.hwnd,
                    w.HWND_TOP,
                    mi.rcMonitor.left,
                    mi.rcMonitor.top,
                    mi.rcMonitor.right - mi.rcMonitor.left,
                    mi.rcMonitor.bottom - mi.rcMonitor.top,
                    w.SWP_FRAMECHANGED,
                );
            } else {
                _ = w.SetWindowLongPtrW(platform.hwnd, w.GWL_STYLE, style | w.WS_OVERLAPPEDWINDOW);
                _ = w.SetWindowPlacement(platform.hwnd, &S.save_placement);
                _ = w.SetWindowPos(platform.hwnd, null, 0, 0, 0, 0, w.SWP_NOSIZE |
                    w.SWP_NOMOVE | w.SWP_NOZORDER | w.SWP_FRAMECHANGED);
            }
        }

        fn windowProc(hwnd: ?w.HWND, message: c_uint, wParam: usize, lParam: isize) callconv(w.WINAPI) isize {
            switch (message) {
                w.WM_PAINT => {
                    _ = w.ValidateRect(hwnd, null);
                },
                w.WM_ERASEBKGND => {
                    return 1;
                },
                w.WM_ACTIVATEAPP => {
                    if (wParam != 0) updateCursorClip();
                },
                w.WM_SIZE => {
                    platform.screen_width = @truncate(@as(usize, @bitCast(lParam)));
                    platform.screen_height = @truncate(@as(usize, @bitCast(lParam)) >> 16);
                },
                w.WM_CREATE => {
                    platform.hwnd = hwnd.?;
                    platform.hdc = w.GetDC(hwnd).?;

                    const dark_mode: c_uint = @intFromBool(true);
                    _ = w.DwmSetWindowAttribute(hwnd, w.DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, @sizeOf(@TypeOf(dark_mode)));
                    const round_mode: c_uint = w.DWMWCP_DONOTROUND;
                    _ = w.DwmSetWindowAttribute(hwnd, w.DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, @sizeOf(@TypeOf(round_mode)));
                },
                w.WM_DESTROY => {
                    w.PostQuitMessage(0);
                },
                else => {
                    if (message == w.WM_SYSCOMMAND and wParam == w.SC_KEYMENU) return 0;
                    return w.DefWindowProcW(hwnd, message, wParam, lParam);
                },
            }
            return 0;
        }

        pub export fn WinMainCRTStartup() callconv(w.WINAPI) noreturn {
            @setAlignStack(16);

            platform.hinstance = w.GetModuleHandleW(null).?;

            const sleep_is_granular = w.timeBeginPeriod(1) == 0;

            _ = w.SetProcessDPIAware();
            const wndclass = core.zeroInit(w.WNDCLASSEXW, .{
                .cbSize = @sizeOf(w.WNDCLASSEXW),
                .style = w.CS_OWNDC,
                .lpfnWndProc = windowProc,
                .hInstance = platform.hinstance,
                .hIcon = w.LoadIconW(null, w.IDI_WARNING).?,
                .hCursor = w.LoadCursorW(null, w.IDC_CROSS).?,
                .lpszClassName = core.utf8ToUtf16LeStringLiteral("A"),
            });
            _ = w.RegisterClassExW(&wndclass);
            _ = w.CreateWindowExW(
                0,
                wndclass.lpszClassName,
                core.utf8ToUtf16LeStringLiteral("caveman"),
                w.WS_OVERLAPPEDWINDOW | w.WS_VISIBLE,
                w.CW_USEDEFAULT,
                w.CW_USEDEFAULT,
                w.CW_USEDEFAULT,
                w.CW_USEDEFAULT,
                null,
                null,
                platform.hinstance,
                null,
            ).?;

            game_loop: while (true) {
                var msg: w.MSG = undefined;
                while (w.PeekMessageW(&msg, null, 0, 0, w.PM_REMOVE) != 0) {
                    _ = w.TranslateMessage(&msg);
                    switch (msg.message) {
                        w.WM_KEYDOWN, w.WM_KEYUP, w.WM_SYSKEYDOWN, w.WM_SYSKEYUP => {
                            const pressed = msg.lParam & 1 << 31 == 0;
                            const repeat = pressed and msg.lParam & 1 << 30 != 0;
                            const sys = msg.message == w.WM_SYSKEYDOWN or msg.message == w.WM_SYSKEYUP;
                            const alt = sys and msg.lParam & 1 << 29 != 0;

                            if (!repeat and (!sys or alt or msg.wParam == w.VK_F10)) {
                                if (pressed) {
                                    if (msg.wParam == w.VK_F4 and alt) _ = w.DestroyWindow(platform.hwnd);
                                    if (msg.wParam == w.VK_F11 or (msg.wParam == w.VK_RETURN and alt)) toggleFullscreen();
                                    if (core.build_mode == .Debug and msg.wParam == w.VK_ESCAPE) _ = w.DestroyWindow(platform.hwnd);
                                }
                            }
                        },
                        w.WM_QUIT => break :game_loop,
                        else => _ = w.DispatchMessageW(&msg),
                    }
                }

                if (sleep_is_granular) {
                    w.Sleep(1);
                }
            }

            w.ExitProcess(0);
        }
    },
    else => unreachable,
};
