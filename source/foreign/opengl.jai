// 1.0
GL_COLOR_BUFFER_BIT :: 0x00004000;
GL_TRIANGLES :: 0x0004;
GL_TEXTURE_2D :: 0x0DE1;
GL_UNSIGNED_BYTE :: 0x1401;
GL_UNSIGNED_INT :: 0x1405;
GL_FLOAT :: 0x1406;
GL_COLOR :: 0x1800;
GL_RGB :: 0x1907;
GL_RGBA :: 0x1908;
GL_NEAREST :: 0x2600;
GL_LINEAR :: 0x2601;
GL_TEXTURE_MAG_FILTER :: 0x2800;
GL_TEXTURE_MIN_FILTER :: 0x2801;
GL_TEXTURE_WRAP_S :: 0x2802;
GL_TEXTURE_WRAP_T :: 0x2803;

glEnable : (_: u32) #c_call;
glDisable : (_: u32) #c_call;
glGetIntegerv : (_: u32, _: *s32) #c_call;
glViewport : (_: s32, _: s32, _: u32, _: u32) #c_call;
glClearColor : (_: float32, _: float32, _: float32, _: float32) #c_call;
glClear : (_: u32) #c_call;

// 1.1
GL_RGB8 :: 0x8051;
GL_RGBA8 :: 0x8058;

// 1.2
GL_CLAMP_TO_EDGE :: 0x812F;

// 1.5
GL_STREAM_DRAW :: 0x88E0;
GL_STATIC_DRAW :: 0x88E4;

// 2.0
GL_FRAGMENT_SHADER :: 0x8B30;
GL_VERTEX_SHADER :: 0x8B31;
GL_LOWER_LEFT :: 0x8CA1;

glCreateProgram : () -> u32 #c_call;
glAttachShader : (_: u32, _: u32) #c_call;
glDetachShader : (_: u32, _: u32) #c_call;
glLinkProgram : (_: u32) #c_call;
glUseProgram : (_: u32) #c_call;
glCreateShader : (_: u32) -> u32 #c_call;
glDeleteShader : (_: u32) #c_call;
glShaderSource : (_: u32, _: u32, **u8, *s32) #c_call;
glCompileShader : (_: u32) #c_call;

// 3.0
GL_RGBA16F :: 0x881A;
GL_COLOR_ATTACHMENT0 :: 0x8CE0;
GL_FRAMEBUFFER :: 0x8D40;
GL_RENDERBUFFER :: 0x8D41;
GL_FRAMEBUFFER_SRGB :: 0x8DB9;

glBindFramebuffer : (_: u32, _: u32) #c_call;
glBindVertexArray : (_: u32) #c_call;

// 3.2
GL_MAX_COLOR_TEXTURE_SAMPLES :: 0x910E;
GL_MAX_DEPTH_TEXTURE_SAMPLES :: 0x910F;

// 4.1
glProgramUniform1i : (_: u32, _: s32, _: s32) #c_call;

// 4.2
glDrawElementsInstancedBaseVertexBaseInstance : (_: u32, _: u32, _: u32, _: *void, _: u32, _: s32, _: u32) #c_call;

// 4.5
GL_ZERO_TO_ONE :: 0x935F;

glClipControl : (_: u32, _: u32) #c_call;
glCreateFramebuffers : (_: u32, _: *u32) #c_call;
glNamedFramebufferRenderbuffer : (_: u32, _: u32, _: u32, _: u32) #c_call;
glClearNamedFramebufferfv : (_: u32, _: u32, _: s32, _: *float32) #c_call;
glBlitNamedFramebuffer : (_: u32, _: u32, _: s32, _: s32, _: s32, _: s32, _: s32, _: s32, _: s32, _: s32, _: u32, _: u32) #c_call;
glCreateRenderbuffers : (_: u32, _: *u32) #c_call;
glNamedRenderbufferStorageMultisample : (_: u32, _: u32, _: u32, _: u32, _: u32) #c_call;
glCreateVertexArrays : (_: u32, _: *u32) #c_call;
glVertexArrayElementBuffer : (_: u32, _: u32) #c_call;
glVertexArrayVertexBuffer : (_: u32, _: u32, _: u32, _: s64, _: u32) #c_call;
glVertexArrayBindingDivisor : (_: u32, _: u32, _: u32) #c_call;
glEnableVertexArrayAttrib : (_: u32, _: u32) #c_call;
glVertexArrayAttribBinding : (_: u32, _: u32, _: u32) #c_call;
glVertexArrayAttribFormat : (_: u32, _: u32, _: s32, _: u32, _: bool, _: u32) #c_call;
glVertexArrayAttribIFormat : (_: u32, _: u32, _: s32, _: u32, _: u32) #c_call;
glCreateBuffers : (_: u32, _: *u32) #c_call;
glNamedBufferData : (_: u32, _: u64, _: *void, _: u32) #c_call;
glCreateTextures : (_: u32, _: u32, _: *u32) #c_call;
glTextureStorage2D : (_: u32, _: u32, _: u32, _: u32, _: u32) #c_call;
glTextureSubImage2D : (_: u32, _: s32, _: s32, _: s32, _: u32, _: u32, _: u32, _: u32, _: *void) #c_call;
glTextureParameteri : (_: u32, _: u32, _: s32) #c_call;
glBindTextureUnit : (_: u32, _: u32) #c_call;
