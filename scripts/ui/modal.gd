extends Control
## Dim backdrop + springy card. Fill `body` (a VBoxContainer), then `open(parent)`.

signal closed

const Kit = preload("res://scripts/ui/kit.gd")

var dismissible := true          # back button / backdrop tap closes it
var body: VBoxContainer
var card: PanelContainer
var _dim: ColorRect
var _closing := false
var _in_layout := false
var max_width := 600.0
var on_lang_change: Callable     # rebuilds texts when the language switches


func _init(title := "", card_color: Color = Kit.CREAM) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	_dim = ColorRect.new()
	_dim.color = Color(0.16, 0.09, 0.05, 0.0)
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_dim.gui_input.connect(_on_dim_input)
	add_child(_dim)

	card = PanelContainer.new()
	var st := Kit.box(card_color, 36, 4, Kit.INK, 0)
	st.border_width_bottom = 10
	st.border_color = Color("d8bf9c")
	st.set_border_width_all(0)
	st.border_width_bottom = 10
	st.shadow_size = 18
	st.shadow_offset = Vector2(0, 10)
	st.shadow_color = Color(0.16, 0.09, 0.05, 0.35)
	st.content_margin_left = 36
	st.content_margin_right = 36
	st.content_margin_top = 34
	st.content_margin_bottom = 40
	card.add_theme_stylebox_override("panel", st)
	add_child(card)

	body = VBoxContainer.new()
	body.add_theme_constant_override("separation", 18)
	card.add_child(body)
	if title != "":
		var t := Kit.label(title, 44, Kit.INK)
		body.add_child(t)

	resized.connect(_layout)
	card.minimum_size_changed.connect(func(): _layout.call_deferred())


func _ready() -> void:
	I18n.changed.connect(_on_lang)


func _on_lang() -> void:
	if on_lang_change.is_valid():
		on_lang_change.call()


func clear_body() -> void:
	for c in body.get_children():
		body.remove_child(c)
		c.queue_free()


func open(parent: Node) -> void:
	parent.add_child(self)
	_layout()
	card.pivot_offset = card.size / 2.0
	card.scale = Vector2(0.8, 0.8)
	card.modulate.a = 0.0
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(_dim, "color:a", 0.55, 0.2)
	tw.tween_property(card, "scale", Vector2.ONE, 0.38).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(card, "modulate:a", 1.0, 0.15)
	Sound.play("pop")


func close() -> void:
	if _closing:
		return
	_closing = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(_dim, "color:a", 0.0, 0.16)
	tw.tween_property(card, "scale", Vector2(0.88, 0.88), 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(card, "modulate:a", 0.0, 0.16)
	tw.chain().tween_callback(func():
		closed.emit()
		queue_free())


func is_closing() -> bool:
	return _closing


func _layout() -> void:
	if _in_layout:
		return
	_in_layout = true
	var w := minf(size.x - 48.0, max_width)
	card.custom_minimum_size.x = w
	# Wrapped labels only know their height once they know their width, so the
	# card is sized from its minimum each time that minimum changes.
	card.size = Vector2(w, card.get_combined_minimum_size().y)
	card.position = ((size - card.size) / 2.0).round()
	card.pivot_offset = card.size / 2.0
	_in_layout = false


func _on_dim_input(e: InputEvent) -> void:
	if dismissible and e is InputEventMouseButton and e.pressed:
		close()


## A row of buttons sharing the width.
func add_buttons(buttons: Array) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	for b in buttons:
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(b)
	body.add_child(row)
	return row


func spacer(h := 8.0) -> void:
	var c := Control.new()
	c.custom_minimum_size.y = h
	body.add_child(c)
