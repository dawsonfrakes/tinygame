#define TARGET_OS_WINDOWS 1
#define TARGET_CPU_ARCH_AMD64 1

#include "basic.h"

#if TARGET_OS_WINDOWS
#include "main_windows.c"
#endif
