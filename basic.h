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

#define null (cast(void*) 0)
#define true (cast(_Bool) 1)
#define false (cast(_Bool) 0)
#define cast(T) (T)
#define size_of(T) sizeof(T)
#define offset_of(T, F) (cast(u64) &(cast(T*) 0)->F)
#define len(X) (size_of(X) / size_of((X)[0]))
#define str(X) (cast(string) {len(X) - 1, cast(u8*) (X)})
#define min(X, Y) ((X) < (Y) ? (X) : (Y))
#define max(X, Y) ((X) > (Y) ? (X) : (Y))

#if BUILD_MODE_DEBUG
    #if COMPILER_TCC
    #define assert(X) do if (!(X)) __asm__ ("int3"); while (0)
    #elif COMPILER_MSVC
    #define assert(X) do if (!(X)) __debugbreak(); while (0)
    #else
    #error assert not defined for this compiler
    #endif
#else
#define assert(X) (cast(void) (X))
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

typedef float float32;
typedef double float64;

typedef u8 bool;

typedef struct {
    float32 x;
    float32 y;
} v2;

typedef struct {
    float32 x;
    float32 y;
    float32 z;
} v3;

typedef struct {
    float32 x;
    float32 y;
    float32 z;
    float32 w;
} v4;

typedef struct {
    float32 e[16];
} m4;

typedef struct {
    u64 count;
    u8* data;
} string;

#if COMPILER_TCC && TARGET_CPU_ARCH_AMD64
void* memset(void*, s32, u64);
void* memset(void* a, s32 b, u64 c) {
    __asm__ ("rep stosb" :: "D" (a), "a" (b), "c" (c));
    return a;
}
#endif
