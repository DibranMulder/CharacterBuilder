extends SceneTree
var failed := false
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failed = true
		printerr("FAIL: "+message)
func run() -> void:
	for id in ["square","tidekin_sea_return_116"]:
		var atlas = preload("res://src/ui/world_map.gd").new()
		atlas.current = id
		root.add_child(atlas)
		atlas.show_world()
		for child in atlas.get_children():
			if child is Button and child.text == "You": child.pressed.emit()
		var entry = atlas.Catalog.node(id)
		check(atlas.selected_node == id and atlas.region_id == entry.region,"You selects the actual current map")
		var point: Vector2 = atlas.chart.position+atlas.chart.points[id]*atlas.zoom
		check(point.distance_to(atlas.canvas.size*.5) < 1,"You centers the current map pin")
		check("You are here" in atlas.targets[id].caption.text,"Current pin explicitly identifies the player")
		check(entry.name in atlas.subtitle.text,"Header names the current map")
		check("You are here" in atlas.detail.text,"Details distinguish current location from browsing")
		atlas.queue_free()
		await process_frame
	print("FAIL: current map is unclear" if failed else "PASS: You centers and identifies the current map")
	quit(1 if failed else 0)
