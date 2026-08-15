#pragma header

uniform float time;
uniform vec2 res;
uniform float cameraZoom;
uniform vec2 cameraPosition;
uniform int STARTING_LAYERS;
uniform bool flipY;
uniform bool pixely;
uniform float Wzoom;
uniform float BRIGHT;
uniform int LAYERS;
uniform float DEPTH;
uniform float WIDTH;
uniform float SPEED;
uniform float OPACITY;

const mat3 p = mat3(13.323122, 23.5112, 21.71123, 21.1212, 28.7312, 11.9312, 21.8112, 14.7212, 61.3934);

float ns;

float sFract(float x, float sm) {
    float aa = max(100.0 / openfl_TextureSize.y * sm, 0.0001);
    vec2 u = vec2(x, aa);
    u.x = fract(u.x);
    u += (1.0 - 2.0 * u) * step(u.y, u.x);
    return clamp(1.0 - u.x / u.y, 0.0, 1.0);
}

float sFloor(float x) {
    return x - sFract(x, 1.0);
}

vec3 hash33(vec3 p) {
    float n = sin(dot(p, vec3(7.0, 157.0, 113.0)));
    return fract(vec3(2097152.0, 262144.0, 32768.0) * n) * 2.0 - 1.0;
}

float tetraNoise(in vec3 p) {
    vec3 i = floor(p + dot(p, vec3(1.0 / 3.0)));
    p -= i - dot(i, vec3(1.0 / 6.0));
    vec3 i1 = step(p.yzx, p);
    vec3 i2 = max(i1, 1.0 - i1.zxy);
    i1 = min(i1, 1.0 - i1.zxy);
    vec3 p1 = p - i1 + 1.0 / 6.0;
    vec3 p2 = p - i2 + 1.0 / 3.0;
    vec3 p3 = p - 0.5;
    vec4 v = max(0.5 - vec4(dot(p, p), dot(p1, p1), dot(p2, p2), dot(p3, p3)), 0.0);
    vec4 d = vec4(dot(p, hash33(i)), dot(p1, hash33(i + i1)), dot(p2, hash33(i + i2)), dot(p3, hash33(i + 1.0)));
    return clamp(dot(d, v * v * v * 8.0) * 1.732 + 0.5, 0.0, 2.0);
}

float func(vec2 p) {
    float n = tetraNoise(vec3(p.x * 4.0, p.y * 4.0, 0.0) - vec3(0.0, 0.25, 0.5) * time);
    float taper = 0.0 + dot(p, p * vec2(0.35, 1.0));
    n = max(n - taper, 0.0) / max(1.0 - taper, 0.0001);
    ns = n;
    const float palNum = 100.0;
    return n * 0.25 + clamp(sFloor(n * (palNum - 0.001)) / (palNum - 1.0), 0.0, 1.0) * 0.75;
}

float coolNoise() {
    vec2 u = (gl_FragCoord.xy - openfl_TextureSize.xy * 0.4) / openfl_TextureSize.y;
    float f = func(u);
    return f * 0.4 + ns * 0.6;
}

float brightness(vec3 color) {
    return (color.r + color.g + color.b) / 3.0;
}

void main() {
    if (BRIGHT == 0.0) {
        gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv.xy);
        return;
    }

    vec2 screenSize = openfl_TextureSize.xy;
    vec2 ndc = (gl_FragCoord.xy / screenSize) * 2.0 - 1.0;
    ndc /= cameraZoom;
    vec2 worldCoord = ((ndc + 1.0) * 0.5) * res + cameraPosition;
    vec2 st = worldCoord / res.xy;
    st *= res.xy / res.y;
    vec2 uvCentered = st * Wzoom;

    vec3 acc = vec3(0.0);
    float dof = 5.0 * sin(time * 0.1);

    for (int i = STARTING_LAYERS; i < LAYERS; i++) {
        float fi = float(i);
        vec2 q = uvCentered * (1.0 + fi * DEPTH);
        q += vec2(
            q.y * (WIDTH * (pixely ? 1.5 : 1.0) * mod(fi * 7.238917, 1.0) - WIDTH * (pixely ? 1.5 : 1.0) * 0.5)
                + (SPEED * ((float(LAYERS) - float(i)) * 0.2) * time * 0.4) * -0.6,
            -(SPEED * time / (1.0 + fi * DEPTH * 0.03))
        );
        vec3 n = vec3(floor(q), 31.189 + fi);
        vec3 m = floor(n) * 0.00001 + fract(n);
        vec3 mp = (31415.9 + m) / fract(p * m);
        vec3 r = fract(mp);
        vec2 s = abs(mod(q, 1.0) - 0.5 + 0.9 * r.xy - 0.45);
        s += 0.01 * abs(2.0 * fract(10.0 * q.yx) - 1.0);
        float d = 0.6 * max(s.x - s.y, s.x + s.y) + max(s.x, s.y) - 0.01;
        float edge = 0.005 + 0.05 * min(0.5 * abs(fi - 5.0 - dof), 1.0);
        acc += vec3(smoothstep(edge, -edge, d) * (r.x / (1.0 + 0.02 * fi * DEPTH)));
    }

    vec4 flixelColor = flixel_texture2D(bitmap, openfl_TextureCoordv.xy);
    vec3 effect = vec3(acc) * 0.8 * (0.6 + coolNoise() * 3.0);
    flixelColor.rgb += effect * (pixely ? 1.6 : 1.0) * BRIGHT * OPACITY * (pow(flixelColor.rgb, vec3(1.7)) * 0.9) * 0.3;

    if (flixelColor.a == 0.0 && (effect.r > 0.0 || effect.g > 0.0 || effect.b > 0.0)) {
        flixelColor.a = brightness(effect);
    }

    gl_FragColor = flixelColor;
}