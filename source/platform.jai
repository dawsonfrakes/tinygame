DEVELOPER :: true;
OPENGL :: true;
STEAM :: true;

platform_screen_width : u16 = ---;
platform_screen_height : u16 = ---;
#if STEAM {
	platform_steam_enabled := false;
	steam_user : ISteamUser = ---;
	steam_utils : ISteamUtils = ---;
	steam_friends : ISteamFriends = ---;

	steam_friend_count : s16 = 0;
	steam_selected_friend_index : s16 = 0;
}
#if OS == .WINDOWS {
	platform_hinstance : HINSTANCE = ---;
	platform_hwnd : HWND = ---;
	platform_hdc : HDC = ---;
	#if OPENGL {
		opengl_ctx : HGLRC = ---;
	}
}
#if OPENGL {
    opengl_main_fbo : u32 = ---;
    opengl_main_fbo_color0 : u32 = ---;

    opengl_rect_vao : u32 = ---;
    opengl_rect_ibo : u32 = ---;
    opengl_rect_shader : u32 = ---;
    opengl_rect_textures : [32] u32 = ---;

}

#scope_file

#load "core.jai";
#if OS == .WINDOWS #load "foreign/windows.jai";
#if STEAM #load "foreign/steam.jai";
#if OPENGL #load "foreign/opengl.jai";

#if OS == .WINDOWS #load "platform/windows.jai";
else #assert false "this os is not currently supported";
#if OPENGL #load "platform/opengl.jai";
