class_name SlashTrailVisual
extends Node2D

var active := false
var _source: GearVisual
var _samples: Array[Dictionary] = []
var _color := Color("9de7ff")
var _lifetime := 0.24
var _maximum_width := 15.0


func start(source: GearVisual, color := Color("9de7ff"), maximum_width := 15.0) -> void:
	_source = source
	_color = color
	_maximum_width = maximum_width
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
	for index in _samples.size()-1:
		var from_sample: Dictionary = _samples[index]
		var to_sample: Dictionary = _samples[index+1]
		var freshness := clampf(1.0-maxf(float(from_sample.age),float(to_sample.age))/_lifetime,0.0,1.0)
		var outer := _color
		outer.a = freshness*.48
		var inner := Color("fff7d6")
		inner.a = freshness*.82
		var width := lerpf(2.0,_maximum_width,freshness)
		draw_line(from_sample.point,to_sample.point,outer,width,true)
		draw_line(from_sample.point,to_sample.point,inner,maxf(1.0,width*.24),true)
	var flare := Color("fff7d6")
	flare.a = .72
	draw_circle(_samples.back().point,_maximum_width*.22,flare)
