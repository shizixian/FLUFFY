extends Control
## Pill toggle switch with a sliding knob.

signal toggled(on: bool)

const Kit = preload("res://scripts/ui/kit.gd")

var on := true
var _k := 1.0


func _init(start_on := true) -> void:
	on = start_on
	_k = 1.0 if on else 0.0
	custom_minimum_size = Vector2(96, 54)
	mouse_filter = Control.MOUSE_FILTER_STOP
	size_flags_vertical = Control.SIZE_SHRINK_CENTER


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		on = not on
		var tw: Tween = create_tween()
		tw.tween_property(self, "_k", 1.0 if on else 0.0, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_method(func(_v): queue_redraw(), 0.0, 1.0, 0.22)
		Sound.play("click")
		toggled.emit(on)
		accept_event()


func _draw() -> void:
	var h := size.y
	var r := h / 2.0
	var col := Kit.GRAY.lerp(Kit.GREEN, clampf(_k, 0.0, 1.0))
	draw_circle(Vector2(r, r), r, col)
	draw_circle(Vector2(size.x - r, r), r, col)
	draw_rect(Rect2(r, 0, size.x - 2 * r, h), col)
	var x := lerpf(r, size.x - r, _k)
	draw_circle(Vector2(x, r + 2), r - 5, Color(0, 0, 0, 0.15))
	draw_circle(Vector2(x, r), r - 6, Color.WHITE)
