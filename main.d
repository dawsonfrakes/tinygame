#!dmd -betterC -run main.d

enum DEVELOPER = true;

version (Windows) {
import windows;

__gshared HINSTANCE platform_hinstance;

extern(Windows) noreturn WinMainCRTStartup() {
    platform_hinstance = GetModuleHandleW(null);

    ExitProcess(0);
}

pragma(linkerDirective, "-subsystem:windows");
pragma(lib, "kernel32");
pragma(lib, "user32");
}
