extends Node
## Visual check harness: drives the real game and saves screenshots.
##   godot --path . --resolution 540x960 res://tests/shot_runner.tscn -- out=/tmp/shots lang=zh_CN
## Uses its own save file; the player's real save is never touched.

var out := "/tmp/fluffy_shots"
var main: Control
var _vp: SubViewport           # fixed-size offscreen render (vp=720x1280)


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=")
		if kv.size() == 2 and kv[0] == "out":
			out = kv[1]
		if kv.size() == 2 and kv[0] == "lang":
			Save.lang = kv[1]
		if kv.size() == 2 and kv[0] == "vp":
			var wh := kv[1].split("x")
			_vp = SubViewport.new()
			_vp.size = Vector2i(int(wh[0]), int(wh[1]))
			_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			add_child(_vp)
	DirAccess.make_dir_recursive_absolute(out)
	Save.path = "user://_shot_runner.cfg"
	Save.player_name = "ZAN"
	Save.player_avatar = 4
	Save.max_level = 10
	Save.total_score = 90343
	Save.level_stars = [3, 1, 3, 3, 3, 1, 1, 1, 3]
	Save.daily_streak = 3
	Save.daily_last_played = Save.yesterday_of(Time.get_date_string_from_system())
	Save.bgm_enabled = false
	main = load("res://scenes/main.tscn").instantiate()
	if _vp:
		_vp.add_child(main)
	else:
		add_child(main)
	_run()


func wait(s: float) -> void:
	await get_tree().create_timer(s).timeout


func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var v: Viewport = _vp if _vp else get_viewport()
	v.get_texture().get_image().save_png("%s/%s.png" % [out, name])
	print("shot ", name)


func game():
	return main._screen


func _run() -> void:
	await wait(1.2)
	await shot("01_menu")
	main.show_levels()
	await wait(0.8)
	await shot("02_levels")

	main.start_level(7)
	await wait(1.6)
	await shot("03_deal")
	await wait(1.2)
	var g = game()
	await shot("04_board")
	var sol: Array = g.state.solution
	g._tap_tile(sol[0][0])
	await wait(0.25)
	await shot("05_selected")
	g._tap_tile(sol[0][1])
	await wait(0.2)
	await shot("06_match_fx")
	for k in range(1, 4):
		g._tap_tile(sol[k][0])
		g._tap_tile(sol[k][1])
		await wait(0.35)
	await shot("07_combo")
	await wait(1.0)
	g._tap_tile(sol[4][0])
	g._on_prop("park")
	await wait(0.6)
	await shot("08_tray")
	g._on_prop("hint")
	await wait(0.3)
	await shot("09_hint")
	await wait(1.5)
	g._open_pause()
	await wait(0.5)
	await shot("10_pause")
	main._open(load("res://scripts/ui/dialogs.gd").settings())
	await wait(0.5)
	await shot("11_settings")
	main._close_dialogs()

	main.start_level(1)
	await wait(1.6)
	g = game()
	for step in g.state.solution:
		g._tap_tile(step[0])
		g._tap_tile(step[1])
		await wait(0.12)
	await wait(1.0)
	await shot("12_win_anim")
	await wait(2.0)
	await shot("13_win")

	main.start_level(11)
	await wait(2.6)
	await shot("14_big_board")
	g = game()
	g._finish_stuck()
	await wait(1.2)
	await shot("15_stuck")

	main.show_menu()
	await wait(0.3)
	main._open(load("res://scripts/ui/dialogs.gd").profile(false, func(): pass))
	await wait(0.6)
	await shot("16_profile")
	main._close_dialogs()
	main.start_daily()
	await wait(2.6)
	await shot("17_daily")
	get_tree().quit()
