class_name GearVisual
extends Node2D

var slot := "weapon"
var item := "none"
var accent := Color("d7a54f")
var carried_on_back := false
var shield_exterior := false
var pants_piece := "full"
var pants_length := 30.0
var bow_draw := 0.0
var crossbow_loaded := true
var two_handed := false
var back_view := false

const REACH_ENDPOINTS := {
	"sword": Vector2(0, 88),
	"axe": Vector2(30, 92),
	"bow": Vector2(0, 40),
	"crossbow": Vector2(0, 88),
	"spear": Vector2(0, 126),
	"staff": Vector2(0, 126),
	"branch_staff": Vector2(0, 126),
}

const INK := Color("352b25")
const RANGER_PANTS_DYE := Color("4b5d3e")
const BAGGY_PANTS_DYE := Color("3b4650")
const BAGGY_PANTS_WIDTHS := {"thigh":30.0, "shin":16.0}
const POLE_BUTT := Vector2(0,-72)
const SHIELD_CENTER := Vector2(0,-20)
const BOW_TOP := Vector2(-40,-40)
const BOW_BOTTOM := Vector2(-40,40)
const CROSSBOW_SECOND_GRIP := Vector2(0,34)
const TWO_HANDED_AXE_SECOND_GRIP := Vector2(0,90)
const LANTERN_DRAW_OFFSET := Vector2(-16,-4)
const LANTERN_DISPLAY_SCALE := 1.35
const QUIVER_DRAW_OFFSET := Vector2(-5,-40)
const STORYBOOK_SWORD := preload("res://assets/equipment/sword_storybook.png")
const STORYBOOK_SHIELD_EXTERIOR := preload("res://assets/equipment/shield_exterior_storybook.png")
const STORYBOOK_SHIELD_INTERIOR := preload("res://assets/equipment/shield_interior_storybook.png")
const STORYBOOK_MARSH_SHIELD_EXTERIOR := preload("res://assets/equipment/marsh_shield_exterior_storybook.png")
const STORYBOOK_DUNE_SHIELD_EXTERIOR := preload("res://assets/equipment/dune_shield_exterior_storybook.png")
const STORYBOOK_STAFF := preload("res://assets/equipment/staff_storybook.png")
const STORYBOOK_BRANCH_STAFF := preload("res://assets/equipment/branch_staff_storybook_v1.png")
const STORYBOOK_BOW := preload("res://assets/equipment/bow_storybook.png")
const STORYBOOK_ARROW := preload("res://assets/equipment/arrow_projectile_storybook.png")
const STORYBOOK_CROSSBOW := preload("res://assets/equipment/crossbow_storybook_v1.png")
const STORYBOOK_CROSSBOW_BOLT := preload("res://assets/equipment/crossbow_bolt_storybook.png")
const STORYBOOK_AXE := preload("res://assets/equipment/axe_storybook.png")
const STORYBOOK_TROLL_GREAT_AXE := preload("res://assets/equipment/troll_great_axe_storybook.png")
const STORYBOOK_SPEAR := preload("res://assets/equipment/spear_storybook.png")
const STORYBOOK_LEATHER_ARMOR := preload("res://assets/equipment/leather_armor_storybook.png")
const STORYBOOK_LEATHER_ARMOR_BACK := preload("res://assets/equipment/leather_armor_storybook_back.png")
const STORYBOOK_CLOTH_ARMOR := preload("res://assets/equipment/cloth_armor_storybook_v3.png")
const STORYBOOK_CLOTH_ARMOR_BACK := preload("res://assets/equipment/cloth_armor_storybook_back.png")
const STORYBOOK_MARSH_TUNIC := preload("res://assets/equipment/marsh_tunic_storybook.png")
const STORYBOOK_MARSH_TUNIC_BACK := preload("res://assets/equipment/marsh_tunic_storybook_back.png")
const STORYBOOK_WOODLAND_HARNESS := preload("res://assets/equipment/woodland_harness_storybook.png")
const STORYBOOK_WOODLAND_HARNESS_BACK := preload("res://assets/equipment/woodland_harness_storybook_back.png")
const STORYBOOK_TROLL_JERKIN := preload("res://assets/equipment/troll_jerkin_storybook.png")
const STORYBOOK_TROLL_JERKIN_BACK := preload("res://assets/equipment/troll_jerkin_storybook_back.png")
const STORYBOOK_FUR_COAT := preload("res://assets/equipment/fur_coat_storybook.png")
const STORYBOOK_FUR_COAT_BACK := preload("res://assets/equipment/fur_coat_storybook_back.png")
const STORYBOOK_FAE_TUNIC := preload("res://assets/equipment/fae_tunic_storybook.png")
const STORYBOOK_FAE_TUNIC_BACK := preload("res://assets/equipment/fae_tunic_storybook_back.png")
const STORYBOOK_LAMELLAR_ARMOR := preload("res://assets/equipment/lamellar_armor_storybook.png")
const STORYBOOK_LAMELLAR_ARMOR_BACK := preload("res://assets/equipment/lamellar_armor_storybook_back.png")
const STORYBOOK_PLATE_ARMOR := preload("res://assets/equipment/plate_armor_storybook.png")
const STORYBOOK_PLATE_ARMOR_BACK := preload("res://assets/equipment/plate_armor_storybook_back.png")
const STORYBOOK_LANTERN := preload("res://assets/equipment/lantern_storybook.png")
const STORYBOOK_SPELLBOOK := preload("res://assets/equipment/spellbook_storybook.png")
const STORYBOOK_HOOD := preload("res://assets/equipment/hood_storybook.png")
const STORYBOOK_HOOD_BACK := preload("res://assets/equipment/hood_storybook_back.png")
const STORYBOOK_HELM := preload("res://assets/equipment/helm_storybook.png")
const STORYBOOK_HELM_BACK := preload("res://assets/equipment/helm_storybook_back.png")
const STORYBOOK_CROWN := preload("res://assets/equipment/crown_storybook.png")
const STORYBOOK_CAPE := preload("res://assets/equipment/cape_storybook.png")
const STORYBOOK_LONG_CAPE := preload("res://assets/equipment/long_cape_storybook_v3.png")
const STORYBOOK_PACK := preload("res://assets/equipment/pack_storybook.png")
const STORYBOOK_QUIVER := preload("res://assets/equipment/quiver_storybook.png")
const STORYBOOK_SCARF := preload("res://assets/equipment/scarf_storybook.png")
const STORYBOOK_SCARF_BACK := preload("res://assets/equipment/scarf_storybook_back.png")
const STORYBOOK_AMULET := preload("res://assets/equipment/amulet_storybook.png")
const STORYBOOK_GOGGLES := preload("res://assets/equipment/goggles_storybook.png")
const STORYBOOK_GOGGLES_BACK := preload("res://assets/equipment/goggles_storybook_back.png")
const STORYBOOK_CLOTH_PANTS_WAIST := preload("res://assets/equipment/cloth_pants_waist_storybook.png")
const STORYBOOK_CLOTH_PANTS_THIGH := preload("res://assets/equipment/cloth_pants_thigh_storybook.png")
const STORYBOOK_CLOTH_PANTS_SHIN := preload("res://assets/equipment/cloth_pants_shin_storybook.png")
const STORYBOOK_LEATHER_PANTS_WAIST := preload("res://assets/equipment/leather_pants_waist_storybook.png")
const STORYBOOK_LEATHER_PANTS_THIGH := preload("res://assets/equipment/leather_pants_thigh_storybook.png")
const STORYBOOK_LEATHER_PANTS_SHIN := preload("res://assets/equipment/leather_pants_shin_storybook.png")
const STORYBOOK_PLATE_PANTS_WAIST := preload("res://assets/equipment/plate_pants_waist_storybook.png")
const STORYBOOK_PLATE_PANTS_THIGH := preload("res://assets/equipment/plate_pants_thigh_storybook.png")
const STORYBOOK_PLATE_PANTS_SHIN := preload("res://assets/equipment/plate_pants_shin_storybook.png")
const STORYBOOK_WRAPS_BOOT := preload("res://assets/equipment/wraps_boot_storybook.png")
const STORYBOOK_LEATHER_BOOT := preload("res://assets/equipment/leather_boot_storybook.png")
const STORYBOOK_PLATE_BOOT := preload("res://assets/equipment/plate_boot_storybook.png")


func setup(p_slot: String, p_item: String, p_accent: Color) -> GearVisual:
	slot = p_slot
	item = p_item
	accent = p_accent
	bow_draw = 0.0
	crossbow_loaded = true
	two_handed = false
	visible = item != "none"
	var needs_magenta_key := (slot == "armor" and item == "plate") or (slot == "accessory" and item == "goggles") or (slot == "pants" and item in ["cloth","ranger","baggy","leather","plate"])
	# The concept sheets repeat one material language while shifting their cloth
	# accents per lineage. Recolor only the cool-blue textile families; leather,
	# metal, glass, wood, and painted highlights retain their authored palettes.
	var needs_accent_dye := (slot == "armor" and item == "cloth") or (slot == "pants" and item in ["cloth","ranger","baggy"]) or (slot == "head" and item == "hood") or (slot == "back" and item in ["cape","long_cape"]) or (slot == "accessory" and item == "scarf")
	var dye_color := accent
	if slot == "pants" and item == "ranger":
		dye_color = RANGER_PANTS_DYE
	elif slot == "pants" and item == "baggy":
		dye_color = BAGGY_PANTS_DYE
	material = _storybook_material(needs_magenta_key,needs_accent_dye,dye_color) if needs_magenta_key or needs_accent_dye else null
	queue_redraw()
	return self


func _storybook_material(use_magenta_key: bool,use_accent_dye: bool,dye_color: Color) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform bool use_magenta_key = false;
uniform bool use_accent_dye = false;
uniform vec4 dye_color : source_color = vec4(0.28,0.47,0.72,1.0);
void fragment() {
	vec4 sample = texture(TEXTURE,UV);
	if (use_magenta_key) {
		float magenta_dominance = max(min(sample.r,sample.b)-sample.g,0.0);
		float red_blue_balance = 1.0-abs(sample.r-sample.b);
		float key_strength = magenta_dominance*red_blue_balance;
		float coverage = 1.0-smoothstep(0.08,0.32,key_strength);
		sample.a *= coverage;
		float despill = smoothstep(0.025,0.28,key_strength)*0.94;
		sample.r = max(sample.r-magenta_dominance*despill,0.0);
		sample.b = max(sample.b-magenta_dominance*despill,0.0);
	}
	if (use_accent_dye) {
		float highest = max(sample.r,max(sample.g,sample.b));
		float lowest = min(sample.r,min(sample.g,sample.b));
		float saturation = highest-lowest;
		float blue_family = smoothstep(0.035,0.15,sample.b-sample.r)*smoothstep(0.025,0.13,sample.b-sample.g)*smoothstep(0.045,0.20,saturation);
		float luminance = dot(sample.rgb,vec3(0.2126,0.7152,0.0722));
		float dye_luminance = max(dot(dye_color.rgb,vec3(0.2126,0.7152,0.0722)),0.18);
		vec3 dyed = clamp(dye_color.rgb*(max(luminance,0.055)/dye_luminance),vec3(0.0),vec3(1.0));
		dyed = mix(vec3(luminance),dyed,0.90);
		sample.rgb = mix(sample.rgb,dyed,blue_family*0.92);
	}
	COLOR = sample;
}
"""
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader
	shader_material.set_shader_parameter("use_magenta_key",use_magenta_key)
	shader_material.set_shader_parameter("use_accent_dye",use_accent_dye)
	shader_material.set_shader_parameter("dye_color",dye_color)
	return shader_material


func reach_endpoint() -> Vector2:
	if item == "axe" and two_handed:
		return Vector2(58,156)
	return REACH_ENDPOINTS.get(item, Vector2.ZERO)


func set_carried_on_back(enabled: bool) -> void:
	carried_on_back = enabled
	queue_redraw()


func set_shield_exterior(enabled: bool) -> void:
	shield_exterior = enabled
	queue_redraw()


func set_pants_piece(piece: String, length := 30.0) -> GearVisual:
	pants_piece = piece
	pants_length = length
	queue_redraw()
	return self


func set_bow_draw(amount: float) -> void:
	bow_draw = amount
	queue_redraw()


func set_crossbow_loaded(enabled: bool) -> void:
	crossbow_loaded = enabled
	queue_redraw()


func set_two_handed(enabled: bool) -> void:
	two_handed = enabled
	queue_redraw()


func set_back_view(enabled: bool) -> void:
	back_view = enabled
	queue_redraw()


func _pants_texture(piece: String) -> Texture2D:
	match item:
		"cloth", "ranger", "baggy":
			return {"waist": STORYBOOK_CLOTH_PANTS_WAIST, "thigh": STORYBOOK_CLOTH_PANTS_THIGH, "shin": STORYBOOK_CLOTH_PANTS_SHIN}.get(piece)
		"leather":
			return {"waist": STORYBOOK_LEATHER_PANTS_WAIST, "thigh": STORYBOOK_LEATHER_PANTS_THIGH, "shin": STORYBOOK_LEATHER_PANTS_SHIN}.get(piece)
		"plate":
			return {"waist": STORYBOOK_PLATE_PANTS_WAIST, "thigh": STORYBOOK_PLATE_PANTS_THIGH, "shin": STORYBOOK_PLATE_PANTS_SHIN}.get(piece)
	return null


func _shield_exterior_texture() -> Texture2D:
	return {
		"marsh_shield": STORYBOOK_MARSH_SHIELD_EXTERIOR,
		"dune_shield": STORYBOOK_DUNE_SHIELD_EXTERIOR,
	}.get(item, STORYBOOK_SHIELD_EXTERIOR)


func _draw() -> void:
	match slot:
		"weapon":
			match item:
				"sword":
					# The image is authored with its grip at the local origin and its
					# blade on +Y, preserving the socket/reach contract used by attacks.
					draw_texture(STORYBOOK_SWORD,Vector2(-31,-14))
				"axe":
					if two_handed:
						# Lower and upper leather wraps align to the primary and support
						# hand sockets; the broad blade reaches the established trail tip.
						draw_texture(STORYBOOK_TROLL_GREAT_AXE,Vector2(-60,-32))
					else:
						# The vertical-flipped export retains its blade on local +X so
						# handedness and the existing reach endpoint stay unchanged.
						draw_texture(STORYBOOK_AXE,Vector2(-33,-20))
				"bow":
					# Keep the responsive string procedural, but anchor it to a painted
					# stave whose leather grip sits at the local hand origin.
					draw_texture(STORYBOOK_BOW,Vector2(-40,-44))
					var nock := Vector2(-40-bow_draw,0)
					draw_line(BOW_TOP,nock,Color("e8dcc6"),2.0)
					draw_line(nock,BOW_BOTTOM,Color("e8dcc6"),2.0)
					if bow_draw > 1.0:
						# Stretch the same painted arrow used in flight between the live
						# nock and fixed tip, replacing the former line-and-triangle proxy.
						draw_texture_rect(STORYBOOK_ARROW,Rect2(nock.x,-9,98.0+bow_draw,18),false)
				"crossbow":
					# Grip at local zero, guide rail on +Y, and the support socket farther
					# along the stock preserve a compact two-handed firing contract.
					draw_texture(STORYBOOK_CROSSBOW,Vector2(-55,-45))
					if crossbow_loaded:
						# The authored horizontal bolt rotates onto the local +Y guide
						# rail, which becomes screen-forward when the weapon is shouldered.
						draw_set_transform(Vector2(0,14),PI*.5)
						draw_texture(STORYBOOK_CROSSBOW_BOLT,Vector2(0,-10))
						draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
				"spear":
					# Shares the pole-weapon butt/hand/tip contract with the staff so
					# run stabilization and the horizontal jab curve remain unchanged.
					draw_texture(STORYBOOK_SPEAR,Vector2(-STORYBOOK_SPEAR.get_width()*.5,POLE_BUTT.y))
				"staff":
					# Runtime export is butt-first along local +Y with its wrapped grip
					# crossing the hand origin and crystal centered on the reach endpoint.
					draw_texture(STORYBOOK_STAFF,Vector2(-STORYBOOK_STAFF.get_width()*.5,POLE_BUTT.y))
				"branch_staff":
					# The Fae reference's forked natural staff shares the same hand, butt,
					# reach, locomotion, and casting contract as the crystal variant.
					draw_texture(STORYBOOK_BRANCH_STAFF,Vector2(-STORYBOOK_BRANCH_STAFF.get_width()*.5,POLE_BUTT.y))
		"offhand":
			match item:
				"shield", "marsh_shield", "dune_shield":
					var center := SHIELD_CENTER
					if carried_on_back or shield_exterior:
						# Wielded and back-mounted reference poses present the selected
						# decorated face while retaining one shared boss/grip socket.
						var exterior := _shield_exterior_texture()
						draw_texture(exterior,center-exterior.get_size()*.5)
					else:
						# Reserved for a future explicit flip/inspection pose.
						draw_texture(STORYBOOK_SHIELD_INTERIOR,center-STORYBOOK_SHIELD_INTERIOR.get_size()*.5)
				"lantern":
					# The hand grips the authored top loop; the painted body hangs below
					# the socket instead of disappearing upward along the forearm.
					draw_texture(STORYBOOK_LANTERN,LANTERN_DRAW_OFFSET)
				"spellbook":
					# The lower spine terminates at the supporting palm; genuine alpha
					# preserves the irregular page and cover silhouette.
					draw_texture(STORYBOOK_SPELLBOOK,Vector2(-25,-33))
		"armor":
			if item == "cloth":
				# The dyed front keeps its compact sleeveless edge; climbing swaps to
				# a buckle-free rear panel with open neck and arm sockets.
				draw_texture(STORYBOOK_CLOTH_ARMOR_BACK if back_view else STORYBOOK_CLOTH_ARMOR,Vector2(-41,0))
			elif item == "marsh_tunic":
				# Loose ivory homespun matches the Bogkin painting without baking
				# frog anatomy or its independently equipped orange scarf.
				draw_texture(STORYBOOK_MARSH_TUNIC_BACK if back_view else STORYBOOK_MARSH_TUNIC,Vector2(-41,0))
			elif item == "leather":
				# Empty neck/arm openings let both authored views layer over every
				# lineage body; the rear replaces chest hardware with crossed straps.
				draw_texture(STORYBOOK_LEATHER_ARMOR_BACK if back_view else STORYBOOK_LEATHER_ARMOR,Vector2(-41,0))
			elif item == "woodland_harness":
				# Bronze pauldrons, crossed tack, and leaf tabs echo the Centaur
				# painting while the open center preserves authored anatomy.
				draw_texture(STORYBOOK_WOODLAND_HARNESS_BACK if back_view else STORYBOOK_WOODLAND_HARNESS,Vector2(-41,0))
			elif item == "troll_jerkin":
				# Rugged charcoal hide and rust skirt tabs match the Frost Troll
				# painting; rear climbing removes its laced inset and buckle.
				draw_texture(STORYBOOK_TROLL_JERKIN_BACK if back_view else STORYBOOK_TROLL_JERKIN,Vector2(-41,0))
			elif item == "fur_coat":
				# The Frostling's quilted indigo travel coat keeps fixed authored
				# colors and swaps to a buckle-free rear panel on the ladder.
				draw_texture(STORYBOOK_FUR_COAT_BACK if back_view else STORYBOOK_FUR_COAT,Vector2(-41,0))
			elif item == "fae_tunic":
				# Paired reference-matched golden tunic, red capelet, and blue sash;
				# ladder motion swaps away the clasp and front sash knot.
				draw_texture(STORYBOOK_FAE_TUNIC_BACK if back_view else STORYBOOK_FAE_TUNIC,Vector2(-41,0))
			elif item == "lamellar":
				# The Duneborn reference's scale rows, shoulder mantle, and belt are
				# paired front/rear items; the neck and both arm holes stay open.
				draw_texture(STORYBOOK_LAMELLAR_ARMOR_BACK if back_view else STORYBOOK_LAMELLAR_ARMOR,Vector2(-41,0))
			elif item == "plate":
				# The keyed front breastplate swaps to a true-alpha articulated
				# backplate so ladder poses never show front-facing armor contours.
				draw_texture(STORYBOOK_PLATE_ARMOR_BACK if back_view else STORYBOOK_PLATE_ARMOR,Vector2(-41,0))
		"pants":
			var pants_texture := _pants_texture(pants_piece)
			if pants_texture and pants_piece == "waist":
				draw_texture(pants_texture,Vector2(-28,-2))
			elif pants_texture and pants_piece in ["thigh","shin"]:
				var width: float
				if item == "baggy":
					width = float(BAGGY_PANTS_WIDTHS[pants_piece])
				else:
					width = 21.0 if pants_piece == "thigh" else 18.0
				var covered_length := pants_length*.98
				# Stretch only down the bone axis. The authored width, seams, straps,
				# and material treatment remain stable while race leg lengths vary.
				# The Fae-reference baggy cut widens only the thigh and narrows the
				# wrapped calf, preserving the same independently animated knee seam.
				draw_texture_rect(pants_texture,Rect2(-width*.5,0,width,covered_length),false)
		"boots":
			var boot_texture: Texture2D = {
				"wraps": STORYBOOK_WRAPS_BOOT,
				"leather": STORYBOOK_LEATHER_BOOT,
				"plate": STORYBOOK_PLATE_BOOT,
			}.get(item)
			if boot_texture:
				# The ankle joint is local zero: the cuff rises over the shin while
				# the painted toe extends along +X, matching the authored bare foot.
				draw_texture(boot_texture,Vector2(-11,-31))
		"head":
			match item:
				"hood":
					# Climbing swaps to the closed rear shell instead of exposing the
					# authored rear head through this front face aperture.
					var hood_texture := STORYBOOK_HOOD_BACK if back_view else STORYBOOK_HOOD
					draw_texture(hood_texture,Vector2(-37,-62))
				"helm":
					var helm_texture := STORYBOOK_HELM_BACK if back_view else STORYBOOK_HELM
					draw_texture(helm_texture,Vector2(-37,-62))
				"crown":
					# The low open circlet is symmetric enough to retain the same
					# silhouette from the rear without obscuring race-specific hair.
					draw_texture(STORYBOOK_CROWN,Vector2(-30,-65))
		"back":
			match item:
				"cape":
					# The twin clasps align around the upper-back origin; the restrained
					# painted sweep supplies motion without detaching from the torso.
					draw_texture(STORYBOOK_CAPE,Vector2(-44,2))
				"long_cape":
					# The reference-matched travel cape shares the clasp socket but adds
					# a broad wind-swept knee-length silhouette around the torso and legs.
					draw_texture(STORYBOOK_LONG_CAPE,Vector2(-92,2))
				"pack":
					draw_texture(STORYBOOK_PACK,Vector2(-35,6))
				"quiver":
					# Preserve the established upper-right arrow opening and lower-left
					# capped end, biased outside the torso so the item remains readable
					# from the front while mirroring consistently with either facing.
					draw_texture(STORYBOOK_QUIVER,QUIVER_DRAW_OFFSET)
		"accessory":
			match item:
				"scarf":
					var scarf_texture := STORYBOOK_SCARF_BACK if back_view else STORYBOOK_SCARF
					draw_texture(scarf_texture,Vector2(-33,-3))
				"amulet":
					# A front-hanging pendant is occluded by the head and torso from the
					# rear rather than being incorrectly painted over a climbing back.
					if not back_view:
						draw_texture(STORYBOOK_AMULET,Vector2(-24,0))
				"goggles":
					if back_view:
						draw_texture(STORYBOOK_GOGGLES_BACK,Vector2(-28,-29))
					else:
						draw_texture(STORYBOOK_GOGGLES,Vector2(-28,-35))
