shader_type canvas_item;
uniform vec2 region_origin;
uniform vec2 region_size;
void fragment() {
	vec4 paint = COLOR;
	float dominance = max(min(paint.r,paint.b)-paint.g,0.0);
	float key = dominance*(1.0-abs(paint.r-paint.b));
	paint.a *= 1.0-smoothstep(0.08,0.32,key);
	float despill = smoothstep(0.025,0.28,key)*0.94;
	paint.r = max(paint.r-dominance*despill,0.0);
	paint.b = max(paint.b-dominance*despill,0.0);
	vec2 portrait_uv = (UV-region_origin)/region_size;
	paint.a *= 1.0-smoothstep(0.485,0.498,distance(portrait_uv,vec2(0.5)));
	COLOR = paint;
}
