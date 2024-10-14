#if !defined(NDEBUG)
#define BUILD_MODE_DEBUG 1
#else
#define BUILD_MODE_DEBUG 0
#endif

#if defined(__x86_64__) || defined(_M_AMD64)
#define TARGET_CPU_ARCH_AMD64 1
#else
#define TARGET_CPU_ARCH_AMD64 0
#endif

#if defined(_WIN32) || defined(_WIN64) || defined(__WIN32__)
#define TARGET_OS_WINDOWS 1
#else
#define TARGET_OS_WINDOWS 0
#endif

#if defined(_MSC_VER)
#define COMPILER_MSVC 1
#else
#define COMPILER_MSVC 0
#endif

#if defined(__TINYC__)
#define COMPILER_TCC 1
#else
#define COMPILER_TCC 0
#endif

#define cast(T) (T)
#define size_of(T) sizeof(T)
#define offset_of(T, F) (cast(u64) &(cast(T*) 0)->F)
#define align_of(T) offset_of(struct { u8 x; T t; }, t)
#define len(X) (size_of(X) / size_of((X)[0]))
#define str(X) {len(X) - 1, (X)}
#define min(X, Y) ((X) < (Y) ? (X) : (Y))
#define max(X, Y) ((X) > (Y) ? (X) : (Y))

#define null (cast(void*) 0)
#define true (cast(_Bool) 1)
#define false (cast(_Bool) 0)

#if COMPILER_MSVC
#define align(N) __declspec(align(N))
#define debug_break() __debugbreak()
#elif COMPILER_TCC
#define align(N) __attribute__((aligned(N)))
#define debug_break() __asm__ ("int3")
#endif

#if BUILD_MODE_DEBUG
#define assert(X) do if (!(X)) debug_break(); while (0)
#else
#define assert(X) (cast(void) (X))
#undef debug_break
#endif

#if TARGET_CPU_ARCH_AMD64
typedef signed char s8;
typedef short s16;
typedef int s32;
typedef long long s64;

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;
#endif

typedef u8 bool;

typedef float f32;

#if TARGET_OS_WINDOWS
// kernel32
typedef struct HINSTANCE__* HINSTANCE;
typedef s64 (*PROC)(void);

#define KERNEL32_FUNCTIONS \
    X(HINSTANCE, GetModuleHandleW, u16*) \
    X(void, ExitProcess, u32)
#endif

#if TARGET_OS_WINDOWS
#define X(RET, NAME, ...) RET NAME(__VA_ARGS__);
KERNEL32_FUNCTIONS
#undef X

static HINSTANCE platform_hinstance;

void WinMainCRTStartup(void) {
    platform_hinstance = GetModuleHandleW(null);

    ExitProcess(0);
}
#endif
