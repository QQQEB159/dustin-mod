#pragma header

#define PI 3.1415926535897932384626433832795
#define TWO_PI (PI * 2.0)

uniform float brightness;
uniform float directions;
uniform float quality;
uniform float size;

void main(void)
{
    vec2 uv = openfl_TextureCoordv.xy;
    vec4 color = flixel_texture2D(bitmap, uv);
    vec4 bloom = color;

    if (brightness == 1.0 && size == 0.0) {
        gl_FragColor = color;
        return;
    }

    float dirStep = TWO_PI / directions;
    float sampleStep = 1.0 / quality;
    float invTexSizeY = 1.0 / openfl_TextureSize.y;
    float invTexSizeX = 1.0 / openfl_TextureSize.x;

    float maxApply = 0.0;

    for (float d = 0.0; d < TWO_PI; d += dirStep) {
        for (float i = sampleStep; i <= 1.0; i += sampleStep) {
            float x_movement = sin(d) * size * i * invTexSizeY;
            float y_movement = cos(d) * size * i * invTexSizeX;

            bloom += flixel_texture2D(bitmap, uv + vec2(x_movement, y_movement));

            float weight = step(0.0, x_movement) + step(0.0, y_movement);
            bloom *= 1.0 - (i * sampleStep) * weight;

            maxApply += 1.0;
        }
    }

    float brightnessFactor = 1.0 - (1.0 / maxApply);
    bloom /= maxApply;

    float brightnessApply = brightness;
    if (brightness < 1.5) {
        brightnessApply = mix(1.5, 0.0, abs(1.0 - ((brightness - 1.0) * 2.0)));
    }

    gl_FragColor = color + ((bloom * brightnessFactor) * brightnessApply);
}