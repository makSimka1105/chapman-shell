#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 itemSize;
    vec2 glassSize;
    vec2 backdropSize;
    vec2 backdropOffset;
    float pad;
    float radius;
    float bezel;
    float thickness;
    float dispersion;
    float softness;
    float tint;
    float saturation;
    float rim;
    float grain;
    float shadow;
};

layout(binding = 1) uniform sampler2D backdrop;

const int TAPS = 16;
const float GOLDEN_ANGLE = 2.39996323;
const float TAU = 6.2831853;

float boxDistance(vec2 q, vec2 extent, float r)
{
    vec2 d = abs(q) - (extent - r);
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - r;
}

float noise(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec3 sampleAt(vec2 p, float lod)
{
    vec2 uv = clamp((p + backdropOffset) / backdropSize, vec2(0.001), vec2(0.999));
    return textureLod(backdrop, uv, lod).rgb;
}

vec3 refracted(vec2 p, vec2 shift, float spread, float reach)
{
    float gap = reach * sqrt(3.14159265 / float(TAPS));
    float lod = clamp(log2(max(gap, 1.0)) + 0.35, 0.0, 5.0);
    float turn = fract(52.9829189 * fract(dot(gl_FragCoord.xy, vec2(0.06711056, 0.00583715)))) * TAU;
    vec3 sum = vec3(0.0);
    float total = 0.0;
    for (int i = 0; i < TAPS; ++i) {
        float k = float(i) + 0.5;
        float r = sqrt(k / float(TAPS));
        float a = k * GOLDEN_ANGLE + turn;
        float w = exp(-2.2 * r * r);
        vec2 o = vec2(cos(a), sin(a)) * r * reach;
        vec3 c;
        c.r = sampleAt(p + o + shift * (1.0 + spread), lod).r;
        c.g = sampleAt(p + o + shift, lod).g;
        c.b = sampleAt(p + o + shift * (1.0 - spread), lod).b;
        sum += c * w;
        total += w;
    }
    return sum / total;
}

vec2 edgeNormal(vec2 q, vec2 extent, float r)
{
    vec2 d = abs(q) - (extent - r);
    vec2 s = vec2(q.x >= 0.0 ? 1.0 : -1.0, q.y >= 0.0 ? 1.0 : -1.0);
    vec2 m = max(d, 0.0);
    if (length(m) > 1e-4)
        return normalize(m) * s;
    return d.x > d.y ? vec2(s.x, 0.0) : vec2(0.0, s.y);
}

void main()
{
    vec2 p = qt_TexCoord0 * itemSize;
    vec2 extent = glassSize * 0.5;
    vec2 q = p - vec2(pad) - extent;
    float r = min(radius, min(extent.x, extent.y));

    float dist = boxDistance(q, extent, r);
    float inside = clamp(0.5 - dist, 0.0, 1.0);
    float drop = 0.32 * shadow * (1.0 - smoothstep(-4.0, 18.0, boxDistance(q - vec2(0.0, 6.0), extent, r)));
    if (dist > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, drop) * qt_Opacity;
        return;
    }

    float depth = max(-dist, 0.0);
    vec2 normal2 = edgeNormal(q, extent, r);

    float u = clamp(depth / bezel, 0.0, 1.0);
    float rest = 1.0 - u;
    float slope = min(rest * rest * rest / pow(max(1.0 - pow(rest, 4.0), 1e-3), 0.75), 7.0);
    vec3 normal = normalize(vec3(normal2 * slope, 1.0));
    vec3 ray = refract(vec3(0.0, 0.0, -1.0), normal, 1.0 / 1.5);
    vec2 shift = ray.xy / max(-ray.z, 0.2) * thickness;

    float reach = softness * mix(0.45, 1.0, smoothstep(0.0, bezel, depth));
    vec3 color = refracted(p, shift, dispersion, max(reach, 0.75));

    float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));
    color = mix(vec3(luma), color, saturation);
    color = mix(color, vec3(0.09, 0.09, 0.10), tint);
    color += 0.02;

    float top = 1.0 - clamp((q.y + extent.y) / glassSize.y, 0.0, 1.0);
    color += top * 0.03;
    color *= 1.0 - 0.12 * exp(-depth / 6.0) * clamp(normal2.y, 0.0, 1.0);
    color *= 1.0 - 0.10 * exp(-depth / (bezel * 0.45));

    float facing = dot(normal2, normalize(vec2(-0.55, -0.83)));
    float spec = pow(max(facing, 0.0), 1.6) + 0.55 * pow(max(-facing, 0.0), 2.2);
    float edge = exp(-depth / 1.1) * (0.18 + 0.78 * spec) + exp(-depth / 5.0) * 0.10 * (0.30 + spec);
    float wave = (depth - bezel * 0.5) / (bezel * 0.2 + 1.0);
    edge += exp(-wave * wave) * 0.07 * (0.35 + spec);
    color += edge * rim * vec3(0.96, 0.98, 1.0);

    color += (noise(gl_FragCoord.xy) + noise(gl_FragCoord.xy * 1.7 + 17.0) - 1.0) * grain;
    color = clamp(color, 0.0, 1.0);

    fragColor = vec4(color * inside, inside + drop * (1.0 - inside)) * qt_Opacity;
}
