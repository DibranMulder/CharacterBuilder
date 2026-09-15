extends SceneTree
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var view := SubViewport.new()
	view.size = Vector2i(1152,648)
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	var sea = load("res://prototypes/tidekin_sea/tidekin_sea.tscn").instantiate()
	view.add_child(sea)
	sea.set_physics_process(false)
	sea.get_window().focus_exited.disconnect(sea._lose_focus)
	for id in ["tidekin_sea_land","tidekin_sea_path_001","tidekin_sea_site_011","tidekin_sea_site_021","tidekin_sea_gs","tidekin_sea_fn","tidekin_sea_return_071","tidekin_sea_return_116"]:
		sea.enter_map(sea.Region.index_of(id),false)
		sea.model.position = sea.model.fixture_point(2) if sea.MAPS[sea.map_index].vertical else Vector2(900,480)
		sea._update_view(1)
		await capture(view,id+"_height")
	sea.free()
	for id in ["market","apothecary","tower","archive"]:
		set_meta("wendmere_destination",id)
		var town = load("res://prototypes/human_hometown/human_hometown.tscn").instantiate()
		view.add_child(town)
		town.set_physics_process(false)
		town.get_window().focus_exited.disconnect(town._lose_focus)
		town.model.position = town.district.lookout.position
		town._update_view(1)
		await capture(view,"wendmere_"+id+"_height")
		town.free()
	print("PASS: captured upper Tidekin and human routes")
	quit()
func capture(view: SubViewport, id: String) -> void:
	for frame in 3: await process_frame
	RenderingServer.force_draw(false)
	assert(view.get_texture().get_image().save_png("res://artifacts/"+id+".png") == OK)
