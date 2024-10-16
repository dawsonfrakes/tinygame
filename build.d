#!rdmd

void main() {
    import std.array : split;
    import std.process : spawnProcess, wait;
    import std.file : copy;
    import std.stdio : toFile;

    "dmd -of=./.out/game.exe -g -betterC game.d -L=-incremental:no".split.spawnProcess.wait;
    "steam_api64.dll".copy(".out/steam_api64.dll");
    "480".toFile(".out/steam_appid.txt");
}
