#version 450

layout(location = 0) in vec3 a_position;
layout(location = 1) in vec3 a_normal;
layout(location = 2) in vec4 a_color;
layout(location = 3) in vec2 a_texcoord;

layout(location = 0) out vec3 f_position;
layout(location = 1) out vec3 f_normal;
layout(location = 2) out vec4 f_color;
layout(location = 3) out vec2 f_texcoord;

layout(location = 0) uniform mat4 u_world_transform;
layout(location = 1) uniform mat4 u_model_transform;

void main() {
    gl_Position = u_world_transform * vec4(a_position, 1.0);
    f_position = vec3(u_model_transform * vec4(a_position, 1.0));
    f_normal = a_normal;
    f_color = a_color;
    f_texcoord = a_texcoord;
}
