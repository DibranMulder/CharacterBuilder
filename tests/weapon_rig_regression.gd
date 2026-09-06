extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
var failed := false


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	assert(GearVisual.STORYBOOK_CLOTH_ARMOR.resource_path.ends_with("cloth_armor_storybook_v3.png"), "cloth armor still uses the detached foreground armhole")
	if GearVisual.STORYBOOK_SWORD.get_size().y < 100.0:
		_fail("authored sword texture is missing or below its game-scale reach")
	if GearVisual.STORYBOOK_SHIELD_EXTERIOR.get_size().y < 56.0 or GearVisual.STORYBOOK_SHIELD_INTERIOR.get_size().y < 56.0:
		_fail("authored shield exterior/interior pair is missing or undersized")
	if GearVisual.STORYBOOK_MARSH_SHIELD_EXTERIOR.get_size() != Vector2(96,96) or GearVisual.STORYBOOK_DUNE_SHIELD_EXTERIOR.get_size() != Vector2(96,96):
		_fail("lineage shield variants must retain their shared 96-pixel socket canvas")
	if GearVisual.STORYBOOK_MARSH_SHIELD_EXTERIOR.get_image().get_pixel(0,0).a > .02 or GearVisual.STORYBOOK_DUNE_SHIELD_EXTERIOR.get_image().get_pixel(95,95).a > .02:
		_fail("lineage shield variants must retain genuine transparent padding")
	if CharacterCatalog.reference_loadout("bogkin").offhand != "marsh_shield" or CharacterCatalog.reference_loadout("duneborn").offhand != "dune_shield":
		_fail("reference loadouts must select their authored lineage shields")
	var shield_variant_avatar := Avatar.new()
	root.add_child(shield_variant_avatar)
	for shield_item in CharacterCatalog.SHIELD_ITEMS:
		shield_variant_avatar.configure("human",{"weapon":"sword","offhand":shield_item})
		var shield_variant: GearVisual = shield_variant_avatar._gear.offhand
		if shield_variant.item != shield_item or not shield_variant.shield_exterior:
			_fail("%s must equip on the shared exterior-facing offhand socket" % shield_item)
		shield_variant_avatar.play_motion(&"climb")
		if shield_variant.get_parent() != shield_variant_avatar._bones.torso or not shield_variant.carried_on_back or not shield_variant.shield_exterior:
			_fail("%s must retain its selected face while carried on the climbing back socket" % shield_item)
		shield_variant_avatar.stop_motion()
		shield_variant_avatar.equip(&"weapon","bow")
		if shield_variant_avatar.loadout.offhand != "none" or shield_variant_avatar.equip(&"offhand",shield_item):
			_fail("%s must obey the bow/offhand incompatibility contract" % shield_item)
	for utility_item in ["lantern","spellbook"]:
		shield_variant_avatar.configure("human",{"weapon":"sword","offhand":utility_item})
		var utility_visual: GearVisual = shield_variant_avatar._gear.offhand
		shield_variant_avatar.play_motion(&"climb")
		if utility_visual.get_parent() != shield_variant_avatar._bones.torso or not utility_visual.carried_on_back:
			_fail("%s must stow on the torso so both climbing hands remain free" % utility_item)
		if utility_visual.position.x > -20.0 or utility_visual.z_index <= shield_variant_avatar._gear.weapon.z_index:
			_fail("%s rear stow must remain visible outside and above the back-mounted weapon" % utility_item)
		shield_variant_avatar.stop_motion()
		if utility_visual.get_parent() != shield_variant_avatar._bones.left_forearm or utility_visual.carried_on_back:
			_fail("%s must return to the offhand after climbing" % utility_item)
	shield_variant_avatar.free()
	if GearVisual.STORYBOOK_STAFF.get_size().y < 190.0:
		_fail("authored staff texture is missing or shorter than its socket contract")
	if GearVisual.STORYBOOK_BOW.get_size() != Vector2(40,88):
		_fail("authored bow stave must preserve the string endpoint and hand socket contract")
	if GearVisual.STORYBOOK_CROSSBOW.get_size() != Vector2(110,140):
		_fail("authored crossbow must preserve its compact stock and limb contract")
	if GearVisual.STORYBOOK_AXE.get_size().y < 110.0:
		_fail("authored one-handed axe is missing or too short for its reach contract")
	if GearVisual.STORYBOOK_TROLL_GREAT_AXE.get_size() != Vector2(120,190):
		_fail("authored Frost Troll great axe must preserve both grip and blade endpoints")
	if GearVisual.STORYBOOK_SPEAR.get_size().y < 195.0:
		_fail("authored spear must span the shared pole-weapon butt and tip contract")
	if GearVisual.LANTERN_DRAW_OFFSET != Vector2(-16,-4):
		_fail("lantern must hang below its offhand loop instead of disappearing along the forearm")
	if GearVisual.LANTERN_DISPLAY_SCALE < 1.3:
		_fail("lantern must remain readable at gameplay scale")
	if GearVisual.QUIVER_DRAW_OFFSET.x < -8.0:
		_fail("quiver must remain biased outside the torso silhouette")
	if GearVisual.STORYBOOK_LEATHER_ARMOR.get_size() != Vector2(82,76) or GearVisual.STORYBOOK_LEATHER_ARMOR_BACK.get_size() != Vector2(82,76):
		_fail("authored leather armor views must share the torso socket dimensions")
	if GearVisual.STORYBOOK_CLOTH_ARMOR.get_size() != Vector2(82,76) or GearVisual.STORYBOOK_CLOTH_ARMOR_BACK.get_size() != Vector2(82,76):
		_fail("authored cloth armor views must share the torso socket dimensions")
	var cloth_armor_back_image := GearVisual.STORYBOOK_CLOTH_ARMOR_BACK.get_image()
	if cloth_armor_back_image.get_pixel(0,0).a > .02 or cloth_armor_back_image.get_pixel(41,0).a > .05:
		_fail("authored rear cloth armor must preserve its transparent field and neck aperture")
	if cloth_armor_back_image.get_pixel(2,18).a > .35 or cloth_armor_back_image.get_pixel(79,18).a > .6:
		_fail("authored rear cloth armor must keep both compact arm apertures transparent")
	var leather_armor_back_image := GearVisual.STORYBOOK_LEATHER_ARMOR_BACK.get_image()
	if leather_armor_back_image.get_pixel(0,0).a > .02 or leather_armor_back_image.get_pixel(41,0).a > .05:
		_fail("authored rear leather armor must preserve its transparent field and neck aperture")
	if leather_armor_back_image.get_pixel(6,26).a > .05 or leather_armor_back_image.get_pixel(75,26).a > .05:
		_fail("authored rear leather armor must keep both articulated arm apertures transparent")
	if GearVisual.STORYBOOK_MARSH_TUNIC.get_size() != Vector2(82,76) or GearVisual.STORYBOOK_MARSH_TUNIC_BACK.get_size() != Vector2(82,76):
		_fail("authored Bogkin marsh tunic views must share the torso socket dimensions")
	var marsh_tunic_image := GearVisual.STORYBOOK_MARSH_TUNIC.get_image()
	if marsh_tunic_image.get_pixel(0,0).a > .02 or marsh_tunic_image.get_pixel(41,12).a > .05:
		_fail("authored Bogkin marsh tunic must keep its outer field and neck aperture transparent")
	if marsh_tunic_image.get_pixel(10,24).a > .05 or marsh_tunic_image.get_pixel(70,28).a > .05:
		_fail("authored Bogkin marsh tunic must keep both articulated arm apertures transparent")
	var marsh_tunic_back_image := GearVisual.STORYBOOK_MARSH_TUNIC_BACK.get_image()
	if marsh_tunic_back_image.get_pixel(0,0).a > .02 or marsh_tunic_back_image.get_pixel(10,24).a > .05 or marsh_tunic_back_image.get_pixel(72,28).a > .05:
		_fail("authored rear Bogkin marsh tunic must preserve its transparent field and arm apertures")
	if GearVisual.STORYBOOK_WOODLAND_HARNESS.get_size() != Vector2(82,76) or GearVisual.STORYBOOK_WOODLAND_HARNESS_BACK.get_size() != Vector2(82,76):
		_fail("authored Centaur woodland harness views must share the torso socket dimensions")
	var woodland_harness_image := GearVisual.STORYBOOK_WOODLAND_HARNESS.get_image()
	if woodland_harness_image.get_pixel(0,0).a > .02 or woodland_harness_image.get_pixel(41,18).a > .05:
		_fail("authored Centaur woodland harness must keep its outer field and torso center transparent")
	if woodland_harness_image.get_pixel(10,26).a > .05 or woodland_harness_image.get_pixel(68,22).a > .05:
		_fail("authored Centaur woodland harness must keep both articulated arm apertures transparent")
	var woodland_harness_back_image := GearVisual.STORYBOOK_WOODLAND_HARNESS_BACK.get_image()
	if woodland_harness_back_image.get_pixel(0,0).a > .02 or woodland_harness_back_image.get_pixel(10,26).a > .05 or woodland_harness_back_image.get_pixel(68,22).a > .05:
		_fail("authored rear Centaur woodland harness must preserve its transparent field and arm apertures")
	if GearVisual.STORYBOOK_TROLL_JERKIN.get_size() != Vector2(82,76) or GearVisual.STORYBOOK_TROLL_JERKIN_BACK.get_size() != Vector2(82,76):
		_fail("authored Frost Troll jerkin views must share the torso socket dimensions")
	var troll_jerkin_image := GearVisual.STORYBOOK_TROLL_JERKIN.get_image()
	if troll_jerkin_image.get_pixel(0,0).a > .02 or troll_jerkin_image.get_pixel(41,12).a > .05:
		_fail("authored Frost Troll jerkin must keep its outer field and neck aperture transparent")
	if troll_jerkin_image.get_pixel(10,25).a > .05 or troll_jerkin_image.get_pixel(70,28).a > .05:
		_fail("authored Frost Troll jerkin must keep both articulated arm apertures transparent")
	var troll_jerkin_back_image := GearVisual.STORYBOOK_TROLL_JERKIN_BACK.get_image()
	if troll_jerkin_back_image.get_pixel(0,0).a > .02 or troll_jerkin_back_image.get_pixel(10,25).a > .05 or troll_jerkin_back_image.get_pixel(72,28).a > .05:
		_fail("authored rear Frost Troll jerkin must preserve its transparent field and arm apertures")
	if GearVisual.STORYBOOK_FUR_COAT.get_size() != Vector2(82,76) or GearVisual.STORYBOOK_FUR_COAT_BACK.get_size() != Vector2(82,76):
		_fail("authored Frostling fur coat views must share the torso socket dimensions")
	var fur_coat_image := GearVisual.STORYBOOK_FUR_COAT.get_image()
	if fur_coat_image.get_pixel(0,0).a > .02 or fur_coat_image.get_pixel(41,15).a > .05:
		_fail("authored Frostling fur coat must keep its outer field and neck aperture transparent")
	if fur_coat_image.get_pixel(12,28).a > .05 or fur_coat_image.get_pixel(68,28).a > .05:
		_fail("authored Frostling fur coat must keep both articulated arm apertures transparent")
	var fur_coat_back_image := GearVisual.STORYBOOK_FUR_COAT_BACK.get_image()
	if fur_coat_back_image.get_pixel(0,0).a > .02 or fur_coat_back_image.get_pixel(10,26).a > .05 or fur_coat_back_image.get_pixel(72,26).a > .05:
		_fail("authored rear Frostling fur coat must preserve its transparent field and arm apertures")
	if GearVisual.STORYBOOK_FAE_TUNIC.get_size() != Vector2(82,76) or GearVisual.STORYBOOK_FAE_TUNIC_BACK.get_size() != Vector2(82,76):
		_fail("authored Fae tunic views must share the torso socket dimensions")
	var fae_tunic_image := GearVisual.STORYBOOK_FAE_TUNIC.get_image()
	if fae_tunic_image.get_pixel(0,0).a > .02 or fae_tunic_image.get_pixel(41,7).a > .02:
		_fail("authored Fae tunic must keep its outer field and neck aperture transparent")
	if fae_tunic_image.get_pixel(10,22).a > .05 or fae_tunic_image.get_pixel(72,22).a > .05:
		_fail("authored Fae tunic must keep both articulated arm apertures transparent")
	var fae_tunic_back_image := GearVisual.STORYBOOK_FAE_TUNIC_BACK.get_image()
	if fae_tunic_back_image.get_pixel(0,0).a > .02 or fae_tunic_back_image.get_pixel(10,22).a > .05 or fae_tunic_back_image.get_pixel(72,22).a > .05:
		_fail("authored rear Fae tunic must preserve its transparent field and arm apertures")
	if GearVisual.STORYBOOK_LAMELLAR_ARMOR.get_size() != Vector2(82,76):
		_fail("authored lamellar armor must preserve the torso socket dimensions")
	if GearVisual.STORYBOOK_LAMELLAR_ARMOR_BACK.get_size() != Vector2(82,76):
		_fail("authored rear lamellar armor must share the front torso socket dimensions")
	var lamellar_image := GearVisual.STORYBOOK_LAMELLAR_ARMOR.get_image()
	if lamellar_image.get_pixel(0,0).a > .02 or lamellar_image.get_pixel(41,5).a > .02:
		_fail("authored lamellar armor must keep its outer field and neck aperture transparent")
	if lamellar_image.get_pixel(8,25).a > .05 or lamellar_image.get_pixel(74,25).a > .05:
		_fail("authored lamellar armor must keep both articulated arm apertures transparent")
	var lamellar_back_image := GearVisual.STORYBOOK_LAMELLAR_ARMOR_BACK.get_image()
	if lamellar_back_image.get_pixel(0,0).a > .02 or lamellar_back_image.get_pixel(41,5).a > .02:
		_fail("authored rear lamellar armor must keep its outer field and neck aperture transparent")
	if lamellar_back_image.get_pixel(12,25).a > .05 or lamellar_back_image.get_pixel(72,25).a > .05:
		_fail("authored rear lamellar armor must keep both articulated arm apertures transparent")
	if GearVisual.STORYBOOK_PLATE_ARMOR.get_size() != Vector2(82,76) or GearVisual.STORYBOOK_PLATE_ARMOR_BACK.get_size() != Vector2(82,76):
		_fail("authored plate armor views must share the torso socket dimensions")
	var plate_armor_back_image := GearVisual.STORYBOOK_PLATE_ARMOR_BACK.get_image()
	if plate_armor_back_image.get_pixel(0,0).a > .02 or plate_armor_back_image.get_pixel(41,5).a > .05:
		_fail("authored rear plate armor must preserve its transparent field and neck aperture")
	if plate_armor_back_image.get_pixel(10,26).a > .05 or plate_armor_back_image.get_pixel(72,26).a > .05:
		_fail("authored rear plate armor must keep both articulated arm apertures transparent")
	if GearVisual.STORYBOOK_LANTERN.get_size() != Vector2(32,50):
		_fail("authored lantern must preserve its compact hand-socket dimensions")
	if GearVisual.STORYBOOK_SPELLBOOK.get_size() != Vector2(50,33):
		_fail("authored spellbook must preserve its supporting-palm dimensions")
	if GearVisual.STORYBOOK_HOOD.get_size() != Vector2(74,76) or GearVisual.STORYBOOK_HOOD_BACK.get_size() != Vector2(74,76):
		_fail("authored hood views must share the head socket dimensions")
	if GearVisual.STORYBOOK_HELM.get_size() != Vector2(74,75) or GearVisual.STORYBOOK_HELM_BACK.get_size() != Vector2(74,75):
		_fail("authored helm views must share the head socket dimensions")
	if GearVisual.STORYBOOK_CROWN.get_size() != Vector2(60,39):
		_fail("authored crown must preserve its compact head socket dimensions")
	if GearVisual.STORYBOOK_CAPE.get_size() != Vector2(88,100):
		_fail("authored cape must preserve its upper-back socket dimensions")
	if GearVisual.STORYBOOK_LONG_CAPE.get_size() != Vector2(160,146):
		_fail("authored long cape must preserve its wind-swept knee-length socket dimensions")
	var long_cape_image := GearVisual.STORYBOOK_LONG_CAPE.get_image()
	if long_cape_image.get_pixel(0,0).a > .02 or long_cape_image.get_pixel(159,145).a > .02:
		_fail("authored long cape must preserve a genuinely transparent outer field")
	if not GearVisual.STORYBOOK_LONG_CAPE.resource_path.ends_with("long_cape_storybook_v3.png") or long_cape_image.get_pixel(25,100).a < .9 or long_cape_image.get_pixel(135,100).a > .05:
		_fail("Human long cape must retain its clasp-anchored screen-left travel sweep")
	if GearVisual.STORYBOOK_PACK.get_size() != Vector2(70,79):
		_fail("authored pack must preserve its compact rear silhouette")
	if GearVisual.STORYBOOK_QUIVER.get_size() != Vector2(62,100):
		_fail("authored quiver must preserve its diagonal rear silhouette")
	if GearVisual.STORYBOOK_SCARF.get_size() != Vector2(66,58) or GearVisual.STORYBOOK_SCARF_BACK.get_size() != Vector2(66,58):
		_fail("authored scarf views must share the neck socket dimensions")
	if GearVisual.STORYBOOK_AMULET.get_size() != Vector2(48,38):
		_fail("authored amulet must preserve its upper-chest socket dimensions")
	if GearVisual.STORYBOOK_GOGGLES.get_size() != Vector2(56,18) or GearVisual.STORYBOOK_GOGGLES_BACK.get_size() != Vector2(56,10):
		_fail("authored goggles must preserve their front lens and rear strap dimensions")
	for waist_texture in [GearVisual.STORYBOOK_CLOTH_PANTS_WAIST, GearVisual.STORYBOOK_LEATHER_PANTS_WAIST, GearVisual.STORYBOOK_PLATE_PANTS_WAIST]:
		if waist_texture.get_size() != Vector2(56,26):
			_fail("authored pants waist pieces must share the hip socket dimensions")
	for thigh_texture in [GearVisual.STORYBOOK_CLOTH_PANTS_THIGH, GearVisual.STORYBOOK_LEATHER_PANTS_THIGH, GearVisual.STORYBOOK_PLATE_PANTS_THIGH]:
		if thigh_texture.get_size() != Vector2(24,40):
			_fail("authored pants thigh pieces must share the articulated bone dimensions")
	for shin_texture in [GearVisual.STORYBOOK_CLOTH_PANTS_SHIN, GearVisual.STORYBOOK_LEATHER_PANTS_SHIN, GearVisual.STORYBOOK_PLATE_PANTS_SHIN]:
		if shin_texture.get_size() != Vector2(20,36):
			_fail("authored pants shin pieces must share the articulated bone dimensions")
	for boot_texture in [GearVisual.STORYBOOK_WRAPS_BOOT, GearVisual.STORYBOOK_LEATHER_BOOT, GearVisual.STORYBOOK_PLATE_BOOT]:
		if boot_texture.get_size() != Vector2(40,42):
			_fail("authored footwear must share the paired ankle socket dimensions")
	var keyed_visual := GearVisual.new().setup("armor","cloth",Color("e05b52"))
	if not keyed_visual.material is ShaderMaterial or keyed_visual.material.get_shader_parameter("use_magenta_key") or not keyed_visual.material.get_shader_parameter("use_accent_dye"):
		_fail("true-alpha cloth armor must use accent dye without the rejected chroma key")
	if keyed_visual.material.get_shader_parameter("dye_color") != Color("e05b52"):
		_fail("dyeable cloth must receive its lineage accent color")
	keyed_visual.setup("armor","plate",Color.WHITE)
	if not keyed_visual.material is ShaderMaterial or not keyed_visual.material.get_shader_parameter("use_magenta_key") or keyed_visual.material.get_shader_parameter("use_accent_dye"):
		_fail("authored plate armor must key its generated magenta source field")
	if "magenta_dominance" not in keyed_visual.material.shader.code or "despill" not in keyed_visual.material.shader.code:
		_fail("keyed equipment must suppress antialiased magenta color spill")
	keyed_visual.setup("armor","leather",Color.WHITE)
	if keyed_visual.material != null:
		_fail("armor chroma key must not leak onto equipment with genuine alpha")
	keyed_visual.setup("accessory","goggles",Color.WHITE)
	if not keyed_visual.material is ShaderMaterial:
		_fail("authored goggles must key their generated magenta production field")
	keyed_visual.setup("accessory","scarf",Color.WHITE)
	if not keyed_visual.material is ShaderMaterial or keyed_visual.material.get_shader_parameter("use_magenta_key") or not keyed_visual.material.get_shader_parameter("use_accent_dye"):
		_fail("goggle chroma key must clear while the genuine-alpha scarf keeps lineage dye")
	for dyeable_piece in [["head","hood"],["back","cape"],["back","long_cape"]]:
		keyed_visual.setup(dyeable_piece[0],dyeable_piece[1],Color("f2a65a"))
		if not keyed_visual.material is ShaderMaterial or not keyed_visual.material.get_shader_parameter("use_accent_dye") or keyed_visual.material.get_shader_parameter("use_magenta_key"):
			_fail("%s must inherit lineage dye without chroma keying" % dyeable_piece[1])
	for pants_item in ["cloth","ranger","baggy","leather","plate"]:
		keyed_visual.setup("pants",pants_item,Color.WHITE)
		if not keyed_visual.material is ShaderMaterial:
			_fail("authored %s pants must key their modular production sheet field" % pants_item)
		if keyed_visual.material.get_shader_parameter("use_accent_dye") != (pants_item in ["cloth","ranger","baggy"]):
			_fail("only cloth-family pants may recolor their blue textile panels")
		if pants_item == "ranger" and keyed_visual.material.get_shader_parameter("dye_color") != GearVisual.RANGER_PANTS_DYE:
			_fail("Human-reference ranger pants must use their fixed olive dye")
		if pants_item == "baggy" and keyed_visual.material.get_shader_parameter("dye_color") != GearVisual.BAGGY_PANTS_DYE:
			_fail("baggy Fae-reference pants must use their fixed charcoal dye")
	if GearVisual.BAGGY_PANTS_WIDTHS != {"thigh":30.0,"shin":16.0}:
		_fail("baggy pants must widen above and taper below the articulated knee")
	keyed_visual.setup("pants","none",Color.WHITE)
	if keyed_visual.material != null:
		_fail("pants chroma key must clear when the equipment slot is empty")
	for fixed_material_piece in [["armor","marsh_tunic"],["armor","leather"],["armor","woodland_harness"],["armor","troll_jerkin"],["armor","fur_coat"],["armor","fae_tunic"],["armor","lamellar"],["armor","plate"],["head","helm"],["back","pack"],["accessory","amulet"]]:
		keyed_visual.setup(fixed_material_piece[0],fixed_material_piece[1],Color("e05b52"))
		if fixed_material_piece[1] == "plate":
			if not keyed_visual.material is ShaderMaterial or keyed_visual.material.get_shader_parameter("use_accent_dye"):
				_fail("plate armor must key transparency without tinting its metal")
		elif keyed_visual.material != null:
			_fail("lineage dye leaked onto fixed %s materials" % fixed_material_piece[1])
	keyed_visual.free()
	var avatar := Avatar.new()
	root.add_child(avatar)
	avatar.configure("human",{"weapon":"none","offhand":"lantern"})
	if not is_zero_approx(avatar._gear.offhand.global_rotation):
		_fail("lantern must establish an upright world hang from its offhand loop")
	avatar.play_motion(&"run")
	avatar._active_tween.custom_step(Avatar.RUN_FRAME_DURATION*3.0)
	var inherited_lantern_tilt := absf(avatar._gear.offhand.global_rotation)
	avatar._process(.25)
	if inherited_lantern_tilt < deg_to_rad(4.0) or absf(avatar._gear.offhand.global_rotation) > deg_to_rad(2.0):
		_fail("lantern must damp the run arm's inherited rotation back toward a gravity hang (before %.1f, after %.1f)" % [rad_to_deg(inherited_lantern_tilt),rad_to_deg(absf(avatar._gear.offhand.global_rotation))])
	avatar.configure("bogkin", {
		"weapon": "sword",
		"offhand": "shield",
	})
	await process_frame
	var profile := CharacterCatalog.race("bogkin")
	var left_boot: GearVisual = avatar.get_node("Rig/Hip/left_leg/left_shin/LeftBoot")
	var right_boot: GearVisual = avatar.get_node("Rig/Hip/right_leg/right_shin/RightBoot")
	if not left_boot.visible or not right_boot.visible or avatar._left_foot_base.visible or avatar._right_foot_base.visible:
		_fail("equipped footwear must cover both authored bare-foot sprites")
	avatar.equip(&"boots","none")
	if left_boot.visible or right_boot.visible or not avatar._left_foot_base.visible or not avatar._right_foot_base.visible:
		_fail("empty footwear must restore both authored bare-foot sprites")
	avatar.equip(&"boots","plate")
	if left_boot.item != "plate" or right_boot.item != "plate" or avatar._left_foot_base.visible or avatar._right_foot_base.visible:
		_fail("footwear swaps must update both articulated ankle attachments")

	var right_arm: Node2D = avatar.get_node("Rig/Hip/torso/right_arm")
	var right_forearm: Node2D = right_arm.get_node("right_forearm")
	var left_arm: Node2D = avatar.get_node("Rig/Hip/torso/left_arm")
	var left_forearm: Node2D = left_arm.get_node("left_forearm")
	var torso: Node2D = avatar.get_node("Rig/Hip/torso")
	var weapon: GearVisual = right_forearm.get_node("Weapon")
	var shield: GearVisual = left_forearm.get_node("Offhand")
	if not shield.shield_exterior:
		_fail("right-facing wielded shield must present the decorated reference face")
	var hand_position := weapon.global_position
	var sword_tip := weapon.to_global(weapon.reach_endpoint())
	var shoulder_position := right_arm.global_position
	var rest_weapon_vector := sword_tip - hand_position
	var forearm_vector := hand_position-right_forearm.global_position

	if right_arm.global_position.x >= torso.global_position.x:
		_fail("right-facing anatomical right shoulder must be drawn on screen-left")
	if left_arm.global_position.x <= torso.global_position.x:
		_fail("right-facing anatomical left shoulder must be drawn on screen-right")
	avatar.set_facing(&"left")
	right_arm.force_update_transform(); left_arm.force_update_transform(); torso.force_update_transform()
	if not shield.shield_exterior:
		_fail("left-facing wielded shield must present its authored exterior")
	if right_arm.global_position.x <= torso.global_position.x:
		_fail("left-facing anatomical right shoulder must be drawn on screen-right")
	if left_arm.global_position.x >= torso.global_position.x:
		_fail("left-facing anatomical left shoulder must be drawn on screen-left")
	avatar.set_facing(&"right")
	avatar.play_motion(&"climb")
	if not shield.carried_on_back or not shield.shield_exterior:
		_fail("climbing must carry the shield on the back with its exterior visible")
	avatar.stop_motion()
	if shield.carried_on_back or not shield.shield_exterior:
		_fail("leaving a climb must restore the wielded exterior shield view")
	right_arm.force_update_transform(); right_forearm.force_update_transform()
	left_arm.force_update_transform(); torso.force_update_transform()

	if right_forearm.global_position.x >= right_arm.global_position.x:
		_fail("idle weapon elbow must project outward from the anatomical right shoulder")

	if sword_tip.x <= avatar.global_position.x:
		_fail("resting weapon must extend toward screen-right")
	if shield.global_position.x <= avatar.global_position.x:
		_fail("cross-body shield must render on the same screen-right side as the weapon")
	var shield_center := shield.to_global(Vector2(0,-20))
	var offhand_socket := left_forearm.to_global(Vector2(0,float(profile.arm)*.48))
	if shield_center.distance_to(offhand_socket) > .5:
		_fail("idle shield grip must sit at the center of the shield")
	var torso_part: PartVisual = torso.get_child(0)
	var minimum_idle_shield_y: float = torso_part.to_global(Vector2(0,float(profile.torso.y)*.38)).y
	if shield_center.y < minimum_idle_shield_y:
		_fail("idle shield guard must sit lower on the torso")
	var maximum_shield_offset: float = profile.torso.x * profile.scale
	if absf(shield_center.x - torso.global_position.x) > maximum_shield_offset:
		_fail("shield face must overlap the torso silhouette instead of floating away from the body")
	if shield.z_index >= 0:
		_fail("shield must remain behind the far-side forearm and torso")
	if shoulder_position.distance_to(sword_tip) <= shoulder_position.distance_to(hand_position):
		_fail("sword tip must extend beyond the hand from the shoulder pivot")
	var rest_weapon_angle := rad_to_deg(rest_weapon_vector.angle())
	if absf(rest_weapon_angle) > 1.0 or rest_weapon_vector.x <= 0:
		_fail("resting sword must be horizontal and point toward screen-right")
	if absf(forearm_vector.normalized().dot(rest_weapon_vector.normalized())) > .02:
		_fail("resting sword must be perpendicular to the forearm at the grip")
	var interior_elbow_angle := 180.0 - absf(right_forearm.rotation_degrees)
	if absf(right_arm.rotation_degrees - 15.0) > 1.0:
		_fail("resting upper weapon arm must hang almost vertically")
	if absf(interior_elbow_angle - 165.0) > 1.0:
		_fail("resting elbow must retain a slight outward bend")
	for weapon_id in ["axe","spear","staff","branch_staff"]:
		avatar.equip(&"weapon",weapon_id)
		weapon.force_update_transform()
		var weapon_axis := weapon.to_global(Vector2(0,80))-weapon.global_position
		var alignment := absf(forearm_vector.normalized().dot(weapon_axis.normalized()))
		if weapon_id == "axe" and (absf(weapon_axis.y) > 1.0 or alignment > .02):
			_fail("resting axe must be horizontal and perpendicular to the forearm")
		if weapon_id in ["spear","staff","branch_staff"] and (absf(weapon_axis.x) > 1.0 or alignment < .98):
			_fail("resting %s must be vertical" % weapon_id)
		if weapon_id in ["spear","staff","branch_staff"]:
			var pole_butt := weapon.to_global(GearVisual.POLE_BUTT)
			var left_knee_y: float = avatar._bones.left_shin.global_position.y
			var right_knee_y: float = avatar._bones.right_shin.global_position.y
			if pole_butt.y <= maxf(left_knee_y,right_knee_y):
				_fail("resting %s shaft must extend below both knees" % weapon_id)
	avatar.equip(&"weapon","bow")
	weapon.force_update_transform()
	if weapon.get_parent() != left_forearm:
		_fail("bow must be wielded by the anatomical left hand")
	var bow_effective_z: int = weapon.z_index+left_forearm.z_index+left_arm.z_index
	var armor_effective_z: int = avatar._gear.armor.z_index+torso.z_index
	if bow_effective_z <= armor_effective_z:
		_fail("wielded bow must render in front of the character armor")
	var bow_hand_effective_z: int = avatar._left_hand_base.z_index+left_forearm.z_index+left_arm.z_index
	if bow_hand_effective_z <= bow_effective_z:
		_fail("bow gripping hand must remain visible in front of the bow")
	var bow_top := weapon.to_global(GearVisual.BOW_TOP)
	var bow_bottom := weapon.to_global(GearVisual.BOW_BOTTOM)
	var right_string_center := (bow_top+bow_bottom)*.5
	# Validate the authored bow geometry in character-local units. A fixed world
	# pixel threshold falsely rejects compact lineages even though their complete
	# rig, weapon, socket, and string are scaled together without changing grip.
	var bow_rig_scale := absf(avatar._bones.rig.scale.x)
	if right_string_center.distance_to(weapon.global_position)/bow_rig_scale < 30.0:
		_fail("bow hand must grip the wooden curve rather than the string midpoint")
	if right_string_center.x >= weapon.global_position.x:
		_fail("right-facing bowstring must sit behind the wooden grip toward the archer")
	avatar.set_facing(&"left")
	weapon.force_update_transform()
	var left_string_center := (weapon.to_global(GearVisual.BOW_TOP)+weapon.to_global(GearVisual.BOW_BOTTOM))*.5
	if left_string_center.x <= weapon.global_position.x:
		_fail("left-facing bowstring must mirror behind the wooden grip toward the archer")
	avatar.set_facing(&"right")
	avatar.equip(&"weapon","sword")
	avatar.equip(&"offhand","shield")
	avatar.equip(&"weapon","bow")
	if avatar.loadout.offhand != "none" or shield.visible:
		_fail("equipping a bow must remove an equipped shield")
	if avatar.equip(&"offhand","shield"):
		_fail("shield must be rejected while a bow is equipped")
	avatar.equip(&"weapon","sword")

	# Sample the same windup/strike angles used by the sword attack. A properly
	# gripped weapon tip must describe a larger arc than the hand carrying it.
	var forehand: Array = Avatar.ATTACK_CURVES.forehand
	right_arm.rotation_degrees = forehand[0].upper
	right_forearm.rotation_degrees = forehand[0].forearm
	weapon.force_update_transform()
	var windup_hand := weapon.global_position
	var windup_tip := weapon.to_global(weapon.reach_endpoint())
	var head: Node2D = avatar.get_node("Rig/Hip/torso/head")
	var face_left_x: float = head.global_position.x - profile.head.x * 0.5 * profile.scale
	if windup_tip.x >= face_left_x:
		_fail("forehand reach-back must carry the weapon beyond the screen-left side of the face")
	var hand_path := 0.0
	var tip_path := 0.0
	var previous_hand := windup_hand
	var previous_tip := windup_tip
	for pose in forehand.slice(1):
		right_arm.rotation_degrees = pose.upper
		right_forearm.rotation_degrees = pose.forearm
		weapon.force_update_transform()
		var next_hand := weapon.global_position
		var next_tip := weapon.to_global(weapon.reach_endpoint())
		hand_path += previous_hand.distance_to(next_hand)
		tip_path += previous_tip.distance_to(next_tip)
		previous_hand = next_hand
		previous_tip = next_tip
	if tip_path <= hand_path * 1.35:
		_fail("sword tip must sweep a substantially wider full slash arc than the hand")

	var troll := Avatar.new()
	root.add_child(troll)
	troll.configure("frost_troll",{"weapon":"axe","offhand":"shield"})
	await process_frame
	if troll.loadout.offhand != "none" or troll.supports_equipment_slot(&"offhand"):
		_fail("Frost Troll's two-handed axe must occupy the offhand slot")
	var troll_axe: GearVisual = troll._gear.weapon
	if not troll_axe.two_handed:
		_fail("Frost Troll axe did not switch to its long double-headed presentation")
	if troll_axe.reach_endpoint().length() < 165.0:
		_fail("Frost Troll's two-handed axe must retain its oversized great-axe silhouette")
	if troll._left_hand_base.part_id != "hand_grip_back" or troll._right_hand_base.part_id != "hand_grip_back":
		_fail("Both Frost Troll axe hands must show the back-of-fist gripping sprite")
	troll.call("_update_two_handed_axe_grip")
	_assert_weapon_elbow_outward(troll,&"right")
	_assert_two_handed_elbow(troll,"idle")
	var second_hand_socket: Vector2 = troll._bones.left_forearm.to_global(Vector2(0,float(troll._profile.arm)*.48))
	var second_grip: Vector2 = troll_axe.to_global(GearVisual.TWO_HANDED_AXE_SECOND_GRIP)
	if second_hand_socket.distance_to(second_grip) > 1.0:
		_fail("Frost Troll's second hand does not meet the axe shaft at idle")
	troll.set_facing(&"left")
	troll.call("_update_two_handed_axe_grip")
	_assert_weapon_elbow_outward(troll,&"left")
	troll.set_facing(&"right")
	troll.call("_update_two_handed_axe_grip")
	troll.play_motion(&"run")
	troll._active_tween.custom_step(.18)
	troll.call("_update_two_handed_axe_grip")
	_assert_two_handed_elbow(troll,"run")
	second_hand_socket = troll._bones.left_forearm.to_global(Vector2(0,float(troll._profile.arm)*.48))
	second_grip = troll_axe.to_global(GearVisual.TWO_HANDED_AXE_SECOND_GRIP)
	if second_hand_socket.distance_to(second_grip) > 1.0:
		_fail("Frost Troll's second hand detached from the axe while running")
	troll.stop_motion()
	troll.play_weapon_attack(&"forehand")
	troll._active_tween.custom_step(.27)
	troll.call("_update_two_handed_axe_grip")
	_assert_two_handed_elbow(troll,"forehand")
	second_hand_socket = troll._bones.left_forearm.to_global(Vector2(0,float(troll._profile.arm)*.48))
	second_grip = troll_axe.to_global(GearVisual.TWO_HANDED_AXE_SECOND_GRIP)
	if second_hand_socket.distance_to(second_grip) > 1.0:
		_fail("Frost Troll's second hand detached during an axe attack")
	troll._active_tween.custom_step(.24)
	troll.call("_update_two_handed_axe_grip")
	_assert_two_handed_elbow(troll,"forehand follow-through")
	second_hand_socket = troll._bones.left_forearm.to_global(Vector2(0,float(troll._profile.arm)*.48))
	second_grip = troll_axe.to_global(GearVisual.TWO_HANDED_AXE_SECOND_GRIP)
	if second_hand_socket.distance_to(second_grip) > 1.0:
		_fail("Frost Troll's second hand detached during the smoothed forehand follow-through")
	troll.play_weapon_attack(&"backhand")
	troll._active_tween.custom_step(.31)
	troll.call("_update_two_handed_axe_grip")
	_assert_two_handed_elbow(troll,"backhand guard")
	second_hand_socket = troll._bones.left_forearm.to_global(Vector2(0,float(troll._profile.arm)*.48))
	second_grip = troll_axe.to_global(GearVisual.TWO_HANDED_AXE_SECOND_GRIP)
	if second_hand_socket.distance_to(second_grip) > 1.0:
		_fail("Frost Troll's second hand detached during the backhand guard")
	troll._active_tween.custom_step(.13)
	troll.call("_update_two_handed_axe_grip")
	_assert_two_handed_elbow(troll,"backhand contact")
	second_hand_socket = troll._bones.left_forearm.to_global(Vector2(0,float(troll._profile.arm)*.48))
	second_grip = troll_axe.to_global(GearVisual.TWO_HANDED_AXE_SECOND_GRIP)
	if second_hand_socket.distance_to(second_grip) > 1.0:
		_fail("Frost Troll's second hand detached during backhand contact")

	var centaur := Avatar.new()
	root.add_child(centaur)
	centaur.configure("centaur",{"boots":"leather"})
	await process_frame
	if centaur.supports_equipment_slot(&"boots") or centaur.equip(&"boots","wraps"):
		_fail("Centaur must reject biped footwear")
	var hidden_boots: GearVisual = centaur.get_node("Rig/Hip/Boots")
	if hidden_boots.visible:
		_fail("Centaur footwear slot node must remain hidden behind its four hooves")
	for hoof_index in 4:
		if not centaur.get_node("Rig/Hip/horse_leg_%d/horse_shin_%d/HoofSprite%d" % [hoof_index,hoof_index,hoof_index]).visible:
			_fail("Centaur footwear exclusion must preserve hoof %d" % hoof_index)

	# Entering and leaving the two-handed crossbow posture rebuilds the rig's
	# captured rest pose, so inspect fresh sockets after the equipment change.
	var crossbow_avatar := Avatar.new()
	root.add_child(crossbow_avatar)
	crossbow_avatar.configure("goblin",{"weapon":"sword","offhand":"shield"})
	if not crossbow_avatar.equip(&"weapon","crossbow"):
		_fail("Goblin must be able to equip the modular crossbow")
	var crossbow: GearVisual = crossbow_avatar._gear.weapon
	var crossbow_right_forearm: Node2D = crossbow_avatar._bones.right_forearm
	var crossbow_left_forearm: Node2D = crossbow_avatar._bones.left_forearm
	crossbow.force_update_transform()
	crossbow_avatar.call("_update_crossbow_support_grip")
	if crossbow.get_parent() != crossbow_right_forearm:
		_fail("crossbow must keep its trigger grip in the primary hand")
	var crossbow_support_socket := crossbow_left_forearm.to_global(Vector2(0,float(crossbow_avatar._profile.arm)*.48))
	var crossbow_support_grip := crossbow.to_global(GearVisual.CROSSBOW_SECOND_GRIP)
	if crossbow_support_socket.distance_to(crossbow_support_grip) > 1.0:
		_fail("crossbow support hand must meet the forward stock grip")
	if crossbow_avatar.loadout.offhand != "none" or crossbow_avatar.equip(&"offhand","shield"):
		_fail("two-handed crossbow must clear and disable the offhand slot")
	if not crossbow_avatar.equip(&"weapon","sword") or not crossbow_avatar.equip(&"offhand","shield"):
		_fail("leaving the crossbow posture must restore ordinary offhand equipment")

	if failed:
		quit(1)
		return
	print("PASS: equipment sockets, handedness, and outward weapon reach")
	quit()


func _fail(message: String) -> void:
	failed = true
	printerr("FAIL: ", message)


func _assert_two_handed_elbow(troll: ModularCharacter, phase: String) -> void:
	var bend: float = troll._bones.left_forearm.rotation_degrees
	if bend >= -10.0:
		_fail("Frost Troll support elbow must use the outward bend branch during %s (was %.1f degrees)" % [phase,bend])
	if bend < -165.0:
		_fail("Frost Troll support elbow must not overfold during %s (was %.1f degrees)" % [phase,bend])


func _assert_weapon_elbow_outward(troll: ModularCharacter, direction: StringName) -> void:
	var shoulder_x: float = troll._bones.right_arm.global_position.x
	var elbow_x: float = troll._bones.right_forearm.global_position.x
	var points_outward := elbow_x < shoulder_x if direction == &"right" else elbow_x > shoulder_x
	if not points_outward:
		_fail("Frost Troll anatomical-right elbow must project outward while facing %s (shoulder %.1f, elbow %.1f)" % [direction,shoulder_x,elbow_x])
