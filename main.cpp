#include "basic.hpp"

#if TARGET_OS_WINDOWS
#include "windows.hpp"
HINSTANCE windows_hinstance;
#include "main_windows.cpp"
#endif
