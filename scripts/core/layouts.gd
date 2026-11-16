extends RefCounted
## Board shapes and the level → (shape, tile-type count) curve.
##
## Coordinates are in half-tile units: a tile at (x, y) covers x..x+1, y..y+1.
## Each layer entry is [z, ox, oy, rows]; an "X" at column c / row r becomes a tile
## at (ox + 2c, oy + 2r, z). Odd offsets put a layer half a tile off the one below,
## so an upper tile can partly cover up to four tiles underneath.

const DEFS := [
	{"name": "sprout", "layers": [
		[0, 0, 0, ["XXXX", "XXXX", "XXXX"]],
		[1, 2, 1, ["XX", "XX"]],
	]},
	{"name": "bridge", "layers": [
		[0, 0, 0, ["XXXXX", "X...X", "XXXXX"]],
		[1, 1, 0, ["XXXX", "....", "XXXX"]],
	]},
	{"name": "diamond", "layers": [
		[0, 0, 0, ["..XX..", ".XXXX.", "XXXXXX", ".XXXX.", "..XX.."]],
		[1, 1, 1, [".XXXX.", "..XX.."]],
	]},
	{"name": "ring", "layers": [
		[0, 0, 0, ["XXXXXX", "X....X", "X....X", "XXXXXX"]],
		[1, 1, 1, ["X...X", "X...X", "X...X"]],
		[1, 3, 0, ["XX", "..", "..", "XX"]],
		[2, 1, 2, ["X...X"]],
	]},
	{"name": "steps", "layers": [
		[0, 0, 0, ["XXXXX", "XXXXX", "XXXXX", "XXXXX"]],
		[1, 1, 1, ["XXXX", "....", "XXXX"]],
		[2, 2, 2, ["XX"]],
	]},
	{"name": "flower", "layers": [
		[0, 0, 0, [".XXXX.", "XXXXXX", "XX..XX", "XXXXXX", ".XXXX."]],
		[1, 1, 1, ["XXXXX", "X...X", "XXXXX"]],
	]},
	{"name": "butterfly", "layers": [
		[0, 0, 0, ["XX...XX", "XXX.XXX", "XXXXXXX", "XXX.XXX", "XX...XX"]],
		[1, 1, 1, ["X....X", "XX..XX", ".X..X."]],
		[1, 5, 1, ["X", "X", "X", "X"]],
		[2, 5, 2, ["X"]],
	]},
	{"name": "pyramid", "layers": [
		[0, 0, 0, ["XXXXXX", "XXXXXX", "XXXXXX", "XXXXXX"]],
		[1, 1, 1, ["XXXXX", "XXXXX", "XXXXX"]],
		[2, 2, 2, ["XXXX", "XXX."]],
	]},
	{"name": "castle", "layers": [
		[0, 0, 0, ["X.X.X.X", "XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX"]],
		[1, 1, 3, ["XXXXXX", "XXXXXX"]],
		[2, 3, 4, ["XXXX"]],
		[1, 0, 0, ["X.....X"]],
	]},
	{"name": "towers", "layers": [
		[0, 0, 0, ["XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX"]],
		[1, 1, 1, ["XX..XX", "XX..XX", "......", "......", "XX..XX", "XX..XX"]],
		[2, 2, 2, ["X...X", ".....", ".....", "X...X"]],
	]},
	{"name": "hive", "layers": [
		[0, 0, 0, [".XXXXX.", "XXXXXXX", "XXXXXXX", "XXXXXXX", ".XXXXX.", "..XXX.."]],
		[1, 1, 1, ["XXXXXX", "XXXXXX", "XXXXXX", "XXXXXX"]],
		[2, 2, 2, ["XXXXX", "X...X", "XXXXX"]],
		[3, 3, 3, ["XXXX", "XXXX"]],
	]},
]

const DAILY_LAYOUT := 8      # castle
const DAILY_TYPES := 10
const MAX_TYPES := 12


static func build(index: int, mirror: bool = false) -> Array:
	var def: Dictionary = DEFS[clampi(index, 0, DEFS.size() - 1)]
	var out: Array = []
	for layer in def["layers"]:
		var z: int = layer[0]
		var ox: int = layer[1]
		var oy: int = layer[2]
		var rows: Array = layer[3]
		for r in rows.size():
			var row: String = rows[r]
			for c in row.length():
				if row[c] == "X":
					out.append({"x": ox + 2 * c, "y": oy + 2 * r, "z": z})
	if mirror:
		var max_x := 0
		for p in out:
			max_x = maxi(max_x, p.x)
		for p in out:
			p.x = max_x - p.x
	return out


## Shape + number of distinct tile types for a campaign level (1-based).
## Levels 1..11 walk through every shape once; after that the four biggest shapes
## rotate (sometimes mirrored) with the full icon set.
static func config_for_level(level: int) -> Dictionary:
	var lv := maxi(level, 1)
	var index: int
	var mirror := false
	if lv <= DEFS.size():
		index = lv - 1
	else:
		var k := lv - DEFS.size() - 1
		index = DEFS.size() - 4 + (k % 4)
		mirror = (k / 4) % 2 == 1
	var types := mini(4 + lv / 2, MAX_TYPES)
	var n := build(index).size()
	types = mini(types, n / 2)
	return {"index": index, "mirror": mirror, "types": types, "name": DEFS[index]["name"]}


static func daily_config() -> Dictionary:
	return {"index": DAILY_LAYOUT, "mirror": false, "types": DAILY_TYPES, "name": DEFS[DAILY_LAYOUT]["name"]}
