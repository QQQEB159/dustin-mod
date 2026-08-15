#pragma header

uniform float sat;
uniform float contrast;

const vec3 LUM = vec3(0.3086, 0.6094, 0.0820);

void main(void)
{
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
    vec3 contrasted = color.rgb * contrast + color.a * (1.0 - contrast) * 0.5;
    float lum = dot(contrasted, LUM);
    gl_FragColor = vec4(mix(vec3(lum), contrasted, sat), color.a);
}