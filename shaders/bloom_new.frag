#pragma header

#define PI 3.1415926535897932384626433832795
#define TWO_PI (PI * 2.0)

uniform float brightness;
uniform float threshold;
uniform float directions;
uniform int quality;
uniform float size;

void main(void) {
    vec2 uv = openfl_TextureCoordv.xy;
    vec4 color = flixel_texture2D(bitmap, uv);

    if (brightness <= 0.0 || size <= 0.0) {
        gl_FragColor = color;
        return;
    }

    vec4 bloom = vec4(0.0);
    float weightSum = 0.0;

    float stepAngle = TWO_PI / directions;
    float invQuality = 1.0 / float(quality);
    float sizeOverQuality = size * invQuality;
    float texSizeY = openfl_TextureSize.y;
    float texSizeX = openfl_TextureSize.x;

    for (float d = 0.0; d < TWO_PI; d += stepAngle) {
        float sinD = sin(d);
        float cosD = cos(d);
        for (float i = 1.0; i <= float(quality); i++) {
            float offset = i * sizeOverQuality;
            float x_offset = (sinD * offset) / texSizeY;
            float y_offset = (cosD * offset) / texSizeX;
            vec2 sampleUV = clamp(uv + vec2(x_offset, y_offset), 0.0, 1.0);

            vec4 sampleColor = max(flixel_texture2D(bitmap, sampleUV) - threshold, 0.0);
            float weight = exp(-2.0 * i * invQuality);
            bloom += sampleColor * weight;
            weightSum += weight;
        }
    }

    if (weightSum > 0.0) {
        bloom /= weightSum;
    }

    gl_FragColor = color + bloom * brightness;
}