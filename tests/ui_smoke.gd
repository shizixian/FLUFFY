extends Node
## Drives the real UI headless through every interaction path.
##   godot --headless --path . res://tests/ui_smoke.tscn
## Exit code 0 = finished; watch the output for SCRIPT ERROR lines.

var main: Control
var fails: Array = []


func check(c: bool, label: String) -> void:
	if not c:
		fails.append(label)


func wait(s: float) -> void:
	await get_tree().create_timer(s).timeout


func _ready() -> void:
	Save.path = "user://_ui_smoke.cfg"
	Save.player_name = ""
	Save.max_level = 1
	Save.level_stars = []
	Save.level_best = []
	Save.total_score = 0
	main = load("res://scenes/main.tscn").instantiate()
	add_child(main)
	_run()


func _run() -> void:
	await wait(0.5)
	check(main._top_dialog() != null, "first launch shows profile dialog")
	main.go_back()                                  # not dismissible
	await wait(0.3)
	check(main._top_dialog() != null, "profile can't be dismissed on first launch")
	main._close_dialogs()
	Save.player_name = "Smoke"

	for code in ["en", "zh_TW", "zh_CN"]:
		I18n.set_lang(code)
		await wait(0.05)
	main.show_levels()
	await wait(0.3)
	main.go_back()
	await wait(0.3)
	check(main._screen.get_script().resource_path.ends_with("main_menu.gd"), "back from levels returns to menu")

	# ---------------- level 4: every interaction
	main.start_level(4)
	await wait(2.0)
	var g = main._screen
	check(g.running, "timer runs after deal")
	var st = g.state
	var blocked := -1
	for i in st.tiles.size():
		if not st.is_free(i):
			blocked = i
			break
	g._tap_tile(blocked)                            # locked feedback
	check(g.sel_tile == -1, "covered tile can't be selected")
	var free: Array = st.free_tiles()
	var a: int = free[0]
	var other := -1
	for j in free:
		if st.tiles[j].type != st.tiles[a].type:
			other = j
			break
	g._tap_tile(a)
	g._tap_tile(other)                              # mismatch → selection moves
	check(g.sel_tile == other, "mismatch moves selection")
	g._tap_tile(other)
	check(g.sel_tile == -1, "tapping again deselects")

	g._on_prop("park")                              # nothing selected
	g._tap_tile(st.solution[0][0])
	g._on_prop("park")
	await wait(0.5)
	check(st.slot_count() == 1 and g.slot_nodes.count(null) == 2, "park puts tile in tray")
	g._tap_slot(st.slots.find(st.tiles[st.solution[0][0]].type))
	g._tap_tile(st.solution[0][1])                  # slot + board match
	await wait(0.6)
	check(st.slot_count() == 0, "slot + board tile cleared")
	g._on_prop("undo")
	await wait(0.4)
	check(st.slot_count() == 1 and g.slot_nodes.count(null) == 2, "undo brings tray tile back")
	check(g.tile_nodes.has(st.solution[0][1]), "undo brings board tile back")
	g._on_prop("hint")
	await wait(0.2)
	g._on_prop("shuffle")
	await wait(0.6)
	check(st.shuffles == 1, "shuffle used")
	for i in g.tile_nodes.keys():
		if g.tile_nodes[i].type_id != st.tiles[i].type:
			fails.append("tile view %d shows wrong type after shuffle" % i)
			break
	main.go_back()                                  # back → pause
	await wait(0.3)
	check(g.paused, "back opens pause")
	I18n.set_lang("en")
	await wait(0.1)
	I18n.set_lang("zh_CN")
	main.go_back()
	await wait(0.4)
	check(not g.paused, "back closes pause")

	# ---------------- level 1: full clear → win
	main.start_level(1)
	await wait(1.6)
	g = main._screen
	for step in g.state.solution:
		g._tap_tile(step[0])
		g._tap_tile(step[1])
		await wait(0.05)
	await wait(1.5)
	check(g.finished and g._modal != null, "win dialog shown")
	check(Save.max_level == 2 and Save.stars_for_level(1) >= 1, "win recorded")

	# ---------------- daily + stuck
	main.start_daily()
	await wait(2.2)
	g = main._screen
	g._finish_stuck()
	await wait(1.0)
	check(g._modal != null, "stuck dialog shown")
	main.show_menu()
	await wait(0.4)

	print("UI smoke: %s" % ("OK" if fails.is_empty() else "FAILED"))
	for f in fails:
		print("  FAIL: ", f)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Save.path))
	get_tree().quit(1 if fails.size() > 0 else 0)
