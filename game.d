version (D_BetterC) {} else pragma(msg, "warning: -betterC recommended");

alias AliasSeq(T...) = T;

version(Windows) {
    // kernel32
    extern extern(Windows) noreturn ExitProcess(uint);

    extern(Windows) noreturn WinMainCRTStartup() {
        ExitProcess(0);
    }

    pragma(linkerDirective, "-subsystem:windows");
    pragma(lib, "kernel32");
}
