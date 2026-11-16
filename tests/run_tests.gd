extends SceneTree
## Headless logic tests (rules, generator, save migration). No rendering needed.
##   godot --headless --path . --script res://tests/run_tests.gd

const Layouts = preload("res://scripts/core/layouts.gd")
const GameState = preload("res://scripts/core/game_state.gd")
const SaveScript = preload("res://scripts/autoload/save.gd")

var checks := 0
var failures: Array = []


func _initialize() -> void:
	print("\n=== FLUFFY v1 logic tests ===")
	_test_layouts()
	_test_generator()
	_test_daily_determinism()
	_test_free_rule()
	_test_match_rules()
	_test_combo()
	_test_slots_and_undo()
	_test_tile_slot_match()
	_test_shuffle()
	_test_hint()
	_test_stuck()
	_test_stars()
	_test_save_migration()
	_test_save_daily()
	print("\n%d checks, %d failures" % [checks, failures.size()])
	for f in failures:
		print("  FAIL: ", f)
	quit(1 if failures.size() > 0 else 0)


func check(cond: bool, label: String) -> void:
	checks += 1
	if not cond:
		failures.append(label)


func new_game(level: int, seed_value: int) -> Object:
	var cfg := Layouts.config_for_level(level)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var gs = GameState.new()
	var ok: bool = gs.start(Layouts.build(cfg.index, cfg.mirror), cfg.types, level, rng)
	check(ok, "generation failed: level %d seed %d" % [level, seed_value])
	return gs


## Plays the generator's own solution; singles pair with the slot of their type.
func replay(gs, steps: Array) -> bool:
	for step in steps:
		if step.size() == 2:
			if not gs.match_tiles(step[0], step[1], 0).ok:
				return false
		else:
			var t: int = gs.tiles[step[0]].type
			var s: int = gs.slots.find(t)
			if s < 0 or not gs.match_tile_with_slot(step[0], s, 0).ok:
				return false
	return gs.is_won()


# ------------------------------------------------------------------ layouts

func _test_layouts() -> void:
	for i in Layouts.DEFS.size():
		for mirror in [false, true]:
			var pts := Layouts.build(i, mirror)
			var name: String = Layouts.DEFS[i].name
			check(pts.size() % 2 == 0, "%s has odd tile count %d" % [name, pts.size()])
			check(pts.size() >= 16, "%s too small" % name)
			var overlap := false
			for a in pts.size():
				for b in range(a + 1, pts.size()):
					var p: Dictionary = pts[a]
					var q: Dictionary = pts[b]
					if p.z == q.z and absi(p.x - q.x) < 2 and absi(p.y - q.y) < 2:
						overlap = true
			check(not overlap, "%s has overlapping tiles in one layer" % name)
	var prev := 0
	for lv in range(1, Layouts.DEFS.size() + 1):
		var n := Layouts.build(Layouts.config_for_level(lv).index).size()
		check(n >= prev, "campaign shrinks at level %d" % lv)
		prev = n


# ------------------------------------------------------------------ generator

func _test_generator() -> void:
	var t0 := Time.get_ticks_msec()
	var bad := 0
	for lv in range(1, 41):
		for k in 25:
			var gs = new_game(lv, lv * 1000 + k)
			var counts := {}
			for t in gs.tiles:
				counts[t.type] = int(counts.get(t.type, 0)) + 1
			for c in counts.values():
				if c % 2 != 0:
					bad += 1
			check(counts.size() <= gs.num_types, "level %d uses too many types" % lv)
			if not replay(gs, gs.solution):
				bad += 1
	check(bad == 0, "%d generated boards were not clearable" % bad)
	print("  generator: 1000 boards in %d ms" % (Time.get_ticks_msec() - t0))


func _test_daily_determinism() -> void:
	var cfg := Layouts.daily_config()
	var types_a: Array = []
	var types_b: Array = []
	for out in [types_a, types_b]:
		var rng := RandomNumberGenerator.new()
		rng.seed = hash("fluffy-daily-2026-11-16")
		var gs = GameState.new()
		gs.start(Layouts.build(cfg.index), cfg.types, 9, rng)
		for t in gs.tiles:
			out.append(t.type)
	check(types_a == types_b, "daily board differs for the same date")


# ------------------------------------------------------------------ rules

func _test_free_rule() -> void:
	var gs = GameState.new()
	# Two bottom tiles side by side, one tile on top straddling both halves.
	var pts := [{"x": 0, "y": 0, "z": 0}, {"x": 2, "y": 0, "z": 0}, {"x": 1, "y": 0, "z": 1}, {"x": 6, "y": 0, "z": 0}]
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	gs.start(pts, 2, 1, rng)
	check(not gs.is_free(0) and not gs.is_free(1), "partly covered tiles must be blocked")
	check(gs.is_free(2) and gs.is_free(3), "uncovered tiles must be free")
	gs.tiles[2].alive = false
	check(gs.is_free(0) and gs.is_free(1), "removing the cover frees both")


func _test_match_rules() -> void:
	var gs = new_game(3, 42)
	var free: Array = gs.free_tiles()
	var blocked := -1
	for i in gs.tiles.size():
		if not gs.is_free(i):
			blocked = i
			break
	check(blocked >= 0, "level 3 should start with covered tiles")
	check(not gs.match_tiles(free[0], free[0], 0).ok, "a tile can't match itself")
	for i in free:
		if i != blocked and gs.tiles[i].type == gs.tiles[blocked].type:
			check(not gs.match_tiles(i, blocked, 0).ok, "covered tile must not match")
			break
	var a := -1
	var b := -1
	for i in free:
		for j in free:
			if i != j and gs.tiles[i].type != gs.tiles[j].type:
				a = i
				b = j
	if a >= 0:
		check(not gs.match_tiles(a, b, 0).ok, "different types must not match")
	check(gs.remaining() == gs.total_tiles, "failed matches must not change the board")


func _test_combo() -> void:
	var gs = new_game(1, 7)
	var base: int = gs.points_per_clear()
	var s: Array = gs.solution
	var g1: int = gs.match_tiles(s[0][0], s[0][1], 1000).gain
	var g2: int = gs.match_tiles(s[1][0], s[1][1], 2000).gain
	var g3: int = gs.match_tiles(s[2][0], s[2][1], 9000).gain
	check(g1 == base, "first clear is base points")
	check(g2 == int(round(base * 1.5)) and gs.best_combo == 2, "second quick clear is ×1.5")
	check(g3 == base and gs.combo == 1, "a slow clear resets the combo")
	var gs2 = new_game(5, 3)
	var last := 0
	for k in 7:
		var st: Array = gs2.solution[k]
		last = gs2.match_tiles(st[0], st[1], 100 * k).gain
	check(last == gs2.points_per_clear() * 3, "combo multiplier caps at ×3")


func _test_slots_and_undo() -> void:
	var gs = new_game(4, 11)
	var s: Array = gs.solution
	var a: int = s[0][0]
	var b: int = s[0][1]
	var r1: Dictionary = gs.move_to_slot(a, 0)
	check(r1.ok and gs.slots[r1.slot] == gs.tiles[a].type, "tile parks in a slot")
	check(gs.remaining() == gs.total_tiles, "parking doesn't count as clearing")
	var r2: Dictionary = gs.move_to_slot(b, 100)
	check(r2.ok and r2.pair.size() == 2 and gs.slot_count() == 0, "two equal slot tiles auto-clear")
	check(gs.remaining() == gs.total_tiles - 2, "auto pair clears two tiles")
	var score_before: int = gs.score
	gs.undo()
	check(gs.slot_count() == 1 and gs.tiles[b].alive and gs.moveouts == 2, "undo reverts the auto-pair and its move together")
	check(gs.score == score_before - r2.gain, "undo gives back the points")
	gs.undo()
	check(gs.slot_count() == 0 and gs.tiles[a].alive and gs.moveouts == 3, "second undo returns the first parked tile")
	check(gs.undos == 1, "undo spends charges")
	gs.match_tiles(a, b, 0)
	gs.undo()
	check(gs.undos == 0 and not gs.can_undo(), "undo charges run out")


func _test_tile_slot_match() -> void:
	var gs = new_game(4, 12)
	var s: Array = gs.solution
	gs.move_to_slot(s[0][0], 0)
	var r: Dictionary = gs.match_tile_with_slot(s[0][1], 0, 10)
	check(r.ok and gs.slot_count() == 0 and gs.remaining() == gs.total_tiles - 2, "board tile pairs with slot tile")
	gs.undo()
	check(gs.slot_count() == 1 and gs.tiles[s[0][1]].alive, "undo restores tile + slot")


func _test_shuffle() -> void:
	for seed_value in 20:
		var gs = new_game(8, 500 + seed_value)
		var s: Array = gs.solution
		gs.match_tiles(s[0][0], s[0][1], 0)
		gs.move_to_slot(s[1][0], 0)       # one type now has an odd count on the board
		var before := {}
		for t in gs.tiles:
			if t.alive:
				before[t.type] = int(before.get(t.type, 0)) + 1
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_value
		check(gs.shuffle(rng), "shuffle succeeds")
		var after := {}
		for t in gs.tiles:
			if t.alive:
				after[t.type] = int(after.get(t.type, 0)) + 1
		check(before == after, "shuffle keeps the same tiles")
		check(gs.shuffles == 1 and gs.history.is_empty(), "shuffle spends a charge and clears undo history")
		check(replay(gs, gs.solution), "board after shuffle is still clearable (seed %d)" % seed_value)


func _test_hint() -> void:
	var gs = new_game(6, 21)
	var h: Array = gs.use_hint()
	check(h.size() == 2 and gs.hints == 2, "hint returns a pair and spends a charge")
	if h.size() == 2:
		check(gs.match_tiles(h[0].tile, h[1].tile, 0).ok, "hinted pair is matchable")


func _test_stuck() -> void:
	var gs = GameState.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	gs.start([{"x": 0, "y": 0, "z": 0}, {"x": 2, "y": 0, "z": 0}, {"x": 0, "y": 0, "z": 1}, {"x": 2, "y": 0, "z": 1}], 2, 1, rng)
	# Hand-made dead end: tops differ, their partners are underneath the other top.
	gs.tiles[0].type = 1
	gs.tiles[1].type = 0
	gs.tiles[2].type = 0
	gs.tiles[3].type = 1
	check(not gs.has_move(), "crossed stacks have no move")
	check(not gs.is_stuck(), "not stuck while power-ups remain")
	gs.moveouts = 0
	gs.shuffles = 0
	check(gs.is_stuck(), "stuck once nothing can help")


func _test_stars() -> void:
	var gs = new_game(2, 1)
	var pairs: float = gs.total_tiles / 2.0
	check(gs.stars_for(pairs * 3.9) == 3, "≤4 s per pair is 3 stars")
	check(gs.stars_for(pairs * 7.9) == 2, "≤8 s per pair is 2 stars")
	check(gs.stars_for(pairs * 20.0) == 1, "slow is 1 star")
	check(gs.time_bonus(9999.0) >= 10 * gs.level, "time bonus has a floor")


# ------------------------------------------------------------------ save

func _fresh_save(content: String) -> Object:
	var path := "user://_test_save.cfg"
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(content)
	f.close()
	var sv = SaveScript.new()
	sv.path = path
	sv.load_data()
	return sv


func _test_save_migration() -> void:
	# A real v0.4 file (schema 2).
	var v04 := """[player]
name="ZAN"
avatar=4
[progress]
max_level=10
total_score=90343
level_stars=[3, 1, 3, 3, 3, 1, 1, 1, 3, 3]
[settings]
volume=0.83
bgm_enabled=false
lang="zh_CN"
[daily]
last_played="2026-11-09"
best=616
streak=1
[meta]
schema=2
"""
	var sv = _fresh_save(v04)
	check(sv.player_name == "ZAN" and sv.player_avatar == 4, "v0.4 profile survives")
	check(sv.max_level == 10 and sv.total_score == 90343, "v0.4 progress survives")
	check(sv.stars_for_level(1) == 3 and sv.stars_for_level(2) == 1, "v0.4 stars survive")
	check(is_equal_approx(sv.bgm_volume, 0.83) and not sv.bgm_enabled, "v0.4 settings survive")
	check(sv.sfx_enabled and sv.vibrate, "new settings default on")
	check(sv.today_best("2026-11-16") == 0, "old daily best doesn't leak into today")
	check(sv.today_best("2026-11-09") == 616, "daily best still belongs to its own day")
	sv.save()
	var again = SaveScript.new()
	again.path = sv.path
	again.load_data()
	check(again.max_level == 10 and again.player_name == "ZAN", "round trip keeps data")
	var r: Dictionary = again.record_level(10, 2, 500)
	check(r.unlocked and again.max_level == 11 and again.stars_for_level(10) == 3, "replaying keeps the best stars and unlocks next")
	check(again.best_for_level(10) == 500, "best score stored")
	sv.free()
	again.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://_test_save.cfg"))


func _test_save_daily() -> void:
	var sv = _fresh_save("")
	check(SaveScript.yesterday_of("2026-03-01") == "2026-02-28", "yesterday across month end")
	check(SaveScript.yesterday_of("2026-01-01") == "2025-12-31", "yesterday across year end")
	sv.record_daily(300, "2026-11-14")
	sv.record_daily(200, "2026-11-15")
	check(sv.daily_streak == 2 and sv.today_best("2026-11-15") == 200, "consecutive days grow the streak; best is per day")
	sv.record_daily(450, "2026-11-15")
	check(sv.daily_streak == 2 and sv.today_best("2026-11-15") == 450, "same day replays keep streak, raise best")
	check(sv.current_streak("2026-11-16") == 2, "streak still alive the next day")
	check(sv.current_streak("2026-11-18") == 0, "missing a day shows a broken streak")
	sv.record_daily(100, "2026-11-18")
	check(sv.daily_streak == 1, "streak restarts after a gap")
	sv.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://_test_save.cfg"))
