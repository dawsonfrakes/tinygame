#if OS_WINDOWS
HGLRC opengl_ctx;

void opengl_platform_init(void) {
    PIXELFORMATDESCRIPTOR pfd = {0};
    pfd.nSize = size_of(PIXELFORMATDESCRIPTOR);
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL |
        PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
    pfd.cColorBits = 24;
    s32 format = ChoosePixelFormat(windows_hdc, &pfd);
    SetPixelFormat(windows_hdc, format, &pfd);

    HGLRC temp_ctx = wglCreateContext(windows_hdc);
    wglMakeCurrent(windows_hdc, temp_ctx);
}

void opengl_platform_deinit(void) {
    if (opengl_ctx) wglDeleteContext(opengl_ctx);
    opengl_ctx = null;
}

void opengl_platform_present(void) {
    SwapBuffers(windows_hdc);
}
#endif

void opengl_init(void) {
    opengl_platform_init();
}

void opengl_deinit(void) {
    opengl_platform_deinit();
}

void opengl_resize(void) {

}

void opengl_present(void) {
    glClearColor(0.6f, 0.2f, 0.2f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    opengl_platform_present();
}
