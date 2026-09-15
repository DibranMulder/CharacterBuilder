extends Control
## Tutorial guidance shares the icon-only world hints.
var guide
var bindings
var model
var camera := Vector2.ZERO
var marker: Node2D
var cached_title := ""
var cached_body := ""

func _ready() -> void:
	size = Vector2(48,48)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker = preload("res://src/ui/world_interaction_marker.gd").new()
	add_child(marker)
	refresh()

func refresh() -> void:
	if not guide.started: return
	var hint: Dictionary = guide.hint().duplicate()
	if bindings != null:
		hint.text = hint.text.replace("H ·",bindings.label_for("hp")+" ·").replace("M · Mana",bindings.label_for("mana")+" · Mana").replace("3 ·",bindings.label_for("skill:0")+" ·")
	if hint.title != cached_title:
		cached_title = hint.title
	if hint.text != cached_body:
		cached_body = hint.text
	var at: Vector2 = hint.at-camera
	# Keep Rowan and his touch interaction unobscured by the nearby hint.
	if model.rowan_enabled and hint.at == model.rowan.position:
		at += Vector2(350,-45)
	marker.refresh(Vector2(clampf(at.x,40,800),clampf(at.y-230,198,288)),cached_title+"\n"+cached_body,false,true,"hint")
