class_name FaeAppearance
extends Node

# Fae art and loadout fitting live together; the existing rig owns motion,
# weapon sockets, facing and wings. No reference outfit is baked into anatomy.
var avatar: Node2D
var body: HumanTorsoSurface
var tunic: HumanTorsoSurface
var limbs: Dictionary = {}
const WING_SOURCE := "res://assets/base_sprites/fae_reference_wings_v2.png"


func setup(character: Node2D) -> void:
	avatar = character
	var torso: Node2D = avatar._bones.torso
	torso.get_child(0).hide()
	body = _torso("FaeBody", "torso", "torso_back", avatar._profile.torso, .24, 0)
	tunic = _torso("FaeTunic", "tunic", "tunic_back", Vector2(88, avatar._profile.torso.y), .50, 1)
	_build_wings()
	for side in ["left", "right"]:
		for kind in ["arm", "leg"]:
			var upper: Node2D = avatar._bones[side + "_" + kind]
			var lower: Node2D = avatar._bones[side + ("_forearm" if kind == "arm" else "_shin")]
			upper.get_child(0).hide()
			lower.get_child(0).hide()
			var surface := HumanLimbSurface.new()
			surface.name = "FaeLimbSurface"
			surface.paint_texture = FaePaintedAtlas.texture(kind)
			surface.paint_material = CentaurPaintedAtlas.paint_material()
			surface.setup(lower, float(avatar._profile[kind]) * .48,
				float(avatar._profile.limb_width if kind == "arm" else avatar._profile.leg_width),
				avatar._profile.skin, kind == "leg")
			upper.add_child(surface)
			limbs[side + "_" + kind] = surface
	refresh()


func _build_wings() -> void:
	var crop := Rect2(140, 80, 1368, 889)
	var root_pixel := Vector2(150, 487)
	var texture := AtlasTexture.new()
	texture.atlas = load(WING_SOURCE)
	texture.region = crop
	texture.filter_clip = true
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
void fragment() {
 vec4 paint = texture(TEXTURE, UV);
 float key = min(paint.r, paint.b) - paint.g;
 paint.a *= 1.0 - smoothstep(0.12, 0.4, key);
 float vein = smoothstep(0.01, 0.12, paint.r - paint.b);
 float ink = 1.0 - smoothstep(0.18, 0.48, max(paint.r, max(paint.g, paint.b)));
 paint.a *= mix(0.22, 0.80, max(vein, ink));
 paint.b = min(paint.b, paint.g + 0.08);
 COLOR = paint;
}
"""
	var membrane := ShaderMaterial.new()
	membrane.shader = shader
	for side in ["left", "right"]:
		var bone: PartVisual = avatar._bones[side + "_wing"]
		bone.set_authored_skin(true)
		var hinge := Node2D.new()
		hinge.name = "ReferenceWing"
		hinge.scale.x = -1.0 if side == "left" else 1.0
		hinge.rotation_degrees = -12.0 if side == "left" else 12.0
		bone.add_child(hinge)
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.scale = Vector2.ONE * (84.0 / crop.size.x)
		sprite.position = (crop.get_center() - root_pixel) * sprite.scale
		sprite.material = membrane
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		hinge.add_child(sprite)


func _torso(label: String, front: String, rear: String, size: Vector2, hem: float, depth: int) -> HumanTorsoSurface:
	var surface := HumanTorsoSurface.new()
	surface.name = label
	surface.front_texture = FaePaintedAtlas.texture(front)
	surface.rear_texture = FaePaintedAtlas.texture(rear)
	surface.surface_material = CentaurPaintedAtlas.paint_material()
	surface.flip_art = false
	surface.size = size
	surface.hem_ratio = hem
	surface.hip = avatar._bones.hip
	surface.z_index = depth
	avatar._bones.torso.add_child(surface)
	return surface


func refresh() -> void:
	var reference_armor: bool = avatar.loadout.armor == "fae_tunic"
	var baggy: bool = avatar.loadout.pants == "baggy"
	tunic.visible = reference_armor
	body.back_view = avatar._head_base.back_view
	tunic.back_view = body.back_view
	avatar._gear.armor.visible = not reference_armor
	for side in ["left", "right"]:
		var arm: HumanLimbSurface = limbs[side + "_arm"]
		arm.paint_texture = FaePaintedAtlas.texture("wrapped_arm" if reference_armor else "arm")
		arm.armor = "none" if reference_armor else avatar.loadout.armor
		var leg: HumanLimbSurface = limbs[side + "_leg"]
		leg.paint_texture = FaePaintedAtlas.texture("baggy_leg" if baggy else "leg")
		leg.width = 37.0 if baggy else float(avatar._profile.leg_width)
		# The reference trousers are already painted; other items retain the
		# shared continuous clothing contour instead of restoring knee sprites.
		leg.pants = "none" if baggy else avatar.loadout.pants
	for i in avatar._pants_parts.size():
		avatar._pants_parts[i].visible = i == 0 and avatar.loadout.pants != "none"
	var waist: GearVisual = avatar._pants_parts[0]
	waist.fitted_waist = true
	waist.material = null
	waist.z_index = 0
	var wrapped: bool = avatar.loadout.boots == "wraps"
	for foot in [avatar._left_foot_base, avatar._right_foot_base]:
		foot.set_part("foot_wraps" if wrapped else "foot")
		foot.visible = wrapped or avatar.loadout.boots == "none"
	for boot in avatar._boot_parts:
		boot.visible = not wrapped
