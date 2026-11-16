extends Node2D
## Self-freeing particle burst (sparkles, puffs, confetti) drawn in one node.

const Kit = preload("res://scripts/ui/kit.gd")

var _parts: Array = []
var gravity := 900.0


static func sparkle(parent: Node, at: Vector2, colors: Array, count := 14, speed := 380.0) -> Node2D:
	var b = load("res://scripts/game/burst.gd").new()
	b.position = at
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in count:
		var a := rng.randf() * TAU
		var v := Vector2(cos(a), sin(a)) * rng.randf_range(speed * 0.35, speed)
		b._parts.append({
			"p": Vector2.ZERO, "v": v + Vector2(0, -120), "life": 0.0,
			"max": rng.randf_range(0.45, 0.8), "size": rng.randf_range(7, 14),
			"color": colors[i % colors.size()], "kind": "star" if i % 3 == 0 else "dot",
			"rot": rng.randf() * TAU, "spin": rng.randf_range(-8, 8),
		})
	b.gravity = 700.0
	parent.add_child(b)
	return b


static func confetti(parent: Node, width: float, top: float, count := 90) -> Node2D:
	var b = load("res://scripts/game/burst.gd").new()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var cols := [Kit.PINK, Kit.GOLD, Kit.GREEN, Kit.BLUE, Kit.PURPLE, Kit.ORANGE]
	for i in count:
		b._parts.append({
			"p": Vector2(rng.randf() * width, top - rng.randf() * 400), "v": Vector2(rng.randf_range(-60, 60), rng.randf_range(120, 320)),
			"life": 0.0, "max": rng.randf_range(2.4, 3.6), "size": rng.randf_range(10, 18),
			"color": cols[i % cols.size()], "kind": "paper", "rot": rng.randf() * TAU, "spin": rng.randf_range(-6, 6),
		})
	b.gravity = 60.0
	parent.add_child(b)
	return b


func _process(delta: float) -> void:
	var alive := false
	for q in _parts:
		q.life += delta
		if q.life >= q.max:
			continue
		alive = true
		q.v.y += gravity * delta
		if q.kind == "paper":
			q.v.x += sin(q.life * 4.0 + q.rot) * 40.0 * delta
		else:
			q.v *= 1.0 - 2.2 * delta
		q.p += q.v * delta
		q.rot += q.spin * delta
	queue_redraw()
	if not alive:
		queue_free()


func _draw() -> void:
	for q in _parts:
		if q.life >= q.max:
			continue
		var k: float = q.life / q.max
		var a := 1.0 - k * k
		var c: Color = q.color
		c.a = a
		match q.kind:
			"star":
				var pts := Kit.star_points(Vector2.ZERO, q.size * (1.0 - 0.4 * k))
				draw_set_transform(q.p, q.rot, Vector2.ONE)
				draw_colored_polygon(pts, c)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"dot":
				draw_circle(q.p, q.size * 0.5 * (1.0 - 0.6 * k), c)
			"paper":
				draw_set_transform(q.p, q.rot, Vector2(1.0, absf(sin(q.life * 6.0 + q.rot)) * 0.8 + 0.2))
				draw_rect(Rect2(-q.size / 2.0, -q.size / 4.0, q.size, q.size / 2.0), c)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
