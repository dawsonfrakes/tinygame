// steam
#define k_EFriendFlagAll 0xFFFF

typedef char SteamErrMsg[1024];
typedef struct ISteamFriends__* ISteamFriends;
typedef struct ISteamUtils__* ISteamUtils;

#define STEAM_FUNCTIONS \
	X(s32, SteamAPI_InitFlat, SteamErrMsg*) \
	X(void, SteamAPI_RunCallbacks, void) \
	X(ISteamFriends, SteamAPI_SteamFriends_v017, void) \
	X(u64, SteamAPI_ISteamFriends_GetFriendByIndex, ISteamFriends, s32, s32) \
	X(s32, SteamAPI_ISteamFriends_GetFriendCount, ISteamFriends, s32) \
	X(s32, SteamAPI_ISteamFriends_GetMediumFriendAvatar, ISteamFriends, u64) \
	X(u8*, SteamAPI_ISteamFriends_GetPersonaName, ISteamFriends) \
	X(u8*, SteamAPI_ISteamFriends_GetFriendPersonaName, ISteamFriends, u64) \
	X(ISteamUtils, SteamAPI_SteamUtils_v010, void) \
	X(bool, SteamAPI_ISteamUtils_GetImageRGBA, ISteamUtils, s32, u8*, s32) \
	X(void, SteamAPI_Shutdown, void)
