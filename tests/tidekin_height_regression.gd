extends SceneTree
const Region = preload("res://prototypes/tidekin_sea/region.gd")
const Model = preload("res://prototypes/tidekin_sea/region_encounter.gd")
var failed := false
func _initialize() -> void:
	var tested := {}
	for spec in Region.maps():
		var layout: String = JSON.stringify([spec.platforms,spec.fixture_points])
		if tested.has(layout): continue
		tested[layout] = true
		var model = Model.new()
		model.configure_region(spec)
		model.enemies.clear()
		var surfaces: Array = [Rect2(40,480,spec.width-80,1)] + model.platforms
		var reached := {0:true}
		var queue := [0]
		while not queue.is_empty():
			var source: int = queue.pop_front()
			var surface: Rect2 = surfaces[source]
			for sample in 17:
				for direction in [-1,0,1]:
					model.position = Vector2(lerpf(surface.position.x+2,surface.end.x-2,float(sample)/16),surface.position.y)
					model.velocity = Vector2.ZERO
					model.grounded = true
					model.jump()
					for frame in 100:
						model.step(1.0/60,direction,false)
						if model.grounded: break
					for target in surfaces.size():
						var landing: Rect2 = surfaces[target]
						if not reached.has(target) and absf(model.position.y-landing.position.y)<1 and landing.has_point(model.position+Vector2(0,.1)):
							reached[target] = true
							queue.append(target)
		for i in 3:
			var reachable := false
			for target in reached:
				if surfaces[target].has_point(model.fixture_point(i)+Vector2(0,.1)): reachable = true
			if not reachable:
				failed = true
				printerr("FAIL: "+spec.id+" fixture "+str(i)+" cannot be reached by jumping")
		# Every layout keeps the continuous ground route for safe drop-down recovery.
		model.position = Vector2(spec.width-200,-200)
		model.velocity = Vector2.ZERO
		for frame in 150: model.step(1.0/60,0,false)
		if not model.grounded or model.position.y != 480:
			failed = true
			printerr("FAIL: no floor return in "+spec.id)
	if not failed: print("PASS: all Tidekin platform layouts, upper objectives and safe floor returns use ordinary jump physics")
	quit(1 if failed else 0)
