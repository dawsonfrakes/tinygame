int main(string[] args) {
    import std.array : split;
    import std.file : copy;
    import std.process : spawnProcess, wait;
    import std.stdio : toFile, writeln;

    int exit_code = "dmd -of=.out/game.exe -g -betterC game.d -L=-incremental:no".split.spawnProcess.wait;
    if (exit_code != 0) return 1;

    "steam_api64.dll".copy(".out/steam_api64.dll");
    "480".toFile(".out/steam_appid.txt");

    if (args.length > 1) switch (args[1]) {
        case "run": ".out/game.exe".spawnProcess.wait; break;
        case "debug": "remedybg .out/game.exe".split.spawnProcess; break;
        case "doc": "qrenderdoc .out/game.exe".split.spawnProcess; break;
        default: writeln("command '", args[1], "' not found");
    }

    return 0;
}
