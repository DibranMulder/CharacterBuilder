extends SceneTree
const Districts = preload("res://prototypes/human_hometown/districts.gd")
const Model = preload("res://prototypes/human_hometown/town_encounter.gd")
var failed := false
func check(value: bool, message: String) -> void:
	if not value:
		failed = true
		printerr("FAIL: "+message)
func _initialize() -> void:
	for id in Districts.NAMES:
		var spec := Districts.spec(id)
		var surfaces: Array = [Rect2(40,480,2320,1)] + spec.platforms
		var reached := {0:true}
		var queue := [0]
		# Discover landings using the actual jump/gravity/collision simulation.
		while not queue.is_empty():
			var source: int = queue.pop_front()
			var surface: Rect2 = surfaces[source]
			for sample in 13:
				for direction in [-1,0,1]:
					var model = Model.new()
					model.configure_map(spec)
					model.position = Vector2(lerpf(surface.position.x+2,surface.end.x-2,float(sample)/12),surface.position.y)
					model.jump()
					for frame in 100:
						model.step(1.0/60,direction,false)
						if model.grounded: break
					for target in surfaces.size():
						var landing: Rect2 = surfaces[target]
						if not reached.has(target) and absf(model.position.y-landing.position.y)<1 and model.position.x >= landing.position.x and model.position.x <= landing.end.x:
							reached[target] = true
							queue.append(target)
			# A ladder/rope is an alternate route from its lower end to its top landing.
			for climb in spec.climbs:
				if absf(surface.position.y-climb.end.y) > 1 or climb.position.x < surface.position.x or climb.end.x > surface.end.x: continue
				var model = Model.new()
				model.configure_map(spec)
				model.position = Vector2(climb.get_center().x,climb.end.y)
				model.climb_axis = -1
				for frame in 400: model.step(1.0/60,0,false)
				check(absf(model.position.y-climb.position.y)<1,id+" rope reaches its top")
				for target in surfaces.size():
					var landing: Rect2 = surfaces[target]
					if not reached.has(target) and absf(landing.position.y-model.position.y)<1 and landing.has_point(model.position+Vector2(0,.1)):
						reached[target] = true
						queue.append(target)
		for portal in spec.portals:
			var reachable := false
			for target in reached:
				var surface: Rect2 = surfaces[target]
				if absf(surface.position.y-portal.y)<1 and portal.x >= surface.position.x and portal.x <= surface.end.x: reachable = true
			check(reachable,id+" portal to "+portal.to+" can be reached through movement")
		if not spec.lookout.is_empty():
			var accessible := false
			for target in reached:
				var surface: Rect2 = surfaces[target]
				if surface.has_point(spec.lookout.position+Vector2(0,.1)): accessible = true
			check(accessible,id+" climbing reward is reachable")
			var collector = Model.new()
			collector.configure_map(spec)
			collector.position = spec.lookout.position
			var coins: int = collector.inventory.coins
			collector.step(.016,0,false)
			check(collector.inventory.coins == coins+20,id+" upper route pays its reward")
			collector.step(.016,0,false)
			check(collector.inventory.coins == coins+20,id+" upper reward is collected only once")
	if not failed: print("PASS: every hometown portal is reachable with simulated jumps or climbing")
	quit(1 if failed else 0)
