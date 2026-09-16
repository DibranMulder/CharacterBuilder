extends Control
## World → Region atlas. Region/stronghold inspection never changes the active level.
signal closed
signal travel_requested(destination: String)
signal test_teleport_requested(destination: String)
const Catalog = preload("res://src/world/world_catalog.gd")
const RegionArt = preload("res://src/world/region_art.gd")
const Chronicle = preload("res://src/ui/chronicle_theme.gd")
const Districts = preload("res://prototypes/human_hometown/districts.gd")
var current := ""
var lineage := "human"
var quest_stage := 0
var quest := ""
var explored: Array = []
var allow_travel := false
var region_id := ""
var selected_region := "open_lands"
var selected_node := ""
var focused_group := ""
var targets := {}
var group_targets := {}
var crossing_targets: Array[Button] = []
var status: Label
var canvas: Control
var chart: Control
var title: Label
var subtitle: Label
var detail_title: Label
var detail: Label
var open_button: Button
var stronghold_button: Button
var story_button: Button
var travel_button: Button
var teleport_button: Button
var zoom_label: Label
var back_button: Button
var zoom := 1.0
var min_zoom := .4
var max_zoom := 2.0
var dragging := false
var drag_distance := 0.0
var chart_bounds := Rect2()
var world_position := Vector2.ZERO
var world_zoom := 1.0
var has_world_view := false

func is_explored(id: String) -> bool:
	return id == current or id in explored

func _ready() -> void:
	z_index = 400
	size = Vector2(1152,648)
	theme = Chronicle.create()
	var panel := Panel.new()
	panel.theme_type_variation = &"InkPanel"
	panel.size = size
	panel.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(panel)
	title = _label(self,"THE VEILED REALMS",Vector2(25,18),24)
	title.theme_type_variation = &"ChronicleHeading"
	subtitle = _label(self,"World atlas · Light Reaches, the neutral frontier & Dark Marches",Vector2(25,52),15)
	back_button = _button("World",Vector2(660,24),Vector2(72,34),show_world)
	_button("−",Vector2(738,24),Vector2(40,34),func(): step_zoom(1.0/1.25))
	_button("+",Vector2(784,24),Vector2(40,34),func(): step_zoom(1.25))
	_button("Fit",Vector2(830,24),Vector2(48,34),reset_view)
	_button("You",Vector2(884,24),Vector2(50,34),show_current)
	_button("Close · M / Esc",Vector2(940,24),Vector2(187,34),func(): closed.emit())
	canvas = Control.new()
	canvas.position = Vector2(20,102)
	canvas.size = Vector2(825,465)
	canvas.clip_contents = true
	canvas.mouse_filter = MOUSE_FILTER_STOP
	canvas.gui_input.connect(_canvas_input)
	add_child(canvas)
	detail_title = _label(self,"",Vector2(865,105),21)
	detail_title.size = Vector2(260,60)
	detail_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var detail_scroll := ScrollContainer.new()
	detail_scroll.position = Vector2(865,169)
	detail_scroll.size = Vector2(260,235)
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(detail_scroll)
	detail = Label.new()
	detail.theme = Chronicle.create()
	detail.custom_minimum_size.x = 242
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_theme_font_size_override("font_size",15)
	detail_scroll.add_child(detail)
	open_button = _button("Open region →",Vector2(862,416),Vector2(265,39),func(): open_region(selected_region))
	stronghold_button = _button("Inside stronghold",Vector2(862,462),Vector2(265,39),func(): open_region(selected_region,"stronghold"))
	story_button = _button("Story site",Vector2(862,508),Vector2(265,39),func(): open_region(selected_region,"story"))
	travel_button = _button("Travel to discovered map",Vector2(862,508),Vector2(265,39),_request_travel)
	teleport_button = _button("Teleport here (test)",Vector2(862,554),Vector2(265,36),_request_test_teleport)
	teleport_button.visible = false
	zoom_label = _label(self,"",Vector2(25,578),14)
	status = _label(self,"",Vector2(25,606),14)
	status.size = Vector2(1095,32)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if not Catalog.node(current).is_empty(): selected_region = Catalog.node(current).region
	# Start with the entire local region; World is an explicit outward step.
	open_region(selected_region)
	if not Catalog.node(current).is_empty(): select_node(current)

func _button(value: String, at: Vector2, dimensions: Vector2, action: Callable) -> Button:
	var button := Button.new()
	button.text = value
	button.position = at
	button.size = dimensions
	button.focus_mode = FOCUS_NONE
	button.pressed.connect(action)
	add_child(button)
	return button

func _label(parent: Node, value: String, at: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.mouse_filter = MOUSE_FILTER_IGNORE
	label.position = at
	label.text = value
	label.add_theme_font_size_override("font_size",font_size)
	parent.add_child(label)
	return label

func _new_chart() -> void:
	if is_instance_valid(chart):
		canvas.remove_child(chart)
		chart.queue_free()
	targets.clear()
	group_targets.clear()
	crossing_targets.clear()
	chart = preload("res://src/ui/world_map_chart.gd").new()
	chart.size = Vector2(2400,1800)
	chart.mouse_filter = MOUSE_FILTER_IGNORE
	chart.region_id = region_id
	chart.current = current
	chart.explored = explored
	chart.selected = selected_region
	canvas.add_child(chart)

func show_world() -> void:
	theme = RegionArt.theme_for("")
	region_id = ""
	selected_node = ""
	focused_group = ""
	_new_chart()
	title.text = "THE VEILED REALMS"
	subtitle.text = "World map · 8 homelands · 4 frontiers · 15 connecting routes"
	back_button.disabled = true
	for spec in Catalog.regions():
		var at := Vector2(spec.position[0],spec.position[1])*Vector2(1000,563)
		var marker := Button.new()
		marker.position = at+Vector2(-87,-27)
		marker.size = Vector2(174,54)
		marker.text = ("♜ " if spec.kind == "homeland" else "◇ ")+spec.name+"\n"+(spec.stronghold.trim_prefix("The ") if spec.kind == "homeland" else spec.story)
		marker.add_theme_font_size_override("font_size",14)
		marker.focus_mode = FOCUS_NONE
		marker.mouse_filter = MOUSE_FILTER_STOP
		marker.tooltip_text = (spec.stronghold+" · " if not spec.stronghold.is_empty() else spec.story+" · ")+"Double-click to open region"
		marker.gui_input.connect(func(event: InputEvent): _region_input(event,spec.id))
		chart.add_child(marker)
		targets[spec.id] = marker
	chart_bounds = Rect2(0,0,1000,563)
	reset_view()
	if has_world_view:
		zoom = world_zoom
		chart.scale = Vector2.ONE*zoom
		chart.position = world_position
		_clamp_pan()
	select_region(selected_region)
	status.text = "Choose a region to browse its maps. Mist marks unexplored places; browsing does not reveal or travel."
	_update_zoom_label()

func select_region(id: String) -> void:
	var spec := Catalog.region(id)
	if spec.is_empty(): return
	selected_region = id
	selected_node = ""
	detail_title.text = spec.name
	var lines: Array[String] = [spec.allegiance+" · "+("Homeland of "+spec.lineage if spec.kind == "homeland" else "Neutral frontier"),""]
	if spec.kind == "homeland":
		lines.append("Village: "+spec.village)
		lines.append("Stronghold: "+spec.stronghold)
		lines.append("Access: "+spec.allegiance+" allegiance")
	else:
		lines.append("Dungeon: "+spec.story)
		lines.append("Danger: "+spec.danger)
	lines.append("\nRoads & crossings")
	for road in Catalog.roads(id):
		var neighbor: String = road.b if road.a == id else road.a
		lines.append(road.name+" → "+Catalog.region(neighbor).name)
	_set_details("\n".join(lines))
	open_button.visible = true
	open_button.text = "Open region →" if region_id.is_empty() else "All region maps"
	stronghold_button.visible = spec.kind == "homeland"
	story_button.visible = true
	story_button.text = "Story site" if spec.kind == "homeland" else "Dungeon depths"
	# Frontiers focus their dungeon rather than a nonexistent story group.
	for connection in story_button.pressed.get_connections(): story_button.pressed.disconnect(connection.callable)
	story_button.pressed.connect(func(): open_region(id,"story" if spec.kind == "homeland" else "dungeon"))
	travel_button.visible = false
	teleport_button.visible = false
	chart.selected = id
	chart.selected_node = ""
	_update_zoom_label()
	chart.queue_redraw()
	if region_id.is_empty():
		for key in targets: targets[key].modulate = Color.WHITE if key == id else Color(.86,.89,.87)

func open_region(id: String, group := "") -> void:
	var spec := Catalog.region(id)
	if spec.is_empty(): return
	if region_id.is_empty() and is_instance_valid(chart):
		world_position = chart.position
		world_zoom = zoom
		has_world_view = true
	region_id = id
	theme = RegionArt.theme_for(id)
	focused_group = group
	_new_chart()
	chart.points = Catalog.positions(id)
	title.text = spec.name.to_upper()
	subtitle.text = "World  /  "+spec.name+"  /  "+("Region maps" if group.is_empty() else group.capitalize())
	back_button.disabled = false
	for cluster in spec.groups:
		var box := Catalog.group_bounds(id,cluster.id)
		var heading := Button.new()
		heading.set_meta("anchor",box.get_center())
		heading.text = cluster.name
		heading.add_theme_font_size_override("font_size",17)
		heading.add_theme_color_override("font_outline_color",Color("10212a"))
		heading.add_theme_constant_override("outline_size",5)
		for state in ["normal","hover","pressed","focus"]: heading.add_theme_stylebox_override(state,StyleBoxEmpty.new())
		heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		heading.focus_mode = FOCUS_NONE
		heading.tooltip_text = "Explore "+cluster.name
		heading.pressed.connect(func(): focus_group(cluster.id))
		chart.add_child(heading)
		group_targets[cluster.id] = heading
	for entry in spec.nodes:
		var marker := preload("res://src/ui/world_map_marker.gd").new()
		marker.size = Vector2(24,24)
		marker.current = entry.id == current
		marker.discovered = is_explored(entry.id)
		marker.accent = RegionArt.accent(id)
		marker.mouse_filter = MOUSE_FILTER_STOP
		marker.tooltip_text = entry.name+" · "+("You are here" if entry.id == current else ("Explored" if is_explored(entry.id) else "Unexplored"))+" · "+entry.access
		marker.gui_input.connect(func(event: InputEvent): _node_input(event,entry.id))
		chart.add_child(marker)
		marker.caption.text = ("You are here\n" if marker.current else "")+entry.name
		if marker.current:
			marker.caption.size.y = 64
			marker.caption.add_theme_color_override("font_color",Color("9cf8ff"))
			marker.z_index = 2
		targets[entry.id] = marker
	chart_bounds = Catalog.group_bounds(id,"")
	_add_crossings(spec)
	select_region(id)
	reset_view()
	if not group.is_empty(): focus_group(group)
	chart.queue_redraw()
	status.text = "Explore the landscape · Click a landmark to zoom in, or a pin to inspect a map. Mist marks unvisited places."

func _add_crossings(spec: Dictionary) -> void:
	var roads := Catalog.roads(spec.id)
	var origin := Vector2(spec.position[0],spec.position[1])
	for i in roads.size():
		var road: Dictionary = roads[i]
		var neighbor: String = road.b if road.a == spec.id else road.a
		var other := Catalog.region(neighbor)
		var direction := Vector2(other.position[0],other.position[1])-origin
		direction /= maxf(absf(direction.x),absf(direction.y))
		var button := Button.new()
		var at := (Vector2(.5,.5)+direction*Vector2(.40,.40))*Catalog.REGION_SIZE
		button.set_meta("anchor",at)
		button.position = at-Vector2(125,24)
		button.size = Vector2(250,48)
		button.text = "→ "+other.name
		button.add_theme_font_size_override("font_size",12)
		button.focus_mode = FOCUS_NONE
		button.tooltip_text = road.name
		crossing_targets.append(button)
		button.pressed.connect(func(): open_region(neighbor))
		chart.add_child(button)

func select_node(id: String) -> void:
	var entry := Catalog.node(id)
	if entry.is_empty() or entry.region != region_id: return
	selected_node = id
	teleport_button.visible = true
	teleport_button.disabled = preload("res://src/world/test_map_travel.gd").destination(id).is_empty()
	teleport_button.tooltip_text = "This map is not playable yet." if teleport_button.disabled else "Test shortcut: bypass exploration and entry gates. Arrive at a safe spawn."
	chart.selected_node = id
	chart.queue_redraw()
	_update_zoom_label()
	detail_title.text = entry.name
	var access: String = "Both allegiances" if entry.access == "Shared" else entry.access+" allegiance required"
	var lines: Array[String] = [entry.group.capitalize()+" map · "+("Explored" if is_explored(id) else "Unexplored"),access,""]
	if id == current: lines.push_front("You are here · "+Catalog.region(entry.region).name+"\n")
	if entry.has("levels"): lines.append("Creature levels: "+str(entry.levels))
	if entry.runtime_id.is_empty(): lines.append("Charted location. This submap is not open for play yet.")
	elif not is_explored(id): lines.append("Visit on foot to explore this map.")
	if id in ["tower","stair","solar"] and quest_stage < 3: lines.append("Warden key required.")
	lines.append("\nConnected maps")
	for neighbor in Catalog.neighbors(region_id,id): lines.append("↔ "+Catalog.node(neighbor).name)
	_set_details("\n".join(lines))
	open_button.visible = true
	open_button.text = "All region maps"
	stronghold_button.visible = entry.group == "stronghold"
	story_button.visible = false
	travel_button.visible = allow_travel and is_explored(id) and Districts.NAMES.has(id)
	travel_button.disabled = not Districts.allowed(id,lineage,quest_stage).is_empty()
	travel_button.tooltip_text = Districts.allowed(id,lineage,quest_stage)
	status.text = "You are here · "+Catalog.region(entry.region).name+" / "+entry.name if id == current else "Selected "+entry.name+". Your character remains in the current map."

func _request_travel() -> void:
	if not allow_travel or not is_explored(selected_node) or not Districts.NAMES.has(selected_node): return
	var refusal := Districts.allowed(selected_node,lineage,quest_stage)
	if not refusal.is_empty():
		status.text = refusal
		return
	travel_requested.emit(selected_node)

func show_current() -> void:
	var entry := Catalog.node(current)
	if entry.is_empty():
		status.text = "This practice area is outside the charted world. Select a region to browse."
		return
	if region_id != entry.region: open_region(entry.region)
	focused_group = ""
	select_node(current)
	zoom = clampf(1.0,min_zoom,max_zoom)
	chart.scale = Vector2.ONE*zoom
	chart.position = canvas.size*.5-chart.points[current]*zoom
	_update_zoom_label()
	subtitle.text = "You are here · "+Catalog.region(entry.region).name+" / "+entry.name

func focus_group(group: String) -> void:
	if region_id.is_empty(): return
	if not Catalog.region(region_id).groups.any(func(item): return item.id == group): return
	focused_group = group
	subtitle.text = "World  /  "+Catalog.region(region_id).name+"  /  "+group.capitalize()
	_fit(Catalog.group_bounds(region_id,group))
	_update_zoom_label()

func reset_view() -> void:
	focused_group = ""
	if not region_id.is_empty(): subtitle.text = "World  /  "+Catalog.region(region_id).name+"  /  Region maps"
	_fit(chart_bounds)

func _fit(bounds: Rect2) -> void:
	zoom = minf(canvas.size.x/bounds.size.x,canvas.size.y/bounds.size.y)*.96
	min_zoom = minf(minf(canvas.size.x/chart_bounds.size.x,canvas.size.y/chart_bounds.size.y)*.96,.4)
	chart.scale = Vector2.ONE*zoom
	chart.position = canvas.size*.5-bounds.get_center()*zoom
	_update_zoom_label()

func set_zoom(value: float) -> void:
	var next := clampf(value,min_zoom,max_zoom)
	var center := canvas.size*.5
	chart.position = center-(center-chart.position)*(next/zoom)
	zoom = next
	chart.scale = Vector2.ONE*zoom
	_clamp_pan()
	_update_zoom_label()

func step_zoom(factor: float) -> void:
	if region_id.is_empty() and zoom*factor > 1.45:
		open_region(selected_region)
	elif not region_id.is_empty() and factor < 1 and zoom*factor < min_zoom*.98:
		show_world()
	else: set_zoom(zoom*factor)

func _clamp_pan() -> void:
	var bounds := chart_bounds.grow(220)
	chart.position.x = clampf(chart.position.x,canvas.size.x*.2-bounds.end.x*zoom,canvas.size.x*.8-bounds.position.x*zoom)
	chart.position.y = clampf(chart.position.y,canvas.size.y*.2-bounds.end.y*zoom,canvas.size.y*.8-bounds.position.y*zoom)

func _update_zoom_label() -> void:
	if not region_id.is_empty():
		var occupied: Array[Rect2] = []
		for group in group_targets:
			var heading: Button = group_targets[group]
			heading.scale = Vector2.ONE/zoom
			heading.size = Vector2(190,54)
			heading.position = heading.get_meta("anchor")-Vector2(95,76)/zoom
			heading.visible = zoom < .70 and focused_group != group
			if heading.visible: occupied.append(Rect2(heading.position*zoom,heading.size))
		for crossing in crossing_targets:
			crossing.scale = Vector2.ONE/zoom
			crossing.size = Vector2(128,28)
			var anchor: Vector2 = crossing.get_meta("anchor")*zoom-crossing.size*.5
			var placement := Rect2(anchor,crossing.size)
			for offset in [Vector2.ZERO,Vector2(0,36),Vector2(0,-36),Vector2(0,72),Vector2(0,-72),Vector2(136,0),Vector2(-136,0)]:
				var candidate := Rect2(anchor+offset,crossing.size)
				if not occupied.any(func(rect): return rect.intersects(candidate.grow(6))):
					placement = candidate
					break
			crossing.position = placement.position/zoom
			crossing.visible = zoom < .70
			if crossing.visible: occupied.append(placement)

		var order: Array = targets.keys()
		# Reserve labels for the selected map and hero before other names.
		for priority in [selected_node,current]:
			if priority in order:
				order.erase(priority)
				order.push_front(priority)
		for id in order:
			var entry := Catalog.node(id)
			var marker = targets[id]
			marker.scale = Vector2.ONE/zoom
			marker.position = chart.points[id]-Vector2(12,12)/zoom
			marker.selected = id == selected_node
			var show_name: bool = id in [current,selected_node] or zoom >= .70 or entry.group == focused_group
			marker.caption.position = Vector2(24,-3)
			var label_rect := Rect2(chart.points[id]*zoom+Vector2(12,-15),marker.caption.size)
			if id in [current,selected_node] and occupied.any(func(rect): return rect.intersects(label_rect)):
				marker.caption.position = Vector2(-70,27)
				label_rect.position = chart.points[id]*zoom+Vector2(-82,15)
			if id not in [current,selected_node] and occupied.any(func(rect): return rect.intersects(label_rect)): show_name = false
			marker.caption.visible = show_name
			if show_name: occupied.append(label_rect)
			marker.queue_redraw()
	zoom_label.text = "%d%% · %s  |  Scroll / + −: zoom · Drag: pan · World: zoom out · You: current map" % [roundi(zoom*100),"World" if region_id.is_empty() else "Region"]

func _region_input(event: InputEvent, id: String) -> void:
	_canvas_input(event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and event.double_click: open_region(id)
		elif not event.pressed and drag_distance < 6: select_region(id)

func _node_input(event: InputEvent, id: String) -> void:
	_canvas_input(event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and drag_distance < 6: select_node(id)

func _canvas_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if event.pressed: drag_distance = 0
		if event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
			step_zoom(1.15 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0/1.15)
			accept_event()
	elif event is InputEventMouseMotion and dragging and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		drag_distance += event.relative.length()
		chart.position += event.relative
		_clamp_pan()
	elif event is InputEventScreenTouch:
		dragging = event.pressed
		if event.pressed: drag_distance = 0
	elif event is InputEventScreenDrag:
		chart.position += event.relative
		drag_distance += event.relative.length()
		_clamp_pan()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	match event.physical_keycode:
		KEY_EQUAL, KEY_KP_ADD: step_zoom(1.25)
		KEY_MINUS, KEY_KP_SUBTRACT: step_zoom(1.0/1.25)
		KEY_BACKSPACE: show_world()
		_: return
	get_viewport().set_input_as_handled()

func _set_details(value: String) -> void:
	detail.text = value
	detail.get_parent().scroll_vertical = 0

func _request_test_teleport() -> void:
	if preload("res://src/world/test_map_travel.gd").destination(selected_node).is_empty(): return
	test_teleport_requested.emit(selected_node)
