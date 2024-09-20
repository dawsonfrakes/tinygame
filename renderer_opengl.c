// 1.0
#define GL_COLOR_BUFFER_BIT 0x00004000
#define GL_COLOR 0x1800
#define GL_DEPTH 0x1801
#define GL_NEAREST 0x2600

#define GL10_FUNCTIONS \
    X(void, glEnable, u32) \
    X(void, glDisable, u32) \
    X(void, glGetIntegerv, u32, s32*) \
    X(void, glClearColor, float32, float32, float32, float32) \
    X(void, glClear, u32)

// 3.0
#define GL_RGBA16F 0x881A
#define GL_DEPTH_COMPONENT32F 0x8CAC
#define GL_COLOR_ATTACHMENT0 0x8CE0
#define GL_DEPTH_ATTACHMENT 0x8D00
#define GL_FRAMEBUFFER 0x8D40
#define GL_RENDERBUFFER 0x8D41
#define GL_FRAMEBUFFER_SRGB 0x8DB9

#define GL30_FUNCTIONS \
    X(void, glBindFramebuffer, u32, u32) \
    X(void, glBindVertexArray, u32)

// 3.2
#define GL_MAX_COLOR_TEXTURE_SAMPLES 0x910E
#define GL_MAX_DEPTH_TEXTURE_SAMPLES 0x910F

// 4.5
#define GL45_FUNCTIONS \
    X(void, glCreateFramebuffers, u32, u32*) \
    X(void, glNamedFramebufferRenderbuffer, u32, u32, u32, u32) \
    X(void, glClearNamedFramebufferfv, u32, u32, s32, float32*) \
    X(void, glBlitNamedFramebuffer, u32, u32, s32, s32, s32, s32, s32, s32, s32, s32, u32, u32) \
    X(void, glCreateRenderbuffers, u32, u32*) \
    X(void, glNamedRenderbufferStorageMultisample, u32, u32, u32, u32, u32)

#if TARGET_OS_WINDOWS
#define WGL_CONTEXT_MAJOR_VERSION_ARB 0x2091
#define WGL_CONTEXT_MINOR_VERSION_ARB 0x2092
#define WGL_CONTEXT_FLAGS_ARB 0x2094
#define WGL_CONTEXT_PROFILE_MASK_ARB 0x9126
#define WGL_CONTEXT_DEBUG_BIT_ARB 0x0001
#define WGL_CONTEXT_CORE_PROFILE_BIT_ARB 0x00000001

#define X(RET, NAME, ...) RET NAME(__VA_ARGS__);
GL10_FUNCTIONS
#undef X

static HGLRC opengl_ctx;
#define X(RET, NAME, ...) static RET (*NAME)(__VA_ARGS__);
GL30_FUNCTIONS
GL45_FUNCTIONS
#undef X

static void opengl_platform_init(void) {
    PIXELFORMATDESCRIPTOR pfd = {0};
    pfd.nSize = size_of(PIXELFORMATDESCRIPTOR);
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL |
        PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
    pfd.cColorBits = 24;
    s32 format = ChoosePixelFormat(platform_hdc, &pfd);
    SetPixelFormat(platform_hdc, format, &pfd);

    HGLRC temp_ctx = wglCreateContext(platform_hdc);
    wglMakeCurrent(platform_hdc, temp_ctx);

    HGLRC (*wglCreateContextAttribsARB)(HDC, HGLRC, s32*) =
        cast(HGLRC (*)(HDC, HGLRC, s32*))
        wglGetProcAddress("wglCreateContextAttribsARB");

    s32 attribs[] = {
        WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
        WGL_CONTEXT_MINOR_VERSION_ARB, 6,
        WGL_CONTEXT_FLAGS_ARB, DEVELOPER ? WGL_CONTEXT_DEBUG_BIT_ARB : 0,
        WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
        0,
    };
    opengl_ctx = wglCreateContextAttribsARB(platform_hdc, null, attribs);
    wglMakeCurrent(platform_hdc, opengl_ctx);

    wglDeleteContext(temp_ctx);

#define X(RET, NAME, ...) NAME = cast(RET (*)(__VA_ARGS__)) wglGetProcAddress(#NAME);
    GL30_FUNCTIONS
    GL45_FUNCTIONS
#undef X
}

static void opengl_platform_deinit(void) {
    if (opengl_ctx) wglDeleteContext(opengl_ctx);
    opengl_ctx = null;
}

static void opengl_platform_present(void) {
    SwapBuffers(platform_hdc);
}
#endif

static u32 opengl_main_fbo;
static u32 opengl_main_fbo_color0;
static u32 opengl_main_fbo_depth;

static void opengl_init(void) {
    opengl_platform_init();

    glCreateFramebuffers(1, &opengl_main_fbo);
    glCreateRenderbuffers(1, &opengl_main_fbo_color0);
    glCreateRenderbuffers(1, &opengl_main_fbo_depth);
}

static void opengl_deinit(void) {
    opengl_platform_deinit();
}

static void opengl_resize(void) {
    s32 fbo_color_samples_max;
    glGetIntegerv(GL_MAX_COLOR_TEXTURE_SAMPLES, &fbo_color_samples_max);
    s32 fbo_depth_samples_max;
    glGetIntegerv(GL_MAX_DEPTH_TEXTURE_SAMPLES, &fbo_depth_samples_max);
    u32 fbo_samples = cast(u32) min(fbo_color_samples_max, fbo_depth_samples_max);

    if (platform_screen_width > 0 && platform_screen_height > 0) {
        glNamedRenderbufferStorageMultisample(opengl_main_fbo_color0, fbo_samples,
            GL_RGBA16F, platform_screen_width, platform_screen_height);
        glNamedFramebufferRenderbuffer(opengl_main_fbo, GL_COLOR_ATTACHMENT0,
            GL_RENDERBUFFER, opengl_main_fbo_color0);

        glNamedRenderbufferStorageMultisample(opengl_main_fbo_depth, fbo_samples,
            GL_DEPTH_COMPONENT32F, platform_screen_width, platform_screen_height);
        glNamedFramebufferRenderbuffer(opengl_main_fbo, GL_DEPTH_ATTACHMENT,
            GL_RENDERBUFFER, opengl_main_fbo_depth);
    }
}

static void opengl_present(void) {
    float32 clear_color0[] = {0.6f, 0.2f, 0.2f, 1.0f};
    glClearNamedFramebufferfv(opengl_main_fbo, GL_COLOR, 0, clear_color0);
    float32 clear_depth = 0.0f;
    glClearNamedFramebufferfv(opengl_main_fbo, GL_DEPTH, 0, &clear_depth);
    glBindFramebuffer(GL_FRAMEBUFFER, opengl_main_fbo);

    // note(dfra): fixes intel default framebuffer resize bug
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glClear(0);

    glEnable(GL_FRAMEBUFFER_SRGB);
    glBlitNamedFramebuffer(opengl_main_fbo, 0,
        0, 0, platform_screen_width, platform_screen_height,
        0, 0, platform_screen_width, platform_screen_height,
        GL_COLOR_BUFFER_BIT, GL_NEAREST);
    glDisable(GL_FRAMEBUFFER_SRGB);

    opengl_platform_present();
}
