#if OS_WINDOWS
#define WGL_CONTEXT_MAJOR_VERSION_ARB 0x2091
#define WGL_CONTEXT_MINOR_VERSION_ARB 0x2092
#define WGL_CONTEXT_FLAGS_ARB 0x2094
#define WGL_CONTEXT_PROFILE_MASK_ARB 0x9126
#define WGL_CONTEXT_DEBUG_BIT_ARB 0x0001
#define WGL_CONTEXT_CORE_PROFILE_BIT_ARB 0x00000001

#define X(RET, NAME, ...) RET NAME(__VA_ARGS__);
GL10_FUNCTIONS
GL11_FUNCTIONS
#undef X

HGLRC opengl_ctx;

#define X(RET, NAME, ...) RET (*NAME)(__VA_ARGS__);
GL20_FUNCTIONS
GL30_FUNCTIONS
GL45_FUNCTIONS
#undef X

void opengl_platform_init(void) {
    static PIXELFORMATDESCRIPTOR pfd = {0};
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

    static s32 attribs[] = {
        WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
        WGL_CONTEXT_MINOR_VERSION_ARB, 6,
        WGL_CONTEXT_FLAGS_ARB, WGL_CONTEXT_DEBUG_BIT_ARB,
        WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
        0,
    };
    opengl_ctx = wglCreateContextAttribsARB(platform_hdc, null, attribs);
    wglMakeCurrent(platform_hdc, opengl_ctx);

    wglDeleteContext(temp_ctx);

#define X(RET, NAME, ...) NAME = cast(RET (*)(__VA_ARGS__)) wglGetProcAddress(#NAME);
    GL20_FUNCTIONS
    GL30_FUNCTIONS
    GL45_FUNCTIONS
#undef X
}

void opengl_platform_deinit(void) {
    if (opengl_ctx) wglDeleteContext(opengl_ctx);
    opengl_ctx = null;
}

void opengl_platform_present(void) {
    SwapBuffers(platform_hdc);
}
#endif

typedef struct {
    v3 position;
    v2 texcoord;
} GameVertex;

GameVertex game_triangle_vertices[] = {
    {{-0.5f, -0.5f, 0.0f}, {0.0f, 0.0f}},
    {{+0.5f, -0.5f, 0.0f}, {1.0f, 0.0f}},
    {{+0.0f, +0.5f, 0.0f}, {0.5f, 1.0f}},
};
u8 game_triangle_indices[] = {0, 1, 2};

u32 opengl_main_fbo;
u32 opengl_main_fbo_color0;
u32 opengl_main_fbo_depth;

u32 opengl_tophat_texture;
u32 opengl_triangle_shader;
u32 opengl_triangle_vao;

void opengl_init(void) {
    opengl_platform_init();

    glCreateFramebuffers(1, &opengl_main_fbo);
    glCreateRenderbuffers(1, &opengl_main_fbo_color0);
    glCreateRenderbuffers(1, &opengl_main_fbo_depth);

    {
        u32 vbo;
        glCreateBuffers(1, &vbo);
        glNamedBufferData(vbo, size_of(game_triangle_vertices), game_triangle_vertices, GL_STATIC_DRAW);

        u32 ebo;
        glCreateBuffers(1, &ebo);
        glNamedBufferData(ebo, size_of(game_triangle_indices), game_triangle_indices, GL_STATIC_DRAW);

        u32 vao;
        glCreateVertexArrays(1, &vao);
        u32 vbo_binding = 0;
        glVertexArrayElementBuffer(vao, ebo);
        glVertexArrayVertexBuffer(vao, vbo_binding, vbo, 0, size_of(GameVertex));

        u32 position_attrib = 0;
        glEnableVertexArrayAttrib(vao, position_attrib);
        glVertexArrayAttribBinding(vao, position_attrib, vbo_binding);
        glVertexArrayAttribFormat(vao, position_attrib, 3, GL_FLOAT, false, offset_of(GameVertex, position));

        u32 texcoord_attrib = 1;
        glEnableVertexArrayAttrib(vao, texcoord_attrib);
        glVertexArrayAttribBinding(vao, texcoord_attrib, vbo_binding);
        glVertexArrayAttribFormat(vao, texcoord_attrib, 2, GL_FLOAT, false, offset_of(GameVertex, texcoord));

        opengl_triangle_vao = vao;
    }
    {
        u8* vsrc =
            "#version 450\n"
            "layout(location = 0) in vec3 a_position;\n"
            "layout(location = 1) in vec2 a_texcoord;\n"
            "layout(location = 1) out vec2 f_texcoord;\n"
            "void main() {\n"
            "   gl_Position = vec4(a_position, 1.0);\n"
            "   f_texcoord = a_texcoord;\n"
            "}\n";
        u32 vshader = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(vshader, 1, &vsrc, null);
        glCompileShader(vshader);

        u8* fsrc =
            "#version 450\n"
            "layout(location = 1) in vec2 f_texcoord;\n"
            "layout(location = 0) out vec4 color;\n"
            "layout(location = 0) uniform sampler2D u_texture;\n"
            "void main() {\n"
            "   color = texture(u_texture, f_texcoord);\n"
            "}\n";
        u32 fshader = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(fshader, 1, &fsrc, null);
        glCompileShader(fshader);

        u32 program = glCreateProgram();
        glAttachShader(program, vshader);
        glAttachShader(program, fshader);
        glLinkProgram(program);
        glDetachShader(program, fshader);
        glDetachShader(program, vshader);

        glDeleteShader(fshader);
        glDeleteShader(vshader);

        opengl_triangle_shader = program;
    }
    {
        u32 texture;
        glCreateTextures(GL_TEXTURE_2D, 1, &texture);
        glTextureStorage2D(texture, 1, GL_RGBA8, 512, 512);
        glTextureParameteri(texture, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

        HANDLE hfile = CreateFileA("textures/tophat.bmp", GENERIC_READ, 0, null, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, null);
        if (hfile != INVALID_HANDLE_VALUE) {
            s64 bmp_file_size;
            GetFileSizeEx(hfile, &bmp_file_size);

            u8* bmp_file = cast(u8*) VirtualAlloc(0, cast(u32) bmp_file_size, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
            ReadFile(hfile, bmp_file, cast(u32) bmp_file_size, null, null);

            CloseHandle(hfile);

            u8* bmp_image_data = bmp_file + *cast(u32*) (bmp_file + 10);
            glTextureSubImage2D(texture, 0, 0, 0, 512, 512, GL_BGR, GL_UNSIGNED_BYTE, bmp_image_data);

            VirtualFree(bmp_file, 0, MEM_RELEASE);
        }

        opengl_tophat_texture = texture;
    }
}

void opengl_deinit(void) {
    opengl_platform_deinit();
}

void opengl_resize(void) {
    s32 fbo_color_samples_max;
    glGetIntegerv(GL_MAX_COLOR_TEXTURE_SAMPLES, &fbo_color_samples_max);
    s32 fbo_depth_samples_max;
    glGetIntegerv(GL_MAX_DEPTH_TEXTURE_SAMPLES, &fbo_depth_samples_max);
    u32 fbo_samples = cast(u32) min(fbo_color_samples_max, fbo_depth_samples_max);

    if (platform_screen_width && platform_screen_height) {
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

void opengl_present(void) {
    static float32 clear_color0[] = {0.6f, 0.2f, 0.2f, 1.0f};
    glClearNamedFramebufferfv(opengl_main_fbo, GL_COLOR, 0, clear_color0);
    static float32 clear_depth = 0.0f;
    glClearNamedFramebufferfv(opengl_main_fbo, GL_DEPTH, 0, &clear_depth);
    glBindFramebuffer(GL_FRAMEBUFFER, opengl_main_fbo);
    glViewport(0, 0, platform_screen_width, platform_screen_height);

    glBindTextureUnit(0, opengl_tophat_texture);
    glUseProgram(opengl_triangle_shader);
    glBindVertexArray(opengl_triangle_vao);
    glDrawElements(GL_TRIANGLES, 3, GL_UNSIGNED_BYTE, cast(void*) 0);

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
