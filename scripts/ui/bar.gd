extends Control
## Rounded progress bar that eases toward its target value.

var value := 0.0          # 0..1, displayed
var target := 0.0
var fill_color := Color("6cc25a")
var track_color := Color(0.29, 0.18, 0.13, 0.14)
var shine := true


func set_target(v: float, instant := false) -> void:
	target = clampf(v, 0.0, 1.0)
	if instant:
		value = target
	queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	if absf(value - target) > 0.0005:
		value = lerpf(value, target, minf(1.0, delta * 10.0))
		queue_redraw()


func _draw() -> void:
	var r := size.y / 2.0
	_pill(Rect2(Vector2.ZERO, size), track_color, r)
	if value > 0.002:
		var w := maxf(size.y, size.x * value)
		_pill(Rect2(0, 0, w, size.y), fill_color, r)
		if shine:
			_pill(Rect2(r * 0.6, size.y * 0.18, maxf(w - r * 1.2, 0.0), size.y * 0.22), Color(1, 1, 1, 0.45), size.y * 0.11)


func _pill(rect: Rect2, c: Color, r: float) -> void:
	if rect.size.x <= 0.0:
		return
	r = minf(r, rect.size.x / 2.0)
	draw_circle(rect.position + Vector2(r, rect.size.y / 2.0), r if rect.size.y / 2.0 >= r else rect.size.y / 2.0, c)
	draw_circle(rect.position + Vector2(rect.size.x - r, rect.size.y / 2.0), r if rect.size.y / 2.0 >= r else rect.size.y / 2.0, c)
	if rect.size.x > 2.0 * r:
		draw_rect(Rect2(rect.position.x + r, rect.position.y + (rect.size.y / 2.0 - minf(r, rect.size.y / 2.0)), rect.size.x - 2.0 * r, 2.0 * minf(r, rect.size.y / 2.0)), c)
