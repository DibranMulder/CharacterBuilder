shader_type canvas_item;
void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	float spill = max(min(pixel.r, pixel.b)-pixel.g, 0.0);
	float strength = spill*(1.0-abs(pixel.r-pixel.b));
	float coverage = 1.0-smoothstep(0.08,0.34,strength);
	float despill = smoothstep(0.025,0.30,strength)*0.94;
	pixel.rb = max(pixel.rb-vec2(spill*despill),vec2(0.0));
	COLOR = vec4(pixel.rgb,pixel.a*coverage);
}
