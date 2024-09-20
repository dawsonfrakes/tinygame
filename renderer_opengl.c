// 1.0
#define GL_COLOR_BUFFER_BIT 0x00004000
#define GL_TRIANGLES 0x0004
#define GL_UNSIGNED_BYTE 0x1401
#define GL_FLOAT 0x1406
#define GL_COLOR 0x1800
#define GL_DEPTH 0x1801
#define GL_NEAREST 0x2600

#define GL10_FUNCTIONS \
    X(void, glEnable, u32) \
    X(void, glDisable, u32) \
    X(void, glGetIntegerv, u32, s32*) \
    X(void, glClear, u32)

// 1.1
#define GL11_FUNCTIONS \
    X(void, glDrawElements, u32, u32, u32, void*)

// 1.5
#define GL_STATIC_DRAW 0x88E4

// 2.0
#define GL_FRAGMENT_SHADER 0x8B30
#define GL_VERTEX_SHADER 0x8B31

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
    X(void, glNamedRenderbufferStorageMultisample, u32, u32, u32, u32, u32) \
    X(void, glCreateVertexArrays, u32, u32*) \
    X(void, glVertexArrayElementBuffer, u32, u32) \
    X(void, glVertexArrayVertexBuffer, u32, u32, u32, s64, u32) \
    X(void, glEnableVertexArrayAttrib, u32, u32) \
    X(void, glVertexArrayAttribBinding, u32, u32, u32) \
    X(void, glVertexArrayAttribFormat, u32, u32, s32, u32, bool, u32) \
    X(void, glCreateBuffers, u32, u32*) \
    X(void, glNamedBufferData, u32, u64, void*, u32) \
    X(void, glProgramUniformMatrix4fv, u32, s32, u32, bool, float32*)

#if TARGET_OS_WINDOWS
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

static HGLRC opengl_ctx;
#define X(RET, NAME, ...) static RET (*NAME)(__VA_ARGS__);
GL20_FUNCTIONS
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
    GL20_FUNCTIONS
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

typedef struct {
    v3 position;
    v2 texcoord;
    v4 color;
} OpenGLUIVertex;

typedef struct {
    u32 element_gl_type;
    u16 offset;
    u8 element_count;
    u8 binding;
} OpenGLMeshAttrib;

typedef struct {
    u64 vertices_size;
    u64 indices_size;
    OpenGLMeshAttrib attribs[16];
    void* vertices;
    void* indices;
    u32 indices_count;
    u8 attribs_count;
    u8 vertices_element_size;
    u8 indices_element_size;

    u32 vao;
    u32 vbo;
    u32 ebo;
} OpenGLMesh;

static u32 opengl_ui_shader;

static u32 opengl_square_vao;

static OpenGLUIVertex triangle_vertices[] = {
    {{-0.5f, -0.5f, 0.0f}, {0.0f, 0.0f}, {1.0f, 0.0f, 0.0f, 1.0f}},
    {{+0.5f, -0.5f, 0.0f}, {1.0f, 0.0f}, {0.0f, 1.0f, 0.0f, 1.0f}},
    {{+0.0f, +0.5f, 0.0f}, {0.5f, 1.0f}, {0.0f, 0.0f, 1.0f, 1.0f}},
};
static u8 triangle_indices[] = {0, 1, 2};

static OpenGLMesh triangle_mesh = {
    .vertices_size = size_of(triangle_vertices),
    .indices_size = size_of(triangle_indices),
    .attribs[0].element_gl_type = GL_FLOAT,
    .attribs[0].offset = offset_of(OpenGLUIVertex, position),
    .attribs[0].element_count = 3,
    .attribs[0].binding = 0,
    .attribs[1].element_gl_type = GL_FLOAT,
    .attribs[1].offset = offset_of(OpenGLUIVertex, texcoord),
    .attribs[1].element_count = 2,
    .attribs[1].binding = 0,
    .attribs[2].element_gl_type = GL_FLOAT,
    .attribs[2].offset = offset_of(OpenGLUIVertex, color),
    .attribs[2].element_count = 4,
    .attribs[2].binding = 0,
    .vertices = triangle_vertices,
    .indices = triangle_indices,
    .indices_count = 3,
    .attribs_count = 3,
    .vertices_element_size = size_of(OpenGLUIVertex),
    .indices_element_size = size_of(triangle_indices[0]),
};

static OpenGLUIVertex square_vertices[] = {
    {{-0.5f, -0.5f, 0.0f}, {0.0f, 0.0f}, {1.0f, 0.0f, 0.0f, 1.0f}},
    {{+0.5f, -0.5f, 0.0f}, {1.0f, 0.0f}, {0.0f, 1.0f, 0.0f, 1.0f}},
    {{+0.5f, +0.5f, 0.0f}, {1.0f, 1.0f}, {0.0f, 0.0f, 1.0f, 1.0f}},
    {{-0.5f, +0.5f, 0.0f}, {0.0f, 1.0f}, {1.0f, 0.0f, 1.0f, 1.0f}},
};
static u8 square_indices[] = {0, 1, 2, 2, 3, 0};

static OpenGLMesh square_mesh = {
    .vertices_size = size_of(square_vertices),
    .indices_size = size_of(square_indices),
    .attribs[0].element_gl_type = GL_FLOAT,
    .attribs[0].offset = offset_of(OpenGLUIVertex, position),
    .attribs[0].element_count = 3,
    .attribs[0].binding = 0,
    .attribs[1].element_gl_type = GL_FLOAT,
    .attribs[1].offset = offset_of(OpenGLUIVertex, texcoord),
    .attribs[1].element_count = 2,
    .attribs[1].binding = 0,
    .attribs[2].element_gl_type = GL_FLOAT,
    .attribs[2].offset = offset_of(OpenGLUIVertex, color),
    .attribs[2].element_count = 4,
    .attribs[2].binding = 0,
    .vertices = square_vertices,
    .indices = square_indices,
    .indices_count = 6,
    .attribs_count = 3,
    .vertices_element_size = size_of(OpenGLUIVertex),
    .indices_element_size = size_of(square_indices[0]),
};

static OpenGLMesh* opengl_meshes[] = {
    &triangle_mesh,
    &square_mesh,
};

static void opengl_upload_mesh_to_gpu(OpenGLMesh* mesh) {
    glCreateBuffers(1, &mesh->vbo);
    glNamedBufferData(mesh->vbo, mesh->vertices_size, mesh->vertices, GL_STATIC_DRAW);
    glCreateBuffers(1, &mesh->ebo);
    glNamedBufferData(mesh->ebo, mesh->indices_size, mesh->indices, GL_STATIC_DRAW);

    glCreateVertexArrays(1, &mesh->vao);
    glVertexArrayElementBuffer(mesh->vao, mesh->ebo);
    u32 vbo_binding = 0;
    glVertexArrayVertexBuffer(mesh->vao, vbo_binding, mesh->vbo, 0, mesh->vertices_element_size);

    for (u32 attrib = 0; attrib < mesh->attribs_count; attrib += 1) {
        glEnableVertexArrayAttrib(mesh->vao, attrib);
        glVertexArrayAttribBinding(mesh->vao, attrib, mesh->attribs[attrib].binding);
        glVertexArrayAttribFormat(mesh->vao, attrib,
            mesh->attribs[attrib].element_count,
            mesh->attribs[attrib].element_gl_type,
            false, mesh->attribs[attrib].offset);
    }
}

static void opengl_init(void) {
    opengl_platform_init();

    glCreateFramebuffers(1, &opengl_main_fbo);
    glCreateRenderbuffers(1, &opengl_main_fbo_color0);
    glCreateRenderbuffers(1, &opengl_main_fbo_depth);

    for (OpenGLMesh** mesh = opengl_meshes; mesh < opengl_meshes + len(opengl_meshes); mesh += 1) {
        opengl_upload_mesh_to_gpu(*mesh);
    }
    {
        u8* vsrc =
            "#version 450\n"
            "layout(location = 0) in vec3 a_position;\n"
            "layout(location = 1) in vec2 a_texcoord;\n"
            "layout(location = 2) in vec4 a_color;\n"
            "layout(location = 1) out vec2 f_texcoord;\n"
            "layout(location = 2) out vec4 f_color;\n"
            "layout(location = 0) uniform mat4 u_transform;\n"
            "void main() {\n"
            "   gl_Position = u_transform * vec4(a_position, 1.0);\n"
            "   f_color = a_color;\n"
            "   f_texcoord = a_texcoord;\n"
            "}\n";
        u32 vshader = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(vshader, 1, &vsrc, null);
        glCompileShader(vshader);

        u8* fsrc =
            "#version 450\n"
            "layout(location = 1) in vec2 f_texcoord;\n"
            "layout(location = 2) in vec4 f_color;\n"
            "layout(location = 0) out vec4 color;\n"
            "void main() {\n"
            "   color = f_color;\n"
            "   // color = vec4(f_texcoord, 0.0, 1.0);\n"
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

        opengl_ui_shader = program;
    }
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

    glUseProgram(opengl_ui_shader);
    {
        static m4 transforms[] = {
            {{
                1.0f, 0.0f, 0.0f, 0.0f,
                0.0f, 1.0f, 0.0f, 0.0f,
                0.0f, 0.0f, 1.0f, 0.0f,
                -0.5f, 0.0f, 0.0f, 1.0f,
            }},
            {{
                1.0f, 0.0f, 0.0f, 0.0f,
                0.0f, 1.0f, 0.0f, 0.0f,
                0.0f, 0.0f, 1.0f, 0.0f,
                0.5f, 0.0f, 0.0f, 1.0f,
            }},
        };
        for (OpenGLMesh** mesh = opengl_meshes; mesh < opengl_meshes + len(opengl_meshes); mesh += 1) {
            glBindVertexArray((*mesh)->vao);
            u32 u_transform = 0;
            glProgramUniformMatrix4fv(opengl_ui_shader, u_transform, 1, false, transforms[mesh - opengl_meshes].e);
            glDrawElements(GL_TRIANGLES, (*mesh)->indices_count, (*mesh)->indices_element_size == 1 ? GL_UNSIGNED_BYTE : 0, cast(void*) 0);
        }
    }

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
