#define true 1
#define false 0
#define null ((void*) 0)
#define min(X, Y) ((X) < (Y) ? (X) : (Y))
#define max(X, Y) ((X) > (Y) ? (X) : (Y))
#define len(X) (sizeof(X) / sizeof((X)[0]))
#define str(X) {len(X) - 1, (X)}

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
    u64 count;
    u8* data;
} string;
