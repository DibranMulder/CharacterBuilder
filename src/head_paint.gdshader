shader_type canvas_item;
varying vec4 vertex_tint;

void vertex() {
	vertex_tint = COLOR;
}

// Key each subpixel before averaging. Filtering magenta into the silhouette
// first leaves dark fringes and makes fine hair flicker at gameplay scale.
vec4 paint_at(vec4 p) {
	float spill = max(min(p.r, p.b) - p.g, 0.0);
	float key = spill * (1.0 - abs(p.r - p.b));
	float coverage = 1.0 - smoothstep(0.08, 0.34, key);
	float despill = smoothstep(0.025, 0.30, key) * 0.94;
	p.rb = max(p.rb - vec2(spill * despill), vec2(0.0));
	p.a *= coverage;
	return vec4(p.rgb * p.a, p.a);
}

void fragment() {
	vec2 dx = dFdx(UV) * 0.25;
	vec2 dy = dFdy(UV) * 0.25;
	vec4 p = (paint_at(texture(TEXTURE,UV-dx-dy)) + paint_at(texture(TEXTURE,UV+dx-dy))
		+ paint_at(texture(TEXTURE,UV-dx+dy)) + paint_at(texture(TEXTURE,UV+dx+dy))) * 0.25;
	COLOR = vec4(p.rgb / max(p.a, 0.0001), p.a) * vertex_tint;
}
