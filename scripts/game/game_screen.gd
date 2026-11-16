extends Control
## One run of the game: board, HUD, tray, power-ups, win / stuck dialogs.
## GameState holds the rules; this node only turns its changes into motion.

signal request_menu
signal request_settings
signal request_level(level: int)
signal request_daily

const Kit = preload("res://scripts/ui/kit.gd")
const Layouts = preload("res://scripts/core/layouts.gd")
const GameState = preload("res://scripts/core/game_state.gd")
const TileView = preload("res://scripts/game/tile_view.gd")
const Burst = preload("res://scripts/game/burst.gd")
const Modal = preload("res://scripts/ui/modal.gd")
const StarRow = preload("res://scripts/ui/star_row.gd")
const Bar = preload("res://scripts/ui/bar.gd")

const HX := 45.0                 # half-tile pitch, x
const HY := 50.0                 # half-tile pitch, y
const LAYER_OFF := Vector2(-4, -10)
const MAX_COLUMN := 760.0
const SLOT_SCALE := 0.92
const PROP_COLORS := {"hint": Color("ffb630"), "undo": Color("5fa8e8"), "park": Color("6cc25a"), "shuffle": Color("a07be0")}

var state = GameState.new()
var rng := RandomNumberGenerator.new()
var is_daily := false
var level := 1
var daily_date := ""

var elapsed := 0.0
var running := false
var paused := false
var finished := false

var sel_tile := -1
var sel_slot := -1
var tile_nodes := {}             # board index → TileView
var slot_nodes: Array = [null, null, null]
var _shade_target := {}
var _shown_score := 0.0
var _last_action_ms := 0
var _no_move_warned := false
var _last_locked_toast := -10000
var _modal: Control

# nodes
var _column: VBoxContainer
var _board_area: Control
var _tiles_root: Node2D
var _fx: Node2D
var _text_layer: Control
var _title: Label
var _timer_lbl: Label
var _score_lbl: Label
var _score_cap: Label
var _progress
var _progress_lbl: Label
var _combo_bar
var _tip: Label
var _slot_holders: Array = []
var _tray_label: Label
var _props := {}                 # name → {btn, badge, label}
var _toast: Label
var _toast_tw: Tween
var _combo_lbl: Label
var _pause_btn: Button


func setup(daily: bool, lv: int) -> void:
	is_daily = daily
	level = lv


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	I18n.changed.connect(_refresh_texts)
	resized.connect(_layout)
	_layout()
	_start_run()


# ================================================================ build

func _build_ui() -> void:
	_column = VBoxContainer.new()
	_column.add_theme_constant_override("separation", 0)
	_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_column)

	# ---- top HUD
	var top := VBoxContainer.new()
	top.add_theme_constant_override("separation", 10)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_column.add_child(top)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(row)

	_pause_btn = Kit.round_button("pause", Color("c79a72"), 80)
	_pause_btn.pressed.connect(_open_pause)
	row.add_child(_pause_btn)

	var mid := VBoxContainer.new()
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.add_theme_constant_override("separation", -4)
	mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(mid)
	_title = Kit.outlined(Kit.label("", 40, Kit.INK), Color(1, 1, 1, 0.9), 10)
	mid.add_child(_title)
	_timer_lbl = Kit.label("00:00", 24, Kit.INK_SOFT)
	mid.add_child(_timer_lbl)

	var score_box := PanelContainer.new()
	var sb := Kit.box(Color(1, 1, 1, 0.75), 24)
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 4
	sb.content_margin_bottom = 6
	score_box.add_theme_stylebox_override("panel", sb)
	score_box.custom_minimum_size = Vector2(150, 0)
	score_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(score_box)
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", -6)
	sv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	score_box.add_child(sv)
	_score_cap = Kit.label("", 18, Kit.INK_SOFT)
	sv.add_child(_score_cap)
	_score_lbl = Kit.label("0", 36, Color("e0782f"))
	sv.add_child(_score_lbl)

	var prow := HBoxContainer.new()
	prow.add_theme_constant_override("separation", 12)
	prow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(prow)
	_progress = Bar.new()
	_progress.custom_minimum_size = Vector2(0, 20)
	_progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_progress.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	prow.add_child(_progress)
	_progress_lbl = Kit.label("", 20, Kit.INK_SOFT)
	_progress_lbl.custom_minimum_size = Vector2(76, 0)
	prow.add_child(_progress_lbl)

	_combo_bar = Bar.new()
	_combo_bar.custom_minimum_size = Vector2(0, 8)
	_combo_bar.fill_color = Kit.ORANGE
	_combo_bar.shine = false
	_combo_bar.track_color = Color(0, 0, 0, 0)
	_combo_bar.modulate.a = 0.0
	top.add_child(_combo_bar)

	_tip = Kit.label("", 22, Kit.INK_SOFT)
	_tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	top.add_child(_tip)

	# ---- board
	_board_area = Control.new()
	_board_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_board_area.mouse_filter = Control.MOUSE_FILTER_STOP
	_board_area.gui_input.connect(_on_board_input)
	_board_area.resized.connect(_fit_board)
	_column.add_child(_board_area)
	_tiles_root = Node2D.new()
	_board_area.add_child(_tiles_root)

	# ---- bottom: tray + power-ups
	var bottom := VBoxContainer.new()
	bottom.add_theme_constant_override("separation", 14)
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_column.add_child(bottom)

	var tray := PanelContainer.new()
	var ts := Kit.box(Color("efd9b6"), 30)
	ts.border_width_bottom = 8
	ts.border_color = Color("d4b48a")
	ts.content_margin_left = 22
	ts.content_margin_right = 22
	ts.content_margin_top = 8
	ts.content_margin_bottom = 12
	tray.add_theme_stylebox_override("panel", ts)
	tray.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	tray.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.add_child(tray)
	var tv := VBoxContainer.new()
	tv.add_theme_constant_override("separation", 4)
	tv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tray.add_child(tv)
	_tray_label = Kit.label("", 18, Color("a07c5c"))
	tv.add_child(_tray_label)
	var slots_row := HBoxContainer.new()
	slots_row.add_theme_constant_override("separation", 16)
	slots_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tv.add_child(slots_row)
	for s in GameState.SLOT_COUNT:
		var holder := Panel.new()
		holder.custom_minimum_size = Vector2(98, 112)
		var hs := Kit.box(Color("dcc19b"), 18)
		hs.border_width_top = 5
		hs.border_color = Color("c9a87e")
		holder.add_theme_stylebox_override("panel", hs)
		holder.mouse_filter = Control.MOUSE_FILTER_STOP
		holder.gui_input.connect(_on_slot_input.bind(s))
		slots_row.add_child(holder)
		_slot_holders.append(holder)

	var props_row := HBoxContainer.new()
	props_row.alignment = BoxContainer.ALIGNMENT_CENTER
	props_row.add_theme_constant_override("separation", 22)
	props_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.add_child(props_row)
	for name in ["hint", "undo", "park", "shuffle"]:
		props_row.add_child(_make_prop(name))

	# ---- overlays
	_fx = Node2D.new()
	_fx.z_index = 50
	add_child(_fx)
	_text_layer = Control.new()
	_text_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_text_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_text_layer)

	_toast = Kit.label("", 26, Color.WHITE)
	var tst := Kit.box(Color(0.24, 0.15, 0.1, 0.86), 30)
	tst.content_margin_left = 28
	tst.content_margin_right = 28
	tst.content_margin_top = 12
	tst.content_margin_bottom = 12
	_toast.add_theme_stylebox_override("normal", tst)
	_toast.modulate.a = 0.0
	_toast.autowrap_mode = TextServer.AUTOWRAP_OFF
	_text_layer.add_child(_toast)

	_refresh_texts()


func _make_prop(name: String) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon_name: String = {"hint": "hint", "undo": "undo", "park": "park", "shuffle": "shuffle"}[name]
	var btn := Kit.round_button(icon_name, PROP_COLORS[name], 96)
	btn.pressed.connect(_on_prop.bind(name))
	box.add_child(btn)
	var badge := Kit.label("3", 20, Color.WHITE)
	var bs := Kit.box(Kit.RED, 16, 3, Color.WHITE)
	bs.content_margin_left = 9
	bs.content_margin_right = 9
	bs.content_margin_top = 0
	bs.content_margin_bottom = 1
	badge.add_theme_stylebox_override("normal", bs)
	badge.position = Vector2(64, -6)
	badge.custom_minimum_size = Vector2(36, 34)
	btn.add_child(badge)
	var lbl := Kit.label("", 21, Kit.INK_SOFT)
	box.add_child(lbl)
	_props[name] = {"btn": btn, "badge": badge, "label": lbl}
	return box


func _refresh_texts() -> void:
	_title.text = I18n.t("daily_title") if is_daily else I18n.t("lbl_level", [level])
	_score_cap.text = I18n.t("lbl_score")
	_tray_label.text = I18n.t("tray_label")
	for name in _props.keys():
		_props[name].label.text = I18n.t("prop_" + ("moveout" if name == "park" else name))
	_tip.text = ""
	if not is_daily and level <= 3:
		_tip.text = I18n.t("tip_%d" % level)
	_tip.visible = _tip.text != ""


func _layout() -> void:
	var ins := Kit.safe_insets(get_viewport())
	var w := minf(size.x - 32.0 - ins.left - ins.right, MAX_COLUMN)
	_column.position = Vector2((size.x - w) / 2.0, 14.0 + ins.top)
	_column.size = Vector2(w, size.y - 14.0 - ins.top - 20.0 - ins.bottom)


# ================================================================ run lifecycle

func _start_run() -> void:
	finished = false
	running = false
	paused = false
	elapsed = 0.0
	sel_tile = -1
	sel_slot = -1
	_no_move_warned = false
	for n in _tiles_root.get_children():
		n.queue_free()
	for s in slot_nodes.size():
		if slot_nodes[s]:
			slot_nodes[s].queue_free()
		slot_nodes[s] = null
	tile_nodes.clear()
	_shade_target.clear()

	var cfg: Dictionary
	var gen_rng := RandomNumberGenerator.new()
	var lv_points := level
	if is_daily:
		daily_date = Time.get_date_string_from_system()
		cfg = Layouts.daily_config()
		gen_rng.seed = hash("fluffy-daily-" + daily_date)
		lv_points = 9
	else:
		cfg = Layouts.config_for_level(level)
		gen_rng.randomize()
	rng.randomize()
	var ok: bool = state.start(Layouts.build(cfg.index, cfg.mirror), cfg.types, lv_points, gen_rng)
	if not ok:
		push_error("board generation failed for %s" % str(cfg))
	_shown_score = 0.0
	_score_lbl.text = "0"
	_progress.set_target(0.0, true)
	_refresh_texts()

	# Draw order: lower layers first, then top-to-bottom rows.
	var order: Array = range(state.tiles.size())
	order.sort_custom(func(a, b): return _order_key(a) < _order_key(b))
	for k in order.size():
		var i: int = order[k]
		var node := _make_tile(i)
		_tiles_root.add_child(node)
		tile_nodes[i] = node
		var target := node.position
		node.position = target + Vector2(0, -70)
		node.modulate.a = 0.0
		node.scale = Vector2(0.7, 0.7)
		var tw: Tween = node.create_tween().set_parallel(true)
		var d := 0.15 + k * 0.014
		tw.tween_property(node, "position", target, 0.42).set_delay(d).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(node, "modulate:a", 1.0, 0.2).set_delay(d)
		tw.tween_property(node, "scale", Vector2.ONE, 0.36).set_delay(d).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		if k % 4 == 0:
			get_tree().create_timer(d + 0.1).timeout.connect(func(): Sound.play("deal", 0.9 + randf() * 0.3, -6.0))
	_fit_board()
	_sync(true)
	var deal_time := 0.15 + order.size() * 0.014 + 0.4
	get_tree().create_timer(deal_time).timeout.connect(func():
		if is_instance_valid(self) and not finished:
			running = true
			_last_action_ms = Time.get_ticks_msec())


func _order_key(i: int) -> int:
	var t: Dictionary = state.tiles[i]
	return t.z * 100000 + t.y * 100 + t.x


func _tile_pos(i: int) -> Vector2:
	var t: Dictionary = state.tiles[i]
	return Vector2(t.x * HX + TileView.W / 2.0, t.y * HY + TileView.H / 2.0) + LAYER_OFF * t.z


func _make_tile(i: int) -> Node2D:
	var node = TileView.new()
	node.setup(state.tiles[i].type, i)
	node.position = _tile_pos(i)
	node.set_meta("key", _order_key(i))
	return node


func _fit_board() -> void:
	if state.tiles.is_empty() or _board_area.size.x <= 0:
		return
	var r := Rect2()
	var first := true
	for i in state.tiles.size():
		var p := _tile_pos(i)
		var tr := Rect2(p - Vector2(TileView.W, TileView.H) / 2.0, Vector2(TileView.W, TileView.H + TileView.DEPTH + 6))
		r = tr if first else r.merge(tr)
		first = false
	r = r.grow(8)
	var avail := _board_area.size - Vector2(8, 24)
	var s := minf(minf(avail.x / r.size.x, avail.y / r.size.y), 1.6)
	_tiles_root.scale = Vector2(s, s)
	_tiles_root.position = _board_area.size / 2.0 - r.get_center() * s


func _process(delta: float) -> void:
	if running and not paused and not finished:
		elapsed += delta
		var secs := int(elapsed)
		_timer_lbl.text = "%02d:%02d" % [secs / 60, secs % 60]
		# Gentle onboarding: on the first two levels, idle players get a free nudge.
		if not is_daily and level <= 2 and Time.get_ticks_msec() - _last_action_ms > 9000:
			_last_action_ms = Time.get_ticks_msec()
			var h: Array = state.find_hint()
			if not h.is_empty():
				_pulse_refs(h, false)

	if absf(_shown_score - state.score) > 0.5:
		_shown_score = lerpf(_shown_score, state.score, minf(1.0, delta * 9.0))
		_score_lbl.text = str(int(round(_shown_score)))

	var since: int = Time.get_ticks_msec() - state.last_clear_ms
	if state.combo >= 1 and since < GameState.COMBO_WINDOW_MS and not finished:
		_combo_bar.set_target(1.0 - float(since) / GameState.COMBO_WINDOW_MS, true)
		_combo_bar.modulate.a = minf(1.0, _combo_bar.modulate.a + delta * 6.0)
	elif _combo_bar.modulate.a > 0.0:
		_combo_bar.modulate.a = maxf(0.0, _combo_bar.modulate.a - delta * 4.0)


# ================================================================ input

func _on_board_input(e: InputEvent) -> void:
	if not (e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT):
		return
	if not _can_play():
		return
	var p: Vector2 = _tiles_root.get_global_transform().affine_inverse() * (_board_area.get_global_transform() * e.position)
	var kids := _tiles_root.get_children()
	for k in range(kids.size() - 1, -1, -1):
		var n = kids[k]
		if n.is_queued_for_deletion() or not tile_nodes.has(n.index) or tile_nodes[n.index] != n:
			continue
		if n.hit_rect().has_point(n.transform.affine_inverse() * p):
			_tap_tile(n.index)
			return
	if sel_tile >= 0 or sel_slot >= 0:
		_clear_selection(true)


func _on_slot_input(e: InputEvent, s: int) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT and _can_play():
		_tap_slot(s)


func _can_play() -> bool:
	return running and not paused and not finished and _modal == null


func _tap_tile(i: int) -> void:
	_last_action_ms = Time.get_ticks_msec()
	if not state.is_free(i):
		_shake(tile_nodes[i], 4.0)
		Sound.play("locked")
		if Time.get_ticks_msec() - _last_locked_toast > 2500:
			_last_locked_toast = Time.get_ticks_msec()
			toast(I18n.t("msg_locked"))
		return

	if sel_slot >= 0:
		var s := sel_slot
		if state.slots[s] == state.tiles[i].type:
			_clear_selection(false)
			_do_tile_slot(i, s)
		else:
			_wrong(slot_nodes[s])
			_clear_selection(false)
			_select_tile(i)
		return

	if sel_tile == -1:
		_select_tile(i)
	elif sel_tile == i:
		_clear_selection(true)
	elif state.tiles[sel_tile].type == state.tiles[i].type:
		var a := sel_tile
		_clear_selection(false)
		_do_match(a, i)
	else:
		_wrong(tile_nodes[sel_tile])
		_clear_selection(false)
		_select_tile(i)


func _tap_slot(s: int) -> void:
	_last_action_ms = Time.get_ticks_msec()
	if state.slots[s] == -1:
		return
	if sel_tile >= 0:
		var i := sel_tile
		if state.tiles[i].type == state.slots[s]:
			_clear_selection(false)
			_do_tile_slot(i, s)
		else:
			_wrong(tile_nodes[i])
			_clear_selection(false)
			_select_slot(s)
		return
	if sel_slot == s:
		_clear_selection(true)
	else:
		_clear_selection(false)
		_select_slot(s)


func _select_tile(i: int) -> void:
	sel_tile = i
	var n = tile_nodes[i]
	n.selected = true
	_tween_lift(n, 14.0)
	Sound.play("select")
	Sound.vibrate(10)


func _select_slot(s: int) -> void:
	sel_slot = s
	var n = slot_nodes[s]
	if n:
		n.selected = true
		_tween_lift(n, 10.0)
	Sound.play("select")


func _clear_selection(with_sound: bool) -> void:
	if sel_tile >= 0 and tile_nodes.has(sel_tile):
		var n = tile_nodes[sel_tile]
		n.selected = false
		_tween_lift(n, 0.0)
	if sel_slot >= 0 and slot_nodes[sel_slot]:
		var m = slot_nodes[sel_slot]
		m.selected = false
		_tween_lift(m, 0.0)
	if with_sound and (sel_tile >= 0 or sel_slot >= 0):
		Sound.play("deselect")
	sel_tile = -1
	sel_slot = -1


# ================================================================ actions

func _do_match(a: int, b: int) -> void:
	var res: Dictionary = state.match_tiles(a, b, Time.get_ticks_msec())
	if not res.ok:
		return
	var na = _detach_tile(a)
	var nb = _detach_tile(b)
	_fly_together(na, nb, res.gain, res.combo)
	_after_action()


func _do_tile_slot(i: int, s: int) -> void:
	var res: Dictionary = state.match_tile_with_slot(i, s, Time.get_ticks_msec())
	if not res.ok:
		return
	var nt = _detach_tile(i)
	var ns = slot_nodes[s]
	slot_nodes[s] = null
	if ns:
		ns.reparent(_fx, true)
	_fly_together(nt, ns, res.gain, res.combo)
	_after_action()


func _do_park() -> void:
	if state.moveouts <= 0:
		_deny("park", I18n.t("msg_charges_empty"))
		return
	if sel_tile < 0:
		_deny("park", I18n.t("msg_pick_tile"))
		return
	if state.first_empty_slot() < 0:
		_deny("park", I18n.t("msg_slots_full"))
		return
	var i := sel_tile
	_clear_selection(false)
	var res: Dictionary = state.move_to_slot(i, Time.get_ticks_msec())
	if not res.ok:
		return
	var s: int = res.slot
	var n = _detach_tile(i)
	slot_nodes[s] = n
	var holder: Control = _slot_holders[s]
	var dest := holder.get_global_transform() * (holder.size / 2.0)
	var tw: Tween = n.create_tween().set_parallel(true)
	tw.tween_property(n, "global_position", dest, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(n, "global_scale", Vector2(SLOT_SCALE, SLOT_SCALE), 0.32)
	tw.tween_property(n, "rotation", TAU, 0.32).set_trans(Tween.TRANS_QUAD)
	tw.chain().tween_callback(func():
		n.rotation = 0.0
		if slot_nodes[s] == n:
			n.reparent(holder, true)
			n.position = holder.size / 2.0
			n.scale = Vector2(SLOT_SCALE, SLOT_SCALE)
		Sound.play("slot"))
	Sound.play("select", 0.8)
	var pair: Array = res.pair
	if not pair.is_empty():
		var o: int = pair[0] if pair[0] != s else pair[1]
		var other = slot_nodes[o]
		slot_nodes[o] = null
		slot_nodes[s] = null
		var gain: int = res.gain
		var combo: int = res.combo
		get_tree().create_timer(0.34).timeout.connect(func():
			if other:
				other.reparent(_fx, true)
			if is_instance_valid(n) and n.get_parent() != _fx:
				n.reparent(_fx, true)
			_fly_together(n, other, gain, combo))
	_after_action()


func _do_hint() -> void:
	if state.hints <= 0:
		_deny("hint", I18n.t("msg_charges_empty"))
		return
	if state.find_hint().is_empty():
		_deny("hint", I18n.t("msg_hint_none"))
		return
	var h: Array = state.use_hint()
	_clear_selection(false)
	_pulse_refs(h, true)
	Sound.play("hint")
	_after_action()


func _do_undo() -> void:
	if state.undos <= 0:
		_deny("undo", I18n.t("msg_charges_empty"))
		return
	if state.history.is_empty():
		_deny("undo", I18n.t("msg_undo_empty"))
		return
	_clear_selection(false)
	state.undo()
	Sound.play("undo")
	_reconcile()
	_after_action()


func _do_shuffle() -> void:
	if state.shuffles <= 0:
		_deny("shuffle", I18n.t("msg_charges_empty"))
		return
	_clear_selection(false)
	if not state.shuffle(rng):
		return
	Sound.play("shuffle")
	toast(I18n.t("msg_shuffled"))
	var k := 0
	for i in tile_nodes.keys():
		var n = tile_nodes[i]
		var t: int = state.tiles[i].type
		var tw: Tween = n.create_tween()
		var d := k * 0.01
		tw.tween_property(n, "scale:x", 0.0, 0.12).set_delay(d)
		tw.tween_callback(func(): n.set_type(t))
		tw.tween_property(n, "scale:x", 1.0, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		k += 1
	_after_action()


func _on_prop(name: String) -> void:
	if not _can_play():
		return
	_last_action_ms = Time.get_ticks_msec()
	match name:
		"hint": _do_hint()
		"undo": _do_undo()
		"park": _do_park()
		"shuffle": _do_shuffle()


func _deny(prop: String, msg: String) -> void:
	toast(msg)
	Sound.play("locked")
	_shake(_props[prop].btn, 6.0)


## After every state change: shading, HUD, then win / stuck / no-pair checks.
func _after_action() -> void:
	_sync(false)
	if state.is_won():
		_finish_win()
		return
	if state.is_stuck():
		_finish_stuck()
		return
	if not state.has_move():
		if not _no_move_warned:
			_no_move_warned = true
			toast(I18n.t("msg_no_pairs"), 2.4)
			for name in _usable_props():
				_pulse_button(_props[name].btn)
	else:
		_no_move_warned = false


func _usable_props() -> Array:
	var out: Array = []
	if state.can_moveout():
		out.append("park")
	if state.can_shuffle():
		out.append("shuffle")
	if state.can_undo():
		out.append("undo")
	return out


# ================================================================ visuals

func _sync(initial: bool) -> void:
	for i in tile_nodes.keys():
		var n = tile_nodes[i]
		var target := 0.0 if state.is_free(i) else 1.0
		var prev = _shade_target.get(i, -1.0)
		if prev == target:
			continue
		_shade_target[i] = target
		if initial:
			n.shade = target
			continue
		var tw: Tween = n.create_tween()
		tw.tween_property(n, "shade", target, 0.25)
		if target == 0.0 and prev == 1.0:
			# Newly uncovered: a little hop says "you can take me now".
			var hop: Tween = n.create_tween()
			hop.tween_property(n, "lift", 8.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			hop.tween_property(n, "lift", 0.0, 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	_progress.set_target(float(state.cleared()) / maxf(state.total_tiles, 1))
	_progress_lbl.text = "%d/%d" % [state.cleared(), state.total_tiles]
	var counts := {"hint": state.hints, "undo": state.undos, "park": state.moveouts, "shuffle": state.shuffles}
	for name in _props.keys():
		var p: Dictionary = _props[name]
		var c: int = counts[name]
		p.badge.text = str(c)
		var bst: StyleBoxFlat = p.badge.get_theme_stylebox("normal")
		bst.bg_color = Kit.RED if c > 0 else Kit.GRAY
		p.btn.modulate = Color.WHITE if c > 0 else Color(1, 1, 1, 0.55)


func _detach_tile(i: int) -> Node2D:
	var n = tile_nodes[i]
	tile_nodes.erase(i)
	_shade_target.erase(i)
	n.selected = false
	n.shade = 0.0
	n.reparent(_fx, true)
	return n


func _fly_together(a: Node2D, b: Node2D, gain: int, combo: int) -> void:
	if a == null or b == null:
		return
	var pa := a.global_position
	var pb := b.global_position
	var mid := (pa + pb) / 2.0
	var dir := (pb - pa).normalized()
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT
	var gap: float = TileView.W * 0.5 * a.global_scale.x
	var dist := pa.distance_to(pb)
	var t := clampf(0.12 + dist / 2600.0, 0.14, 0.32)
	for n in [a, b]:
		n.z_index = 5
		var target: Vector2 = mid - dir * gap if n == a else mid + dir * gap
		var tw: Tween = n.create_tween().set_parallel(true)
		tw.tween_property(n, "global_position", target, t).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_property(n, "lift", 10.0, t)
		tw.chain().tween_property(n, "global_scale", n.global_scale * 1.18, 0.07)
		tw.chain().tween_property(n, "global_scale", Vector2(0.05, 0.05), 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tw.chain().tween_callback(n.queue_free)
	get_tree().create_timer(t).timeout.connect(func():
		if not is_instance_valid(self):
			return
		var pitch := 1.0 + 0.06 * mini(combo - 1, 8)
		Sound.play("match", pitch)
		Sound.vibrate(18)
		var col: Color = [Kit.GOLD, Kit.PINK, Kit.GREEN, Kit.BLUE][randi() % 4]
		Burst.sparkle(_fx, mid, [Kit.GOLD, col, Color.WHITE], 16)
		_float_text("+%d" % gain, mid, Color("ff8a1f"), 40)
		if combo >= 2:
			_show_combo(combo, mid))


func _float_text(text: String, global_at: Vector2, color: Color, size_px: int) -> void:
	var l := Kit.outlined(Kit.label(text, size_px, color), Color.WHITE, 10)
	_text_layer.add_child(l)
	l.reset_size()
	var local := _text_layer.get_global_transform().affine_inverse() * global_at
	l.position = local - l.size / 2.0
	l.pivot_offset = l.size / 2.0
	l.scale = Vector2(0.5, 0.5)
	var tw: Tween = l.create_tween().set_parallel(true)
	tw.tween_property(l, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "position:y", l.position.y - 70, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.3).set_delay(0.55)
	tw.chain().tween_callback(l.queue_free)


func _show_combo(combo: int, at: Vector2) -> void:
	var words := I18n.t("praise_%d" % mini(combo, 5))
	var colors := [Kit.ORANGE, Kit.PINK, Kit.PURPLE, Color("ff5a5a")]
	var c: Color = colors[clampi(combo - 2, 0, colors.size() - 1)]
	if _combo_lbl and is_instance_valid(_combo_lbl):
		_combo_lbl.queue_free()
	var l := Kit.outlined(Kit.label("%s  %s" % [words, I18n.t("combo", [combo])], 44 + mini(combo, 6) * 2, c), Color.WHITE, 12)
	_combo_lbl = l
	_text_layer.add_child(l)
	l.reset_size()
	var area_top := _text_layer.get_global_transform().affine_inverse() * (_board_area.get_global_transform() * Vector2(_board_area.size.x / 2.0, 0))
	l.position = Vector2(_text_layer.size.x / 2.0 - l.size.x / 2.0, area_top.y + 10)
	l.pivot_offset = l.size / 2.0
	l.scale = Vector2(0.3, 0.3)
	l.rotation = -0.08
	var tw: Tween = l.create_tween()
	tw.tween_property(l, "scale", Vector2(1.08, 1.08), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(l, "rotation", 0.0, 0.3)
	tw.tween_property(l, "scale", Vector2.ONE, 0.1)
	tw.tween_interval(0.45)
	tw.tween_property(l, "modulate:a", 0.0, 0.3)
	tw.tween_callback(l.queue_free)


func _tween_lift(n: Node2D, to: float) -> void:
	var tw: Tween = n.create_tween()
	tw.tween_property(n, "lift", to, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _shake(n: Node, amount: float) -> void:
	if n == null or not is_instance_valid(n):
		return
	var prop := "position:x"
	var base: float = n.position.x
	var tw: Tween = n.create_tween()
	for k in 4:
		var off := amount * (1.0 if k % 2 == 0 else -1.0) * (1.0 - k * 0.2)
		tw.tween_property(n, prop, base + off, 0.04)
	tw.tween_property(n, prop, base, 0.04)


func _wrong(n) -> void:
	_shake(n, 7.0)
	Sound.play("wrong")
	Sound.vibrate(35)
	state.break_combo()


func _pulse_refs(refs: Array, strong: bool) -> void:
	for r in refs:
		var n = null
		if r.has("tile"):
			n = tile_nodes.get(r.tile)
		elif r.has("slot"):
			n = slot_nodes[r.slot]
		if n == null:
			continue
		var tw: Tween = n.create_tween().set_loops(3 if strong else 2)
		tw.tween_property(n, "glow", 1.0, 0.25)
		tw.parallel().tween_property(n, "lift", 8.0, 0.25).set_trans(Tween.TRANS_QUAD)
		tw.tween_property(n, "glow", 0.0, 0.25)
		tw.parallel().tween_property(n, "lift", 0.0, 0.25).set_trans(Tween.TRANS_QUAD)


func _pulse_button(b: Control) -> void:
	var tw: Tween = b.create_tween().set_loops(2)
	tw.tween_property(b, "scale", Vector2(1.12, 1.12), 0.18).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(b, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_QUAD)


## Bring nodes back in line with the state after undo (restored tiles pop back in).
func _reconcile() -> void:
	for i in state.tiles.size():
		var alive: bool = state.tiles[i].alive
		if alive and not tile_nodes.has(i):
			var n := _make_tile(i)
			_insert_sorted(n)
			tile_nodes[i] = n
			n.scale = Vector2(0.2, 0.2)
			var tw: Tween = n.create_tween()
			tw.tween_property(n, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		elif not alive and tile_nodes.has(i):
			var n = tile_nodes[i]
			tile_nodes.erase(i)
			_shade_target.erase(i)
			n.queue_free()
	for s in GameState.SLOT_COUNT:
		var t: int = state.slots[s]
		var n = slot_nodes[s]
		if t == -1 and n:
			n.queue_free()
			slot_nodes[s] = null
		elif t != -1 and (n == null or n.type_id != t):
			if n:
				n.queue_free()
			var holder: Control = _slot_holders[s]
			var m = TileView.new()
			m.setup(t, -1)
			holder.add_child(m)
			m.position = holder.size / 2.0
			m.scale = Vector2(0.2, 0.2)
			var tw: Tween = m.create_tween()
			tw.tween_property(m, "scale", Vector2(SLOT_SCALE, SLOT_SCALE), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			slot_nodes[s] = m


func _insert_sorted(n: Node2D) -> void:
	_tiles_root.add_child(n)
	var key: int = n.get_meta("key")
	var kids := _tiles_root.get_children()
	for k in kids.size():
		var o = kids[k]
		if o != n and o.has_meta("key") and int(o.get_meta("key")) > key:
			_tiles_root.move_child(n, k)
			return


func toast(text: String, secs := 1.6) -> void:
	_toast.text = text
	_toast.reset_size()
	var area := _text_layer.get_global_transform().affine_inverse() * (_board_area.get_global_transform() * Vector2(_board_area.size.x / 2.0, _board_area.size.y))
	_toast.position = Vector2((_text_layer.size.x - _toast.size.x) / 2.0, area.y - _toast.size.y - 10)
	if _toast_tw and _toast_tw.is_valid():
		_toast_tw.kill()
	_toast_tw = _toast.create_tween()
	_toast_tw.tween_property(_toast, "modulate:a", 1.0, 0.15)
	_toast_tw.tween_interval(secs)
	_toast_tw.tween_property(_toast, "modulate:a", 0.0, 0.3)


# ================================================================ end states

func _finish_win() -> void:
	finished = true
	running = false
	var stars: int = state.stars_for(elapsed)
	var bonus: int = state.time_bonus(elapsed)
	if is_daily:
		bonus = maxi(bonus / 2, 10)
	var total: int = state.score + bonus
	var rec: Dictionary
	if is_daily:
		rec = Save.record_daily(total, daily_date)
	else:
		rec = Save.record_level(level, stars, total)
	await get_tree().create_timer(0.55).timeout
	if not is_instance_valid(self):
		return
	Burst.confetti(_fx, size.x, -20.0)
	Sound.play("win")
	_show_win(stars, bonus, total, rec.get("new_best", false))


func _finish_stuck() -> void:
	finished = true
	running = false
	await get_tree().create_timer(0.6).timeout
	if not is_instance_valid(self):
		return
	Sound.play("fail")
	var m = Modal.new(I18n.t("stuck_title"))
	m.dismissible = false
	var sheep := Kit.icon_rect(Kit.tile_tex(0), 150, Color(0.85, 0.85, 0.9))
	m.body.add_child(sheep)
	m.body.move_child(sheep, 0)
	var txt := Kit.label(I18n.t("stuck_text"), 26, Kit.INK_SOFT, false)
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	m.body.add_child(txt)
	m.spacer(6)
	var home := Kit.round_button("home", Kit.BROWN, 92)
	home.pressed.connect(func(): request_menu.emit())
	var again := Kit.button(I18n.t("btn_restart"), Kit.GREEN, Vector2(0, 92), 32, "restart")
	again.pressed.connect(func():
		m.close()
		_restart())
	m.add_buttons([home, again])
	home.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_open_modal(m)


func _show_win(stars: int, bonus: int, total: int, new_best: bool) -> void:
	var m = Modal.new()
	m.dismissible = false
	var mascot := Kit.icon_rect(Kit.tile_tex(0), 150)
	mascot.pivot_offset = Vector2(75, 150)
	m.body.add_child(mascot)
	var bounce: Tween = mascot.create_tween().set_loops()
	bounce.tween_property(mascot, "scale", Vector2(1.06, 0.94), 0.35).set_trans(Tween.TRANS_SINE)
	bounce.tween_property(mascot, "scale", Vector2(0.97, 1.04), 0.35).set_trans(Tween.TRANS_SINE)

	var title := Kit.outlined(Kit.label(I18n.t("daily_done") if is_daily else I18n.t("win_title"), 52, Color("ff8a1f")), Color.WHITE, 12)
	m.body.add_child(title)

	var star_row = null
	if not is_daily:
		star_row = StarRow.new(stars, 64.0)
		star_row.custom_minimum_size.y = 84
		star_row.pop = [0.0, 0.0, 0.0]
		m.body.add_child(star_row)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 6)
	var secs := int(elapsed)
	var rows := [
		[I18n.t("win_time"), "%02d:%02d" % [secs / 60, secs % 60]],
		[I18n.t("win_bonus"), "+%d" % bonus],
	]
	if state.best_combo >= 2:
		rows.append([I18n.t("win_combo"), "×%d" % state.best_combo])
	if is_daily:
		rows.append([I18n.t("daily_streak", [Save.daily_streak]), ""])
	for r in rows:
		var k := Kit.label(r[0], 26, Kit.INK_SOFT, false, HORIZONTAL_ALIGNMENT_LEFT)
		k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(k)
		grid.add_child(Kit.label(r[1], 28, Kit.INK, true, HORIZONTAL_ALIGNMENT_RIGHT))
	var gwrap := MarginContainer.new()
	gwrap.add_theme_constant_override("margin_left", 30)
	gwrap.add_theme_constant_override("margin_right", 30)
	gwrap.add_child(grid)
	m.body.add_child(gwrap)

	var score_line := HBoxContainer.new()
	score_line.alignment = BoxContainer.ALIGNMENT_CENTER
	score_line.add_theme_constant_override("separation", 14)
	score_line.add_child(Kit.label(I18n.t("win_score"), 30, Kit.INK_SOFT))
	var score_val := Kit.label("0", 56, Color("e0782f"))
	score_line.add_child(score_val)
	m.body.add_child(score_line)
	if new_best:
		var badge := Kit.label(I18n.t("new_record"), 22, Color.WHITE)
		var bst := Kit.box(Kit.PINK, 18)
		bst.content_margin_left = 16
		bst.content_margin_right = 16
		bst.content_margin_top = 2
		bst.content_margin_bottom = 4
		badge.add_theme_stylebox_override("normal", bst)
		badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		m.body.add_child(badge)

	m.spacer(4)
	var home := Kit.round_button("home", Kit.BROWN, 92)
	home.pressed.connect(func(): request_menu.emit())
	var again := Kit.round_button("restart", Kit.BLUE, 92)
	again.pressed.connect(func():
		m.close()
		_restart())
	var buttons: Array = [home, again]
	if not is_daily:
		var next := Kit.button(I18n.t("btn_next"), Kit.GREEN, Vector2(0, 92), 34, "play")
		next.pressed.connect(func(): request_level.emit(level + 1))
		buttons.append(next)
	m.add_buttons(buttons)
	home.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	again.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN if not is_daily else Control.SIZE_EXPAND_FILL
	_open_modal(m)

	# Count the score up, then drop the stars in one by one.
	var counter: Tween = m.create_tween()
	counter.tween_method(func(v: float): score_val.text = str(int(v)), 0.0, float(total), 0.9).set_delay(0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if star_row:
		for k in stars:
			var tw: Tween = m.create_tween()
			tw.tween_interval(0.45 + k * 0.28)
			tw.tween_callback(func(): Sound.play("star", 1.0 + k * 0.12))
			tw.tween_method(func(v: float): star_row.set_pop(k, v), 0.0, 1.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _open_modal(m: Control) -> void:
	_modal = m
	m.closed.connect(func():
		if _modal == m:
			_modal = null)
	m.open(self)


func _restart() -> void:
	if is_daily:
		request_daily.emit()
	else:
		request_level.emit(level)


func _open_pause() -> void:
	if not _can_play():
		return
	paused = true
	_clear_selection(false)
	var m = Modal.new(I18n.t("pause_title"))
	var resume := Kit.button(I18n.t("btn_resume"), Kit.GREEN, Vector2(0, 96), 34, "play")
	resume.pressed.connect(m.close)
	m.body.add_child(resume)
	var restart := Kit.button(I18n.t("btn_restart"), Kit.BLUE, Vector2(0, 86), 30, "restart")
	restart.pressed.connect(func():
		m.close()
		_restart())
	m.body.add_child(restart)
	var settings := Kit.button(I18n.t("btn_settings"), Kit.ORANGE, Vector2(0, 86), 30, "gear")
	settings.pressed.connect(func(): request_settings.emit())
	m.body.add_child(settings)
	var menu := Kit.button(I18n.t("btn_menu"), Kit.BROWN, Vector2(0, 86), 30, "home")
	menu.pressed.connect(func(): request_menu.emit())
	m.body.add_child(menu)
	m.closed.connect(func(): paused = false)
	_open_modal(m)


## Android back / Esc. Returns true when handled.
func handle_back() -> bool:
	if _modal and is_instance_valid(_modal):
		if _modal.dismissible:
			_modal.close()
		return true
	if not finished:
		_open_pause()
	return true


func _notification(what: int) -> void:
	# Leaving the app mid-level pauses it.
	if (what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED) and _can_play():
		_open_pause()
