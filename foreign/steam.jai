steamapi :: #library "../vendor/steam_api64";

SteamAPI_Init_Result :: enum u32 #specified {
    OK :: 0;
    FAILED_GENERIC :: 1;
    NO_STEAM_CLIENT :: 2;
    VERSION_MISMATCH :: 3;
}

SteamAPI_InitFlat :: (_: *[1024]u8) -> SteamAPI_Init_Result #foreign steamapi;
SteamAPI_RunCallbacks :: () #foreign steamapi;
SteamAPI_Shutdown :: () #foreign steamapi;
