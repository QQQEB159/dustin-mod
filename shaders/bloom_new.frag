#pragma header

uniform float brightness;

void main(void) {
    vec2 uv = openfl_TextureCoordv.xy;
    vec4 color = flixel_texture2D(bitmap, uv);

    float finalBright = 1.0 + (brightness - 1.0) * 0.5;

    gl_FragColor = vec4(color.rgb * finalBright, color.a);
}