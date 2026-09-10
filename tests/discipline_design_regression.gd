extends SceneTree
const Progress = preload("res://src/discipline_progress.gd")
const Overview = preload("res://src/ui/discipline_overview.gd")

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	for lineage in CharacterCatalog.race_ids():
		var panel := Overview.new()
		panel.lineage = lineage
		panel.progression = Progress.new()
		var before: Dictionary = panel.progression.snapshot()
		root.add_child(panel)
		assert(panel.rows.size() == 12 and panel.nodes.size() == 6)
		for id in panel.rows:
			panel.rows[id].pressed.emit()
			assert(panel.selected == id)
			assert(panel.rows[id].position.x+panel.rows[id].size.x < 304)
			assert(panel.rows[id].position.y+panel.rows[id].size.y < 557)
		for i in panel.nodes.size():
			var node = panel.nodes[i]
			node.pressed.emit()
			assert(panel.selected_skill == i and node.selected)
			assert(node.portrait.texture != null)
			assert(node.unlocked == panel.progression.allows(preload("res://prototypes/sparring_arena/lineage_skills.gd").combat_kit(lineage)[i]))
			await process_frame
			assert(panel.detail.get_minimum_size().y <= 221,"Detail overflow: "+lineage+" slot "+str(i))
			assert(panel.unlocks[i].get_minimum_size().y <= 25,"Plaque overflow")
		assert(panel.progression.snapshot() == before,"Inspecting nodes never buys skills or awards XP")
		panel.free()
	print("PASS: all 8 discipline boards, 12 icon rows, 6 interactive medallions, real lock states and text bounds")
	quit()
