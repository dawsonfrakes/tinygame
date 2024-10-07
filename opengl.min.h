// 1.0
#define GL_COLOR_BUFFER_BIT 0x00004000

#define GL10_FUNCTIONS \
	X(void, glEnable, u32) \
	X(void, glDisable, u32) \
	X(void, glGetIntegerv, u32, s32*) \
	X(void, glDepthFunc, u32) \
	X(void, glBlendFunc, u32, u32) \
	X(void, glViewport, s32, s32, u32, u32) \
	X(void, glClearColor, f32, f32, f32, f32) \
	X(void, glClear, u32)

// 3.0
#define GL_FRAMEBUFFER_SRGB 0x8DB9
