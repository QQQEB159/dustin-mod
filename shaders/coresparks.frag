// Shader from: https://www.shadertoy.com/view/MlKSWm
// Optimized for mobile
#pragma header

uniform float time;
uniform float strength;
uniform float speed;
uniform float zoom;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float hash21(vec2 p) {
	p = fract(p * vec2(234.34, 435.345));
	p += dot(p, p + 19.19);
	return fract(p.x * p.y);
}

float prng(in vec2 seed) {
	seed = fract(seed * vec2(5.3983, 5.4427));
	seed += dot(seed.yx, seed.xy + vec2(21.5351, 14.3137));
	return fract(seed.x * seed.y * 95.4337);
}

float noiseStack(vec2 pos) {
	vec2 i = floor(pos);
	vec2 f = fract(pos);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void main() {
    vec2 uv = openfl_TextureCoordv.xy;
	vec2 fragCoord = uv * openfl_TextureSize;
	float xfuel = pow(1.0 - abs(2.0 * uv.x - 1.0), 0.8) / zoom;
	float realTime = time * speed * 0.5;
	float sparkGridSize = 25.0;
	float lifeMin = 24.0 - 20.0 * hash21(fragCoord / 100.0);
	vec2 sparkCoord = fragCoord - vec2(0.0, 190.0 * realTime);
	sparkCoord -= 30.0 * (noiseStack(sparkCoord * 0.01 + vec2(realTime * 0.5)) - 0.5) * 1.0;
	// sparkCoord.y /= zoom;
	if (mod(sparkCoord.y / sparkGridSize, 2.0) < 1.0) sparkCoord.x += 0.5 * sparkGridSize;
	vec2 gridIndex = floor(sparkCoord / sparkGridSize);
	float sparkRandom = prng(gridIndex);
	float sparkLife = clamp(5.0 * strength * (1.0 - clamp((gridIndex.y + 190.0 * realTime / sparkGridSize) / lifeMin, 0.0, 1.0)), 0.0, strength * 0.5);
	vec3 sparks = vec3(0.0);
	if (sparkLife > 0.0) {
		float sparkSize = xfuel * xfuel * sparkRandom * 0.13;
		float sparkRadians = 999.0 * sparkRandom * 6.28318 + 2.0 * time;
		vec2 sparkCircular = vec2(sin(sparkRadians), cos(sparkRadians));
		vec2 sparkOffset = (0.5 - sparkSize) * sparkGridSize * sparkCircular;
		vec2 sparkModulus = mod(sparkCoord + sparkOffset, sparkGridSize) - 0.5 * vec2(sparkGridSize);
		float sparkLength = length(sparkModulus);
		float sparksGray = max(0.0, 1.0 - sparkLength / (sparkSize * sparkGridSize));
		sparks = sparkLife * sparksGray * vec3(1.0, 0.5, 0.0);
	}
	
	float brightness = (sparks.r + sparks.g + sparks.b) / 3.0;
	gl_FragColor = vec4(sparks * 2.0, brightness);
}