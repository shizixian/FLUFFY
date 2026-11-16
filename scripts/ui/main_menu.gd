extends Control
## Title screen: cover art, player chip, play / daily / levels, small settings row.

signal play(level: int)
signal daily
signal levels
signal settings
signal about
signal profile

const Kit = preload("res://scripts/ui/kit.gd")

var _cover: TextureRect


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	I18n.changed.connect(_rebuild)


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	_build(false)


func _build(animate := true) -> void:
	_cover = TextureRect.new()
	_cover.texture = load("res://assets/cover.jpg")
	_cover.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cover.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_cover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_cover)
	_cover.resized.connect(func(): _cover.pivot_offset = _cover.size * Vector2(0.5, 0.35))
	var breathe: Tween = _cover.create_tween().set_loops()
	breathe.tween_property(_cover, "scale", Vector2(1.05, 1.05), 9.0).set_trans(Tween.TRANS_SINE)
	breathe.tween_property(_cover, "scale", Vector2.ONE, 9.0).set_trans(Tween.TRANS_SINE)

	# Fade the lower half of the art into a warm cream so the buttons read cleanly.
	var shade := TextureRect.new()
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.97, 0.9, 0.0))
	grad.set_color(1, Color(1.0, 0.95, 0.86, 0.96))
	grad.add_point(0.45, Color(1.0, 0.96, 0.88, 0.55))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	gt.width = 4
	gt.height = 256
	shade.texture = gt
	shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shade.stretch_mode = TextureRect.STRETCH_SCALE
	shade.anchor_left = 0
	shade.anchor_right = 1
	shade.anchor_top = 0.42
	shade.anchor_bottom = 1
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var ins := Kit.safe_insets(get_viewport())

	# ---- avatar (top-left): round, with a level tag; tap to edit the profile.
	# Kept narrow on purpose so it never covers the logo baked into the cover art.
	var chip := PanelContainer.new()
	var cs := Kit.box(Color(1, 1, 1, 0.92), 44, 4, Color.WHITE, 8)
	cs.set_content_margin_all(6)
	chip.add_theme_stylebox_override("panel", cs)
	chip.position = Vector2(20 + ins.left, 16 + ins.top)
	chip.mouse_filter = Control.MOUSE_FILTER_STOP
	chip.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
			var tw: Tween = chip.create_tween()
			tw.tween_property(chip, "scale", Vector2(0.92, 0.92) if e.pressed else Vector2.ONE, 0.12)
			if not e.pressed:
				Sound.play("click")
				profile.emit())
	chip.resized.connect(func(): chip.pivot_offset = chip.size / 2.0)
	add_child(chip)
	chip.add_child(Kit.icon_rect(Kit.avatar_tex(Save.player_avatar), 68))
	var lv_tag := Kit.label("Lv.%d" % Save.max_level, 18, Color.WHITE)
	var ls := Kit.box(Kit.ORANGE, 14, 3, Color.WHITE)
	ls.content_margin_left = 10
	ls.content_margin_right = 10
	ls.content_margin_bottom = 2
	lv_tag.add_theme_stylebox_override("normal", ls)
	lv_tag.position = Vector2(14 + ins.left, 84 + ins.top)
	lv_tag.custom_minimum_size = Vector2(92, 0)
	add_child(lv_tag)

	# ---- settings (top-right)
	var gear := Kit.round_button("gear", Color("c79a72"), 80)
	gear.anchor_left = 1
	gear.anchor_right = 1
	gear.offset_left = -100 - ins.right
	gear.offset_right = -20 - ins.right
	gear.offset_top = 20 + ins.top
	gear.offset_bottom = 100 + ins.top
	gear.pressed.connect(func(): settings.emit())
	add_child(gear)

	# ---- main buttons (bottom)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	col.anchor_left = 0.5
	col.anchor_right = 0.5
	col.anchor_top = 1
	col.anchor_bottom = 1
	col.grow_horizontal = Control.GROW_DIRECTION_BOTH
	col.grow_vertical = Control.GROW_DIRECTION_BEGIN
	col.offset_left = -270
	col.offset_right = 270
	col.offset_bottom = -40 - ins.bottom
	add_child(col)

	var next_level := Save.max_level
	var play_btn := Kit.button("%s  ·  %s" % [I18n.t("btn_start"), I18n.t("btn_play_level", [next_level])],
			Kit.GREEN, Vector2(0, 112), 38, "play", 36)
	play_btn.pressed.connect(func(): play.emit(next_level))
	col.add_child(play_btn)
	var pulse: Tween = play_btn.create_tween().set_loops()
	pulse.tween_property(play_btn, "scale", Vector2(1.03, 1.03), 0.8).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(play_btn, "scale", Vector2.ONE, 0.8).set_trans(Tween.TRANS_SINE)

	var daily_btn := Kit.button(I18n.t("btn_daily"), Kit.PURPLE, Vector2(0, 96), 32, "daily", 32)
	daily_btn.pressed.connect(func(): daily.emit())
	col.add_child(daily_btn)
	var today := Time.get_date_string_from_system()
	var streak := Save.current_streak(today)
	var best := Save.today_best(today)
	if streak > 0 or best > 0:
		var info := []
		if streak > 0:
			info.append(I18n.t("daily_streak", [streak]))
		if best > 0:
			info.append(I18n.t("daily_best", [best]))
		var badge := Kit.label("  ·  ".join(info), 20, Color.WHITE)
		var bs := Kit.box(Kit.PINK, 16, 3, Color.WHITE)
		bs.content_margin_left = 12
		bs.content_margin_right = 12
		bs.content_margin_bottom = 2
		badge.add_theme_stylebox_override("normal", bs)
		daily_btn.add_child(badge)
		badge.anchor_left = 1
		badge.anchor_right = 1
		badge.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		badge.offset_right = -10
		badge.offset_left = -10
		badge.offset_top = -18
		badge.offset_bottom = 16

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	col.add_child(row)
	var lv_btn := Kit.button(I18n.t("select_level"), Kit.ORANGE, Vector2(0, 84), 28, "", 28)
	lv_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lv_btn.pressed.connect(func(): levels.emit())
	row.add_child(lv_btn)
	var about_btn := Kit.round_button("info", Kit.BLUE, 84)
	about_btn.pressed.connect(func(): about.emit())
	row.add_child(about_btn)
	if not OS.has_feature("mobile") and not OS.has_feature("web"):
		var quit := Kit.round_button("close", Kit.RED, 84)
		quit.pressed.connect(func(): get_tree().quit())
		row.add_child(quit)

	var ver := Kit.label("v%s" % ProjectSettings.get_setting("application/config/version", ""), 18, Kit.INK_SOFT, false)
	col.add_child(ver)

	if animate:
		var k := 0
		for c in [play_btn, daily_btn, row]:
			c.modulate.a = 0.0
			var tw: Tween = c.create_tween()
			tw.tween_interval(0.08 + k * 0.08)
			tw.tween_property(c, "modulate:a", 1.0, 0.25)
			k += 1
