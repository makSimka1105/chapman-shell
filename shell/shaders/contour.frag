#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 itemSize;
    vec2 cursor;
    float radius;
    float strength;
    float reach;
    vec4 tint;
};

float boxDistance(vec2 q, vec2 extent, float r)
{
    vec2 d = abs(q) - (extent - r);
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - r;
}

void main()
{
    vec2 p = qt_TexCoord0 * itemSize;
    vec2 extent = itemSize * 0.5;
    float r = min(radius, min(extent.x, extent.y));
    float dist = boxDistance(p - extent, extent, r);

    float inside = 1.0 - smoothstep(-0.3, 0.6, dist);
    float line = exp(-max(-dist, 0.0)) * inside;
    float sheen = exp(min(dist, 0.0) / 5.0) * 0.14 * inside;
    float near = exp(-length(p - cursor) / reach);
    float alpha = (line * 0.95 + sheen) * mix(0.18, 1.0, near) * strength;

    fragColor = vec4(tint.rgb * alpha, alpha) * qt_Opacity;
}
