#pragma header

uniform float time;
uniform float strength;
uniform vec2 res;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
			 mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void main() {
	vec2 uv = openfl_TextureCoordv.xy;
	vec2 pixelSize = 1.0 / res;
	float t = time;
	float amt = clamp(strength, 0.0, 2.0);

	float wave = sin(uv.y * 7.0 - t * 1.9) * 0.00105 + sin(uv.y * 29.0 + t * 5.4) * 0.00042;
	float randBend = (noise(vec2(uv.y * 9.0, t * 0.42)) - 0.5) * 0.00125;
	uv.x += (wave + randBend) * amt;

	float riseTime = t * 0.31;
	float riseCycle = floor(riseTime);
	float risePhase = fract(riseTime);
	float risePos = 1.10 - risePhase * 1.24;
	float riseDist = abs(uv.y - risePos);
	float riseWide = (1.0 - smoothstep(0.010, 0.070, riseDist)) * mix(0.45, 1.0, hash(vec2(riseCycle + 41.7, 0.0)));
	uv.x += riseWide * mix(-1.0, 1.0, step(0.5, hash(vec2(riseCycle + 8.3, 0.0)))) * 0.006 * amt;

	float tearTick = floor(t * 7.0);
	float tearEnabled = smoothstep(0.972, 0.995, hash(vec2(tearTick + 71.2, 0.0)));
	float tearPos = hash(vec2(tearTick + 13.7, 0.0));
	float tearMask = 1.0 - smoothstep(0.0015, 0.012, abs(uv.y - tearPos));
	uv.x += tearMask * tearEnabled * (hash(vec2(tearTick + 91.4, 0.0)) - 0.5) * 0.014 * amt;

	vec4 center = texture2D(bitmap, clamp(uv, 0.001, 0.999));
	vec4 left = texture2D(bitmap, clamp(uv - vec2(pixelSize.x * 2.0, 0.0), 0.001, 0.999));
	vec4 right = texture2D(bitmap, clamp(uv + vec2(pixelSize.x * 2.0, 0.0), 0.001, 0.999));

	float chromaOff = 0.00105 * amt;
	float r = texture2D(bitmap, clamp(uv + vec2(chromaOff, 0.0), 0.001, 0.999)).r;
	float b = texture2D(bitmap, clamp(uv - vec2(chromaOff, 0.0), 0.001, 0.999)).b;
	vec3 color = vec3(r, center.g, b);

	float blurAmount = min(amt * 0.08, 0.5);
	vec4 blurSample = texture2D(bitmap, clamp(uv + vec2(pixelSize.x * 3.0 * blurAmount, 0.0), 0.001, 0.999));
	vec4 blurSample2 = texture2D(bitmap, clamp(uv - vec2(pixelSize.x * 3.0 * blurAmount, 0.0), 0.001, 0.999));
	vec3 blurAvg = (center.rgb + blurSample.rgb + blurSample2.rgb) / 3.0;
	color = mix(color, blurAvg, blurAmount * 0.5);

	color = mix(color, (left.rgb + center.rgb * 2.0 + right.rgb) / 4.0, 0.04 * amt);

     float scanline = 0.5 + 0.5 * sin(uv.y * res.y * 0.3);
     color *= 1.0 - scanline * 0.011 * amt;

     float noiseVal = hash(floor(uv * res) + vec2(floor(t * 30.0) * 37.0, 0.0));
     color += (noiseVal - 0.5) * 0.013 * amt;

	vec2 centered = uv - 0.5;
	vec2 aspect = vec2(res.x / res.y, 1.0);
	float edge = smoothstep(0.42, 0.95, length(centered * aspect));
	color *= 1.0 - edge * 0.045 * amt;

	gl_FragColor = vec4(clamp(color, 0.0, 1.0), center.a);
}