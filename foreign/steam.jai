steamapi :: #library "../vendor/steam_api64";

ISteamUser :: #type,distinct *void;
ISteamUtils :: #type,distinct *void;
ISteamFriends :: #type,distinct *void;
SteamAPI_Init_Result :: enum u32 #specified {
    OK :: 0;
    FAILED_GENERIC :: 1;
    NO_STEAM_CLIENT :: 2;
    VERSION_MISMATCH :: 3;
}
SteamAPI_Friend_Flags :: enum_flags s32 {
    NONE :: 0x0000;
    BLOCKED :: 0x0001;
    FRIENDSHIP_REQUESTED :: 0x0002;
    IMMEDIATE :: 0x0004;
    CLAN_MEMBER :: 0x0008;
    ON_GAME_SERVER :: 0x0010;
    REQUESTING_FRIENDSHIP :: 0x0080;
    REQUESTING_INFO :: 0x0100;
    IGNORED :: 0x0200;
    IGNORED_FRIEND :: 0x0400;
    CHAT_MEMBER :: 0x1000;
    ALL :: 0xFFFF;
}

SteamAPI_InitFlat :: (_: *[1024]u8) -> SteamAPI_Init_Result #foreign steamapi;
SteamAPI_RunCallbacks :: () #foreign steamapi;
SteamAPI_Shutdown :: () #foreign steamapi;
SteamAPI_SteamFriends_v017 :: () -> ISteamFriends #foreign steamapi;
SteamAPI_ISteamFriends_GetPersonaName :: (_: ISteamFriends) -> *u8 #foreign steamapi;
SteamAPI_ISteamFriends_GetFriendCount :: (_: ISteamFriends, _: SteamAPI_Friend_Flags) -> s32 #foreign steamapi;
SteamAPI_ISteamFriends_GetFriendByIndex :: (_: ISteamFriends, _: s32, _: SteamAPI_Friend_Flags) -> u64 #foreign steamapi;
SteamAPI_ISteamFriends_GetFriendPersonaName :: (_: ISteamFriends, _: u64) -> *u8 #foreign steamapi;
SteamAPI_ISteamFriends_GetMediumFriendAvatar :: (_: ISteamFriends, _: u64) -> s32 #foreign steamapi;
SteamAPI_SteamUtils_v010 :: () -> ISteamUtils #foreign steamapi;
SteamAPI_ISteamUtils_GetImageRGBA :: (_: ISteamUtils, _: s32, _: *u8, _: s32) -> bool #foreign steamapi;
SteamAPI_SteamUser_v023 :: () -> ISteamUser #foreign steamapi;
SteamAPI_ISteamUser_GetSteamID :: (_: ISteamUser) -> u64 #foreign steamapi;
