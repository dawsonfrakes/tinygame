RectVertex :: struct {
    position : Vector3;
}
RectInstance :: struct {
    transform : Matrix4;
    texture_index : u32;
}

rect_size :: 64.0;
rect_vertices :: RectVertex.[
    .{.{-rect_size, -rect_size, 0.0}},
    .{.{+rect_size, -rect_size, 0.0}},
    .{.{+rect_size, +rect_size, 0.0}},
    .{.{-rect_size, +rect_size, 0.0}},
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

    transform_attrib :: 1;
    for 0..3 {
        glEnableVertexArrayAttrib(vao, xx (transform_attrib + it));
        glVertexArrayAttribBinding(vao, xx (transform_attrib + it), ibo_binding);
        glVertexArrayAttribFormat(vao, xx (transform_attrib + it), 4, GL_FLOAT, false, xx ((#run get_field_offset(RectInstance, "transform")) + it * size_of(Vector4)));
    }

    texture_index_attrib :: 5;
    glEnableVertexArrayAttrib(vao, texture_index_attrib);
    glVertexArrayAttribBinding(vao, texture_index_attrib, ibo_binding);
    glVertexArrayAttribIFormat(vao, texture_index_attrib, 1, GL_UNSIGNED_INT, (#run get_field_offset(RectInstance, "texture_index")));

    opengl_rect_vao = vao;
    opengl_rect_ibo = ibo;

    vsrc :: #string DONE
#version 450

layout(location = 0) in vec3 a_position;
layout(location = 1) in mat4 i_transform;
layout(location = 5) in uint i_texture_index;

layout(location = 0) out vec2 f_texcoord;
layout(location = 1) out uint f_texture_index;

float d = 1.0 / 8.0;
const vec2[] g_texcoords = vec2[](
    vec2(0.0, d),
    vec2(d, d),
    vec2(d, 0.0),
    vec2(0.0, 0.0)
);

void main() {
    gl_Position = i_transform * vec4(a_position, 1.0);
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
        glTextureParameteri(it, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
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

    x_scale := 1.0 / max(1.0, cast(float32) platform_screen_width);
    y_scale := 1.0 / max(1.0, cast(float32) platform_screen_height);

    steam_selected_friend_index = clamp(steam_selected_friend_index, 0, steam_friend_count - 1);
    INSTANCES_MAX :: 128;
    instances_data : [INSTANCES_MAX] RectInstance = ---;

    instances : [] RectInstance = instances_data;
    instances.count = steam_friend_count;
    y := -cast(s32) platform_screen_height / 1.0 + 64.0 + 150.0;
    index := 0;
    for row: 0..7 {
        x := -cast(s32) platform_screen_width / 1.0 + 64.0 + 150.0;
        for col: 0..12 {
            if index >= instances.count break row;
            instances[index] = .{
                transform=Matrix4.{.[
                    x_scale, 0.0, 0.0, 0.0,
                    0.0, y_scale, 0.0, 0.0,
                    0.0, 0.0, 1.0, 0.0,
                    0.0, 0.0, 0.0, 1.0,
                ]} * Matrix4.{.[
                    1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0,
                    0.0, 0.0, 1.0, 0.0,
                    x, y, 0.0, 1.0,
                ]},
                texture_index = xx index,
            };
            x += 128.0 + 50.0;
            index += 1;
        }
        y += 128.0 + 50.0;
    }
    glNamedBufferData(opengl_rect_ibo, xx (size_of(RectInstance) * instances.count), instances.data, GL_STREAM_DRAW);

    glUseProgram(opengl_rect_shader);
    glBindVertexArray(opengl_rect_vao);
    glDrawElementsInstancedBaseVertexBaseInstance(GL_TRIANGLES,
        rect_indices.count, GL_UNSIGNED_BYTE, cast(*void) 0,
        xx instances.count, 0, 0);

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
