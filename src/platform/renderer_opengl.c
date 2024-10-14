#if TARGET_OS_WINDOWS
static HGLRC opengl_ctx;

static void opengl_platform_init(void) {
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
	GL31_FUNCTIONS
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

typedef struct {
	v3 position;
	v2 texcoord;
} OpenGLRectVertex;

typedef struct align(16) {
	m4 transform;
} OpenGLRectInstance;

static OpenGLRectVertex rect_vertices[] = {
	{.position = {-0.5f, -0.5f, 0.0f}, .texcoord = {0.0f, 0.0f}},
	{.position = {+0.5f, -0.5f, 0.0f}, .texcoord = {1.0f, 0.0f}},
	{.position = {+0.5f, +0.5f, 0.0f}, .texcoord = {1.0f, 1.0f}},
	{.position = {-0.5f, +0.5f, 0.0f}, .texcoord = {0.0f, 1.0f}},
};
static u8 rect_indices[] = {0, 1, 2, 2, 3, 0};
static u32 opengl_rect_vao;
static u32 opengl_rect_ibo;
static u32 opengl_rect_shader;
static u32 opengl_rect_texture;

static void opengl_init(void) {
	opengl_platform_init();

	glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE);

	{
	u32 vbo;
	glCreateBuffers(1, &vbo);
	glNamedBufferData(vbo, size_of(rect_vertices), rect_vertices, GL_STATIC_DRAW);

	u32 ebo;
	glCreateBuffers(1, &ebo);
	glNamedBufferData(ebo, size_of(rect_indices), rect_indices, GL_STATIC_DRAW);

	u32 ibo;
	glCreateBuffers(1, &ibo);

	u32 vao;
	glCreateVertexArrays(1, &vao);
	glVertexArrayElementBuffer(vao, ebo);
	u32 vbo_binding = 0;
	glVertexArrayVertexBuffer(vao, vbo_binding, vbo, 0, size_of(OpenGLRectVertex));
	u32 ibo_binding = 1;
	glVertexArrayVertexBuffer(vao, ibo_binding, ibo, 0, size_of(OpenGLRectInstance));
	glVertexArrayBindingDivisor(vao, ibo_binding, 1);

	u32 position_attrib = 0;
	glEnableVertexArrayAttrib(vao, position_attrib);
	glVertexArrayAttribBinding(vao, position_attrib, vbo_binding);
	glVertexArrayAttribFormat(vao, position_attrib, 3, GL_FLOAT, false, offset_of(OpenGLRectVertex, position));

	u32 texcoord_attrib = 1;
	glEnableVertexArrayAttrib(vao, texcoord_attrib);
	glVertexArrayAttribBinding(vao, texcoord_attrib, vbo_binding);
	glVertexArrayAttribFormat(vao, texcoord_attrib, 2, GL_FLOAT, false, offset_of(OpenGLRectVertex, texcoord));

	u32 transform_attrib = 2;
	for (u8 i = 0; i < 4; i += 1) {
		glEnableVertexArrayAttrib(vao, transform_attrib + i);
		glVertexArrayAttribBinding(vao, transform_attrib + i, ibo_binding);
		glVertexArrayAttribFormat(vao, transform_attrib + i, 4, GL_FLOAT, false, offset_of(OpenGLRectInstance, transform) + i * size_of(v4));
	}

	opengl_rect_vao = vao;
	opengl_rect_ibo = ibo;
	}

	{
	u8* vsrc =
		"#version 450\n"
		"layout(location = 0) in vec3 a_position;\n"
		"layout(location = 1) in vec2 a_texcoord;\n"
		"layout(location = 2) in mat4 a_transform;\n"
		"layout(location = 1) out vec2 f_texcoord;\n"
		"void main() {\n"
		"	gl_Position = a_transform * vec4(a_position, 1.0);\n"
		"	f_texcoord = a_texcoord;\n"
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
		"	color = texture(u_texture, vec2(f_texcoord.x, 1.0 - f_texcoord.y));\n"
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

	opengl_rect_shader = program;
	}

	{
	u32 texture;
	glCreateTextures(GL_TEXTURE_2D, 1, &texture);
	glTextureStorage2D(texture, 1, GL_RGB8, 512, 512);

	static u8 avatar[64 * 64 * 4];
	s32 count = SteamAPI_ISteamFriends_GetFriendCount(steam_friends, k_EFriendFlagAll);

	s32 i = 0;
	for (s32 y = 0; y < 512; y += 64) {
	for (s32 x = 0; x < 512; x += 64) {
		u64 id = SteamAPI_ISteamFriends_GetFriendByIndex(steam_friends, i, k_EFriendFlagAll);
		// u8* name = SteamAPI_ISteamFriends_GetFriendPersonaName(steam_friends, id);
		s32 image_id = SteamAPI_ISteamFriends_GetMediumFriendAvatar(steam_friends, id);
		SteamAPI_ISteamUtils_GetImageRGBA(steam_utils, image_id, avatar, size_of(avatar));
		glTextureSubImage2D(texture, 0, x, y, 64, 64, GL_RGBA, GL_UNSIGNED_BYTE, avatar);
		i += 1;
		if (i == count) break;
	}
	}

	glTextureParameteri(texture, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTextureParameteri(texture, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTextureParameteri(texture, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	opengl_rect_texture = texture;
	}
}

static void opengl_deinit(void) {
	opengl_platform_deinit();
}

static void opengl_resize(void) {

}

static void opengl_present(void) {
	glEnable(GL_FRAMEBUFFER_SRGB);
	glViewport(0, 0, platform_screen_width, platform_screen_height);
	glClearColor(0.6f, 0.2f, 0.2f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);

	static OpenGLRectInstance rect_instances[1] = {
		{
			.transform = {{
				1.0f, 0.0f, 0.0f, 0.0f,
				0.0f, 1.0f, 0.0f, 0.0f,
				0.0f, 0.0f, 1.0f, 0.0f,
				0.0f, 0.0f, 0.0f, 1.0f,
			}},
		},
	};
	rect_instances[0].transform.e[0] = cast(f32) platform_screen_height / cast(f32) platform_screen_width;
	glNamedBufferData(opengl_rect_ibo, size_of(rect_instances), rect_instances, GL_STREAM_DRAW);

	glBindTextureUnit(0, opengl_rect_texture);
	glUseProgram(opengl_rect_shader);
	glBindVertexArray(opengl_rect_vao);
	glDrawElementsInstanced(GL_TRIANGLES, len(rect_indices), GL_UNSIGNED_BYTE, cast(void*) 0, len(rect_instances));

	opengl_platform_present();
}
