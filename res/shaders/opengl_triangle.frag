#version 450

layout(location = 0) in vec3 f_position;
layout(location = 1) in vec3 f_normal;
layout(location = 2) in vec4 f_color;
layout(location = 3) in vec2 f_texcoord;

layout(location = 0) out vec4 color;

layout(location = 2) uniform sampler2D u_texture;

vec3 light_color = vec3(0.5, 0.3, 0.2);
vec3 light_position = vec3(0.0, 0.0, 1.0);

void main() {
    vec3 view_dir = vec3(0.0, 0.0, -1.0);
    vec3 light_dir = normalize(light_position - f_position);
    vec3 reflect_dir = reflect(-light_dir, f_normal);

    // phong
    float ambient_strength = 0.1;
    vec3 ambient = light_color * ambient_strength;
    float diffuse_strength = max(dot(light_dir, normalize(f_normal)), 0.0);
    vec3 diffuse = texture(u_texture, f_texcoord).xyz * diffuse_strength;
    float specular_strength = 0.5;
    vec3 specular = light_color * pow(max(dot(view_dir, reflect_dir), 0.0), 32) * specular_strength;
    vec4 result = vec4(ambient + diffuse + specular, 1.0);

    color = result;
    // color = vec4(f_normal, 1.0);
    // color = vec4(f_texcoord, 0.0, 1.0);
}
