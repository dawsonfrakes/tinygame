int main(string[] args) {
    import std.array : split;
    import std.file : copy;
    import std.process : spawnProcess, wait;
    import std.stdio : toFile;

    int exit_code = "dmd -of=.out/game.exe -g -betterC game.d -L=-incremental:no".split.spawnProcess.wait;
    if (exit_code != 0) return 1;

    "steam_api64.dll".copy(".out/steam_api64.dll");
    "480".toFile(".out/steam_appid.txt");

    if (args.length > 1 && args[1] == "run") {
        ".out/game.exe".spawnProcess.wait;
    }

    return 0;
}
