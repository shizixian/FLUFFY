extends RefCounted
## Settings, About and Profile dialogs (all built on Modal).

const Kit = preload("res://scripts/ui/kit.gd")
const Modal = preload("res://scripts/ui/modal.gd")
const Switch = preload("res://scripts/ui/switch.gd")


static func settings() -> Control:
	var m = Modal.new()
	var fill := func():
		m.clear_body()
		m.body.add_child(Kit.label(I18n.t("settings_title"), 44))
		_audio_row(m.body, "set_music", Save.bgm_enabled, Save.bgm_volume,
				func(on): Save.bgm_enabled = on,
				func(v): Save.bgm_volume = v)
		_audio_row(m.body, "set_sfx", Save.sfx_enabled, Save.sfx_volume,
				func(on): Save.sfx_enabled = on,
				func(v): Save.sfx_volume = v)
		var vib := _row(m.body, I18n.t("set_vibrate"))
		var sw = Switch.new(Save.vibrate)
		sw.toggled.connect(func(on):
			Save.vibrate = on
			Save.save()
			Sound.vibrate(30))
		vib.add_child(sw)

		var lang_row := _row(m.body, I18n.t("set_lang"))
		var seg := HBoxContainer.new()
		seg.add_theme_constant_override("separation", 8)
		for code in I18n.LANGS:
			var b := Kit.button(I18n.LANG_NAMES[code], Kit.ORANGE if code == I18n.lang else Color("e8d5bb"),
					Vector2(0, 62), 22, "", 20)
			if code != I18n.lang:
				for k in ["font_color", "font_hover_color", "font_pressed_color"]:
					b.add_theme_color_override(k, Kit.INK_SOFT)
				b.add_theme_constant_override("outline_size", 0)
			b.pressed.connect(func():
				Save.lang = code
				Save.save()
				I18n.set_lang(code))
			seg.add_child(b)
		lang_row.add_child(seg)
		m.spacer(6)
		var close := Kit.button(I18n.t("btn_ok"), Kit.GREEN, Vector2(0, 90), 32)
		close.pressed.connect(m.close)
		m.body.add_child(close)
	fill.call()
	m.on_lang_change = fill
	return m


static func _row(parent: Control, text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var l := Kit.label(text, 30, Kit.INK, true, HORIZONTAL_ALIGNMENT_LEFT)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(l)
	parent.add_child(row)
	return row


static func _audio_row(parent: Control, key: String, enabled: bool, vol: float,
		set_on: Callable, set_vol: Callable) -> void:
	var row := _row(parent, I18n.t(key))
	var sw = Switch.new(enabled)
	row.add_child(sw)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = vol
	slider.custom_minimum_size = Vector2(0, 40)
	slider.editable = enabled
	slider.modulate.a = 1.0 if enabled else 0.4
	parent.add_child(slider)
	sw.toggled.connect(func(on):
		set_on.call(on)
		slider.editable = on
		slider.modulate.a = 1.0 if on else 0.4
		Save.save()
		Sound.apply_settings())
	slider.value_changed.connect(func(v):
		set_vol.call(v)
		Sound.apply_settings())
	slider.drag_ended.connect(func(_c):
		Save.save()
		Sound.play("click"))


static func about() -> Control:
	var m = Modal.new()
	var fill := func():
		m.clear_body()
		m.body.add_child(Kit.icon_rect(Kit.tile_tex(0), 130))
		m.body.add_child(Kit.label(I18n.t("about_title"), 40))
		var t := Kit.label(I18n.t("about_text", [ProjectSettings.get_setting("application/config/version", "1.0.0")]), 25, Kit.INK_SOFT, false)
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		m.body.add_child(t)
		var close := Kit.button(I18n.t("btn_close"), Kit.GREEN, Vector2(0, 86), 30)
		close.pressed.connect(m.close)
		m.body.add_child(close)
	fill.call()
	m.on_lang_change = fill
	return m


## First launch (`first` = true) can't be dismissed and always saves.
static func profile(first: bool, on_done: Callable) -> Control:
	var m = Modal.new()
	m.dismissible = not first
	var chosen := [Save.player_avatar]
	var name_box := LineEdit.new()
	name_box.text = Save.player_name
	name_box.max_length = 12
	name_box.alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_box.custom_minimum_size = Vector2(0, 76)
	name_box.select_all_on_focus = true

	var fill := func():
		if name_box.get_parent():
			name_box.get_parent().remove_child(name_box)   # keep the typed name across rebuilds
		m.clear_body()
		m.body.add_child(Kit.label(I18n.t("profile_create") if first else I18n.t("profile_edit"), 40))
		m.body.add_child(Kit.label(I18n.t("profile_name"), 24, Kit.INK_SOFT, false, HORIZONTAL_ALIGNMENT_LEFT))
		name_box.placeholder_text = I18n.t("profile_name_ph")
		m.body.add_child(name_box)
		m.body.add_child(Kit.label(I18n.t("profile_avatar"), 24, Kit.INK_SOFT, false, HORIZONTAL_ALIGNMENT_LEFT))
		var grid := GridContainer.new()
		grid.columns = 6
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 10)
		var buttons: Array = []
		for k in Kit.AVATAR_NAMES.size():
			var b := Button.new()
			b.custom_minimum_size = Vector2(76, 76)
			b.icon = Kit.avatar_tex(k)
			b.expand_icon = true
			b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			b.focus_mode = Control.FOCUS_NONE
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			Kit.juice(b)
			buttons.append(b)
			grid.add_child(b)
		var paint := func():
			for k in buttons.size():
				var on: bool = k == chosen[0]
				var st := Kit.box(Color("fff3d6") if on else Color(1, 1, 1, 0.7), 20, 5 if on else 0, Kit.ORANGE)
				st.set_content_margin_all(6)
				for s in ["normal", "hover", "pressed"]:
					buttons[k].add_theme_stylebox_override(s, st)
		for k in buttons.size():
			buttons[k].pressed.connect(func():
				chosen[0] = k
				paint.call())
		paint.call()
		m.body.add_child(grid)
		m.spacer(4)
		var ok := Kit.button(I18n.t("profile_ok_create") if first else I18n.t("profile_ok_save"), Kit.GREEN, Vector2(0, 92), 32, "play" if first else "")
		ok.pressed.connect(func():
			var n := name_box.text.strip_edges()
			Save.player_name = n if n != "" else I18n.t("default_name")
			Save.player_avatar = chosen[0]
			Save.save()
			m.close()
			on_done.call())
		m.body.add_child(ok)
	fill.call()
	m.on_lang_change = fill
	return m
