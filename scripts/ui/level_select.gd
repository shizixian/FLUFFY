extends Control
## Scrollable grid of level cards with stars; locked ones show a padlock.

signal back
signal pick(level: int)

const Kit = preload("res://scripts/ui/kit.gd")
const StarRow = preload("res://scripts/ui/star_row.gd")

const COLS := 4
const MAX_COLUMN := 760.0

var _col: VBoxContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_fit)
	_build()
	I18n.changed.connect(func():
		for c in get_children():
			c.queue_free()
		_build())


func _build() -> void:
	var ins := Kit.safe_insets(get_viewport())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 18)
	col.anchor_left = 0.5
	col.anchor_right = 0.5
	col.anchor_bottom = 1
	col.offset_left = -MAX_COLUMN / 2.0
	col.offset_right = MAX_COLUMN / 2.0
	col.offset_top = 20 + ins.top
	col.offset_bottom = -ins.bottom
	add_child(col)
	_col = col
	_fit()

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	col.add_child(header)
	var back_btn := Kit.round_button("back", Color("c79a72"), 80)
	back_btn.pressed.connect(func(): back.emit())
	header.add_child(back_btn)
	var title := Kit.outlined(Kit.label(I18n.t("select_level"), 44), Color.WHITE, 10)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var total := Kit.label(I18n.t("total_score", [Save.total_score]), 22, Kit.INK_SOFT)
	var ts := Kit.box(Color(1, 1, 1, 0.75), 22)
	ts.content_margin_left = 16
	ts.content_margin_right = 16
	ts.content_margin_top = 6
	ts.content_margin_bottom = 8
	total.add_theme_stylebox_override("normal", ts)
	header.add_child(total)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	var pad := MarginContainer.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_theme_constant_override("margin_top", 10)
	pad.add_theme_constant_override("margin_bottom", 40)
	pad.add_theme_constant_override("margin_left", 6)
	pad.add_theme_constant_override("margin_right", 6)
	scroll.add_child(pad)
	var grid := GridContainer.new()
	grid.columns = COLS
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 18)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_child(grid)

	var count := maxi(Save.max_level + 8, 24)
	count = int(ceil(count / float(COLS))) * COLS
	var current: Control = null
	for lv in range(1, count + 1):
		var card := _card(lv)
		grid.add_child(card)
		if lv == Save.max_level:
			current = card
	if current:
		_scroll_to.call_deferred(scroll, current)


func _fit() -> void:
	if _col and is_instance_valid(_col):
		var w := minf(size.x - 32.0, MAX_COLUMN)
		_col.offset_left = -w / 2.0
		_col.offset_right = w / 2.0


## Start scrolled so the next level to play is visible.
func _scroll_to(scroll: ScrollContainer, card: Control) -> void:
	await get_tree().process_frame
	if is_instance_valid(scroll) and is_instance_valid(card):
		scroll.scroll_vertical = int(maxf(card.position.y - 200, 0))


func _card(lv: int) -> Control:
	var unlocked := lv <= Save.max_level
	var is_next := lv == Save.max_level
	var b := Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(0, 150)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var color := Kit.GREEN if is_next else (Color("fff6e4") if unlocked else Color("e6d9c8"))
	var st := Kit.candy(color, 28, 8)
	for k in st.keys():
		b.add_theme_stylebox_override(k, st[k])
	b.disabled = not unlocked
	if unlocked:
		Kit.juice(b)
		b.pressed.connect(func(): pick.emit(lv))

	var v := VBoxContainer.new()
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	v.offset_bottom = -8
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 2)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(v)
	if unlocked:
		var num := Kit.label(str(lv), 46, Color.WHITE if is_next else Kit.INK)
		if is_next:
			Kit.outlined(num, Kit.GREEN_DARK, 8)
		v.add_child(num)
		if is_next and Save.stars_for_level(lv) == 0:
			v.add_child(Kit.label(I18n.t("level_new"), 20, Color.WHITE))
		else:
			var stars = StarRow.new(Save.stars_for_level(lv), 26.0)
			stars.custom_minimum_size.y = 32
			v.add_child(stars)
	else:
		v.add_child(Kit.icon_rect(Kit.icon("lock"), 46, Color("b7a58f")))
		v.add_child(Kit.label(str(lv), 22, Color("b7a58f")))
	return b
