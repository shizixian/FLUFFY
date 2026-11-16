extends Control
## Three stars; `filled` of them gold. `pop` scales each star independently so the
## win screen can drop them in one by one.

const Kit = preload("res://scripts/ui/kit.gd")

var filled := 0:
	set(v):
		filled = v
		queue_redraw()
var star_size := 22.0
var gap := 6.0
var empty_color := Color(0.29, 0.18, 0.13, 0.18)
var pop: Array = [1.0, 1.0, 1.0]


func _init(n_filled := 0, px := 22.0) -> void:
	filled = n_filled
	star_size = px
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(px * 3 + gap * 2, px * 1.15)


func set_pop(i: int, v: float) -> void:
	pop[i] = v
	queue_redraw()


func _draw() -> void:
	var total := star_size * 3 + gap * 2
	var x0 := (size.x - total) / 2.0 + star_size / 2.0
	# Middle star sits a little higher and bigger, like a podium.
	for i in 3:
		var big := 1.18 if i == 1 else 1.0
		var c := Vector2(x0 + i * (star_size + gap), size.y / 2.0 - (star_size * 0.12 if i == 1 else 0.0))
		var r: float = star_size * 0.5 * big
		draw_colored_polygon(Kit.star_points(c + Vector2(0, 2), r * 1.12), Color(0.29, 0.18, 0.13, 0.25) if i < filled else Color(0, 0, 0, 0))
		var outline := Kit.star_points(c, r * 1.12)
		draw_colored_polygon(outline, empty_color)
		if i < filled and pop[i] > 0.01:
			var s: float = pop[i]
			draw_colored_polygon(Kit.star_points(c, r * 1.12 * s), Kit.INK)
			draw_colored_polygon(Kit.star_points(c, r * 0.92 * s), Kit.GOLD)
			draw_colored_polygon(Kit.star_points(c + Vector2(-r * 0.12, -r * 0.14) * s, r * 0.42 * s), Color(1, 1, 1, 0.45))
