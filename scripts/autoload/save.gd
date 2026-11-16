extends Node
## Player profile, progress and settings in user://player_data.cfg.
## Keeps every key v0.4 wrote, so existing players keep their levels and stars.

const PATH := "user://player_data.cfg"
const SCHEMA := 3

var player_name := ""
var player_avatar := 0
var max_level := 1
var total_score := 0
var level_stars: Array = []        # index 0 = level 1
var level_best: Array = []         # best score per level

var bgm_volume := 0.7
var bgm_enabled := true
var sfx_volume := 0.8
var sfx_enabled := true
var vibrate := true
var lang := "zh_CN"

var daily_last_played := ""        # date the streak was last extended
var daily_best := 0
var daily_best_date := ""          # date daily_best belongs to
var daily_streak := 0

var path := PATH                   # tests point this somewhere else


func _ready() -> void:
	load_data()


func has_profile() -> bool:
	return player_name != ""


func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return
	player_name = cfg.get_value("player", "name", "")
	player_avatar = int(cfg.get_value("player", "avatar", 0))
	max_level = int(cfg.get_value("progress", "max_level", 1))
	total_score = int(cfg.get_value("progress", "total_score", 0))
	level_stars = Array(cfg.get_value("progress", "level_stars", []))
	level_best = Array(cfg.get_value("progress", "level_best", []))
	while level_stars.size() < max_level - 1:
		level_stars.append(1)       # levels finished before stars existed
	bgm_volume = float(cfg.get_value("settings", "volume", 0.7))
	bgm_enabled = bool(cfg.get_value("settings", "bgm_enabled", true))
	sfx_volume = float(cfg.get_value("settings", "sfx_volume", 0.8))
	sfx_enabled = bool(cfg.get_value("settings", "sfx_enabled", true))
	vibrate = bool(cfg.get_value("settings", "vibrate", true))
	lang = str(cfg.get_value("settings", "lang", "zh_CN"))
	daily_last_played = str(cfg.get_value("daily", "last_played", ""))
	daily_best = int(cfg.get_value("daily", "best", 0))
	daily_streak = int(cfg.get_value("daily", "streak", 0))
	# v0.4 never reset the daily best between days; it only belonged to the last day played.
	daily_best_date = str(cfg.get_value("daily", "best_date", daily_last_played))


func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("player", "name", player_name)
	cfg.set_value("player", "avatar", player_avatar)
	cfg.set_value("progress", "max_level", max_level)
	cfg.set_value("progress", "total_score", total_score)
	cfg.set_value("progress", "level_stars", level_stars)
	cfg.set_value("progress", "level_best", level_best)
	cfg.set_value("settings", "volume", bgm_volume)
	cfg.set_value("settings", "bgm_enabled", bgm_enabled)
	cfg.set_value("settings", "sfx_volume", sfx_volume)
	cfg.set_value("settings", "sfx_enabled", sfx_enabled)
	cfg.set_value("settings", "vibrate", vibrate)
	cfg.set_value("settings", "lang", lang)
	cfg.set_value("daily", "last_played", daily_last_played)
	cfg.set_value("daily", "best", daily_best)
	cfg.set_value("daily", "best_date", daily_best_date)
	cfg.set_value("daily", "streak", daily_streak)
	cfg.set_value("meta", "schema", SCHEMA)
	cfg.save(path)


func stars_for_level(lv: int) -> int:
	return int(level_stars[lv - 1]) if lv >= 1 and lv <= level_stars.size() else 0


func best_for_level(lv: int) -> int:
	return int(level_best[lv - 1]) if lv >= 1 and lv <= level_best.size() else 0


## Returns {"new_best": bool, "unlocked": bool}.
func record_level(lv: int, stars: int, score: int) -> Dictionary:
	while level_stars.size() < lv:
		level_stars.append(0)
	while level_best.size() < lv:
		level_best.append(0)
	level_stars[lv - 1] = maxi(int(level_stars[lv - 1]), stars)
	var new_best := score > int(level_best[lv - 1])
	if new_best:
		level_best[lv - 1] = score
	var unlocked := lv + 1 > max_level
	max_level = maxi(max_level, lv + 1)
	total_score += score
	save()
	return {"new_best": new_best, "unlocked": unlocked}


func today_best(today: String) -> int:
	return daily_best if daily_best_date == today else 0


## A streak only survives when yesterday was played as well.
func current_streak(today: String) -> int:
	if daily_last_played == today or daily_last_played == yesterday_of(today):
		return daily_streak
	return 0


func record_daily(score: int, today: String) -> Dictionary:
	var new_best := score > today_best(today)
	if daily_best_date != today:
		daily_best = 0
		daily_best_date = today
	daily_best = maxi(daily_best, score)
	if daily_last_played != today:
		daily_streak = daily_streak + 1 if daily_last_played == yesterday_of(today) else 1
		daily_last_played = today
	elif daily_streak <= 0:
		daily_streak = 1
	save()
	return {"new_best": new_best}


static func yesterday_of(date_str: String) -> String:
	var unix := Time.get_unix_time_from_datetime_string(date_str + "T12:00:00")
	return Time.get_date_string_from_unix_time(unix - 86400)
