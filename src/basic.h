#if defined(_WIN32) || defined(_WIN64) || defined(__WIN32__)
#define OS_WINDOWS 1
#else
#define OS_WINDOWS 0
#endif

#if defined(_MSC_VER)
#define COMPILER_MSVC 1
#else
#define COMPILER_MSVC 0
#endif

#define cast(T) (T)
#define size_of(T) sizeof(T)
#define offset_of(T, F) (cast(u64) &(cast(T*) 0)->F)
#define min(X, Y) ((X) < (Y) ? (X) : (Y))
#define max(X, Y) ((X) > (Y) ? (X) : (Y))
#define len(X) (size_of(X) / size_of((X)[0]))
#define str(X) (cast(string) {len(X) - 1, (X)})

#define null (cast(void*) 0)
#define true (cast(_Bool) 1)
#define false (cast(_Bool) 0)

typedef signed char s8;
typedef short s16;
typedef int s32;
typedef long long s64;

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;

typedef float float32;
typedef double float64;

typedef u8 bool;
