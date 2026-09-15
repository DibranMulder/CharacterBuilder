extends SceneTree
## Rendered, fixed-step gameplay benchmark. Run without --headless.
const CASES := [
	["tidekin_landing","res://prototypes/tidekin_sea/tidekin_sea.tscn",0],
	["tidekin_combat","res://prototypes/tidekin_sea/tidekin_sea.tscn",1],
	["wendmere_square","res://prototypes/human_hometown/human_hometown.tscn",0],
	["training_combat","res://prototypes/training_clearing/training_clearing.tscn",0],
	["sparring","res://prototypes/sparring_arena/arena.tscn",0],
]
var results: Array = []
var failed := false
func _initialize() -> void: run.call_deferred()
func run() -> void:
	if DisplayServer.get_name() == "headless":
		printerr("Run with a graphics display to measure rendered frames.")
		quit(2)
		return
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	RenderingServer.render_loop_enabled = false
	seed(12345)
	var arguments := OS.get_cmdline_user_args()
	for spec in CASES:
		if arguments.size() > 1 and spec[0] != arguments[1]: continue
		print("Benchmarking "+spec[0])
		var start := Time.get_ticks_usec()
		var scene = load(spec[1]).instantiate()
		root.add_child(scene)
		scene.set_physics_process(false)
		if scene.get_window().focus_exited.is_connected(scene._lose_focus) if scene.has_method("_lose_focus") else false:
			scene.get_window().focus_exited.disconnect(scene._lose_focus)
		if spec[0] == "tidekin_combat": scene.enter_map(spec[2],false)
		if spec[0] == "training_combat": scene.model.position.x = 650
		if spec[0] != "sparring": scene.model.invulnerable = 999
		else: scene.model.countdown = 0
		await process_frame
		RenderingServer.force_draw(false)
		var load_ms := (Time.get_ticks_usec()-start)/1000.0
		var samples: Array[float] = []
		var updates: Array[float] = []
		var draw_calls: Array[float] = []
		for frame in 120:
			start = Time.get_ticks_usec()
			if spec[0] != "sparring":
				scene.touch_right = frame % 90 < 45
				scene.touch_left = not scene.touch_right
				if frame % 30 == 0: scene._attack(false)
			else:
				scene.held.right = frame % 90 < 45
				scene.held.left = not scene.held.right
				if frame % 30 == 0: scene._attack(-1)
			scene._physics_process(1.0/60)
			var update_ms := (Time.get_ticks_usec()-start)/1000.0
			await process_frame
			RenderingServer.force_draw(false)
			if frame >= 30:
				samples.append((Time.get_ticks_usec()-start)/1000.0)
				updates.append(update_ms)
				draw_calls.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		var row := {"scene":spec[0],"load_ms":load_ms,"frame_ms":stats(samples),"update_ms":stats(updates),"draw_calls":stats(draw_calls),"texture_mb":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)/1048576.0}
		results.append(row)
		print(JSON.stringify(row))
		if row.frame_ms.p95 > 20: failed = true
		scene.queue_free()
		await process_frame
		await process_frame
	var path := "/tmp/character-gameplay-performance.json"
	var args := OS.get_cmdline_user_args()
	if not args.is_empty(): path = args[0]
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify(results,"\t"))
	print("FAIL: at least one scenario exceeds 20ms p95 frame budget" if failed else "PASS: all gameplay scenarios within 20ms p95 frame budget")
	quit(1 if failed else 0)
func stats(values: Array[float]) -> Dictionary:
	values.sort()
	var total := 0.0
	for value in values: total += value
	return {"mean":total/values.size(),"p50":values[values.size()/2],"p95":values[mini(values.size()-1,ceili(values.size()*.95)-1)],"max":values[-1]}
