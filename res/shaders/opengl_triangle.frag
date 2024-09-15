#version 450

layout(location = 1) in vec4 f_color;
layout(location = 2) in vec2 f_texcoord;
layout(location = 0) out vec4 color;

layout(location = 1) uniform sampler2D u_texture;

void main() {
    color = texture(u_texture, f_texcoord) * f_color;
    // color = vec4(f_texcoord, 0.0, 1.0);
}
