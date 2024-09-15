#version 450

layout(location = 0) in vec3 a_position;
layout(location = 1) in vec4 a_color;
layout(location = 2) in vec2 a_texcoord;
layout(location = 1) out vec4 f_color;
layout(location = 2) out vec2 f_texcoord;

void main() {
    gl_Position = vec4(a_position, 1.0);
    f_color = a_color;
    f_texcoord = a_texcoord;
}
