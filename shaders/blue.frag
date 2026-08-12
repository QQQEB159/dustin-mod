#pragma header

uniform float time;
uniform vec2 res;

uniform float cameraZoom;
uniform vec2 cameraPosition;

uniform int STARTING_LAYERS;
uniform bool flipY;

uniform vec4 snowMeltRect;
uniform bool snowMelts;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float coolNoise() {
    vec2 uv = (gl_FragCoord.xy - openfl_TextureSize.xy * 0.4) / openfl_TextureSize.y;
    return random(uv + time * 0.5);
}

uniform int LAYERS;
uniform float DEPTH;
uniform float WIDTH;
uniform float SPEED;

const mat3 p = mat3(13.323122, 23.5112, 21.71123,
                    21.1212,  28.7312, 11.9312,
                    21.8112,  14.7212, 61.3934);

void main()
{
    vec2 trueFragCoord = gl_FragCoord.xy * (res / openfl_TextureSize);
    vec2 centeredPixel = trueFragCoord - res.xy * 0.5;
    vec2 zoomedCenteredPixel = centeredPixel * (1.0 / (cameraZoom + 1.0));
    vec2 pixel = zoomedCenteredPixel + res.xy * 0.5 + cameraPosition.xy;

    vec2 uvCentered = (2.0 * pixel / res.y);
    if (flipY) uvCentered.y *= -1.0;

    float meltiness = abs(1.0 - ((pixel.y - snowMeltRect.y) / snowMeltRect.w));
    if (pixel.y >= snowMeltRect.y + snowMeltRect.w) meltiness = 0.0;

    vec3 acc = vec3(0.0);
    float dof = 5.0 * sin(time * 0.1);
    for (int i = STARTING_LAYERS; i < LAYERS; i++) {
        float fi = float(i);
        vec2 q = uvCentered * (1.0 + fi * DEPTH);
        q += vec2(0.0, SPEED * time / (1.0 + fi * DEPTH * 0.03));
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

    vec4 rect = vec4((snowMeltRect.x / openfl_TextureSize.x) * res.x,
                     (snowMeltRect.y / openfl_TextureSize.y) * res.y,
                     (snowMeltRect.z / openfl_TextureSize.x) * res.x,
                     (snowMeltRect.w / openfl_TextureSize.y) * res.y);
    rect.xy += openfl_TextureSize.xy - res.xy;

    if (snowMelts && ((pixel.x >= rect.x) && (pixel.x < rect.x + rect.z) && (pixel.y >= rect.y)))
        acc *= meltiness;

    vec4 flixelColor = flixel_texture2D(bitmap, openfl_TextureCoordv.xy);

    gl_FragColor = flixelColor + vec4(acc * vec3(0.4, 0.7, 1.5) * 1.0 * (2.0 + (coolNoise() * 0.4)), flixelColor.a);
}