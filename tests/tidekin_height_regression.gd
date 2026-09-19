extends SceneTree
## Tall SVG galleries use their authored climbs (tidekin_svg_regression).
## Furniture must remain reachable with the ordinary jump, without climb input.
const Region = preload("res://prototypes/tidekin_sea/region.gd")
const Model = preload("res://prototypes/tidekin_sea/region_encounter.gd")
var failed := false
func _initialize() -> void:
	var checked := 0
	for spec in Region.maps():
		var model = Model.new()
		model.configure_region(spec)
		model.enemies.clear()
		var authored: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://designs/map-layouts/manifest.json"))
		var original: Dictionary
		for map in authored.maps:
			if map.id==spec.id: original=map; break
		for obj in spec.objects:
			if not obj.jumpable: continue
			var support_y := 480.0
			for landing in original.platforms:
				if landing.id==obj.surface: support_y=480+(landing.y-original.floor.y)*.9
			var x: float = obj.rect[0]+obj.rect[2]*.5
			model.position = Vector2(x,support_y)
			model.velocity = Vector2.ZERO
			model.grounded = true
			model.jump()
			for frame in 100:
				model.step(1.0/60,0,false)
				if model.grounded: break
			if not model.grounded or model.position.y>=support_y-.5:
				failed = true
				printerr("FAIL: "+spec.id+" ordinary jump cannot land on "+obj.type+" at "+str(x))
			checked += 1
		model.position = Vector2(spec.width-42,-200)
		model.velocity = Vector2.ZERO
		for frame in 180: model.step(1.0/60,0,false)
		if not model.grounded or model.position.y!=480:
			failed = true
			printerr("FAIL: no floor return in "+spec.id)
	if not failed: print("PASS: %d authored furniture surfaces accept ordinary jumps; all 39 maps retain safe floor returns" % checked)
	quit(1 if failed else 0)
