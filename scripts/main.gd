extends Control
## Root: owns the background, swaps screens, hosts app-level dialogs.

const Kit = preload("res://scripts/ui/kit.gd")
const Background = preload("res://scripts/ui/background.gd")
const MainMenu = preload("res://scripts/ui/main_menu.gd")
const LevelSelect = preload("res://scripts/ui/level_select.gd")
const GameScreen = preload("res://scripts/game/game_screen.gd")
const Dialogs = preload("res://scripts/ui/dialogs.gd")

var _screen: Control
var _dialogs: Control           # app-level modals sit above every screen


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = Kit.make_theme()
	ThemeDB.fallback_font = Kit.font(false)
	I18n.lang = Save.lang
	get_tree().root.min_size = Vector2i(360, 640)

	add_child(Background.new())
	_dialogs = Control.new()
	_dialogs.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dialogs.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dialogs)

	show_menu()
	if not Save.has_profile():
		_open(Dialogs.profile(true, show_menu))


func _swap(next: Control) -> void:
	var old := _screen
	_screen = next
	add_child(next)
	move_child(next, _dialogs.get_index())
	next.modulate.a = 0.0
	var tw: Tween = next.create_tween()
	tw.tween_property(next, "modulate:a", 1.0, 0.22)
	if old and is_instance_valid(old):
		old.mouse_filter = Control.MOUSE_FILTER_IGNORE
		old.process_mode = Node.PROCESS_MODE_DISABLED
		old.queue_free()


func show_menu() -> void:
	var m = MainMenu.new()
	m.play.connect(start_level)
	m.daily.connect(start_daily)
	m.levels.connect(show_levels)
	m.settings.connect(func(): _open(Dialogs.settings()))
	m.about.connect(func(): _open(Dialogs.about()))
	m.profile.connect(func(): _open(Dialogs.profile(false, show_menu)))
	_swap(m)


func show_levels() -> void:
	var l = LevelSelect.new()
	l.back.connect(show_menu)
	l.pick.connect(start_level)
	_swap(l)


func start_level(lv: int) -> void:
	_start(false, lv)


func start_daily() -> void:
	_start(true, 1)


func _start(daily: bool, lv: int) -> void:
	_close_dialogs()
	var g = GameScreen.new()
	g.setup(daily, lv)
	g.request_menu.connect(show_menu)
	g.request_settings.connect(func(): _open(Dialogs.settings()))
	g.request_level.connect(start_level)
	g.request_daily.connect(start_daily)
	_swap(g)


func _open(m: Control) -> void:
	m.open(_dialogs)


func _close_dialogs() -> void:
	for c in _dialogs.get_children():
		if c.has_method("close"):
			c.close()


func _top_dialog() -> Control:
	var kids := _dialogs.get_children()
	for k in range(kids.size() - 1, -1, -1):
		if not kids[k].is_closing():
			return kids[k]
	return null


## Android back button / Esc: close the top dialog, else step back one screen.
func go_back() -> void:
	var d := _top_dialog()
	if d:
		if d.dismissible:
			d.close()
		return
	if _screen is LevelSelect:
		show_menu()
	elif _screen.has_method("handle_back"):
		_screen.handle_back()


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		go_back()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		go_back()
