// 1.0
GL_COLOR_BUFFER_BIT :: 0x00004000;

glEnable : (_: u32) #c_call;
glDisable : (_: u32) #c_call;
glViewport : (_: s32, _: s32, _: u32, _: u32) #c_call;
glClearColor : (_: float32, _: float32, _: float32, _: float32) #c_call;
glClear : (_: u32) #c_call;

// 2.0
GL_LOWER_LEFT :: 0x8CA1;

// 4.5
GL_ZERO_TO_ONE :: 0x935F;

glClipControl : (_: u32, _: u32) #c_call;
