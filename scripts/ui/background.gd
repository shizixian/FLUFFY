extends Control
## Soft meadow backdrop: warm sky gradient, clouds, rolling hills.
## Static on purpose: any moving pixel makes Godot repaint the whole screen,
## and on a phone drifting clouds alone tripled idle CPU (13% → 33%).

const SKY_TOP := Color("fff3dc")
const SKY_BOTTOM := Color("f3f7dc")
const HILL_BACK := Color("d9efc0")
const HILL_FRONT := Color("c5e6a6")

var _t := 0.0
var _clouds: Array = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 5:
		_clouds.append({
			"x": rng.randf(), "y": rng.randf_range(0.04, 0.5),
			"s": rng.randf_range(0.7, 1.3), "v": rng.randf_range(0.004, 0.012),
		})


func _draw() -> void:
	var w := size.x
	var h := size.y
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, h), Vector2(0, h)]),
			PackedColorArray([SKY_TOP, SKY_TOP, SKY_BOTTOM, SKY_BOTTOM]))

	# Clouds drift slowly to the right and wrap around.
	for c in _clouds:
		var x := fposmod(c.x + _t * c.v, 1.2) * (w + 240) - 200
		var y: float = c.y * h
		var s: float = c.s * 1.2
		var col := Color(1, 1, 1, 0.55)
		draw_circle(Vector2(x, y), 34 * s, col)
		draw_circle(Vector2(x + 40 * s, y - 14 * s), 42 * s, col)
		draw_circle(Vector2(x + 86 * s, y), 32 * s, col)
		draw_rect(Rect2(x, y - 4 * s, 86 * s, 34 * s), col)

	_hill(h * 0.86, 26.0, 0.006, 0.3, HILL_BACK)
	_hill(h * 0.92, 18.0, 0.009, 1.7, HILL_FRONT)


func _hill(base: float, amp: float, freq: float, phase: float, col: Color) -> void:
	# Drawn as vertical quads: always convex, so triangulation can't fail.
	var w := size.x
	if w < 2.0 or size.y < 2.0:
		return
	var steps := 32
	var prev := Vector2(0, base + sin(phase) * amp)
	for i in range(1, steps + 1):
		var x := w * i / steps
		var cur := Vector2(x, base + sin(x * freq + phase) * amp)
		draw_colored_polygon(PackedVector2Array([prev, cur, Vector2(cur.x, size.y), Vector2(prev.x, size.y)]), col)
		prev = cur
