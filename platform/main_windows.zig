const core = @import("core");
const w = struct {
    const windows = core.windows;
    usingnamespace windows;
    usingnamespace windows.kernel32;
    usingnamespace windows.user32;
};

pub const platform = struct {
    pub var hinstance: w.HINSTANCE = undefined;
};

pub export fn WinMainCRTStartup() callconv(w.WINAPI) noreturn {
    @setAlignStack(16);

    platform.hinstance = w.GetModuleHandleW(null).?;

    w.ExitProcess(0);
}
