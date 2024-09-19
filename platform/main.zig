const core = @import("core");

pub usingnamespace switch (core.os_tag) {
    .windows => @import("main_windows.zig"),
    else => unreachable,
};
