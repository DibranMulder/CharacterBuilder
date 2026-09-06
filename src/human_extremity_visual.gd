class_name HumanExtremityVisual
extends Node2D

var part := "hand_open"
var skin := Color("f0bd91")


func _ready() -> void:
	material = HumanPaintedAtlas.paint_material()


func _draw() -> void:
	var bounds := Rect2(-6, -9, 21, 18)
	if part == "foot":
		bounds = Rect2(-5, -7, 22, 15)
	elif part != "hand_open":
		bounds = Rect2(-6, -7, 17, 14)
	draw_texture_rect(HumanPaintedAtlas.texture(part), bounds, false)
