class_name FrostlingAppearance
extends Node

var avatar: Node2D
var body: HumanTorsoSurface
var coat: HumanTorsoSurface
var limbs: Dictionary = {}


func setup(character: Node2D) -> void:
	avatar = character
	avatar._bones.torso.get_child(0).hide()
	body = _torso("FrostlingBody", "torso", "torso_back", .24, 0)
	coat = _torso("FrostlingCoat", "coat", "coat_back", .50, 1)
	coat.size.x *= 1.55
	for side in ["left", "right"]:
		for kind in ["arm", "leg"]:
			var upper: Node2D = avatar._bones[side + "_" + kind]
			var lower: Node2D = avatar._bones[side + ("_forearm" if kind == "arm" else "_shin")]
			upper.get_child(0).hide()
			lower.get_child(0).hide()
			var surface := HumanLimbSurface.new()
			surface.name = "FrostlingLimbSurface"
			surface.paint_texture = FrostlingPaintedAtlas.texture(kind)
			surface.paint_material = TrollPaintedAtlas.paint_material()
			surface.accent = avatar._profile.accent
			surface.setup(lower, float(avatar._profile[kind]) * .48,
				float(avatar._profile.limb_width if kind == "arm" else avatar._profile.leg_width),
				avatar._profile.skin, kind == "leg")
			upper.add_child(surface)
			limbs[side + "_" + kind] = surface
	refresh()


func _torso(label: String, front: String, rear: String, hem: float, depth: int) -> HumanTorsoSurface:
	var surface := HumanTorsoSurface.new()
	surface.name = label
	surface.front_texture = FrostlingPaintedAtlas.texture(front)
	surface.rear_texture = FrostlingPaintedAtlas.texture(rear)
	surface.surface_material = TrollPaintedAtlas.paint_material()
	surface.flip_art = false
	surface.size = avatar._profile.torso
	surface.hem_ratio = hem
	surface.hip = avatar._bones.hip
	surface.z_index = depth
	avatar._bones.torso.add_child(surface)
	return surface


func refresh() -> void:
	var fur_coat: bool = avatar.loadout.armor == "fur_coat"
	coat.visible = fur_coat
	body.back_view = avatar._head_base.back_view
	coat.back_view = body.back_view
	avatar._gear.armor.visible = not fur_coat
	for side in ["left", "right"]:
		var arm: HumanLimbSurface = limbs[side + "_arm"]
		arm.paint_texture = FrostlingPaintedAtlas.texture("braced_arm" if fur_coat else "arm")
		arm.armor = "none" if fur_coat else avatar.loadout.armor
		var leg: HumanLimbSurface = limbs[side + "_leg"]
		leg.paint_texture = FrostlingPaintedAtlas.texture("cloth_leg" if avatar.loadout.pants == "cloth" else "leg")
		leg.pants = "none" if avatar.loadout.pants == "cloth" else avatar.loadout.pants
	for i in avatar._pants_parts.size():
		avatar._pants_parts[i].visible = i == 0 and avatar.loadout.pants != "none"
	var waist: GearVisual = avatar._pants_parts[0]
	waist.fitted_waist = true
	waist.material = null
	waist.z_index = 0
	for boot in avatar._boot_parts:
		_override(boot, "boot" if avatar.loadout.boots == "leather" else "", Rect2(-12, -12, 32, 28))
	_override(avatar._gear.back, "pack" if avatar.loadout.back == "pack" else "", Rect2(-58, -9, 51, 67))
	var covered: bool = avatar.loadout.head == "hood"
	avatar._head_base.visible = not covered
	# Front hair hangs below the chin; the rear hood stops at the coat collar.
	var hood_rect := Rect2(-48, -58, 96, 88 if body.back_view else 108)
	_override(avatar._gear.head, ("hood_back" if body.back_view else "hood") if covered else "", hood_rect)


func _override(gear: GearVisual, part: String, rect: Rect2) -> void:
	var was_override := gear.appearance_texture != null
	gear.appearance_texture = FrostlingPaintedAtlas.texture(part) if part != "" else null
	gear.appearance_rect = rect
	if part != "":
		gear.material = TrollPaintedAtlas.paint_material()
	elif was_override:
		gear.setup(gear.slot, gear.item, gear.accent)
	gear.queue_redraw()
