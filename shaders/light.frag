#pragma header

uniform float time;
uniform vec2 res;

uniform float cameraZoom;
uniform vec2 cameraPosition;

uniform int STARTING_LAYERS;
uniform bool flipY;

uniform vec4 snowMeltRect;
uniform bool snowMelts;

uniform int LAYERS;
uniform float DEPTH;
uniform float WIDTH;
uniform float SPEED;
uniform float OPACITY;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void main()
{
    vec2 trueFragCoord = gl_FragCoord.xy * (res / openfl_TextureSize);
    vec2 centeredPixel = trueFragCoord - res.xy * 0.5;
    vec2 zoomedCenteredPixel = centeredPixel / (cameraZoom + 1.0);
    vec2 pixel = zoomedCenteredPixel + res.xy * 0.5 + cameraPosition.xy;
    vec2 uvCentered = (2.0 * pixel) / res.y;
    if (flipY) uvCentered.y *= -1.0;
    
    float meltiness = abs(1.0 - (pixel.y - snowMeltRect.y) / snowMeltRect.w);
    if (pixel.y >= snowMeltRect.y + snowMeltRect.w) meltiness = 0.0;

    vec3 acc = vec3(0.0);
    float dof = 5.0 * sin(time * 0.1);

    for (int i = STARTING_LAYERS; i < LAYERS; i++) {
        float fi = float(i);
        float scale = 1.0 + fi * DEPTH;
        float invScale = 1.0 / scale;

        vec2 q = uvCentered * scale;
        q.y += SPEED * time * invScale;

        vec2 cell = floor(q);
        vec2 r = vec2(hash(cell + fi), hash(cell + fi + 1.0));
        vec2 center = cell + 0.5 + (r - 0.5) * 0.9;

        float d = length(q - center);
        float edge = 0.05 * invScale;
        float brightness = 1.0 - smoothstep(0.0, edge, d);
        brightness *= r.x / (1.0 + 0.02 * fi * DEPTH);

        acc += brightness;
    }

    vec4 rect = vec4((snowMeltRect.x / openfl_TextureSize.x) * res.x,
                     (snowMeltRect.y / openfl_TextureSize.y) * res.y,
                     (snowMeltRect.z / openfl_TextureSize.x) * res.x,
                     (snowMeltRect.w / openfl_TextureSize.y) * res.y);
    rect.xy += openfl_TextureSize.xy - res.xy;

    if (snowMelts && (pixel.x >= rect.x) && (pixel.x < rect.x + rect.z) && (pixel.y >= rect.y))
        acc *= meltiness;

    float noiseFactor = fract(sin(dot(pixel * 0.1 + time, vec2(12.9898, 78.233))) * 43758.5453);
    float brightness = 0.6 + noiseFactor * 0.4;

    vec4 flixelColor = flixel_texture2D(bitmap, openfl_TextureCoordv.xy);
    gl_FragColor = flixelColor + vec4(acc * vec3(1.0, 1.0, 0.6) * 0.8 * brightness, flixelColor.a) * OPACITY;
}