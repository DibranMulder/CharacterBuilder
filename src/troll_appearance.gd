class_name TrollAppearance
extends Node

var avatar: Node2D
var body: HumanTorsoSurface
var jerkin: HumanTorsoSurface
var limbs: Dictionary = {}


func setup(character: Node2D) -> void:
	avatar = character
	avatar._bones.torso.get_child(0).hide()
	body = _torso("TrollBody", "torso", "torso_back", avatar._profile.torso, .24, 0)
	jerkin = _torso("TrollJerkin", "jerkin", "jerkin_back",
		Vector2(avatar._profile.torso.x * 1.12, avatar._profile.torso.y), .36, 1)
	for side in ["left", "right"]:
		for kind in ["arm", "leg"]:
			var upper: Node2D = avatar._bones[side + "_" + kind]
			var lower: Node2D = avatar._bones[side + ("_forearm" if kind == "arm" else "_shin")]
			upper.get_child(0).hide()
			lower.get_child(0).hide()
			var surface := HumanLimbSurface.new()
			surface.name = "TrollLimbSurface"
			surface.paint_texture = TrollPaintedAtlas.texture(kind)
			surface.paint_material = TrollPaintedAtlas.paint_material()
			surface.setup(lower, float(avatar._profile[kind]) * .48,
				float(avatar._profile.limb_width if kind == "arm" else avatar._profile.leg_width),
				avatar._profile.skin, kind == "leg")
			upper.add_child(surface)
			limbs[side + "_" + kind] = surface
	refresh()


func _torso(label: String, front: String, rear: String, size: Vector2, hem: float, depth: int) -> HumanTorsoSurface:
	var surface := HumanTorsoSurface.new()
	surface.name = label
	surface.front_texture = TrollPaintedAtlas.texture(front)
	surface.rear_texture = TrollPaintedAtlas.texture(rear)
	surface.surface_material = TrollPaintedAtlas.paint_material()
	surface.flip_art = false
	surface.size = size
	surface.hem_ratio = hem
	surface.hip = avatar._bones.hip
	surface.z_index = depth
	avatar._bones.torso.add_child(surface)
	return surface


func refresh() -> void:
	var reference_armor: bool = avatar.loadout.armor == "troll_jerkin"
	var leather: bool = avatar.loadout.pants == "leather"
	jerkin.visible = reference_armor
	body.back_view = avatar._head_base.back_view
	jerkin.back_view = body.back_view
	avatar._gear.armor.visible = not reference_armor
	for side in ["left", "right"]:
		var arm: HumanLimbSurface = limbs[side + "_arm"]
		arm.paint_texture = TrollPaintedAtlas.texture("braced_arm" if reference_armor else "arm")
		arm.armor = "none" if reference_armor else avatar.loadout.armor
		var leg: HumanLimbSurface = limbs[side + "_leg"]
		leg.paint_texture = TrollPaintedAtlas.texture("leather_leg" if leather else "leg")
		leg.pants = "none" if leather else avatar.loadout.pants
	for i in avatar._pants_parts.size():
		avatar._pants_parts[i].visible = i == 0 and avatar.loadout.pants != "none"
	var waist: GearVisual = avatar._pants_parts[0]
	waist.fitted_waist = true
	waist.material = null
	waist.z_index = 0
