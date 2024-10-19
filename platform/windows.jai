toggle_fullscreen :: () #no_context {

}

update_cursor_clip :: () #no_context {

}

clear_held_keys :: () #no_context {

}

#if OPENGL {
Vector2 :: struct { x, y: float32; }
Vector3 :: struct { x, y, z: float32; }
RectVertex :: struct {
    position : Vector3;
}
RectInstance :: struct {
    texture_index : u32;
}

rect_vertices :: RectVertex.[
    .{.{-0.5, -0.5, 0.0}},
    .{.{+0.5, -0.5, 0.0}},
    .{.{+0.5, +0.5, 0.0}},
    .{.{-0.5, +0.5, 0.0}},
];
rect_indices :: u8.[0, 1, 2, 2, 3, 0];

opengl_init :: () #no_context {
    glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE);

    glCreateFramebuffers(1, *opengl_main_fbo);
    glCreateRenderbuffers(1, *opengl_main_fbo_color0);

    vbo : u32 = ---;
    glCreateBuffers(1, *vbo);
    glNamedBufferData(vbo, size_of(type_of(rect_vertices)), rect_vertices.data, GL_STATIC_DRAW);
    ebo : u32 = ---;
    glCreateBuffers(1, *ebo);
    glNamedBufferData(ebo, size_of(type_of(rect_indices)), rect_indices.data, GL_STATIC_DRAW);
    ibo : u32 = ---;
    glCreateBuffers(1, *ibo);

    vao : u32 = ---;
    glCreateVertexArrays(1, *vao);
    glVertexArrayElementBuffer(vao, ebo);
    vbo_binding :: 0;
    glVertexArrayVertexBuffer(vao, vbo_binding, vbo, 0, size_of(RectVertex));
    ibo_binding :: 1;
    glVertexArrayVertexBuffer(vao, ibo_binding, ibo, 0, size_of(RectInstance));
    glVertexArrayBindingDivisor(vao, ibo_binding, 1);

    position_attrib :: 0;
    glEnableVertexArrayAttrib(vao, position_attrib);
    glVertexArrayAttribBinding(vao, position_attrib, vbo_binding);
    glVertexArrayAttribFormat(vao, position_attrib, 3, GL_FLOAT, false, 0);

    texture_index_attrib :: 1;
    glEnableVertexArrayAttrib(vao, texture_index_attrib);
    glVertexArrayAttribBinding(vao, texture_index_attrib, ibo_binding);
    glVertexArrayAttribIFormat(vao, texture_index_attrib, 1, GL_UNSIGNED_INT, 0);

    opengl_rect_vao = vao;
    opengl_rect_ibo = ibo;

    vsrc :: #string DONE
#version 450

layout(location = 0) in vec3 a_position;
layout(location = 1) in uint i_texture_index;

layout(location = 0) out vec2 f_texcoord;
layout(location = 1) out uint f_texture_index;

float d = 1.0 / 8.0;
vec2[] g_texcoords = vec2[](
    vec2(0.0, d),
    vec2(d, d),
    vec2(d, 0.0),
    vec2(0.0, 0.0)
);

void main() {
    gl_Position = vec4(a_position, 1.0);
    uint row = i_texture_index / 8;
    uint col = i_texture_index % 8;
    f_texcoord = g_texcoords[gl_VertexID] + vec2(d * float(col), d * float(row));
    f_texture_index = i_texture_index / 64;
}
DONE
    vshader := glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vshader, 1, (*u8).[vsrc.data].data, null);
    glCompileShader(vshader);

    fsrc :: #string DONE
#version 450

layout(location = 0) in vec2 f_texcoord;
layout(location = 1) flat in uint f_texture_index;

layout(location = 0) out vec4 color;

layout(location = 0) uniform sampler2D u_textures[32];

void main() {
    color = texture(u_textures[f_texture_index], f_texcoord);
}
DONE
    fshader := glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fshader, 1, (*u8).[fsrc.data].data, null);
    glCompileShader(fshader);

    program := glCreateProgram();
    glAttachShader(program, vshader);
    glAttachShader(program, fshader);
    glLinkProgram(program);
    glDetachShader(program, fshader);
    glDetachShader(program, vshader);

    glDeleteShader(fshader);
    glDeleteShader(vshader);

    u_textures :: 0;
    for 0..opengl_rect_textures.count-1
        glProgramUniform1i(program, xx (u_textures + it), xx it);

    opengl_rect_shader = program;

    glCreateTextures(GL_TEXTURE_2D, opengl_rect_textures.count, opengl_rect_textures.data);
    for opengl_rect_textures {
        glTextureStorage2D(it, 1, GL_RGB8, 512, 512);
        glTextureParameteri(it, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTextureParameteri(it, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTextureParameteri(it, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTextureParameteri(it, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glBindTextureUnit(xx it_index, it);
    }

    #if STEAM if platform_steam_enabled {
        steam_friend_count = xx SteamAPI_ISteamFriends_GetFriendCount(steam_friends, .ALL);
        if steam_friend_count > 0 {
            i : s32 = 0;
            for texture: 0..opengl_rect_textures.count-1 {
                for row: 0..7 {
                    for col: 0..7 {
                        friend_id := SteamAPI_ISteamFriends_GetFriendByIndex(steam_friends, i, .ALL);
                        avatar_id := SteamAPI_ISteamFriends_GetMediumFriendAvatar(steam_friends, friend_id);
                        avatar_data : [64 * 64 * 4] u8 = ---;
                        SteamAPI_ISteamUtils_GetImageRGBA(steam_utils, avatar_id, avatar_data.data, xx avatar_data.count);

                        glTextureSubImage2D(opengl_rect_textures[texture], 0, xx (col * 64), xx (row * 64), 64, 64, GL_RGBA, GL_UNSIGNED_BYTE, avatar_data.data);

                        if i >= steam_friend_count break;
                        i += 1;
                    }
                }
            }
        }
    }
}

opengl_resize :: () #no_context {
    if !platform_screen_width || !platform_screen_height return;

    fbo_color_samples_max : s32 = ---;
    glGetIntegerv(GL_MAX_COLOR_TEXTURE_SAMPLES, *fbo_color_samples_max);
    fbo_depth_samples_max : s32 = ---;
    glGetIntegerv(GL_MAX_DEPTH_TEXTURE_SAMPLES, *fbo_depth_samples_max);
    fbo_samples := cast(u32) min(fbo_color_samples_max, fbo_depth_samples_max);

    glNamedRenderbufferStorageMultisample(opengl_main_fbo_color0,
        fbo_samples, GL_RGBA16F,
        platform_screen_width, platform_screen_height);
    glNamedFramebufferRenderbuffer(opengl_main_fbo,
        GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, opengl_main_fbo_color0);
}

opengl_present :: () #no_context {
    glBindFramebuffer(GL_FRAMEBUFFER, opengl_main_fbo);
    color0 := float32.[0.6, 0.2, 0.2, 1.0];
    glClearNamedFramebufferfv(opengl_main_fbo, GL_COLOR, 0, color0.data);
    glViewport(0, 0, platform_screen_width, platform_screen_height);

    steam_selected_friend_index = clamp(steam_selected_friend_index, 0, steam_friend_count - 1);
    instances := RectInstance.[
        .{xx steam_selected_friend_index},
    ];
    glNamedBufferData(opengl_rect_ibo, size_of(type_of(instances)), instances.data, GL_STREAM_DRAW);

    glUseProgram(opengl_rect_shader);
    glBindVertexArray(opengl_rect_vao);
    glDrawElementsInstancedBaseVertexBaseInstance(GL_TRIANGLES,
        rect_indices.count, GL_UNSIGNED_BYTE, cast(*void) 0,
        instances.count, 0, 0);

    // @note(dfra): fixes intel default framebuffer resize bug
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glClear(0);

    glEnable(GL_FRAMEBUFFER_SRGB);
    glBlitNamedFramebuffer(opengl_main_fbo, 0,
        0, 0, platform_screen_width, platform_screen_height,
        0, 0, platform_screen_width, platform_screen_height,
        GL_COLOR_BUFFER_BIT, GL_NEAREST);
    glDisable(GL_FRAMEBUFFER_SRGB);
}
}

window_proc :: (hwnd: HWND, message: u32, wParam: u64, lParam: s64) -> s64 #c_call {
    if message == {
    case WM_PAINT;
        ValidateRect(hwnd, null);
    case WM_ERASEBKGND;
        return 1;
    case WM_ACTIVATEAPP;
        if wParam != 0 update_cursor_clip();
        else clear_held_keys();
    case WM_SIZE;
        platform_screen_width = cast,no_check(u16) cast,no_check(u64) lParam;
        platform_screen_height = cast,no_check(u16) (cast,no_check(u64) lParam >> 16);

        #if OPENGL opengl_resize();
    case WM_CREATE;
        platform_hwnd = hwnd;
        platform_hdc = GetDC(hwnd);

        dark_mode : s32 = xx true;
        DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, *dark_mode, size_of(type_of(dark_mode)));
        round_mode : s32 = DWMWCP_DONOTROUND;
        DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, *round_mode, size_of(type_of(round_mode)));

        #if OPENGL {
            pfd : PIXELFORMATDESCRIPTOR;
            pfd.nSize = size_of(PIXELFORMATDESCRIPTOR);
            pfd.nVersion = 1;
            pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL |
                PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
            pfd.cColorBits = 24;
            format := ChoosePixelFormat(platform_hdc, *pfd);
            SetPixelFormat(platform_hdc, format, *pfd);

            temp_ctx := wglCreateContext(platform_hdc);
            wglMakeCurrent(platform_hdc, temp_ctx);

            wglCreateContextAttribsARB : (HDC, HGLRC, *s32) -> HGLRC #c_call
                = xx wglGetProcAddress("wglCreateContextAttribsARB");

            attribs := s32.[
                WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
                WGL_CONTEXT_MINOR_VERSION_ARB, 6,
                WGL_CONTEXT_FLAGS_ARB, xx ifx DEVELOPER WGL_CONTEXT_DEBUG_BIT_ARB,
                WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
                0,
            ];
            opengl_ctx = wglCreateContextAttribsARB(platform_hdc, xx null, attribs.data);
            wglMakeCurrent(platform_hdc, opengl_ctx);

            wglDeleteContext(temp_ctx);

            dll := LoadLibraryW((#run ascii_to_utf16le_string_literal("opengl32")).data);
            glEnable = xx GetProcAddress(dll, "glEnable");
            glDisable = xx GetProcAddress(dll, "glDisable");
            glGetIntegerv = xx GetProcAddress(dll, "glGetIntegerv");
            glViewport = xx GetProcAddress(dll, "glViewport");
            glClearColor = xx GetProcAddress(dll, "glClearColor");
            glClear = xx GetProcAddress(dll, "glClear");

            glCreateProgram = xx wglGetProcAddress("glCreateProgram");
            glAttachShader = xx wglGetProcAddress("glAttachShader");
            glDetachShader = xx wglGetProcAddress("glDetachShader");
            glLinkProgram = xx wglGetProcAddress("glLinkProgram");
            glUseProgram = xx wglGetProcAddress("glUseProgram");
            glCreateShader = xx wglGetProcAddress("glCreateShader");
            glDeleteShader = xx wglGetProcAddress("glDeleteShader");
            glShaderSource = xx wglGetProcAddress("glShaderSource");
            glCompileShader = xx wglGetProcAddress("glCompileShader");

            glBindFramebuffer = xx wglGetProcAddress("glBindFramebuffer");
            glBindVertexArray = xx wglGetProcAddress("glBindVertexArray");

            glProgramUniform1i = xx wglGetProcAddress("glProgramUniform1i");

            glDrawElementsInstancedBaseVertexBaseInstance = xx wglGetProcAddress("glDrawElementsInstancedBaseVertexBaseInstance");

            glClipControl = xx wglGetProcAddress("glClipControl");
            glCreateFramebuffers = xx wglGetProcAddress("glCreateFramebuffers");
            glNamedFramebufferRenderbuffer = xx wglGetProcAddress("glNamedFramebufferRenderbuffer");
            glClearNamedFramebufferfv = xx wglGetProcAddress("glClearNamedFramebufferfv");
            glBlitNamedFramebuffer = xx wglGetProcAddress("glBlitNamedFramebuffer");
            glCreateRenderbuffers = xx wglGetProcAddress("glCreateRenderbuffers");
            glNamedRenderbufferStorageMultisample = xx wglGetProcAddress("glNamedRenderbufferStorageMultisample");
            glCreateVertexArrays = xx wglGetProcAddress("glCreateVertexArrays");
            glVertexArrayElementBuffer = xx wglGetProcAddress("glVertexArrayElementBuffer");
            glVertexArrayVertexBuffer = xx wglGetProcAddress("glVertexArrayVertexBuffer");
            glVertexArrayBindingDivisor = xx wglGetProcAddress("glVertexArrayBindingDivisor");
            glEnableVertexArrayAttrib = xx wglGetProcAddress("glEnableVertexArrayAttrib");
            glVertexArrayAttribBinding = xx wglGetProcAddress("glVertexArrayAttribBinding");
            glVertexArrayAttribFormat = xx wglGetProcAddress("glVertexArrayAttribFormat");
            glVertexArrayAttribIFormat = xx wglGetProcAddress("glVertexArrayAttribIFormat");
            glCreateBuffers = xx wglGetProcAddress("glCreateBuffers");
            glNamedBufferData = xx wglGetProcAddress("glNamedBufferData");
            glCreateTextures = xx wglGetProcAddress("glCreateTextures");
            glTextureStorage2D = xx wglGetProcAddress("glTextureStorage2D");
            glTextureSubImage2D = xx wglGetProcAddress("glTextureSubImage2D");
            glTextureParameteri = xx wglGetProcAddress("glTextureParameteri");
            glBindTextureUnit = xx wglGetProcAddress("glBindTextureUnit");

            opengl_init();
        }
    case WM_DESTROY;
        PostQuitMessage(0);
    case WM_SYSCOMMAND;
        if (wParam == SC_KEYMENU) return 0;
        #through;
    case;
        return DefWindowProcW(hwnd, message, wParam, lParam);
    }
    return 0;
}

entry :: () {
    platform_hinstance = GetModuleHandleW(null);

    sleep_is_granular := timeBeginPeriod(1) == TIMERR_NOERROR;

    #if STEAM {
        platform_steam_enabled = SteamAPI_InitFlat(null) == .OK;
        defer if platform_steam_enabled SteamAPI_Shutdown();
        steam_user = SteamAPI_SteamUser_v023();
        steam_utils = SteamAPI_SteamUtils_v010();
        steam_friends = SteamAPI_SteamFriends_v017();
    }

    SetProcessDPIAware();
    wndclass : WNDCLASSEXW;
    wndclass.cbSize = size_of(WNDCLASSEXW);
    wndclass.style = CS_OWNDC;
    wndclass.lpfnWndProc = window_proc;
    wndclass.hInstance = platform_hinstance;
    wndclass.hIcon = LoadIconW(xx null, IDI_WARNING);
    wndclass.hCursor = LoadCursorW(xx null, IDC_CROSS);
    wndclass.lpszClassName = (#run ascii_to_utf16le_string_literal("A")).data;
    RegisterClassExW(*wndclass);
    CreateWindowExW(0, wndclass.lpszClassName, (#run ascii_to_utf16le_string_literal("Colliders")).data,
        WS_OVERLAPPEDWINDOW | WS_VISIBLE,
        CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
        xx null, xx null, platform_hinstance, null);

    while game_loop := true {
        msg : MSG = ---;
        while PeekMessageW(*msg, xx null, 0, 0, PM_REMOVE) {
            using msg;
            TranslateMessage(*msg);
            if message == {
            case WM_KEYDOWN; #through;
            case WM_KEYUP; #through;
            case WM_SYSKEYDOWN; #through;
            case WM_SYSKEYUP;
                pressed := lParam & (1 << 31) == 0;
                repeat  := pressed && lParam & (1 << 30) != 0;
                sys     := message == WM_SYSKEYDOWN || message == WM_SYSKEYUP;
                alt     := sys && lParam & (1 << 29) != 0;

                if !repeat && (!sys || alt || wParam == VK_F10) {
                    if pressed {
                        if wParam == VK_F4 && alt DestroyWindow(platform_hwnd);
                        if wParam == VK_F11 || (wParam == VK_RETURN && alt) toggle_fullscreen();
                        if DEVELOPER && wParam == VK_ESCAPE DestroyWindow(platform_hwnd);
                    }
                }

                DispatchMessageW(*msg); // @hack steam overlay needs input.
            case WM_MOUSEWHEEL;
                delta := cast,no_check(s16) (wParam >> 16) / WHEEL_DELTA;
                steam_selected_friend_index -= delta;
            case WM_QUIT;
                break game_loop;
            case;
                DispatchMessageW(*msg);
            }
        }

        #if STEAM if platform_steam_enabled SteamAPI_RunCallbacks();

        #if OPENGL {
            opengl_present();
            SwapBuffers(platform_hdc);
        }

        if sleep_is_granular {
            Sleep(1);
        }
    }
}

#program_export
RawEntryPoint :: () #c_call {
    first_thread_context : type_of(context);
    push_context first_thread_context {
        entry();
    }

    ExitProcess(0);
}
