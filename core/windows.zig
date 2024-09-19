const core = @import("core.zig");

pub const WINAPI: core.CallingConvention = if (core.cpu_arch == .x86) .Stdcall else .C;

pub const kernel32 = struct {
    pub const HINSTANCE = *opaque {};

    pub extern "kernel32" fn GetModuleHandleW(?[*:0]const u16) callconv(WINAPI) ?HINSTANCE;
    pub extern "kernel32" fn ExitProcess(c_uint) callconv(WINAPI) noreturn;
};

pub const user32 = struct {};
