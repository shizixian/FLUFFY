extends RefCounted
## Shared look & feel: palette, font, candy buttons, panels, icons.

# ---- palette (warm meadow) ----
const INK := Color("4a2e22")            # outlines / main text
const INK_SOFT := Color("7a5a48")
const CREAM := Color("fff8ec")
const PAPER := Color("fdf1dc")
const SHADOW := Color(0.29, 0.18, 0.13, 0.28)
const GREEN := Color("6cc25a")
const GREEN_DARK := Color("4c9a3f")
const ORANGE := Color("ffaa3b")
const BLUE := Color("5fa8e8")
const PURPLE := Color("a07be0")
const PINK := Color("ff7fa6")
const RED := Color("ef6a5b")
const GOLD := Color("ffc93c")
const BROWN := Color("9b6b4b")
const GRAY := Color("b9aa9b")

# Order = order in which levels introduce them (most distinct first).
const TILE_NAMES := ["sheep", "grass", "carrot", "wolf", "apple", "wheat",
		"rabbit", "flower", "field", "sun", "grapes", "clover"]
# Avatar ids 0-5 match the icons v0.4 saved (sheep, grass, rice, field, rabbit, wolf).
const AVATAR_NAMES := ["sheep", "grass", "wheat", "field", "rabbit", "wolf",
		"carrot", "apple", "flower", "sun", "grapes", "clover"]

static var _font: Font
static var _font_bold: Font
static var _tex_cache := {}
static var _theme: Theme


static func font(bold := true) -> Font:
	if _font == null:
		var names := PackedStringArray(["PingFang SC", "Hiragino Sans GB", "Noto Sans CJK SC",
				"Noto Sans SC", "Source Han Sans SC", "Microsoft YaHei", "sans-serif"])
		var regular := SystemFont.new()
		regular.font_names = names
		regular.font_weight = 500
		regular.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
		_font = regular
		var heavy := SystemFont.new()
		heavy.font_names = names
		heavy.font_weight = 800
		heavy.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
		_font_bold = heavy
	return _font_bold if bold else _font


static func tex(path: String) -> Texture2D:
	if not _tex_cache.has(path):
		_tex_cache[path] = load(path) if ResourceLoader.exists(path) else null
	return _tex_cache[path]


static func tile_tex(type_id: int) -> Texture2D:
	return tex("res://assets/tiles/%s.svg" % TILE_NAMES[clampi(type_id, 0, TILE_NAMES.size() - 1)])


static func avatar_tex(avatar_id: int) -> Texture2D:
	return tex("res://assets/tiles/%s.svg" % AVATAR_NAMES[clampi(avatar_id, 0, AVATAR_NAMES.size() - 1)])


static func icon(name: String) -> Texture2D:
	return tex("res://assets/ui/%s.svg" % name)


# ---------------------------------------------------------------- styles

static func box(bg: Color, radius: int = 24, border: int = 0, border_color: Color = INK,
		shadow: int = 0, shadow_offset := Vector2(0, 4)) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	s.set_border_width_all(border)
	s.border_color = border_color
	if shadow > 0:
		s.shadow_size = shadow
		s.shadow_offset = shadow_offset
		s.shadow_color = SHADOW
	s.anti_aliasing = true
	return s


## Candy style: the darker bottom border is the button's "thickness"; pressing
## squashes it so the face visibly sinks.
static func candy(color: Color, radius: int = 26, depth: int = 7) -> Dictionary:
	var dark := color.darkened(0.28)
	var normal := box(color, radius)
	normal.border_width_bottom = depth
	normal.border_color = dark
	normal.content_margin_left = 22
	normal.content_margin_right = 22
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10 + depth
	normal.shadow_size = 6
	normal.shadow_offset = Vector2(0, 4)
	normal.shadow_color = Color(0.29, 0.18, 0.13, 0.22)
	var hover := normal.duplicate()
	hover.bg_color = color.lightened(0.08)
	var pressed := normal.duplicate()
	pressed.border_width_bottom = 2
	pressed.expand_margin_top = -float(depth - 2)
	pressed.content_margin_top = 10 + depth - 2
	pressed.content_margin_bottom = 12
	pressed.shadow_size = 2
	var disabled := normal.duplicate()
	disabled.bg_color = color.lerp(GRAY, 0.75)
	disabled.border_color = disabled.bg_color.darkened(0.2)
	return {"normal": normal, "hover": hover, "pressed": pressed, "disabled": disabled,
			"focus": StyleBoxEmpty.new()}


static func style_button(b: Button, color: Color, radius: int = 26, font_size: int = 30,
		text_color: Color = Color.WHITE, depth: int = 7) -> void:
	var st := candy(color, radius, depth)
	for k in st.keys():
		b.add_theme_stylebox_override(k, st[k])
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_font_override("font", font(true))
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(k, text_color)
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.75))
	if text_color == Color.WHITE:
		b.add_theme_color_override("font_outline_color", color.darkened(0.4))
		b.add_theme_constant_override("outline_size", 6)
	b.add_theme_color_override("icon_normal_color", text_color)
	b.add_theme_color_override("icon_hover_color", text_color)
	b.add_theme_color_override("icon_pressed_color", text_color)
	b.add_theme_color_override("icon_disabled_color", Color(1, 1, 1, 0.75))
	b.focus_mode = Control.FOCUS_NONE


static func button(text: String, color: Color, min_size := Vector2(0, 92), font_size := 32,
		icon_name := "", radius := 28) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = min_size
	style_button(b, color, radius, font_size)
	if icon_name != "":
		b.icon = icon(icon_name)
		b.expand_icon = false
		b.add_theme_constant_override("icon_max_width", int(font_size * 1.15))
		b.add_theme_constant_override("h_separation", 12)
	juice(b)
	return b


static func round_button(icon_name: String, color: Color, diameter := 84) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(diameter, diameter)
	style_button(b, color, diameter / 2, 24, Color.WHITE, 6)
	for k in ["normal", "hover", "pressed", "disabled"]:
		var s: StyleBoxFlat = b.get_theme_stylebox(k)
		s.content_margin_left = 0
		s.content_margin_right = 0
	b.icon = icon(icon_name)
	b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.expand_icon = false
	b.add_theme_constant_override("icon_max_width", int(diameter * 0.46))
	juice(b)
	return b


## Squash on press, spring back on release, plus a click.
static func juice(c: Control, with_sound := true) -> void:
	var refresh_pivot := func(): c.pivot_offset = c.size / 2.0
	c.resized.connect(refresh_pivot)
	if c is BaseButton:
		var b: BaseButton = c
		b.button_down.connect(func():
			if b.disabled:
				return
			var tw: Tween = b.create_tween()
			tw.tween_property(b, "scale", Vector2(0.93, 0.93), 0.07).set_trans(Tween.TRANS_QUAD))
		b.button_up.connect(func():
			var tw: Tween = b.create_tween()
			tw.tween_property(b, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT))
		if with_sound:
			b.pressed.connect(func(): Sound.play("click"))


static func label(text: String, size := 28, color: Color = INK, bold := true,
		align := HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", font(bold))
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func outlined(l: Label, outline: Color, px: int = 8) -> Label:
	l.add_theme_color_override("font_outline_color", outline)
	l.add_theme_constant_override("outline_size", px)
	return l


static func icon_rect(t: Texture2D, px: int, tint := Color.WHITE) -> TextureRect:
	var r := TextureRect.new()
	r.texture = t
	r.custom_minimum_size = Vector2(px, px)
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.modulate = tint
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


static func make_theme() -> Theme:
	if _theme:
		return _theme
	var t := Theme.new()
	t.default_font = font(false)
	t.default_font_size = 26
	t.set_color("font_color", "Label", INK)

	var le_normal := box(Color.WHITE, 22, 3, INK.lerp(Color.WHITE, 0.55))
	le_normal.content_margin_left = 22
	le_normal.content_margin_right = 22
	le_normal.content_margin_top = 14
	le_normal.content_margin_bottom = 14
	var le_focus := le_normal.duplicate()
	le_focus.border_color = ORANGE
	t.set_stylebox("normal", "LineEdit", le_normal)
	t.set_stylebox("focus", "LineEdit", le_focus)
	t.set_color("font_color", "LineEdit", INK)
	t.set_color("font_placeholder_color", "LineEdit", INK.lerp(Color.WHITE, 0.55))
	t.set_color("caret_color", "LineEdit", ORANGE)
	t.set_font_size("font_size", "LineEdit", 30)
	t.set_font("font", "LineEdit", font(true))

	var track := box(Color("ead8bf"), 10)
	track.content_margin_top = 8
	track.content_margin_bottom = 8
	var fill := box(ORANGE, 10)
	fill.content_margin_top = 8
	fill.content_margin_bottom = 8
	t.set_stylebox("slider", "HSlider", track)
	t.set_stylebox("grabber_area", "HSlider", fill)
	t.set_stylebox("grabber_area_highlight", "HSlider", fill)
	var knob := _circle_texture(34, Color.WHITE, ORANGE.darkened(0.15), 4)
	t.set_icon("grabber", "HSlider", knob)
	t.set_icon("grabber_highlight", "HSlider", knob)
	t.set_icon("grabber_disabled", "HSlider", knob)

	var empty := StyleBoxEmpty.new()
	t.set_stylebox("panel", "ScrollContainer", empty)
	var thin := box(Color(0.29, 0.18, 0.13, 0.25), 4)
	thin.content_margin_left = 3
	thin.content_margin_right = 3
	t.set_stylebox("grabber", "VScrollBar", thin)
	t.set_stylebox("grabber_highlight", "VScrollBar", thin)
	t.set_stylebox("grabber_pressed", "VScrollBar", thin)
	t.set_stylebox("scroll", "VScrollBar", empty)
	_theme = t
	return t


static func _circle_texture(d: int, fill_c: Color, ring: Color, ring_w: int) -> Texture2D:
	var img := Image.create(d, d, false, Image.FORMAT_RGBA8)
	var r := d / 2.0
	for y in d:
		for x in d:
			var dist := Vector2(x + 0.5 - r, y + 0.5 - r).length()
			var a := clampf(r - dist, 0.0, 1.0)
			var c := ring if dist > r - ring_w else fill_c
			img.set_pixel(x, y, Color(c, a))
	return ImageTexture.create_from_image(img)


# ---------------------------------------------------------------- shapes

static func star_points(center: Vector2, outer: float, inner_ratio := 0.48) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for k in 10:
		var r := outer if k % 2 == 0 else outer * inner_ratio
		var a := -PI / 2.0 + k * PI / 5.0
		pts.append(center + Vector2(cos(a), sin(a)) * r)
	return pts


## Safe-area insets in viewport units (mobile only; desktop reports the work area).
static func safe_insets(vp: Viewport) -> Dictionary:
	var out := {"top": 0.0, "bottom": 0.0, "left": 0.0, "right": 0.0}
	if not OS.has_feature("mobile"):
		return out
	var win := DisplayServer.window_get_size()
	if win.x <= 0 or win.y <= 0:
		return out
	var safe := DisplayServer.get_display_safe_area()
	var vis := vp.get_visible_rect().size
	var sx := vis.x / win.x
	var sy := vis.y / win.y
	out.top = maxf(safe.position.y, 0) * sy
	out.left = maxf(safe.position.x, 0) * sx
	out.bottom = maxf(win.y - safe.end.y, 0) * sy
	out.right = maxf(win.x - safe.end.x, 0) * sx
	return out
