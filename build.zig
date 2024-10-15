const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "Colliders",
        .root_source_file = b.path("game.zig"),
        .target = target,
        .optimize = optimize,
        .single_threaded = true,
    });
    if (target.result.os.tag == .windows) {
        exe.subsystem = .Windows;
        b.installBinFile("steam_api64.dll", "steam_api64.dll");
        if (optimize == .Debug) {
            var wf = b.addWriteFiles();
            b.getInstallStep().dependOn(&b.addInstallBinFile(
                wf.add("steam_appid.txt", "480"),
                "steam_appid.txt",
            ).step);
        }
    }
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    b.step("run", "run game").dependOn(&run_cmd.step);
}
