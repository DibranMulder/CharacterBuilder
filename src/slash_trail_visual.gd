class_name SlashTrailVisual
extends Node2D

var active := false
var _source: GearVisual
var _samples: Array[Dictionary] = []
var _color := Color("9de7ff")
var _lifetime := 0.24
var _maximum_width := 15.0
var _thrust_mode := false


func start(source: GearVisual, color := Color("9de7ff"), maximum_width := 15.0, thrust_mode := false) -> void:
	_source = source
	_color = color
	_maximum_width = maximum_width
	_thrust_mode = thrust_mode
	_samples.clear()
	active = true
	_capture_tip()
	queue_redraw()


func stop() -> void:
	active = false


func cancel() -> void:
	active = false
	_source = null
	_samples.clear()
	queue_redraw()


func _process(delta: float) -> void:
	for index in _samples.size():
		_samples[index].age += delta
	while not _samples.is_empty() and float(_samples[0].age) >= _lifetime:
		_samples.pop_front()
	if active and is_instance_valid(_source):
		_capture_tip()
	if not _samples.is_empty():
		queue_redraw()


func _capture_tip() -> void:
	var point := to_local(_source.to_global(_source.reach_endpoint()))
	if _samples.is_empty() or point.distance_to(_samples.back().point) >= 1.5:
		_samples.append({"point":point,"age":0.0})
		if _samples.size() > 24:
			_samples.pop_front()


func _draw() -> void:
	if _samples.size() < 2:
		return
	var newest: Vector2 = _samples.back().point
	if is_instance_valid(_source):
		newest = to_local(_source.to_global(_source.reach_endpoint()))
	var thrust_axis := Vector2.RIGHT
	if _thrust_mode and is_instance_valid(_source):
		var grip := to_local(_source.global_position)
		thrust_axis = (newest-grip).normalized()
	for index in _samples.size()-1:
		var from_sample: Dictionary = _samples[index]
		var to_sample: Dictionary = _samples[index+1]
		var from_point: Vector2 = from_sample.point
		var to_point: Vector2 = to_sample.point
		if _thrust_mode:
			from_point = newest+thrust_axis*thrust_axis.dot(from_point-newest)
			to_point = newest+thrust_axis*thrust_axis.dot(to_point-newest)
		var freshness := clampf(1.0-maxf(float(from_sample.age),float(to_sample.age))/_lifetime,0.0,1.0)
		var outer := _color
		outer.a = freshness*.48
		var inner := Color("fff7d6")
		inner.a = freshness*.82
		var width := lerpf(2.0,_maximum_width,freshness)
		draw_line(from_point,to_point,outer,width,true)
		draw_line(from_point,to_point,inner,maxf(1.0,width*.24),true)
	var latest_sample: Vector2 = _samples.back().point
	if _thrust_mode:
		latest_sample = newest+thrust_axis*thrust_axis.dot(latest_sample-newest)
	if latest_sample.distance_to(newest) > .5:
		var outer_tip := _color
		outer_tip.a = .48
		var inner_tip := Color("fff7d6")
		inner_tip.a = .82
		draw_line(latest_sample,newest,outer_tip,_maximum_width,true)
		draw_line(latest_sample,newest,inner_tip,maxf(1.0,_maximum_width*.24),true)
	var flare := Color("fff7d6")
	flare.a = .72
	draw_circle(newest,_maximum_width*.22,flare)
