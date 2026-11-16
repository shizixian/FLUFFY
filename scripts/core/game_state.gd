extends RefCounted
## Pure game rules for one run: tiles, holding slots, props, score, combo, undo.
## No nodes, no rendering — the GameScreen drives it and animates the results,
## and the headless tests drive it directly.
##
## Rule: a tile is free when no live tile on a higher layer overlaps it. Two free
## tiles of the same type clear each other. A tile parked in a slot can pair with
## a free board tile or with another slot tile.

const SLOT_COUNT := 3
const HINT_CHARGES := 3
const UNDO_CHARGES := 3
const MOVEOUT_CHARGES := 3
const SHUFFLE_CHARGES := 2
const COMBO_WINDOW_MS := 3000
const COMBO_MAX_STEPS := 4          # +50% per step → up to 3×
const GEN_ATTEMPTS := 60

var tiles: Array = []               # {x, y, z, type, alive}
var covered_by: Array = []          # covered_by[i] = indices of higher tiles overlapping i
var covers: Array = []              # covers[i]     = indices of lower tiles i overlaps
var slots: Array = []               # type id or -1
var history: Array = []
var solution: Array = []            # removal order found by the generator (pairs / singles)

var level := 1
var num_types := 4
var total_tiles := 0
var score := 0
var combo := 0
var best_combo := 0
var last_clear_ms := -1000000

var hints := HINT_CHARGES
var undos := UNDO_CHARGES
var moveouts := MOVEOUT_CHARGES
var shuffles := SHUFFLE_CHARGES
var props_used := 0


# ---------------------------------------------------------------- setup

func start(positions: Array, types: int, lv: int, rng: RandomNumberGenerator) -> bool:
	level = lv
	num_types = types
	tiles.clear()
	for p in positions:
		tiles.append({"x": int(p.x), "y": int(p.y), "z": int(p.z), "type": -1, "alive": true})
	_build_cover_graph()
	slots.clear()
	for i in SLOT_COUNT:
		slots.append(-1)
	history.clear()
	score = 0
	combo = 0
	best_combo = 0
	last_clear_ms = -1000000
	hints = HINT_CHARGES
	undos = UNDO_CHARGES
	moveouts = MOVEOUT_CHARGES
	shuffles = SHUFFLE_CHARGES
	props_used = 0
	total_tiles = tiles.size()

	# Spread the pairs evenly over the type set, then let the generator place them.
	var pair_count := total_tiles / 2
	var pair_types: Array = []
	for k in pair_count:
		pair_types.append(k % num_types)
	var all_idx: Array = range(tiles.size())
	return _assign_types(all_idx, pair_types, [], rng)


func _build_cover_graph() -> void:
	covered_by.clear()
	covers.clear()
	for i in tiles.size():
		covered_by.append([])
		covers.append([])
	for i in tiles.size():
		var a: Dictionary = tiles[i]
		for j in tiles.size():
			if i == j:
				continue
			var b: Dictionary = tiles[j]
			if b.z > a.z and absi(b.x - a.x) < 2 and absi(b.y - a.y) < 2:
				covered_by[i].append(j)
				covers[j].append(i)


## Assigns types to `indices` so the board is guaranteed clearable.
## Works by simulating a full clear from the complete board: repeatedly take two
## tiles that are free *right now*, give them the same type and remove them.
## Replaying that removal order is then a legal solution. `singles` are types whose
## partner already sits in a slot; they get a lone free tile first.
func _assign_types(indices: Array, pair_types: Array, singles: Array, rng: RandomNumberGenerator) -> bool:
	for attempt in GEN_ATTEMPTS:
		var alive := {}
		for i in indices:
			alive[i] = true
		var assign := {}
		var order: Array = []
		var ok := true

		for t in singles:
			var free := _sim_free(alive)
			if free.is_empty():
				ok = false
				break
			var s: int = free[rng.randi_range(0, free.size() - 1)]
			assign[s] = t
			alive.erase(s)
			order.append([s])

		var pool := pair_types.duplicate()
		_shuffle(pool, rng)
		while ok and not alive.is_empty():
			var free := _sim_free(alive)
			if free.size() < 2 or pool.is_empty():
				ok = false
				break
			var a := _weighted_pick(free, alive, rng)
			free.erase(a)
			var b := _weighted_pick(free, alive, rng)
			var t: int = pool.pop_back()
			assign[a] = t
			assign[b] = t
			alive.erase(a)
			alive.erase(b)
			order.append([a, b])

		if ok:
			for i in assign.keys():
				tiles[i].type = assign[i]
			solution = order
			return true
	return false


func _sim_free(alive: Dictionary) -> Array:
	var out: Array = []
	for i in alive.keys():
		var blocked := false
		for j in covered_by[i]:
			if alive.has(j):
				blocked = true
				break
		if not blocked:
			out.append(i)
	return out


## Prefer tiles that sit on top of others: clearing peaks early keeps the
## simulated board wide, which is what prevents a one-tile dead end.
func _weighted_pick(free: Array, alive: Dictionary, rng: RandomNumberGenerator) -> int:
	var weights: Array = []
	var total := 0.0
	for i in free:
		var under := 0
		for j in covers[i]:
			if alive.has(j):
				under += 1
		var w := 1.0 + 2.5 * under
		weights.append(w)
		total += w
	var r := rng.randf() * total
	for k in free.size():
		r -= weights[k]
		if r <= 0.0:
			return free[k]
	return free[free.size() - 1]


func _shuffle(arr: Array, rng: RandomNumberGenerator) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp


# ---------------------------------------------------------------- queries

func is_free(i: int) -> bool:
	if i < 0 or i >= tiles.size() or not tiles[i].alive:
		return false
	for j in covered_by[i]:
		if tiles[j].alive:
			return false
	return true


func free_tiles() -> Array:
	var out: Array = []
	for i in tiles.size():
		if is_free(i):
			out.append(i)
	return out


func alive_count() -> int:
	var n := 0
	for t in tiles:
		if t.alive:
			n += 1
	return n


func slot_count() -> int:
	var n := 0
	for s in slots:
		if s != -1:
			n += 1
	return n


func remaining() -> int:
	return alive_count() + slot_count()


func cleared() -> int:
	return total_tiles - remaining()


func is_won() -> bool:
	return remaining() == 0


func first_empty_slot() -> int:
	for i in SLOT_COUNT:
		if slots[i] == -1:
			return i
	return -1


func points_per_clear() -> int:
	return 10 + maxi(level, 1) * 2


## Two refs that can be cleared together, or [] — refs are {"tile": i} / {"slot": s}.
func find_hint() -> Array:
	var by_type := {}
	for i in free_tiles():
		var t: int = tiles[i].type
		if by_type.has(t):
			return [{"tile": by_type[t]}, {"tile": i}]
		by_type[t] = i
	for s in SLOT_COUNT:
		if slots[s] != -1 and by_type.has(slots[s]):
			return [{"slot": s}, {"tile": by_type[slots[s]]}]
	return []


func has_move() -> bool:
	if not find_hint().is_empty():
		return true
	for a in SLOT_COUNT:
		for b in range(a + 1, SLOT_COUNT):
			if slots[a] != -1 and slots[a] == slots[b]:
				return true
	return false


func can_moveout() -> bool:
	return moveouts > 0 and first_empty_slot() >= 0 and not free_tiles().is_empty()


func can_undo() -> bool:
	return undos > 0 and not history.is_empty()


func can_shuffle() -> bool:
	return shuffles > 0 and alive_count() > 0


## No pair to clear and no prop left that could change that.
func is_stuck() -> bool:
	if is_won() or has_move():
		return false
	return not (can_moveout() or can_shuffle() or can_undo())


# ---------------------------------------------------------------- actions

func _register_clear(now_ms: int) -> int:
	if now_ms - last_clear_ms <= COMBO_WINDOW_MS:
		combo += 1
	else:
		combo = 1
	last_clear_ms = now_ms
	best_combo = maxi(best_combo, combo)
	var mult := 1.0 + 0.5 * mini(combo - 1, COMBO_MAX_STEPS)
	return int(round(points_per_clear() * mult))


func break_combo() -> void:
	combo = 0
	last_clear_ms = -1000000


func combo_multiplier() -> float:
	return 1.0 + 0.5 * mini(maxi(combo - 1, 0), COMBO_MAX_STEPS)


## Returns {"ok", "gain", "combo"}.
func match_tiles(a: int, b: int, now_ms: int) -> Dictionary:
	if a == b or not is_free(a) or not is_free(b) or tiles[a].type != tiles[b].type:
		return {"ok": false}
	var gain := _register_clear(now_ms)
	tiles[a].alive = false
	tiles[b].alive = false
	score += gain
	history.append({"kind": "match", "a": a, "b": b, "gain": gain})
	return {"ok": true, "gain": gain, "combo": combo}


func match_tile_with_slot(i: int, s: int, now_ms: int) -> Dictionary:
	if not is_free(i) or s < 0 or s >= SLOT_COUNT or slots[s] != tiles[i].type:
		return {"ok": false}
	var gain := _register_clear(now_ms)
	var t: int = slots[s]
	tiles[i].alive = false
	slots[s] = -1
	score += gain
	history.append({"kind": "tile_slot", "tile": i, "slot": s, "type": t, "gain": gain})
	return {"ok": true, "gain": gain, "combo": combo}


## Parks a free tile in the first empty slot. If that completes a pair inside the
## tray it clears automatically; the result says which slots popped.
func move_to_slot(i: int, now_ms: int) -> Dictionary:
	if moveouts <= 0 or not is_free(i):
		return {"ok": false}
	var s := first_empty_slot()
	if s < 0:
		return {"ok": false}
	var t: int = tiles[i].type
	tiles[i].alive = false
	slots[s] = t
	moveouts -= 1
	props_used += 1
	history.append({"kind": "to_slot", "tile": i, "slot": s, "type": t})
	var res := {"ok": true, "slot": s, "pair": []}
	for o in SLOT_COUNT:
		if o != s and slots[o] == t:
			var gain := _register_clear(now_ms)
			slots[o] = -1
			slots[s] = -1
			score += gain
			history.append({"kind": "slot_pair", "a": o, "b": s, "type": t, "gain": gain})
			res["pair"] = [o, s]
			res["gain"] = gain
			res["combo"] = combo
			break
	return res


func use_hint() -> Array:
	if hints <= 0:
		return []
	var h := find_hint()
	if not h.is_empty():
		hints -= 1
		props_used += 1
	return h


## Reverts the last action (an auto slot-pair is reverted together with the move
## that caused it). Returns the reverted actions, newest first.
func undo() -> Array:
	if not can_undo():
		return []
	var undone: Array = []
	var act: Dictionary = history.pop_back()
	_revert(act)
	undone.append(act)
	if act.kind == "slot_pair" and not history.is_empty() and history.back().kind == "to_slot":
		var prev: Dictionary = history.pop_back()
		_revert(prev)
		undone.append(prev)
	undos -= 1
	props_used += 1
	break_combo()
	return undone


func _revert(act: Dictionary) -> void:
	match act.kind:
		"match":
			tiles[act.a].alive = true
			tiles[act.b].alive = true
			score = maxi(score - int(act.gain), 0)
		"tile_slot":
			tiles[act.tile].alive = true
			slots[act.slot] = act.type
			score = maxi(score - int(act.gain), 0)
		"to_slot":
			tiles[act.tile].alive = true
			slots[act.slot] = -1
			moveouts += 1
		"slot_pair":
			slots[act.a] = act.type
			slots[act.b] = act.type
			score = maxi(score - int(act.gain), 0)


## Re-deals the tiles still on the board into a solvable arrangement (positions
## stay, types move). Slot tiles stay put; their partners land on free tiles.
func shuffle(rng: RandomNumberGenerator) -> bool:
	if not can_shuffle():
		return false
	var idx: Array = []
	var counts := {}
	for i in tiles.size():
		if tiles[i].alive:
			idx.append(i)
			counts[tiles[i].type] = int(counts.get(tiles[i].type, 0)) + 1
	var singles: Array = []
	var pairs: Array = []
	for t in counts.keys():
		var c: int = counts[t]
		if c % 2 == 1:
			singles.append(t)
			c -= 1
		for k in c / 2:
			pairs.append(t)
	var before: Array = []
	for i in idx:
		before.append(tiles[i].type)
	if not _assign_types(idx, pairs, singles, rng):
		for k in idx.size():
			tiles[idx[k]].type = before[k]
		return false
	shuffles -= 1
	props_used += 1
	history.clear()          # positions changed meaning; older steps can't be replayed
	break_combo()
	return true


# ---------------------------------------------------------------- results

## 3★ ≤ 4s per pair, 2★ ≤ 8s, else 1★.
func stars_for(elapsed: float) -> int:
	var per_pair := elapsed / maxf(total_tiles / 2.0, 1.0)
	if per_pair <= 4.0:
		return 3
	if per_pair <= 8.0:
		return 2
	return 1


func time_bonus(elapsed: float) -> int:
	var s := stars_for(elapsed)
	var lv := maxi(level, 1)
	var bonus := 0
	if s == 3:
		bonus = int(200 * lv - elapsed * 2)
	elif s == 2:
		bonus = int(100 * lv - elapsed)
	return maxi(bonus, 10 * lv)
