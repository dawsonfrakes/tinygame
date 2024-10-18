DEVELOPER :: true;
OPENGL :: true;
STEAM :: true;

platform_screen_width : u16 = ---;
platform_screen_height : u16 = ---;
#if STEAM {
	platform_steam_enabled := false;
}
#if OS == .WINDOWS {
	platform_hinstance : HINSTANCE = ---;
	platform_hwnd : HWND = ---;
	platform_hdc : HDC = ---;
}

#scope_file

#load "core.jai";
#if OS == .WINDOWS #load "foreign/windows.jai";
#if STEAM #load "foreign/steam.jai";
#if OPENGL #load "foreign/opengl.jai";

#if OS == .WINDOWS #load "platform/windows.jai";
else #assert false "this os is not currently supported";
