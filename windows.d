import utils : AliasOpaque;

// kernel32
mixin AliasOpaque!"HINSTANCE";

extern(Windows) HINSTANCE GetModuleHandleW(const(wchar)*);
extern(Windows) noreturn ExitProcess(uint);
