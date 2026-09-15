extends SceneTree
var failed := false
func _initialize() -> void: _run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failed = true
		printerr("FAIL: "+message)
func move_mouse(at: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = at
	event.global_position = at
	root.push_input(event,true)
func _run() -> void:
	var holder := Node2D.new()
	holder.position = Vector2(100,100)
	holder.scale = Vector2.ONE*1.5
	root.add_child(holder)
	var marker = preload("res://src/ui/world_interaction_marker.gd").new()
	holder.add_child(marker)
	marker.refresh(Vector2(100,100),"Village Square\nStep into the light",true,true,"east")
	await process_frame
	check(not marker.caption.visible and not marker.expanded,"world hints start as icons")
	move_mouse(marker.hit_area.get_global_rect().get_center())
	await process_frame
	check(marker.caption.visible and marker.expanded,"real hover reveals text under gameplay scaling")
	check(marker.caption.text == "Village Square\nStep into the light","hover retains destination and instruction")
	move_mouse(Vector2(900,600))
	await process_frame
	check(not marker.caption.visible,"mouse exit hides text")
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = marker.hit_area.get_global_rect().get_center()
	marker._hint_input(touch)
	check(marker.touch_pinned and marker.caption.visible,"touch reveals the hint without performing an action")
	marker._hint_input(touch)
	check(not marker.touch_pinned and not marker.caption.visible,"second tap closes text")
	marker._hint_input(touch)
	touch.position = Vector2(900,600)
	marker._input(touch)
	check(not marker.touch_pinned and not marker.caption.visible,"tap elsewhere dismisses touch hint")
	marker._set_expanded(true)
	marker.refresh(Vector2(100,100),"Village Square\nStep into the light",true,false,"east")
	check(not marker.expanded and not marker.caption.visible,"hidden world signs never retain open text")
	marker.refresh(Vector2(100,100),"Village Square\nStep into the light",true,true,"east")
	check(not marker.caption.visible,"returning from a menu starts collapsed")
	holder.queue_free()
	await process_frame
	if not failed: print("PASS: icon-only defaults, scaled mouse hover, touch toggle, outside dismissal and menu cleanup")
	quit(1 if failed else 0)
