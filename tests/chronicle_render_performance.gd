extends SceneTree
## The decorated panel must retain its grain without hundreds of draw calls.
class Sample extends Node2D:
	func _draw() -> void:
		draw_style_box(preload("res://src/ui/chronicle_theme.gd").create().get_stylebox("panel","InkPanel"),Rect2(20,20,400,150))
func _initialize() -> void: run.call_deferred()
func run() -> void:
	if DisplayServer.get_name() == "headless":
		print("SKIP: draw-call regression requires a graphics display")
		quit()
		return
	root.add_child(Sample.new())
	for frame in 4: await process_frame
	RenderingServer.force_draw(false)
	var calls := int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	print("Decorated panel: %d draw calls (budget: 30)" % calls)
	print("PASS: panel rendering budget" if calls <= 30 else "FAIL: decorative grain generates excessive draw calls")
	quit(0 if calls <= 30 else 1)
