shader_type canvas_item;
// Same source-background key as the character's painted equipment, preserving
// vertex color so frames and lettering can share the material safely.
void fragment() {
	vec4 sample_color = COLOR;
	float dominance = max(min(sample_color.r, sample_color.b) - sample_color.g, 0.0);
	float key_strength = dominance * (1.0 - abs(sample_color.r - sample_color.b));
	sample_color.a *= 1.0 - smoothstep(0.08, 0.32, key_strength);
	float despill = smoothstep(0.025, 0.28, key_strength) * 0.94;
	sample_color.r = max(sample_color.r - dominance * despill, 0.0);
	sample_color.b = max(sample_color.b - dominance * despill, 0.0);
	COLOR = sample_color;
}
