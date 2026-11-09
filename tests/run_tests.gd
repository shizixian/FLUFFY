extends SceneTree

# Headless regression tests for FLUFFY v0.4.
# Run with:  godot --headless --path . --script res://tests/run_tests.gd

var main
var failures: Array = []
var checks := 0


func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _check(cond: bool, label: String) -> void:
	checks += 1
	if not cond:
		failures.append(label)


func _run() -> void:
	await process_frame

	print("\n=== FLUFFY v0.4 test suite ===")
	_test_layouts()
	_test_generator_all_levels()
	_test_type_parity()
	_test_combo()
	_test_hint()
	_test_undo_match()
	_test_move_out_and_undo()
	_test_board_slot_match()
	_test_shuffle_preserves_slots()
	_test_daily_determinism()
	_test_full_playthrough()
	_test_daily_records()
	_test_difficulty_curve()

	print("\n%d checks, %d failures" % [checks, failures.size()])
	for f in failures:
		print("  FAIL: %s" % f)
	print("")
	quit(1 if failures.size() > 0 else 0)


func _test_layouts() -> void:
	for def in main.LAYOUT_DEFS:
		var slots: Array = main._build_layout(def)
		var seen := {}
		var dup := false
		for s in slots:
			var key := "%d:%d:%d" % [s.gx, s.gy, s.layer]
			if seen.has(key):
				dup = true
			seen[key] = true
		_check(not dup, "layout %s has duplicate slots" % def["name"])
		_check(slots.size() >= 16, "layout %s has too few slots (%d)" % [def["name"], slots.size()])
		print("  layout %-8s %2d slots" % [def["name"], slots.size()])


func _count_types() -> Dictionary:
	var counts := {}
	for c in main.cards:
		if c.type != -1:
			counts[c.type] = counts.get(c.type, 0) + 1
	return counts


func _test_type_parity() -> void:
	for lv in [1, 2, 3, 5, 8, 12, 20]:
		main.start_level(lv)
		var counts := _count_types()
		var bad := []
		for t in counts.keys():
			if counts[t] % 2 != 0:
				bad.append("%s=%d" % [t, counts[t]])
		_check(bad.is_empty(), "level %d has unpaired types: %s" % [lv, str(bad)])
		var total: int = main.remaining_tiles
		_check(total % 2 == 0, "level %d deals an odd number of tiles" % lv)
		_check(total == main.level_total_cards, "level %d remaining/total mismatch" % lv)


func _check_solvable(label: String) -> void:
	var order: Array = main._last_generation_order.duplicate(true)
	if order.is_empty():
		_check(false, "%s: generator produced no order" % label)
		return
	for k in range(order.size() - 1, -1, -1):
		var entry: Array = order[k]
		var types: Array = []
		for idx in entry:
			if main.cards[idx].type == -1:
				_check(false, "%s: tile %d empty at step %d" % [label, idx, k])
				return
			types.append(main.cards[idx].type)
		for idx in entry:
			if not main.is_card_free(idx):
				_check(false, "%s: tile %d not free at step %d" % [label, idx, k])
				return
		if types.size() == 2 and types[0] != types[1]:
			_check(false, "%s: pair mismatch at step %d" % [label, k])
			return
		for idx in entry:
			main.remove_card(idx)
	_check(main.remaining_tiles == 0, "%s: %d tiles left after full replay" % [label, main.remaining_tiles])


func _test_generator_all_levels() -> void:
	var bad := 0
	for lv in range(1, 61):
		main.start_level(lv)
		var before := failures.size()
		_check_solvable("level %d" % lv)
		if failures.size() > before:
			bad += 1
	_check(bad == 0, "generator failed on %d levels" % bad)
	print("  levels 1-60: generator replay OK")


func _test_combo() -> void:
	main.start_level(1)
	main.combo_count = 0
	main.last_match_msec = -1000000
	var g1: int = main._register_match()
	var g2: int = main._register_match()
	var g3: int = main._register_match()
	_check(main.combo_count == 3, "combo did not chain (got %d)" % main.combo_count)
	_check(g2 > g1, "combo did not increase score")
	_check(g3 > g2, "combo did not keep increasing score")
	_check(main.best_combo == 3, "best_combo not tracked")
	main._break_combo()
	_check(main.combo_count == 0, "combo not reset")


func _test_hint() -> void:
	main.start_level(1)
	var before: int = main.hints_left
	var pair = main._find_hint_pair()
	_check(not pair.is_empty(), "hint found no pair on a fresh board")
	main._on_hint_pressed()
	_check(main.hints_left == before - 1, "hint charge not consumed")
	main.hints_left = 0
	main._on_hint_pressed()
	_check(main.hints_left == 0, "hint charge went negative")


func _find_free_pair() -> Array:
	var free: Array = []
	for i in range(main.cards.size()):
		if main.is_card_free(i):
			free.append(i)
	for a in range(free.size()):
		for b in range(a + 1, free.size()):
			if main.cards[free[a]].type == main.cards[free[b]].type:
				return [free[a], free[b]]
	return []


func _test_undo_match() -> void:
	main.start_level(1)
	var pair = _find_free_pair()
	if pair.is_empty():
		_check(false, "no free pair to test undo")
		return
	var t: int = main.cards[pair[0]].type
	var score_before: int = main.score
	var left_before: int = main.remaining_tiles

	main.handle_tile_click(pair[0])
	main.handle_tile_click(pair[1])
	_check(main.cards[pair[0]].type == -1, "match did not clear first tile")
	_check(main.remaining_tiles == left_before - 2, "match did not reduce remaining by 2")
	_check(main.history.size() == 1, "match was not recorded for undo")

	main._on_undo_pressed()
	_check(main.cards[pair[0]].type == t and main.cards[pair[1]].type == t, "undo did not restore both tiles")
	_check(main.remaining_tiles == left_before, "undo did not restore remaining count")
	_check(main.score == score_before, "undo did not refund score (got %d, want %d)" % [main.score, score_before])
	_check(main.undos_left == main.UNDO_CHARGES - 1, "undo charge not consumed")


func _test_move_out_and_undo() -> void:
	main.start_level(1)
	var pair = _find_free_pair()
	if pair.is_empty():
		_check(false, "no free pair to test move out")
		return
	var idx: int = pair[0]
	var t: int = main.cards[idx].type
	var left_before: int = main.remaining_tiles

	main.handle_tile_click(idx)
	main._on_moveout_pressed()
	_check(main.slot_tiles[0] != null and main.slot_tiles[0].type == t, "move out did not park the tile")
	_check(main.cards[idx].type == -1, "moved tile still on board")
	_check(main.remaining_tiles == left_before, "move out must NOT count as cleared")
	_check(main.moveouts_left == main.MOVEOUT_CHARGES - 1, "move out charge not consumed")

	main._on_undo_pressed()
	_check(main.slot_tiles[0] == null, "undo move out did not empty the slot")
	_check(main.cards[idx].type == t, "undo move out did not return the tile")
	_check(main.remaining_tiles == left_before, "undo move out changed remaining count")


func _test_board_slot_match() -> void:
	main.start_level(1)
	var pair = _find_free_pair()
	if pair.is_empty():
		_check(false, "no free pair for slot match test")
		return
	var idx: int = pair[0]
	var partner := -1
	for i in range(main.cards.size()):
		if i != idx and main.cards[i].type == main.cards[idx].type and main.is_card_free(i):
			partner = i
			break
	if partner == -1:
		_check(false, "no free partner for slot match test")
		return

	main.handle_tile_click(idx)
	main._on_moveout_pressed()
	var left_after_move: int = main.remaining_tiles

	main._on_slot_pressed(0)
	_check(main.selected_slot == 0, "tapping a slot did not select it")
	main.handle_tile_click(partner)

	_check(main.slot_tiles[0] == null, "board+slot match did not clear the slot")
	_check(main.cards[partner].type == -1, "board+slot match did not clear the board tile")
	_check(main.remaining_tiles == left_after_move - 2, "board+slot match removed the wrong count")


func _test_shuffle_preserves_slots() -> void:
	main.start_level(2)
	var pair = _find_free_pair()
	if pair.is_empty():
		return
	# Park one tile in a slot, then clear a board pair, then shuffle.
	main.handle_tile_click(pair[0])
	main._on_moveout_pressed()
	var parked_type: int = main.slot_tiles[0].type
	var total_before: int = main.remaining_tiles

	main._on_shuffle_pressed()
	_check(main.slot_tiles[0] != null and main.slot_tiles[0].type == parked_type, "shuffle dropped the parked tile")
	_check(main.remaining_tiles == total_before, "shuffle changed the total tile count")
	_check(main._slot_tile_count() == 1, "shuffle changed slot occupancy")


func _snapshot_board() -> Array:
	var out: Array = []
	for c in main.cards:
		out.append("%d,%d,%d:%d" % [c.gx, c.gy, c.layer, c.type])
	return out


func _test_daily_determinism() -> void:
	main.start_daily()
	var a := _snapshot_board()
	var def: Dictionary = main.LAYOUT_DEFS[3]
	main._begin_run(def, main.DAILY_CARDS, 12345)
	var b := _snapshot_board()
	main._begin_run(def, main.DAILY_CARDS, 12345)
	var c := _snapshot_board()
	main._begin_run(def, main.DAILY_CARDS, 99999)
	var d := _snapshot_board()

	_check(a.size() == b.size(), "daily and seeded boards differ in slot count")
	_check(b == c, "repeat with identical seed is not stable")
	_check(c != d, "different seeds produced identical boards")
	_check(main.is_daily, "daily flag not set")



func _auto_play(max_steps: int = 400) -> bool:
	var steps := 0
	while main.remaining_tiles > 0 and steps < max_steps:
		steps += 1
		var pair = _find_free_pair()
		if pair.is_empty():
			# Try to unblock by matching a parked slot tile with a board tile.
			var moved := false
			for i in range(main.SLOT_COUNT):
				if main.slot_tiles[i] == null:
					continue
				for j in range(main.cards.size()):
					if main.cards[j].type == main.slot_tiles[i].type and main.is_card_free(j):
						main._on_slot_pressed(i)
						main.handle_tile_click(j)
						moved = true
						break
				if moved:
					break
			if moved:
				continue
			# Last resort: park a free tile and see if that opens something up.
			for j in range(main.cards.size()):
				if main.is_card_free(j):
					main.handle_tile_click(j)
					main._on_moveout_pressed()
					moved = true
					break
			if not moved:
				return false
			continue
		main.handle_tile_click(pair[0])
		main.handle_tile_click(pair[1])
	return main.remaining_tiles == 0


func _test_full_playthrough() -> void:
	for lv in [1, 3, 5, 9]:
		main.start_level(lv)
		var won: bool = _auto_play()
		_check(won, "could not clear level %d by playing it" % lv)
		_check(main.win_panel.visible, "level %d finished without showing the win panel" % lv)
		_check(main.remaining_tiles == 0, "level %d ended with tiles left" % lv)
	print("  playthrough: levels 1/3/5/9 cleared")


func _test_daily_records() -> void:
	main.daily_date = ""
	main.daily_best = 0
	main.daily_streak = 0
	main.daily_last_played = ""
	main.start_daily()
	var won: bool = _auto_play()
	_check(won, "could not clear the daily challenge")
	_check(main.daily_best > 0, "daily best score was not recorded")
	_check(main.daily_streak == 1, "daily streak did not start at 1")
	var first_best: int = main.daily_best
	main.start_daily()
	main.score = 0
	_auto_play()
	_check(main.daily_best >= first_best, "daily best regressed on replay")
	_check(main.daily_streak == 1, "replaying the same day must not increase the streak")

func _test_difficulty_curve() -> void:
	var last := 0
	var bad := 0
	for lv in range(1, 26):
		main.start_level(lv)
		var n: int = main.remaining_tiles
		if n < last:
			bad += 1
		last = n
	_check(bad == 0, "tile count drops as levels go up (%d times)" % bad)
