#version 450

layout(location = 1) in vec4 f_color;
layout(location = 0) out vec4 color;

void main() {
    color = f_color;
}
