// 1.0
#define GL_COLOR_BUFFER_BIT 0x00004000
#define GL_TRIANGLES 0x0004
#define GL_UNSIGNED_BYTE 0x1401
#define GL_FLOAT 0x1406
#define GL_TEXTURE_2D 0x0DE1
#define GL_RGB 0x1907
#define GL_RGBA 0x1908
#define GL_LINEAR 0x2601
#define GL_TEXTURE_MIN_FILTER 0x2801
#define GL_TEXTURE_WRAP_S 0x2802
#define GL_TEXTURE_WRAP_T 0x2803

#define GL10_FUNCTIONS \
	X(void, glEnable, u32) \
	X(void, glDisable, u32) \
	X(void, glGetIntegerv, u32, s32*) \
	X(void, glDepthFunc, u32) \
	X(void, glBlendFunc, u32, u32) \
	X(void, glViewport, s32, s32, u32, u32) \
	X(void, glClearColor, f32, f32, f32, f32) \
	X(void, glClear, u32)

// 1.1
#define GL_RGB8 0x8051

#define GL11_FUNCTIONS \
	X(void, glDrawElements, u32, u32, u32, void*)

// 1.2
#define GL_CLAMP_TO_EDGE 0x812F

// 1.5
#define GL_STREAM_DRAW 0x88E0
#define GL_STATIC_DRAW 0x88E4

// 2.0
#define GL_FRAGMENT_SHADER 0x8B30
#define GL_VERTEX_SHADER 0x8B31
#define GL_LOWER_LEFT 0x8CA1

#define GL20_FUNCTIONS \
	X(u32, glCreateProgram, void) \
	X(void, glAttachShader, u32, u32) \
	X(void, glDetachShader, u32, u32) \
	X(void, glLinkProgram, u32) \
	X(void, glUseProgram, u32) \
	X(u32, glCreateShader, u32) \
	X(void, glDeleteShader, u32) \
	X(void, glShaderSource, u32, u32, u8**, s32*) \
	X(void, glCompileShader, u32)

// 3.0
#define GL_FRAMEBUFFER_SRGB 0x8DB9

// 3.0
#define GL30_FUNCTIONS \
	X(void, glBindFramebuffer, u32, u32) \
	X(void, glBindVertexArray, u32)

// 3.1
#define GL31_FUNCTIONS \
	X(void, glDrawElementsInstanced, u32, u32, u32, void*, u32)

// 4.5
#define GL_ZERO_TO_ONE 0x935F

#define GL45_FUNCTIONS \
	X(void, glClipControl, u32, u32) \
	X(void, glCreateVertexArrays, u32, u32*) \
	X(void, glVertexArrayElementBuffer, u32, u32) \
	X(void, glVertexArrayVertexBuffer, u32, u32, u32, s64, u32) \
	X(void, glVertexArrayBindingDivisor, u32, u32, u32) \
	X(void, glEnableVertexArrayAttrib, u32, u32) \
	X(void, glVertexArrayAttribBinding, u32, u32, u32) \
	X(void, glVertexArrayAttribFormat, u32, u32, s32, u32, bool, u32) \
	X(void, glCreateBuffers, u32, u32*) \
	X(void, glNamedBufferData, u32, u64, void*, u32) \
	X(void, glNamedBufferSubData, u32, s64, u64, void*) \
	X(void, glCreateTextures, u32, u32, u32*) \
	X(void, glTextureStorage2D, u32, u32, u32, u32, u32) \
	X(void, glTextureSubImage2D, u32, s32, s32, s32, u32, u32, u32, u32, void*) \
	X(void, glTextureParameteri, u32, u32, s32) \
	X(void, glBindTextureUnit, u32, u32)

// WGL_ARB_create_context
#define WGL_CONTEXT_MAJOR_VERSION_ARB 0x2091
#define WGL_CONTEXT_MINOR_VERSION_ARB 0x2092
#define WGL_CONTEXT_FLAGS_ARB 0x2094
#define WGL_CONTEXT_PROFILE_MASK_ARB 0x9126
#define WGL_CONTEXT_DEBUG_BIT_ARB 0x0001
#define WGL_CONTEXT_CORE_PROFILE_BIT_ARB 0x00000001
