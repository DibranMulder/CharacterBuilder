extends Control
var value := 0.0
var color := Color("a5573e")

func _draw() -> void:
	draw_style_box(_frame(Color("bba575")),Rect2(Vector2.ZERO,size))
	var fill := Rect2(Vector2.ONE,size-Vector2.ONE*2)
	fill.size.x *= clampf(value/100,0,1)
	draw_rect(fill,color)
	draw_line(Vector2(2,2),Vector2(maxf(2,fill.end.x-1),2),color.lightened(.3),1)

func _frame(fill: Color) -> StyleBoxFlat:
	var frame := StyleBoxFlat.new()
	frame.bg_color = fill
	frame.border_color = Color("79603f")
	frame.set_border_width_all(1)
	frame.set_corner_radius_all(3)
	return frame
