extends Node2D
## One tile, drawn in code: drop shadow, side "thickness", cream face, icon.
## Animatable properties redraw themselves: lift (selection), shade (covered),
## glow (hint pulse), flip (shuffle squash).

const Kit = preload("res://scripts/ui/kit.gd")

const W := 86.0
const H := 96.0
const DEPTH := 10.0
const ICON := 70.0

static var _face: StyleBoxFlat
static var _side: StyleBoxFlat
static var _shadow: StyleBoxFlat
static var _sel: StyleBoxFlat
static var _glow: StyleBoxFlat
static var _shade_box: StyleBoxFlat

var type_id := 0
var index := -1                      # board index, -1 for tray tiles
var texture: Texture2D

var lift := 0.0:
	set(v):
		lift = v
		queue_redraw()
var shade := 0.0:
	set(v):
		shade = v
		queue_redraw()
var glow := 0.0:
	set(v):
		glow = v
		queue_redraw()
var selected := false:
	set(v):
		selected = v
		queue_redraw()


static func _styles() -> void:
	if _face:
		return
	_face = Kit.box(Color("fffaf0"), 16, 3, Color("8d6a55"))
	_side = Kit.box(Color("e9cfa6"), 16, 3, Color("8d6a55"))
	_shadow = Kit.box(Color(0.29, 0.18, 0.13, 0.20), 18)
	_sel = Kit.box(Color(0, 0, 0, 0), 20, 6, Kit.GOLD)
	_glow = Kit.box(Color(1.0, 0.93, 0.55, 0.0), 22, 0)
	_shade_box = Kit.box(Color(0.24, 0.16, 0.11, 1.0), 16)


func setup(t: int, idx: int) -> void:
	type_id = t
	index = idx
	texture = Kit.tile_tex(t)
	queue_redraw()


func set_type(t: int) -> void:
	setup(t, index)


func _ready() -> void:
	_styles()


func _draw() -> void:
	_styles()
	var face := Rect2(-W / 2.0, -H / 2.0 - lift, W, H)
	var side := Rect2(face.position + Vector2(0, DEPTH), face.size)

	var sh := Rect2(-W / 2.0 + 3, -H / 2.0 + DEPTH + 5, W, H)
	draw_style_box(_shadow, sh.grow(lift * 0.15))

	if glow > 0.0:
		_glow.bg_color.a = 0.75 * glow
		draw_style_box(_glow, Rect2(face.position, face.size + Vector2(0, DEPTH)).grow(10.0 * glow + 2))

	draw_style_box(_side, side)
	draw_style_box(_face, face)
	# Thin highlight under the top edge makes the face read as slightly domed.
	draw_line(face.position + Vector2(16, 7), face.position + Vector2(W - 16, 7), Color(1, 1, 1, 0.9), 3.0, true)

	if texture:
		var r := Rect2(-ICON / 2.0, -ICON / 2.0 - lift - 2, ICON, ICON)
		draw_texture_rect(texture, r, false)

	if shade > 0.001:
		_shade_box.bg_color.a = 0.42 * shade
		draw_style_box(_shade_box, Rect2(face.position, face.size + Vector2(0, DEPTH)))

	if selected:
		draw_style_box(_sel, Rect2(face.position, face.size + Vector2(0, DEPTH)).grow(5))


## Local-space hit rectangle (face plus thickness).
func hit_rect() -> Rect2:
	return Rect2(-W / 2.0, -H / 2.0, W, H + DEPTH)
