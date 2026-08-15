#pragma header

uniform vec3 color;
uniform float amount;
uniform float strength;
uniform bool transperency;

void main() {
    const vec2 center = vec2(0.5);

    if (transperency) {
        vec4 flixelColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
        float dist = distance(openfl_TextureCoordv, center);
        float vignette = 1.0 - amount * dist;
        float vignetteStrength = 1.0 - pow(vignette, strength);

        gl_FragColor = flixelColor + vec4(color * vignetteStrength, vignetteStrength);
    } else {
        vec2 uv = getCamPos(openfl_TextureCoordv);
        vec3 col = pow(textureCam(bitmap, uv).rgb, vec3(1.0 / strength));

        float vignette = 1.0 - amount * distance(uv, center);
        col = pow(mix(col * color, col, vignette), vec3(strength));

        gl_FragColor = vec4(col, 1.0);
    }
}