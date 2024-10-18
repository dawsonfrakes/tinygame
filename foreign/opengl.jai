gl10 :: struct {
    GL_COLOR_BUFFER_BIT :: 0x00004000;

    glEnable :: (_: u32) #foreign;
    glDisable :: (_: u32) #foreign;
    glViewport :: (_: s32, _: s32, _: u32, _: u32) #foreign;
    glClearColor :: (_: float32, _: float32, _: float32, _: float32) #foreign;
    glClear :: (_: u32) #foreign;
}

gl20 :: struct {
    GL_LOWER_LEFT :: 0x8CA1;
}

gl45 :: struct {
    GL_ZERO_TO_ONE :: 0x935F;

    glClipControl :: (_: u32, _: u32) #foreign;
}
