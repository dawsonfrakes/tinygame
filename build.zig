const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "game",
        .root_source_file = b.path("platform/main.zig"),
        .target = target,
        .optimize = optimize,
        .single_threaded = true,
    });
    exe.root_module.addAnonymousImport("core", .{
        .root_source_file = b.path("core/core.zig"),
    });
    b.installArtifact(exe);

    b.step("run", "run game")
        .dependOn(&b.addRunArtifact(exe).step);
}
