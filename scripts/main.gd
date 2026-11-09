extends Node2D

# FLUFFY羊羊乐风格小游戏 - 简单堆叠配对消除
# 移动端友好，休闲小游戏

const TILE_TYPES = ["羊", "草", "米", "田", "兔", "狼"]
const COLORS = [
	Color(1.0, 0.8, 0.8),  # 羊 粉
	Color(0.6, 0.9, 0.6),  # 草 绿
	Color(1.0, 0.95, 0.6), # 米 黄
	Color(0.8, 0.7, 0.5),  # 田 棕
	Color(1.0, 0.85, 0.9), # 兔 浅粉
	Color(0.7, 0.7, 0.9),  # 狼 紫
]

# ====================== UI COLOR PALETTE ======================
# Warm, inviting palette for a cute casual matching game
# --- Background & Surfaces ---
const COLOR_SURFACE_DARK  = Color(0.282, 0.220, 0.184, 0.95)  # warm dark panel bg
const COLOR_OVERLAY       = Color(0.078, 0.051, 0.020, 0.55)  # warm dark overlay
const COLOR_OVERLAY_DEEP  = Color(0.078, 0.051, 0.020, 0.85)  # deep overlay for modals
const COLOR_ACCENT_GOLD   = Color(1.000, 0.851, 0.250)        # gold accent borders
# --- Text ---
const COLOR_TEXT_LIGHT    = Color(1.000, 0.969, 0.922)        # light warm text on dark
const COLOR_TEXT_MUTED    = Color(0.753, 0.682, 0.600)        # muted text
const COLOR_TEXT_GOLD     = Color(1.000, 0.780, 0.149)        # gold text
const COLOR_TEXT_DARK     = Color(0.220, 0.149, 0.102)        # dark text on cream bg
# --- Buttons ---
const COLOR_BTN_GREEN     = Color(0.451, 0.780, 0.451)        # start / continue
const COLOR_BTN_RED       = Color(0.882, 0.400, 0.353)        # quit / exit
const COLOR_BTN_BLUE      = Color(0.498, 0.620, 0.820)        # settings
const COLOR_BTN_ORANGE    = Color(1.000, 0.722, 0.400)        # shuffle
const COLOR_BTN_ROSE      = Color(0.780, 0.502, 0.400)        # restart
const COLOR_BTN_NEUTRAL   = Color(0.651, 0.549, 0.451)        # pause / close
const COLOR_BTN_PURPLE    = Color(0.627, 0.514, 0.784)        # daily challenge
# --- Sizing ---
const RADIUS_LARGE  = 24
const RADIUS_MEDIUM = 18
const RADIUS_PILL   = 28
const SHADOW_SIZE   = 6
const SHADOW_OFFSET = 3

# ====================== v0.4 GAMEPLAY TUNING ======================
const VERSION := "0.4.0"
const COMBO_WINDOW := 3.0        # seconds between two clears to keep the combo alive
const COMBO_MAX_STEPS := 4       # +50% score per combo step, capped
const SLOT_COUNT := 3            # holding slots for the "move out" prop
const HINT_CHARGES := 3
const UNDO_CHARGES := 3
const MOVEOUT_CHARGES := 3
const DAILY_CARDS := 32

# ====================== LOCALIZATION ======================
const LOCALE = {
	"zh_CN": {
		"tile_sheep": "羊", "tile_grass": "草", "tile_rice": "米",
		"tile_field": "田", "tile_rabbit": "兔", "tile_wolf": "狼",
		"game_title": "FLUFFY羊羊乐",
		"game_subtitle": "可爱配对消除 · 休闲小游戏",
		"btn_start": "开始游戏", "btn_continue": "继续游戏",
		"btn_settings": "设置", "btn_quit": "退出游戏",
		"btn_about": "关于", "btn_close": "关闭",
		"btn_shuffle": "洗牌", "btn_restart": "重来",
		"btn_pause": "⏸ 暂停", "btn_next": "下一关",
		"btn_resume": "继续游戏", "btn_exit_main": "退出至主页",
		"btn_back": "← 返回",
		"lbl_level": "第 %d 关", "lbl_score": "得分: %d",
		"lbl_remaining": "剩余: %d", "lbl_total_score": "总分: %d",
		"lbl_level_progress": "Lv.%d",
		"selected_one": "选中: %s", "select_another": "再选一个",
		"msg_match": "消除成功！", "msg_no_match": "不匹配！",
		"msg_no_moves": "牌面已无解！点击【洗牌】继续",
		"msg_shuffled": "已洗牌",
		"msg_shuffled_solvable": "已洗牌（可解重排）",
		"msg_shuffled_auto": "已洗牌（系统已自动重排直到有解）",
		# --- v0.4: props / combo / daily ---
		"btn_daily": "每日挑战",
		"btn_hint": "提示",
		"btn_undo": "撤销",
		"btn_moveout": "移出",
		"msg_hint_none": "暂时没有可消的对子，试试洗牌",
		"msg_hint_used": "已高亮一对，快消掉它！",
		"msg_undo_empty": "没有可撤销的操作",
		"msg_undo_done": "已撤销一步",
		"msg_charges_empty": "该道具次数已用完",
		"msg_pick_tile": "先点选一张牌",
		"msg_slot_empty": "先选一张牌，再点【移出】",
		"msg_slot_match": "槽位消除！",
		"msg_daily_locked": "今天的挑战已完成，明天再来",
		"combo_text": "连击 ×%d",
		"daily_title": "每日挑战",
		"daily_sub": "每天一副固定牌面 · 全服同款",
		"daily_done": "今日挑战完成！",
		"daily_best": "今日最佳：%d",
		"daily_streak": "🔥 连续 %d 天",
		"lbl_streak": "🔥 %d",
		"win_combo_best": "最高连击：×%d",
		"win_daily_best": "今日最佳成绩：%d",
		"win_title": "🌟 通关！",
		"win_level_done": "第 %d 关完成",
		"win_time": "用时: %s",
		"win_score": "本关得分: %d (+%d 时间奖励)",
		"pause_title": "游戏暂停",
		"settings_title": "设置",
		"settings_volume": "背景音乐音量",
		"settings_bgm": "开启背景音乐",
		"settings_lang": "语言 / Language",
		"about_title": "关于",
		"about_text": "作者：ShiZixian (Zan)\n\n编程协助：Grok & Claude Code\n\n这是一个基于《FLUFFY羊羊乐》的休闲消除类小游戏。\n感谢游玩！\n\n© 2026",
		"select_level": "关卡选择",
		"profile_create": "创建玩家档案",
		"profile_edit": "修改档案",
		"profile_username": "用户名:",
		"profile_name_placeholder": "输入你的名字",
		"profile_avatar": "选择头像",
		"profile_confirm_create": "创建并开始",
		"profile_confirm_save": "保存修改",
		"default_name": "玩家",
		"level_new": "NEW",
		"timer_format": "⏱ %02d:%02d",
	},
	"zh_TW": {
		"tile_sheep": "羊", "tile_grass": "草", "tile_rice": "米",
		"tile_field": "田", "tile_rabbit": "兔", "tile_wolf": "狼",
		"game_title": "FLUFFY羊羊樂",
		"game_subtitle": "可愛配對消除 · 休閒小遊戲",
		"btn_start": "開始遊戲", "btn_continue": "繼續遊戲",
		"btn_settings": "設定", "btn_quit": "退出遊戲",
		"btn_about": "關於", "btn_close": "關閉",
		"btn_shuffle": "洗牌", "btn_restart": "重來",
		"btn_pause": "⏸ 暫停", "btn_next": "下一關",
		"btn_resume": "繼續遊戲", "btn_exit_main": "退出至主頁",
		"btn_back": "← 返回",
		"lbl_level": "第 %d 關", "lbl_score": "得分: %d",
		"lbl_remaining": "剩餘: %d", "lbl_total_score": "總分: %d",
		"lbl_level_progress": "Lv.%d",
		"selected_one": "選中: %s", "select_another": "再選一個",
		"msg_match": "消除成功！", "msg_no_match": "不匹配！",
		"msg_no_moves": "牌面已無解！點擊【洗牌】繼續",
		"msg_shuffled": "已洗牌",
		"msg_shuffled_solvable": "已洗牌（可解重排）",
		"msg_shuffled_auto": "已洗牌（系統已自動重排直到有解）",
		# --- v0.4: props / combo / daily ---
		"btn_daily": "每日挑戰",
		"btn_hint": "提示",
		"btn_undo": "撤銷",
		"btn_moveout": "移出",
		"msg_hint_none": "暫時沒有可消的對子，試試洗牌",
		"msg_hint_used": "已高亮一對，快消掉它！",
		"msg_undo_empty": "沒有可撤銷的操作",
		"msg_undo_done": "已撤銷一步",
		"msg_charges_empty": "該道具次數已用完",
		"msg_pick_tile": "先點選一張牌",
		"msg_slot_empty": "先選一張牌，再點【移出】",
		"msg_slot_match": "槽位消除！",
		"msg_daily_locked": "今天的挑戰已完成，明天再來",
		"combo_text": "連擊 ×%d",
		"daily_title": "每日挑戰",
		"daily_sub": "每天一副固定牌面 · 全服同款",
		"daily_done": "今日挑戰完成！",
		"daily_best": "今日最佳：%d",
		"daily_streak": "🔥 連續 %d 天",
		"lbl_streak": "🔥 %d",
		"win_combo_best": "最高連擊：×%d",
		"win_daily_best": "今日最佳成績：%d",
		"win_title": "🌟 通關！",
		"win_level_done": "第 %d 關完成",
		"win_time": "用時: %s",
		"win_score": "本關得分: %d (+%d 時間獎勵)",
		"pause_title": "遊戲暫停",
		"settings_title": "設定",
		"settings_volume": "背景音樂音量",
		"settings_bgm": "開啟背景音樂",
		"settings_lang": "語言 / Language",
		"about_title": "關於",
		"about_text": "作者：ShiZixian (Zan)\n\n程式協助：Grok & Claude Code\n\n這是一個基於《FLUFFY羊羊樂》的休閒消除類小遊戲。\n感謝遊玩！\n\n© 2026",
		"select_level": "關卡選擇",
		"profile_create": "創建玩家檔案",
		"profile_edit": "修改檔案",
		"profile_username": "用戶名:",
		"profile_name_placeholder": "輸入你的名字",
		"profile_avatar": "選擇頭像",
		"profile_confirm_create": "創建並開始",
		"profile_confirm_save": "儲存修改",
		"default_name": "玩家",
		"level_new": "NEW",
		"timer_format": "⏱ %02d:%02d",
	},
	"en": {
		"tile_sheep": "Sheep", "tile_grass": "Grass", "tile_rice": "Rice",
		"tile_field": "Field", "tile_rabbit": "Rabbit", "tile_wolf": "Wolf",
		"game_title": "FLUFFY",
		"game_subtitle": "Cute Matching Puzzle · Casual Game",
		"btn_start": "Start", "btn_continue": "Continue",
		"btn_settings": "Settings", "btn_quit": "Quit",
		"btn_about": "About", "btn_close": "Close",
		"btn_shuffle": "Shuffle", "btn_restart": "Restart",
		"btn_pause": "⏸ Pause", "btn_next": "Next",
		"btn_resume": "Continue", "btn_exit_main": "Exit to Menu",
		"btn_back": "← Back",
		"lbl_level": "Level %d", "lbl_score": "Score: %d",
		"lbl_remaining": "Left: %d", "lbl_total_score": "Total: %d",
		"lbl_level_progress": "Lv.%d",
		"selected_one": "Selected: %s", "select_another": "Pick another",
		"msg_match": "Match!", "msg_no_match": "No match!",
		"msg_no_moves": "No moves! Tap Shuffle",
		"msg_shuffled": "Shuffled!",
		"msg_shuffled_solvable": "Shuffled (solvable)",
		"msg_shuffled_auto": "Shuffled (auto-solved)",
		# --- v0.4: props / combo / daily ---
		"btn_daily": "Daily",
		"btn_hint": "Hint",
		"btn_undo": "Undo",
		"btn_moveout": "Move",
		"msg_hint_none": "No matching pair right now — try Shuffle",
		"msg_hint_used": "A pair is highlighted!",
		"msg_undo_empty": "Nothing to undo",
		"msg_undo_done": "Undone",
		"msg_charges_empty": "No charges left",
		"msg_pick_tile": "Pick a tile first",
		"msg_slot_empty": "Select a tile, then tap Move",
		"msg_slot_match": "Slot cleared!",
		"msg_daily_locked": "Today's challenge is done — come back tomorrow",
		"combo_text": "Combo ×%d",
		"daily_title": "Daily Challenge",
		"daily_sub": "One fixed board a day · Same for everyone",
		"daily_done": "Daily Challenge Cleared!",
		"daily_best": "Today's best: %d",
		"daily_streak": "🔥 %d-day streak",
		"lbl_streak": "🔥 %d",
		"win_combo_best": "Best combo: ×%d",
		"win_daily_best": "Today's best score: %d",
		"win_title": "🌟 Cleared!",
		"win_level_done": "Level %d Complete",
		"win_time": "Time: %s",
		"win_score": "Score: %d (+%d bonus)",
		"pause_title": "Game Paused",
		"settings_title": "Settings",
		"settings_volume": "BGM Volume",
		"settings_bgm": "Enable BGM",
		"settings_lang": "Language",
		"about_title": "About",
		"about_text": "Author: ShiZixian (Zan)\n\nCode: Grok & Claude Code\n\nA casual matching puzzle game.\nThanks for playing!\n\n© 2026",
		"select_level": "Select Level",
		"profile_create": "Create Profile",
		"profile_edit": "Edit Profile",
		"profile_username": "Username:",
		"profile_name_placeholder": "Enter your name",
		"profile_avatar": "Choose Avatar",
		"profile_confirm_create": "Create & Start",
		"profile_confirm_save": "Save Changes",
		"default_name": "Player",
		"level_new": "NEW",
		"timer_format": "⏱ %02d:%02d",
	},
}

const LANG_NAMES = {
	"zh_CN": "简体中文",
	"zh_TW": "繁体中文",
	"en": "English",
}
const LANG_LIST = ["zh_CN", "zh_TW", "en"]
const TILE_TRANSLATION_KEYS = ["tile_sheep", "tile_grass", "tile_rice", "tile_field", "tile_rabbit", "tile_wolf"]

# ====================== UI HELPERS ======================

func _make_panel_style(radius: int = RADIUS_LARGE) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = COLOR_SURFACE_DARK
	s.set_corner_radius_all(radius)
	s.border_width_left = 1
	s.border_width_right = 1
	s.border_width_top = 1
	s.border_width_bottom = 1
	s.border_color = Color(1, 0.95, 0.85, 0.06)
	s.shadow_size = SHADOW_SIZE
	s.shadow_offset = Vector2(0, SHADOW_OFFSET)
	s.shadow_color = Color(0, 0, 0, 0.3)
	return s

func _make_pill_style(bg_color: Color = COLOR_SURFACE_DARK) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = bg_color
	s.set_corner_radius_all(RADIUS_PILL)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 4
	s.content_margin_bottom = 4
	return s

func _add_pill_behind(label_node: Label, extra_padding: Vector2 = Vector2(24, 10)) -> void:
	# Place a semi-transparent pill Panel behind the label (as sibling, no reparenting)
	var pill = Panel.new()
	pill.name = label_node.name + "Pill"
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill.position = label_node.position - extra_padding / 2
	pill.size = label_node.size + extra_padding
	var style = _make_pill_style(Color(COLOR_SURFACE_DARK.r, COLOR_SURFACE_DARK.g, COLOR_SURFACE_DARK.b, 0.7))
	pill.add_theme_stylebox_override("panel", style)
	label_node.get_parent().add_child(pill)
	label_node.get_parent().move_child(pill, label_node.get_index())

func _fade_in(ctrl, dur: float = 0.2) -> void:
	ctrl.modulate.a = 0.0
	ctrl.visible = true
	var t = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(ctrl, "modulate:a", 1.0, dur)

func _fade_out(ctrl, dur: float = 0.15) -> void:
	var t = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.tween_property(ctrl, "modulate:a", 0.0, dur)
	t.tween_callback(func(): ctrl.visible = false)

func _t(key: String, args = []) -> String:
	var dict = LOCALE.get(current_lang, LOCALE["zh_CN"])
	var template: String = dict.get(key, key)
	if args.is_empty():
		return template
	return template % args

func _tile_name(type_idx: int) -> String:
	return _t(TILE_TRANSLATION_KEYS[min(type_idx, TILE_TRANSLATION_KEYS.size() - 1)])

# Cartoon tile icons (flat cute cartoon patterns, one per type).
# Files are in res://assets/icons/ — you can replace any .jpg with nicer PNGs from the web.
var icon_textures: Array[Texture2D] = [
	preload("res://assets/icons/sheep.jpg"),
	preload("res://assets/icons/grass.jpg"),
	preload("res://assets/icons/rice.jpg"),
	preload("res://assets/icons/field.jpg"),
	preload("res://assets/icons/rabbit.jpg"),
	preload("res://assets/icons/wolf.jpg"),
]

var level: int = 1
var score: int = 0
var remaining_tiles: int = 0
var elapsed_time: float = 0.0
var timer_running: bool = false
var timer_label: Label

# ====================== BOARD LAYOUTS (v0.4) ======================
# Several board shapes, rotated by level so the campaign stops looking identical.
# rows:   rows[gy] = [gx_start, gx_end]  (a contiguous run of tiles, layer 0)
# stacks: [gx, gy, max_layer]            (layers 1..max_layer stacked on that cell)
const LAYOUT_DEFS = [
	{
		"name": "diamond",
		"rows": [[2, 3], [1, 4], [0, 5], [1, 4], [2, 3]],
		"stacks": [[2, 2, 2], [3, 2, 2], [2, 3, 1], [3, 3, 1]],
	},
	{
		"name": "pyramid",
		"rows": [[2, 3], [1, 4], [0, 5], [0, 5], [1, 4]],
		"stacks": [[2, 3, 2], [3, 3, 2], [2, 2, 1], [3, 2, 1]],
	},
	{
		"name": "wide",
		"rows": [[0, 5], [0, 5], [0, 5], [1, 4]],
		"stacks": [[1, 1, 2], [2, 1, 2], [3, 1, 2], [4, 1, 2]],
	},
	{
		"name": "classic",
		"rows": [[2, 3], [1, 4], [0, 5], [0, 5], [1, 4]],
		"stacks": [[2, 2, 3], [3, 2, 3], [4, 2, 2], [1, 2, 1], [5, 2, 1]],
	},
	{
		"name": "towers",
		"rows": [[0, 5], [0, 5], [0, 5], [0, 5]],
		"stacks": [[0, 2, 2], [1, 2, 2], [2, 2, 2], [3, 2, 2], [4, 2, 2], [5, 2, 2]],
	},
]

var layout: Array = []
var layout_index := 0

var cards = []  # each {gx, gy, layer, type, node}

var selected_idx = -1  # index in cards, or -1
var selected_node = null  # the node for highlight, for convenience

@onready var board_node: Node2D = $Board
@onready var level_label: Label = $UI/LevelLabel
@onready var score_label: Label = $UI/ScoreLabel
@onready var remaining_label: Label = $UI/RemainingLabel
@onready var message_label: Label = $UI/MessageLabel
@onready var shuffle_button: Button = $UI/ShuffleButton
@onready var restart_button: Button = $UI/RestartButton
@onready var win_panel: Panel = $UI/WinPanel
@onready var next_button: Button = $UI/WinPanel/NextButton

# New menu system
var main_menu: CanvasLayer
var level_select: Control
var pause_menu: Control
var pause_button: Button
var cover_texture: Texture2D
var paused = false
var about_dialog: AcceptDialog
var bgm_player: AudioStreamPlayer
var settings_menu: Control
var bgm_volume := 0.7
var bgm_enabled := true
var current_lang := "zh_CN"
var _shuffle_message_showing := false
var lang_selector: OptionButton
var lang_selector_pause: OptionButton
var pause_vol_slider: HSlider
var settings_vol_slider: HSlider
var pause_bgm_check: CheckBox
var settings_bgm_check: CheckBox

# Language refresh references
var _r_menu_title: Label
var _r_menu_subtitle: Label
var _r_menu_start: Button
var _r_menu_settings: Button
var _r_menu_quit: Button
var _r_menu_about: Button
var _r_settings_title: Label
var _r_settings_vol_label: Label
var _r_settings_close: Button
var _r_pause_title: Label
var _r_pause_resume: Button
var _r_pause_exit: Button
var _r_pause_vol_label: Label
var _r_level_select_title: Label
var _r_level_select_total: Label
var _r_level_select_back: Button

# Player profile and progress
var player_name := ""
var player_avatar := 0  # 0-5 corresponding to icon_textures
var max_level := 1
var level_stars: Array = []  # per-level stars (index 0 = level 1)
var total_score := 0
var selected_avatar_for_profile := 0
var safe_left_margin := 50  # adjusted for camera cutouts on mobile
var _safe_area_detected := false

# ====================== v0.4 RUNTIME STATE ======================
var _rng := RandomNumberGenerator.new()
var _last_generation_order: Array = []   # placement order of the solvable generator (for tests)
var run_label := ""                      # "Level 3" / "Daily Challenge"
var level_total_cards := 0               # tiles dealt this run (drives star rating)

var hints_left := 0
var undos_left := 0
var moveouts_left := 0

var history: Array = []                  # undo stack: match / slot_move / slot_pair
var slot_tiles: Array = []               # SLOT_COUNT entries: {type, node} or null
var selected_slot := -1

var combo_count := 0
var best_combo := 0
var last_match_msec := -1000000

var is_daily := false
var daily_date := ""
var daily_seed := 0
var daily_best := 0
var daily_streak := 0
var daily_last_played := ""

# v0.4 UI nodes
var hint_btn: Button
var undo_btn: Button
var moveout_btn: Button
var combo_label: Label
var slot_panels: Array = []
var slot_buttons: Array = []
var daily_btn: Button
var daily_badge: Label
var _msg_seq := 0

func _ready() -> void:
	shuffle_button.pressed.connect(_on_shuffle_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	next_button.pressed.connect(_on_next_level)

	# Style HUD buttons (scene-defined, no styling yet)
	_make_rounded_button(shuffle_button, COLOR_BTN_ORANGE, RADIUS_PILL)
	shuffle_button.size = Vector2(160, 62)
	shuffle_button.position = Vector2(355, 1145)
	_make_rounded_button(restart_button, COLOR_BTN_ROSE, RADIUS_PILL)
	restart_button.size = Vector2(160, 62)
	restart_button.position = Vector2(530, 1145)

	# Set button texts (translated)
	shuffle_button.text = _t("btn_shuffle")
	restart_button.text = _t("btn_restart")

	# Style HUD labels — add pill backgrounds behind them (as siblings, no reparenting)
	_add_pill_behind(level_label)
	_add_pill_behind(score_label)
	_add_pill_behind(remaining_label)

	# HUD pills are dark, so the scene's dark text needs to be light
	for lbl in [level_label, score_label, remaining_label]:
		lbl.add_theme_color_override("font_color", COLOR_TEXT_LIGHT)

	# Message label styling
	message_label.add_theme_color_override("font_color", COLOR_TEXT_GOLD)
	message_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.4))
	message_label.add_theme_font_size_override("font_size", 48)

	# WinPanel styling — unified panel with gold border
	var win_style = _make_panel_style()
	win_style.bg_color = Color(COLOR_SURFACE_DARK.r, COLOR_SURFACE_DARK.g, COLOR_SURFACE_DARK.b, 0.93)
	win_style.border_color = COLOR_ACCENT_GOLD
	win_style.border_width_left = 2
	win_style.border_width_right = 2
	win_style.border_width_top = 2
	win_style.border_width_bottom = 2
	win_panel.add_theme_stylebox_override("panel", win_style)

	# Style NextButton
	_make_rounded_button(next_button, COLOR_BTN_GREEN, RADIUS_MEDIUM)
	next_button.add_theme_font_size_override("font_size", 36)
	next_button.text = _t("btn_next")

	# Load cover (AI generated)
	cover_texture = load("res://assets/cover.jpg")

	# Ensure original title (and any selected/highlighted text from scene) is not visible on main menu
	$UI/TitleLabel.visible = false

	# Setup menus
	_setup_pause_button()
	_setup_pause_menu()
	_setup_main_menu()
	_setup_about_dialog()
	_setup_bgm()
	_setup_settings_menu()
	_setup_timer_label()
	_setup_slot_ui()
	_setup_props_ui()
	_setup_combo_label()

	# Load player data before building level select (needs max_level/level_stars)
	load_player_data()
	_setup_level_select()

	# Sync initial slider values
	if pause_vol_slider:
		pause_vol_slider.value = bgm_volume
	if settings_vol_slider:
		settings_vol_slider.value = bgm_volume
	apply_volume()

	# Start BGM if enabled
	if bgm_player and bgm_player.stream and bgm_enabled:
		bgm_player.volume_db = linear_to_db(bgm_volume)
		bgm_player.play()

	# Initial state — hide game UI, show main menu directly
	_hide_game_ui()

	# Defer cutout detection to avoid blocking _ready
	_safe_area_detected = false
	call_deferred("_detect_safe_area")
	if player_name == "":
		main_menu.visible = true
		show_profile_creation()
	else:
		show_main_menu()
		pause_menu.visible = false
		pause_button.visible = false

func _process(delta: float) -> void:
	if timer_running and not paused:
		elapsed_time += delta
		_update_timer_display()

func _update_timer_display():
	if timer_label:
		var total_secs = int(elapsed_time)
		var mins = total_secs / 60
		var secs = total_secs % 60
		timer_label.text = _t("timer_format", [mins, secs])

func start_level(new_level: int) -> void:
	is_daily = false
	level = new_level
	score = 0 if level == 1 else score
	run_label = _t("lbl_level", [level])
	var def := _layout_def_for_level(level)
	_begin_run(def, 16 + (level - 1) * 5)


func start_daily() -> void:
	is_daily = true
	daily_date = Time.get_date_string_from_system()
	daily_seed = int(daily_date.hash())
	level = 1
	score = 0
	run_label = _t("daily_title")
	# Fixed layout every player sees on the same day, driven by the date seed.
	_begin_run(LAYOUT_DEFS[3], DAILY_CARDS, daily_seed)


func _begin_run(def: Dictionary, target_wanted: int, seed_value: int = -1) -> void:
	if seed_value >= 0:
		_rng.seed = seed_value
	else:
		_rng.randomize()

	layout_index = max(LAYOUT_DEFS.find(def), 0)
	layout = _build_layout(def)

	remaining_tiles = 0
	elapsed_time = 0.0
	timer_running = true
	_update_timer_display()
	message_label.text = ""
	message_label.visible = false
	win_panel.visible = false
	_clear_selection()
	_clear_slots()
	if combo_label and is_instance_valid(combo_label):
		combo_label.visible = false
	update_ui()

	# Clear previous board
	for child in board_node.get_children():
		child.queue_free()

	cards.clear()
	for pos in layout:
		cards.append({"gx": pos.gx, "gy": pos.gy, "layer": pos.layer, "type": -1, "node": null})

	hints_left = HINT_CHARGES
	undos_left = UNDO_CHARGES
	moveouts_left = MOVEOUT_CHARGES
	history.clear()
	combo_count = 0
	best_combo = 0
	last_match_msec = -1000000

	# Number of tiles for this run (always even).
	var target_cards := int(clamp(target_wanted, 8, cards.size()))
	if target_cards % 2 == 1:
		target_cards += 1
	level_total_cards = target_cards

	# More tile types on later levels / daily = harder to find a pair on the surface.
	var num_types := int(min(4 + max(level, 1), TILE_TYPES.size()))
	if is_daily:
		num_types = TILE_TYPES.size()
	var pairs_total := int(target_cards / 2)
	var pairs_per := int(pairs_total / num_types)
	var extra_pairs := int(pairs_total % num_types)
	var types_pool: Array = []
	for i in range(num_types):
		var this_pairs := pairs_per + (1 if i < extra_pairs else 0)
		for k in range(this_pairs * 2):
			types_pool.append(i)

	var needed: Dictionary = {}
	for t in types_pool:
		needed[t] = needed.get(t, 0) + 1

	var generated := generate_solvable_layout(needed)
	if not generated:
		# Defensive fallback only — the new generator should always succeed.
		var slot_indices: Array = range(cards.size())
		_shuffle(slot_indices)
		for i in range(target_cards):
			cards[slot_indices[i]].type = types_pool[i]

	for p in slot_panels:
		p.visible = true
	for b in [hint_btn, undo_btn, moveout_btn]:
		if b and is_instance_valid(b):
			b.visible = true
	pause_button.visible = true
	shuffle_button.visible = true
	restart_button.visible = true

	render_cards()
	remaining_tiles = target_cards
	refresh_props_ui()
	update_ui()
	check_for_moves()


func _card_position(c) -> Vector2:
	return Vector2(25 + c.gx * 104 + (c.gy % 2) * 24, 110 + c.gy * 82 - c.layer * 22)


func render_cards() -> void:
	for i in range(cards.size()):
		var c = cards[i]
		if c.type == -1:
			continue
		var node = create_tile_node(c.type, i)
		node.position = _card_position(c)
		board_node.add_child(node)
		c.node = node

func create_tile_node(type_idx: int, card_idx: int) -> Node2D:
	var node = Node2D.new()

	var icon_size := 72
	var half := icon_size / 2.0

	# Rounded card behind the artwork — makes stacked tiles read as cards instead of
	# square crops, and frames the (white-background) icon images.
	var card := Panel.new()
	card.name = "Card"
	card.size = Vector2(icon_size + 10, icon_size + 10)
	card.position = -card.size / 2.0
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(1.0, 0.99, 0.955)
	card_style.set_corner_radius_all(14)
	card_style.border_width_left = 1
	card_style.border_width_right = 1
	card_style.border_width_top = 1
	card_style.border_width_bottom = 1
	card_style.border_color = Color(0.35, 0.26, 0.20, 0.20)
	card_style.shadow_size = 3
	card_style.shadow_offset = Vector2(0, 2)
	card_style.shadow_color = Color(0, 0, 0, 0.16)
	card.add_theme_stylebox_override("panel", card_style)
	node.add_child(card)

	# Selection border (behind the icon, one step bigger so it stays visible)
	var sel_border = ColorRect.new()
	sel_border.name = "SelBorder"
	sel_border.size = Vector2(icon_size + 12, icon_size + 12)
	sel_border.color = Color(1, 0.85, 0, 0)
	sel_border.position = -sel_border.size / 2.0
	sel_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_child(sel_border)

	# Use a BUTTON for each card — native touch handling, works 100% on mobile.
	# Flat style = no visible button chrome, just the icon.
	var btn := Button.new()
	btn.name = "CardBtn"
	btn.size = Vector2(icon_size + 14, icon_size + 14)
	btn.position = Vector2(-half - 7, -half - 7)
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	# Make button invisible — show only the icon inside
	var empty_style := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty_style)
	btn.add_theme_stylebox_override("hover", empty_style)
	btn.add_theme_stylebox_override("pressed", empty_style)
	btn.add_theme_stylebox_override("focus", empty_style)
	btn.pressed.connect(_on_card_button_pressed.bind(card_idx))
	node.add_child(btn)

	# Icon on top of button (mouse_filter=IGNORE so touches pass to button)
	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.texture = icon_textures[type_idx]
	icon.size = Vector2(icon_size, icon_size)
	icon.position = Vector2(-half, -half)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Lower layers sit slightly in shadow so the pile reads as depth.
	var depth := 0
	if card_idx >= 0 and card_idx < cards.size():
		depth = int(cards[card_idx].layer)
	var tint := clampf(1.0 - depth * 0.06, 0.78, 1.0)
	icon.modulate = Color(tint, tint, tint)
	node.add_child(icon)

	return node

func _on_card_button_pressed(card_idx: int) -> void:
	if paused or win_panel.visible:
		return
	if not is_card_free(card_idx):
		return
	# Brief visual feedback — flash the button
	var c = cards[card_idx]
	if c.node:
		var btn = c.node.get_node_or_null("CardBtn") as Button
		if btn:
			btn.modulate = Color(1.3, 1.3, 0.6)
			await get_tree().create_timer(0.08).timeout
			if is_instance_valid(btn):
				btn.modulate = Color(1, 1, 1)
	handle_tile_click(card_idx)


func handle_tile_click(card_idx: int) -> void:
	if paused or win_panel.visible:
		return
	var c = cards[card_idx]
	if c.type == -1:
		return

	# A slot tile is already selected → this tap is the second pick.
	if selected_slot >= 0:
		var held = slot_tiles[selected_slot]
		if held != null and held.type == c.type:
			var slot_i = selected_slot
			_clear_selection()
			_match_board_with_slot(card_idx, slot_i)
		else:
			_flash_message(_t("msg_no_match"))
			_break_combo()
			_clear_selection()
			_select_card(card_idx)
			update_ui()
		return

	if selected_idx == -1:
		_select_card(card_idx)
		update_ui()
		return

	if selected_idx == card_idx:
		_clear_selection()
		update_ui()
		return

	if cards[selected_idx].type == c.type:
		var idx1 = selected_idx
		_clear_selection()
		_do_match(idx1, card_idx)
	else:
		_flash_message(_t("msg_no_match"))
		_break_combo()
		_clear_selection()
		_select_card(card_idx)
		update_ui()
		check_for_moves()


# ====================== MATCHING / COMBO ======================

func _do_match(idx1: int, idx2: int) -> void:
	var t = cards[idx1].type
	var gain = _register_match()
	remove_card(idx1)
	remove_card(idx2)
	score += gain
	history.append({"kind": "match", "a": idx1, "b": idx2, "type": t, "score": gain})
	_flash_message(_t("msg_match"))
	_after_clear()


func _match_board_with_slot(card_idx: int, slot_i: int) -> void:
	var held = slot_tiles[slot_i]
	if held == null:
		return
	var t = held.type
	var gain = _register_match()
	remove_card(card_idx)
	_clear_slot(slot_i, true)
	score += gain
	history.append({"kind": "board_slot", "idx": card_idx, "slot": slot_i, "type": t, "score": gain})
	_flash_message(_t("msg_match"))
	_after_clear()


func _register_match() -> int:
	# Combo: chaining clears within COMBO_WINDOW seconds multiplies the score.
	var now = Time.get_ticks_msec()
	if now - last_match_msec <= int(COMBO_WINDOW * 1000):
		combo_count += 1
	else:
		combo_count = 1
	last_match_msec = now
	best_combo = max(best_combo, combo_count)

	var base = 10 + max(level, 1) * 2
	var mult = 1.0 + 0.5 * min(combo_count - 1, COMBO_MAX_STEPS)
	var gain = int(round(base * mult))
	if combo_count >= 2:
		_show_combo(combo_count)
	return gain


func _break_combo() -> void:
	combo_count = 0
	last_match_msec = -1000000


func _after_clear() -> void:
	refresh_props_ui()
	update_ui()
	if remaining_tiles <= 0:
		show_win()
	else:
		check_for_moves()


# ====================== SELECTION HELPERS ======================

func _select_card(idx: int) -> void:
	selected_idx = idx
	selected_node = cards[idx].node
	highlight_tile(selected_node, true)


func _select_slot(i: int) -> void:
	selected_slot = i
	_highlight_slot(i, true)


func _clear_selection() -> void:
	if selected_node and is_instance_valid(selected_node):
		highlight_tile(selected_node, false)
	selected_idx = -1
	selected_node = null
	if selected_slot >= 0:
		_highlight_slot(selected_slot, false)
	selected_slot = -1


func _highlight_slot(i: int, on: bool) -> void:
	if i < 0 or i >= slot_panels.size():
		return
	var panel = slot_panels[i]
	if panel and is_instance_valid(panel):
		var style = panel.get_theme_stylebox("panel")
		if style is StyleBoxFlat:
			style.border_color = COLOR_ACCENT_GOLD if on else Color(COLOR_SURFACE_DARK.r, COLOR_SURFACE_DARK.g, COLOR_SURFACE_DARK.b, 0.55)
			style.border_width_left = 3 if on else 2
			style.border_width_right = 3 if on else 2
			style.border_width_top = 3 if on else 2
			style.border_width_bottom = 3 if on else 2


# ====================== SLOTS ("MOVE OUT") ======================

func _has_empty_slot() -> bool:
	for i in range(SLOT_COUNT):
		if i >= slot_tiles.size() or slot_tiles[i] == null:
			return true
	return false


func _first_empty_slot() -> int:
	for i in range(SLOT_COUNT):
		if i >= slot_tiles.size() or slot_tiles[i] == null:
			return i
	return -1


func _has_free_card() -> bool:
	for i in range(cards.size()):
		if is_card_free(i):
			return true
	return false


func _clear_slot(i: int, animate: bool) -> void:
	if i < 0 or i >= slot_tiles.size():
		return
	var held = slot_tiles[i]
	if held == null:
		return
	slot_tiles[i] = null
	remaining_tiles -= 1
	if held.node and is_instance_valid(held.node):
		var node = held.node
		if animate:
			var tween = create_tween()
			tween.tween_property(node, "scale", Vector2(1.25, 1.25), 0.08)
			tween.tween_property(node, "scale", Vector2(0.05, 0.05), 0.15)
			tween.tween_callback(node.queue_free)
		else:
			node.queue_free()
	update_slot_ui()


func _clear_slots() -> void:
	for i in range(slot_tiles.size()):
		var held = slot_tiles[i]
		if held != null and held.node and is_instance_valid(held.node):
			held.node.queue_free()
	slot_tiles.clear()
	for i in range(SLOT_COUNT):
		slot_tiles.append(null)
	selected_slot = -1
	update_slot_ui()


func _take_card_to_slot(idx: int, t: int) -> void:
	var c = cards[idx]
	# Leaves the board but is NOT counted as cleared — it still has to be matched.
	if c.node and is_instance_valid(c.node):
		c.node.queue_free()
	c.node = null
	c.type = -1
	var slot_i = _first_empty_slot()
	if slot_i < 0:
		return
	slot_tiles[slot_i] = {"type": t, "node": _create_slot_tile(t, slot_i)}
	update_slot_ui()


func _auto_match_slots() -> void:
	for i in range(SLOT_COUNT):
		for j in range(i + 1, SLOT_COUNT):
			var a = slot_tiles[i]
			var b = slot_tiles[j]
			if a != null and b != null and a.type == b.type:
				var t = a.type
				var gain = _register_match()
				_clear_slot(i, true)
				_clear_slot(j, true)
				score += gain
				history.append({"kind": "slot_pair", "a": i, "b": j, "type": t, "score": gain})
				_flash_message(_t("msg_slot_match"))
				_after_clear()
				return


func _on_slot_pressed(i: int) -> void:
	if paused or win_panel.visible:
		return
	var held = slot_tiles[i] if i < slot_tiles.size() else null
	if held == null:
		return

	if selected_idx >= 0:
		if cards[selected_idx].type == held.type:
			var board_i = selected_idx
			_clear_selection()
			_match_board_with_slot(board_i, i)
		else:
			_flash_message(_t("msg_no_match"))
			_break_combo()
			_clear_selection()
			_select_slot(i)
			update_ui()
		return

	if selected_slot == i:
		_clear_selection()
		return

	_clear_selection()
	_select_slot(i)
	update_ui()


func _on_moveout_pressed() -> void:
	if paused or win_panel.visible:
		return
	if moveouts_left <= 0:
		_flash_message(_t("msg_charges_empty"))
		return
	if selected_idx < 0:
		_flash_message(_t("msg_slot_empty"))
		return
	if not _has_empty_slot():
		_flash_message(_t("msg_slot_full"))
		return
	var idx = selected_idx
	var t = cards[idx].type
	_clear_selection()
	_take_card_to_slot(idx, t)
	moveouts_left -= 1
	history.append({"kind": "slot_move", "idx": idx, "type": t})
	refresh_props_ui()
	update_ui()
	_auto_match_slots()


# ====================== PROPS: HINT / UNDO ======================

func _on_hint_pressed() -> void:
	if paused or win_panel.visible:
		return
	if hints_left <= 0:
		_flash_message(_t("msg_charges_empty"))
		return
	var pair = _find_hint_pair()
	if pair.is_empty():
		_flash_message(_t("msg_hint_none"))
		return
	hints_left -= 1
	_flash_message(_t("msg_hint_used"))
	_pulse_hint(pair)
	refresh_props_ui()


func _find_hint_pair() -> Array:
	# Prefer a pair of free board tiles; fall back to a slot tile + free board tile.
	var free_list: Array = []
	for i in range(cards.size()):
		if is_card_free(i):
			free_list.append(i)

	var by_type: Dictionary = {}
	for i in free_list:
		var t = cards[i].type
		if not by_type.has(t):
			by_type[t] = []
		by_type[t].append(i)
	for t in by_type.keys():
		if by_type[t].size() >= 2:
			return [{"slot": -1, "idx": by_type[t][0]}, {"slot": -1, "idx": by_type[t][1]}]

	for i in range(SLOT_COUNT):
		if i >= slot_tiles.size() or slot_tiles[i] == null:
			continue
		var st = slot_tiles[i]
		if by_type.has(st.type):
			return [{"slot": i, "idx": -1}, {"slot": -1, "idx": by_type[st.type][0]}]
	return []


func _pulse_hint(pair: Array) -> void:
	for entry in pair:
		var target = null
		if entry["slot"] >= 0:
			if entry["slot"] < slot_buttons.size():
				target = slot_buttons[entry["slot"]]
		elif entry["idx"] >= 0:
			target = cards[entry["idx"]].node
		if target == null or not is_instance_valid(target):
			continue
		var tw = create_tween()
		tw.set_loops(3)
		tw.tween_property(target, "modulate", Color(1.4, 1.3, 0.5), 0.22)
		tw.tween_property(target, "modulate", Color(1, 1, 1), 0.22)


func _on_undo_pressed() -> void:
	if paused or win_panel.visible:
		return
	if undos_left <= 0:
		_flash_message(_t("msg_charges_empty"))
		return
	if history.is_empty():
		_flash_message(_t("msg_undo_empty"))
		return

	var action: Dictionary = history.pop_back()
	match action["kind"]:
		"match":
			_restore_card(int(action["a"]), int(action["type"]), true)
			_restore_card(int(action["b"]), int(action["type"]), true)
			score = max(score - int(action["score"]), 0)
		"board_slot":
			_restore_card(int(action["idx"]), int(action["type"]), true)
			_restore_slot(int(action["slot"]), int(action["type"]), true)
			score = max(score - int(action["score"]), 0)
		"slot_move":
			_restore_card(int(action["idx"]), int(action["type"]), false)
			_remove_slot_of_type(int(action["type"]))
		"slot_pair":
			_restore_slot(int(action["a"]), int(action["type"]), true)
			_restore_slot(int(action["b"]), int(action["type"]), true)
			score = max(score - int(action["score"]), 0)

	undos_left -= 1
	_break_combo()
	_flash_message(_t("msg_undo_done"))
	refresh_props_ui()
	update_ui()
	check_for_moves()


func _restore_card(idx: int, t: int, count_it: bool) -> void:
	var c = cards[idx]
	if c.type != -1:
		return
	c.type = t
	var node = create_tile_node(t, idx)
	node.position = _card_position(c)
	board_node.add_child(node)
	c.node = node
	if count_it:
		remaining_tiles += 1


func _restore_slot(i: int, t: int, count_it: bool) -> void:
	if slot_tiles[i] != null:
		var old = slot_tiles[i]
		if old.node and is_instance_valid(old.node):
			old.node.queue_free()
		slot_tiles[i] = null
	slot_tiles[i] = {"type": t, "node": _create_slot_tile(t, i)}
	if count_it:
		remaining_tiles += 1
	update_slot_ui()


func _remove_slot_of_type(t: int) -> void:
	for i in range(slot_tiles.size()):
		var held = slot_tiles[i]
		if held != null and held.type == t:
			if held.node and is_instance_valid(held.node):
				held.node.queue_free()
			slot_tiles[i] = null
			update_slot_ui()
			return


func highlight_tile(tile_node: Node, on: bool) -> void:
	if not tile_node or not is_instance_valid(tile_node):
		return
	if on:
		tile_node.modulate = Color(1.15, 1.15, 0.9)
		tile_node.scale = Vector2(1.06, 1.06)
		# Yellow surround around the card border
		var border = tile_node.get_node_or_null("SelBorder")
		if border:
			border.color = Color(1, 0.8, 0, 0.9)
	else:
		tile_node.modulate = Color(1, 1, 1)
		tile_node.scale = Vector2(1, 1)
		var border = tile_node.get_node_or_null("SelBorder")
		if border:
			border.color = Color(1, 0.85, 0, 0)

func remove_card(idx: int) -> void:
	var c = cards[idx]
	if c.node and is_instance_valid(c.node):
		# Pop-out animation: quick scale-up then shrink away
		var tween = create_tween()
		tween.tween_property(c.node, "scale", Vector2(1.2, 1.2), 0.08)
		tween.tween_property(c.node, "scale", Vector2(0.05, 0.05), 0.18).set_ease(Tween.EASE_IN)
		tween.tween_callback(c.node.queue_free)
	c.type = -1
	c.node = null
	remaining_tiles -= 1
	update_ui()

func is_card_free(idx: int) -> bool:
	var c = cards[idx]
	if c.type == -1 or not c.node or not is_instance_valid(c.node):
		return false

	# Only check vertical covering (higher layer at exact same gx,gy).
	# A tile is selectable if nothing is stacked directly on top of it.
	# This fixes cases where a visually exposed tile ("就在上边") couldn't be selected due to horizontal side checks.
	for j in range(cards.size()):
		var o = cards[j]
		if o.type != -1 and o.gx == c.gx and o.gy == c.gy and o.layer > c.layer:
			return false

	return true

func _cell_key(gx: int, gy: int) -> String:
	return "%d:%d" % [gx, gy]


func _shuffle(arr: Array) -> void:
	# Deterministic shuffle driven by _rng, so a daily challenge can be replayed exactly.
	for i in range(arr.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp


func _build_layout(def: Dictionary) -> Array:
	var out: Array = []
	var rows: Array = def["rows"]
	for gy in range(rows.size()):
		var span: Array = rows[gy]
		for gx in range(int(span[0]), int(span[1]) + 1):
			out.append({"gx": gx, "gy": gy, "layer": 0})
	for s in def.get("stacks", []):
		for l in range(1, int(s[2]) + 1):
			out.append({"gx": int(s[0]), "gy": int(s[1]), "layer": l})
	return out


func _layout_def_for_level(lv: int) -> Dictionary:
	# Pick the smallest board that fits this level's tile budget, so the campaign
	# grows monotonically instead of shrinking every time the shape rotates.
	var desired := 16 + (int(max(lv, 1)) - 1) * 4
	var ranked: Array = []
	for def in LAYOUT_DEFS:
		ranked.append({"def": def, "size": _build_layout(def).size()})
	ranked.sort_custom(func(a, b): return a["size"] < b["size"])
	for entry in ranked:
		if entry["size"] >= desired:
			return entry["def"]
	return ranked[ranked.size() - 1]["def"]


func _next_free_layers(fill: Dictionary, cell_max: Dictionary) -> Array:
	# One entry per cell: the next layer that must be filled to keep stacks bottom-up.
	var out: Array = []
	for key in fill.keys():
		var l := int(fill[key])
		if l <= int(cell_max[key]):
			out.append(key)
	return out


func generate_solvable_layout(needed: Dictionary) -> bool:
	# Reverse-pair placement, guaranteed solvable.
	#
	# The play rule is "a tile is free when nothing is stacked directly on top of it",
	# so any legal clear order is top-down. We build the board the other way round:
	# each stack is filled from its lowest layer upwards, two tiles (in two different
	# cells) at a time. Reversing that placement order is then a legal full clear —
	# when a pair comes up, every tile that could cover it has already been removed.
	#
	# Two details make it fail-proof:
	#  * quota: how many tiles each cell gets is decided up front by water-filling, so
	#    the work is always spread over many cells and never piles up on the last one;
	#  * pairing always takes the two cells with the largest remaining quota, which
	#    keeps that spread invariant while placing.
	var total := 0
	for v in needed.values():
		total += int(v)
	if total <= 0:
		return false

	for c in cards:
		c.type = -1

	var cell_max: Dictionary = {}
	var slot_of: Dictionary = {}
	for i in range(cards.size()):
		var c = cards[i]
		var key := _cell_key(c.gx, c.gy)
		cell_max[key] = max(int(cell_max.get(key, -1)), int(c.layer))
		slot_of["%s:%d" % [key, int(c.layer)]] = i

	# Quota per cell (how many tiles of its stack will be used), water-filled from the
	# bottom so that no cell is ever the only one left with work to do.
	var quota: Dictionary = {}
	var fill: Dictionary = {}
	for key in cell_max.keys():
		quota[key] = 0
		fill[key] = 0
	var to_assign := total
	var layer := 0
	while to_assign > 0:
		var progressed := false
		for key in quota.keys():
			if to_assign <= 0:
				break
			if int(quota[key]) <= layer and int(quota[key]) <= int(cell_max[key]):
				quota[key] = int(quota[key]) + 1
				to_assign -= 1
				progressed = true
		if not progressed:
			return false
		layer += 1

	# Type pool: one entry per pair. A "move out" can leave a single odd tile; it is
	# placed last so it sits on top and can be paired with the tile held in a slot.
	var pair_types: Array = []
	var odd_type := -1
	for t in needed.keys():
		var cnt := int(needed[t])
		if cnt % 2 == 1:
			odd_type = int(t)
			cnt -= 1
		for k in range(cnt / 2):
			pair_types.append(int(t))
	_shuffle(pair_types)

	var order: Array = []
	while pair_types.size() > 0:
		# Two distinct cells with the most remaining quota — random among ties.
		var keys: Array = []
		for key in quota.keys():
			if int(quota[key]) > 0:
				keys.append(key)
		if keys.size() < 2:
			return false
		keys.sort_custom(func(a, b): return int(quota[a]) > int(quota[b]))
		var top: int = int(quota[keys[0]])
		var tied: Array = keys.filter(func(k): return int(quota[k]) == top)
		_shuffle(tied)
		var key_a: String = tied[0]
		var rest: Array = keys.filter(func(k): return k != key_a)
		var key_b: String = rest[0]

		var ia := int(slot_of["%s:%d" % [key_a, int(fill[key_a])]])
		var ib := int(slot_of["%s:%d" % [key_b, int(fill[key_b])]])
		fill[key_a] = int(fill[key_a]) + 1
		fill[key_b] = int(fill[key_b]) + 1
		quota[key_a] = int(quota[key_a]) - 1
		quota[key_b] = int(quota[key_b]) - 1

		var t: int = pair_types.pop_back()
		cards[ia].type = t
		cards[ib].type = t
		order.append([ia, ib])

	if odd_type >= 0:
		var key := ""
		for k in quota.keys():
			if int(quota[k]) > 0:
				key = k
				break
		if key == "":
			return false
		var ix := int(slot_of["%s:%d" % [key, int(fill[key])]])
		cards[ix].type = odd_type
		fill[key] = int(fill[key]) + 1
		quota[key] = int(quota[key]) - 1
		order.append([ix])

	_last_generation_order = order
	return true


func update_ui() -> void:
	level_label.text = run_label if run_label != "" else _t("lbl_level", [level])
	score_label.text = _t("lbl_score", [score])
	remaining_label.text = _t("lbl_remaining", [remaining_tiles])


func has_possible_move() -> bool:
	# "Can I still clear something?" — board pairs, slot pairs, or a slot tile that
	# matches a free board tile.
	var free_list: Array = []
	for i in range(cards.size()):
		if is_card_free(i):
			free_list.append(i)
	for a in range(free_list.size()):
		for b in range(a + 1, free_list.size()):
			if cards[free_list[a]].type == cards[free_list[b]].type:
				return true
	for i in range(SLOT_COUNT):
		for j in range(i + 1, SLOT_COUNT):
			var x = slot_tiles[i] if i < slot_tiles.size() else null
			var y = slot_tiles[j] if j < slot_tiles.size() else null
			if x != null and y != null and x.type == y.type:
				return true
	for i in range(SLOT_COUNT):
		if i >= slot_tiles.size() or slot_tiles[i] == null:
			continue
		var st = slot_tiles[i]
		for idx in free_list:
			if cards[idx].type == st.type:
				return true
	return false


func check_for_moves() -> void:
	if remaining_tiles == 0:
		return
	shuffle_button.disabled = false
	if has_possible_move():
		message_label.text = ""
		message_label.visible = false
	elif moveouts_left > 0 and _has_empty_slot() and _has_free_card():
		# Not stuck yet — the player can still "move out" a tile into a slot.
		message_label.text = ""
		message_label.visible = false
	else:
		message_label.text = _t("msg_no_moves")
		message_label.visible = true


func _flash_message(text: String, dur: float = 0.8) -> void:
	_msg_seq += 1
	var mine = _msg_seq
	message_label.text = text
	message_label.visible = true
	await get_tree().create_timer(dur).timeout
	if mine == _msg_seq:
		message_label.text = ""
		message_label.visible = false


func _show_combo(n: int) -> void:
	if combo_label == null or not is_instance_valid(combo_label):
		return
	combo_label.text = _t("combo_text", [n])
	combo_label.visible = true
	combo_label.modulate.a = 1.0
	combo_label.pivot_offset = combo_label.size / 2
	combo_label.scale = Vector2(0.6, 0.6)
	var tw = create_tween()
	tw.tween_property(combo_label, "scale", Vector2(1.15, 1.15), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.12)
	tw.tween_property(combo_label, "modulate:a", 0.0, 0.5).set_delay(0.45)
	tw.tween_callback(func(): combo_label.visible = false)


func _slot_tile_count() -> int:
	var n := 0
	for st in slot_tiles:
		if st != null:
			n += 1
	return n


func _on_shuffle_pressed() -> void:
	# Re-deal only the tiles still on the board; tiles parked in slots stay there.
	var remaining_types: Array = []
	for c in cards:
		if c.type != -1:
			remaining_types.append(c.type)
	if remaining_types.is_empty():
		return

	_clear_selection()
	_break_combo()
	for c in cards:
		if c.node and is_instance_valid(c.node):
			c.node.queue_free()
		c.node = null
		c.type = -1

	var remaining_needed: Dictionary = {}
	for t in remaining_types:
		remaining_needed[t] = remaining_needed.get(t, 0) + 1

	var used_solvable := generate_solvable_layout(remaining_needed)
	if not used_solvable:
		var slot_indices: Array = range(cards.size())
		_shuffle(slot_indices)
		for j in range(remaining_types.size()):
			cards[slot_indices[j]].type = remaining_types[j]

	for c in cards:
		if c.node and is_instance_valid(c.node):
			c.node.queue_free()
		c.node = null
	render_cards()

	remaining_tiles = remaining_types.size() + _slot_tile_count()
	update_ui()
	check_for_moves()
	refresh_props_ui()

	_shuffle_message_showing = true
	message_label.text = _t("msg_shuffled_solvable") if used_solvable else _t("msg_shuffled")
	message_label.visible = true

	await get_tree().create_timer(1.2).timeout
	if _shuffle_message_showing:
		message_label.text = ""
		_shuffle_message_showing = false
		message_label.visible = false


func _on_restart_pressed() -> void:
	if is_daily:
		start_daily()
	else:
		start_level(level)

func _on_next_level() -> void:
	win_panel.visible = false
	if is_daily:
		_hide_game_ui()
		show_main_menu()
		return
	start_level(level + 1)

func show_win() -> void:
	timer_running = false
	message_label.text = ""
	message_label.visible = false
	_clear_selection()

	var pairs = max(level_total_cards / 2, 1)
	var avg_secs_per_pair = elapsed_time / pairs
	var stars := 1
	if avg_secs_per_pair <= 3.5:
		stars = 3
	elif avg_secs_per_pair <= 7.0:
		stars = 2

	var time_bonus = 0
	if stars == 3:
		time_bonus = int(200 * level - elapsed_time * 2)
	elif stars == 2:
		time_bonus = int(100 * level - elapsed_time)
	time_bonus = max(time_bonus, 10 * level)
	if is_daily:
		time_bonus = max(int(time_bonus * 0.5), 10 * level)
	score += time_bonus

	# Persist first, so the panel can show the freshly updated records.
	update_progress_on_complete()
	update_ui()

	var win_label = $UI/WinPanel/WinLabel
	if win_label:
		win_label.text = _t("daily_done") if is_daily else _t("win_title")
		win_label.add_theme_color_override("font_color", COLOR_TEXT_GOLD)
		win_label.add_theme_font_size_override("font_size", 46)

	for child in win_panel.get_children():
		if child.name.begins_with("Stat_"):
			child.queue_free()

	var stats_y := 110
	if not is_daily:
		var star_container = HBoxContainer.new()
		star_container.name = "Stat_StarsContainer"
		star_container.alignment = BoxContainer.ALIGNMENT_CENTER
		star_container.size = Vector2(400, 60)
		star_container.position = Vector2(120, 108)
		for i in range(3):
			var star_lbl = Label.new()
			star_lbl.text = "⭐" if i < stars else "☆"
			star_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			star_lbl.add_theme_font_size_override("font_size", 42)
			star_lbl.size = Vector2(100, 56)
			star_container.add_child(star_lbl)
		win_panel.add_child(star_container)
		stats_y = 186

	var total_secs = int(elapsed_time)
	var time_str = "%02d:%02d" % [total_secs / 60, total_secs % 60]

	var stats: Array = []
	if is_daily:
		stats.append(_t("daily_best", [daily_best]))
		stats.append(_t("win_time", [time_str]))
		stats.append(_t("win_score", [score, time_bonus]))
		stats.append(_t("daily_streak", [daily_streak]))
	else:
		stats.append(_t("win_level_done", [level]))
		stats.append(_t("win_time", [time_str]))
		stats.append(_t("win_score", [score, time_bonus]))
		if best_combo >= 2:
			stats.append(_t("win_combo_best", [best_combo]))

	for stat in stats:
		var sl = Label.new()
		sl.name = "Stat_%s" % stat
		sl.text = stat
		sl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sl.position = Vector2(20, stats_y)
		sl.size = Vector2(480, 34)
		sl.add_theme_font_size_override("font_size", 24)
		sl.add_theme_color_override("font_color", COLOR_TEXT_LIGHT)
		win_panel.add_child(sl)
		stats_y += 44

	next_button.text = _t("btn_back") if is_daily else _t("btn_next")
	$UI/WinPanel/NextButton.position = Vector2(170, 400)
	for p in slot_panels:
		p.visible = false
	for b in [hint_btn, undo_btn, moveout_btn]:
		if b and is_instance_valid(b):
			b.visible = false
	if combo_label and is_instance_valid(combo_label):
		combo_label.visible = false
	pause_button.visible = false
	shuffle_button.visible = false
	restart_button.visible = false
	win_panel.move_to_front()
	win_panel.visible = true

	print("%s cleared! Score: %d, Time: %s, Stars: %d, BestCombo: %d" % [run_label, score, time_str, stars, best_combo])


func _input(event: InputEvent) -> void:
	# Card touch handled by Button.pressed signals (see _on_card_button_pressed).
	# Only global shortcuts here.
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if level_select.visible:
			level_select.visible = false
			show_main_menu()
		elif pause_menu.visible:
			_on_resume_pressed()
		elif settings_menu.visible:
			_fade_out(settings_menu)
		elif win_panel.visible:
			pass
		elif main_menu.visible:
			pass  # do nothing — let user stay on main menu
		else:
			_on_restart_pressed()

# ====================== NEW MENU SYSTEM ======================

func _setup_pause_button():
	pause_button = Button.new()
	pause_button.text = _t("btn_pause")
	pause_button.position = Vector2(580, 50)
	pause_button.size = Vector2(120, 48)
	pause_button.pressed.connect(_on_pause_pressed)
	_make_rounded_button(pause_button, COLOR_BTN_NEUTRAL, RADIUS_PILL)
	$UI.add_child(pause_button)

func _setup_pause_menu():
	pause_menu = Control.new()
	pause_menu.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Warm semi-transparent background
	var bg = ColorRect.new()
	bg.color = COLOR_OVERLAY
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_menu.add_child(bg)

	# Centered rounded panel with unified style
	var panel = Panel.new()
	panel.size = Vector2(520, 560)
	panel.position = Vector2(100, 360)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	pause_menu.add_child(panel)

	# Title
	var title = Label.new()
	title.text = _t("pause_title")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 30)
	title.size = Vector2(520, 50)
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", COLOR_TEXT_LIGHT)
	panel.add_child(title)

	# Resume button
	var resume = Button.new()
	resume.text = _t("btn_resume")
	resume.position = Vector2(110, 100)
	resume.size = Vector2(300, 70)
	_make_rounded_button(resume, COLOR_BTN_GREEN, RADIUS_MEDIUM)
	resume.pressed.connect(_on_resume_pressed)
	panel.add_child(resume)

	# Exit to main menu
	var exit_btn = Button.new()
	exit_btn.text = _t("btn_exit_main")
	exit_btn.position = Vector2(110, 190)
	exit_btn.size = Vector2(300, 70)
	_make_rounded_button(exit_btn, COLOR_BTN_RED, RADIUS_MEDIUM)
	exit_btn.pressed.connect(_on_exit_to_main_pressed)
	panel.add_child(exit_btn)

	# Volume control
	var vol_label = Label.new()
	vol_label.text = _t("settings_volume")
	vol_label.position = Vector2(50, 280)
	vol_label.add_theme_font_size_override("font_size", 18)
	vol_label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	panel.add_child(vol_label)

	var vol_slider = HSlider.new()
	vol_slider.min_value = 0
	vol_slider.max_value = 1
	vol_slider.step = 0.01
	vol_slider.value = bgm_volume
	vol_slider.position = Vector2(50, 310)
	vol_slider.size = Vector2(420, 30)
	vol_slider.value_changed.connect(_on_volume_changed)
	panel.add_child(vol_slider)
	pause_vol_slider = vol_slider

	# BGM on/off checkbox
	var bgm_check = CheckBox.new()
	bgm_check.text = _t("settings_bgm")
	bgm_check.position = Vector2(50, 360)
	bgm_check.button_pressed = bgm_enabled
	bgm_check.add_theme_font_size_override("font_size", 18)
	bgm_check.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	bgm_check.toggled.connect(_on_bgm_toggled)
	panel.add_child(bgm_check)
	pause_bgm_check = bgm_check

	# Language selector
	var pause_lang_label = Label.new()
	pause_lang_label.text = _t("settings_lang")
	pause_lang_label.position = Vector2(50, 410)
	pause_lang_label.add_theme_font_size_override("font_size", 18)
	pause_lang_label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	panel.add_child(pause_lang_label)

	var pause_lang_opt = OptionButton.new()
	pause_lang_opt.position = Vector2(50, 440)
	pause_lang_opt.size = Vector2(420, 38)
	pause_lang_opt.add_theme_font_size_override("font_size", 18)
	for lc in LANG_LIST:
		pause_lang_opt.add_item(LANG_NAMES[lc])
	pause_lang_opt.select(LANG_LIST.find(current_lang))
	pause_lang_opt.item_selected.connect(_on_language_selected)
	panel.add_child(pause_lang_opt)
	lang_selector_pause = pause_lang_opt

	$UI.add_child(pause_menu)

func _setup_main_menu():
	main_menu = CanvasLayer.new()

	# Cover background (AI generated)
	var bg = TextureRect.new()
	bg.texture = cover_texture
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_menu.add_child(bg)

	# Two-tone warm overlay: lighter top, darker bottom for readability
	var overlay_top = ColorRect.new()
	overlay_top.color = Color(0.078, 0.051, 0.020, 0.25)
	overlay_top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	overlay_top.anchor_bottom = 0.35
	main_menu.add_child(overlay_top)

	var overlay_bottom = ColorRect.new()
	overlay_bottom.color = Color(0.078, 0.051, 0.020, 0.50)
	overlay_bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	overlay_bottom.anchor_top = 0.35
	main_menu.add_child(overlay_bottom)

	# Title banner — centered card with gold border
	var title_banner = Panel.new()
	title_banner.size = Vector2(440, 120)
	title_banner.position = Vector2((720 - 440) / 2, 200)
	var banner_style = StyleBoxFlat.new()
	banner_style.bg_color = Color(COLOR_SURFACE_DARK.r, COLOR_SURFACE_DARK.g, COLOR_SURFACE_DARK.b, 0.88)
	banner_style.set_corner_radius_all(28)
	banner_style.border_width_left = 2
	banner_style.border_width_right = 2
	banner_style.border_width_top = 2
	banner_style.border_width_bottom = 2
	banner_style.border_color = COLOR_ACCENT_GOLD
	banner_style.shadow_size = 10
	banner_style.shadow_offset = Vector2(0, 4)
	banner_style.shadow_color = Color(0, 0, 0, 0.3)
	title_banner.add_theme_stylebox_override("panel", banner_style)
	main_menu.add_child(title_banner)

	var title_label = Label.new()
	title_label.text = _t("game_title")
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.size = Vector2(440, 66)
	title_label.position = Vector2(0, 6)
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.add_theme_color_override("font_color", COLOR_TEXT_GOLD)
	_r_menu_title = title_label
	title_banner.add_child(title_label)

	var subtitle_label = Label.new()
	subtitle_label.text = _t("game_subtitle")
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.size = Vector2(440, 28)
	subtitle_label.position = Vector2(0, 72)
	subtitle_label.add_theme_font_size_override("font_size", 16)
	subtitle_label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	_r_menu_subtitle = subtitle_label
	title_banner.add_child(subtitle_label)

	# Button card — centered panel containing all action buttons
	var btn_card_y = 700
	var btn_card = Panel.new()
	btn_card.size = Vector2(480, 420)
	btn_card.position = Vector2((720 - 480) / 2, btn_card_y)
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0, 0, 0, 0)
	card_style.set_corner_radius_all(RADIUS_LARGE)
	card_style.shadow_size = SHADOW_SIZE
	card_style.shadow_offset = Vector2(0, SHADOW_OFFSET)
	card_style.shadow_color = Color(0, 0, 0, 0.3)
	btn_card.add_theme_stylebox_override("panel", card_style)
	main_menu.add_child(btn_card)

	# Start button
	var start = Button.new()
	start.text = _t("btn_start")
	start.position = Vector2(40, 18)
	start.size = Vector2(400, 78)
	start.pressed.connect(_on_start_game_pressed)
	_r_menu_start = start
	_make_rounded_button(start, COLOR_BTN_GREEN, RADIUS_PILL)
	btn_card.add_child(start)
	start.name = "StartContinueBtn"
	# Daily challenge button
	var daily = Button.new()
	daily.text = _t("btn_daily")
	daily.position = Vector2(40, 106)
	daily.size = Vector2(400, 66)
	daily.pressed.connect(_on_daily_pressed)
	_make_rounded_button(daily, COLOR_BTN_PURPLE, RADIUS_MEDIUM)
	btn_card.add_child(daily)
	daily_btn = daily

	daily_badge = Label.new()
	daily_badge.name = "DailyBadge"
	daily_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	daily_badge.position = Vector2(280, 0)
	daily_badge.size = Vector2(104, 66)
	daily_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	daily_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	daily_badge.add_theme_font_size_override("font_size", 20)
	daily_badge.add_theme_color_override("font_color", COLOR_TEXT_LIGHT)
	daily_badge.visible = false
	daily.add_child(daily_badge)

	# Settings button
	var settings_btn = Button.new()
	settings_btn.text = _t("btn_settings")
	settings_btn.position = Vector2(40, 182)
	settings_btn.size = Vector2(400, 66)
	settings_btn.pressed.connect(_on_settings_pressed)
	_r_menu_settings = settings_btn
	_make_rounded_button(settings_btn, COLOR_BTN_BLUE, RADIUS_MEDIUM)
	btn_card.add_child(settings_btn)

	# Quit button
	var quit = Button.new()
	quit.text = _t("btn_quit")
	quit.position = Vector2(40, 258)
	quit.size = Vector2(400, 66)
	quit.pressed.connect(func(): get_tree().quit())
	_r_menu_quit = quit
	_make_rounded_button(quit, COLOR_BTN_RED, RADIUS_MEDIUM)
	btn_card.add_child(quit)

	# Version / About — subtle text link at bottom of card
	var about_btn = Button.new()
	about_btn.text = "%s · v%s" % [_t("btn_about"), VERSION]
	about_btn.position = Vector2(140, 336)
	about_btn.size = Vector2(200, 42)
	about_btn.flat = true
	about_btn.add_theme_font_size_override("font_size", 14)
	about_btn.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	about_btn.add_theme_color_override("font_hover_color", COLOR_TEXT_GOLD)
	about_btn.pressed.connect(_on_about_pressed)
	_r_menu_about = about_btn
	btn_card.add_child(about_btn)

	add_child(main_menu)

func _setup_level_select():
	level_select = Control.new()
	level_select.set_anchors_preset(Control.PRESET_FULL_RECT)
	level_select.visible = false

	# Warm dark background
	var bg = ColorRect.new()
	bg.color = COLOR_OVERLAY_DEEP
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	level_select.add_child(bg)

	# Panel — centered vertically on screen
	var panel = Panel.new()
	panel.size = Vector2(640, 880)
	panel.position = Vector2((720 - 640) / 2, (1280 - 880) / 2)
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	level_select.add_child(panel)

	# Title
	var title = Label.new()
	title.text = _t("select_level")
	_r_level_select_title = title
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 20)
	title.size = Vector2(640, 44)
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", COLOR_TEXT_GOLD)
	panel.add_child(title)

	# Total score
	var score_lbl = Label.new()
	score_lbl.name = "TotalScoreLabel"
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_lbl.position = Vector2(0, 64)
	score_lbl.size = Vector2(640, 30)
	score_lbl.add_theme_font_size_override("font_size", 20)
	score_lbl.add_theme_color_override("font_color", COLOR_TEXT_LIGHT)
	panel.add_child(score_lbl)

	# Grid of level buttons — 5 per row, scrollable if many levels
	var grid_start_y = 110
	var btn_size = 90
	var star_area_h = 26
	var cell_w = 640 / 5  # 128px per cell
	var cell_h = btn_size + star_area_h + 16  # ~132px

	var level_count = max(max_level, 10)  # show at least 10 slots
	var total = level_count + 4  # a few extra locked slots for visual

	for i in range(total):
		var lv = i + 1
		var col = i % 5
		var row = i / 5
		var cx = col * cell_w + (cell_w - btn_size) / 2
		var cy = grid_start_y + row * cell_h

		# Level button (circle-ish via pill radius)
		var lv_btn = Button.new()
		lv_btn.text = str(lv)
		lv_btn.size = Vector2(btn_size, btn_size)
		lv_btn.position = Vector2(cx, cy)
		lv_btn.add_theme_font_size_override("font_size", 28)
		if lv <= max_level:
			# Unlocked — colored button
			_make_rounded_button(lv_btn, COLOR_BTN_GREEN, btn_size / 2)
		else:
			# Locked — gray
			var locked = StyleBoxFlat.new()
			locked.bg_color = Color(0.35, 0.3, 0.25, 0.7)
			locked.set_corner_radius_all(btn_size / 2)
			locked.border_width_left = 2
			locked.border_width_right = 2
			locked.border_width_top = 2
			locked.border_width_bottom = 2
			locked.border_color = Color(0.5, 0.45, 0.4, 0.5)
			lv_btn.add_theme_stylebox_override("normal", locked)
			lv_btn.add_theme_font_size_override("font_size", 28)
			lv_btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
			lv_btn.disabled = true
		lv_btn.pressed.connect(_on_level_selected.bind(lv))
		panel.add_child(lv_btn)

		# Stars below button
		var star_str = ""
		var star_color = COLOR_TEXT_MUTED
		if lv <= level_stars.size():
			# Has star data — show actual stars
			var s = level_stars[lv - 1]
			for j in range(3):
				star_str += "⭐" if j < s else "☆"
			if s > 0:
				star_color = COLOR_ACCENT_GOLD
		elif lv < max_level:
			# Unlocked but no star data — show 1 star baseline
			star_str = "⭐☆☆"
			star_color = COLOR_ACCENT_GOLD
		elif lv == max_level:
			# Current level — never played
			star_str = _t("level_new")
			star_color = COLOR_ACCENT_GOLD

		if star_str != "":
			var star_lbl = Label.new()
			star_lbl.name = "StarLabel_Lv%d" % lv
			star_lbl.text = star_str
			star_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			star_lbl.position = Vector2(cx, cy + btn_size + 2)
			star_lbl.size = Vector2(btn_size, star_area_h)
			star_lbl.add_theme_font_size_override("font_size", 14)
			star_lbl.add_theme_color_override("font_color", star_color)
			panel.add_child(star_lbl)

	# Back button
	var back = Button.new()
	back.text = _t("btn_back")
	_r_level_select_back = back
	back.position = Vector2((640 - 200) / 2, 820)
	back.size = Vector2(200, 50)
	_make_rounded_button(back, COLOR_BTN_NEUTRAL, RADIUS_MEDIUM)
	back.pressed.connect(func():
			level_select.visible = false
			show_main_menu()	)
	panel.add_child(back)

	add_child(level_select)

func _show_level_select():
	# Update total score display
	var score_lbl = level_select.get_node_or_null("Panel/TotalScoreLabel") as Label
	if score_lbl:
		score_lbl.text = _t("lbl_total_score", [total_score])

	# Refresh button states and star labels
	var panel = level_select.get_node_or_null("Panel")
	if panel:
		for child in panel.get_children():
			if child is Button and child.text.is_valid_int():
				var lv = child.text.to_int()
				if lv <= max_level:
					child.disabled = false
				else:
					child.disabled = true
			# Update star labels
			if child is Label and child.name.begins_with("StarLabel_Lv"):
				var lv = child.name.trim_prefix("StarLabel_Lv").to_int()
				var star_str = ""
				var star_color = COLOR_TEXT_MUTED
				if lv <= level_stars.size():
					var s = level_stars[lv - 1]
					for j in range(3):
						star_str += "⭐" if j < s else "☆"
					if s > 0:
						star_color = COLOR_ACCENT_GOLD
				elif lv < max_level:
					star_str = "⭐☆☆"
					star_color = COLOR_ACCENT_GOLD
				elif lv == max_level:
					star_str = _t("level_new")
					star_color = COLOR_ACCENT_GOLD
				child.text = star_str
				child.add_theme_color_override("font_color", star_color)

	_fade_in(level_select)

func _on_level_selected(lv: int):
	_fade_out(level_select, 0.2)
	await get_tree().create_timer(0.12).timeout
	_show_game_ui()
	start_level(lv)

func _hide_game_ui():
	board_node.visible = false
	pause_button.visible = false
	level_label.visible = false
	score_label.visible = false
	remaining_label.visible = false
	shuffle_button.visible = false
	restart_button.visible = false
	message_label.visible = false
	$UI/LevelLabelPill.visible = false
	$UI/ScoreLabelPill.visible = false
	$UI/RemainingLabelPill.visible = false
	win_panel.visible = false
	$UI/TitleLabel.visible = false
	settings_menu.visible = false
	for p in slot_panels:
		p.visible = false
	for b in [hint_btn, undo_btn, moveout_btn]:
		if b and is_instance_valid(b):
			b.visible = false
	if combo_label and is_instance_valid(combo_label):
		combo_label.visible = false
	timer_running = false
	if timer_label:
		timer_label.get_parent().visible = false
	# Keep BGM playing continuously (loops in game and menus)

func _show_game_ui():
	board_node.visible = true
	pause_button.visible = true
	level_label.visible = true
	score_label.visible = true
	remaining_label.visible = true
	shuffle_button.visible = true
	restart_button.visible = true
	$UI/LevelLabelPill.visible = true
	$UI/ScoreLabelPill.visible = true
	$UI/RemainingLabelPill.visible = true
	$UI/TitleLabel.visible = false
	for p in slot_panels:
		p.visible = true
	for b in [hint_btn, undo_btn, moveout_btn]:
		if b and is_instance_valid(b):
			b.visible = true
	refresh_props_ui()
	update_slot_ui()
	if timer_label:
		timer_label.get_parent().visible = true
	if bgm_player and bgm_player.stream and bgm_enabled and not bgm_player.playing:
		bgm_player.play()

func _on_pause_pressed():
	paused = true
	if pause_vol_slider:
		pause_vol_slider.value = bgm_volume
	if pause_bgm_check:
		pause_bgm_check.button_pressed = bgm_enabled
	if lang_selector_pause:
		lang_selector_pause.select(LANG_LIST.find(current_lang))
	_fade_in(pause_menu)
	pause_button.visible = false

func _on_resume_pressed():
	paused = false
	_fade_out(pause_menu)
	pause_button.visible = true

func _on_exit_to_main_pressed():
	paused = false
	_fade_out(pause_menu)
	if settings_menu.visible:
		_fade_out(settings_menu)
	await get_tree().create_timer(0.15).timeout
	_hide_game_ui()
	show_main_menu()

func _on_start_game_pressed():
	_fade_out(main_menu, 0.25)
	await get_tree().create_timer(0.15).timeout
	main_menu.visible = false
	_show_level_select()

func _on_daily_pressed():
	_fade_out(main_menu, 0.22)
	await get_tree().create_timer(0.16).timeout
	main_menu.visible = false
	_show_game_ui()
	start_daily()


func _refresh_daily_badge() -> void:
	if daily_badge == null or not is_instance_valid(daily_badge):
		return
	if daily_streak > 0:
		daily_badge.text = _t("lbl_streak", [daily_streak])
		daily_badge.visible = true
	else:
		daily_badge.visible = false


func _make_rounded_button(btn: Button, bg_color: Color, corner_radius: int = RADIUS_MEDIUM):
	var normal = StyleBoxFlat.new()
	normal.bg_color = bg_color
	normal.set_corner_radius_all(corner_radius)
	normal.content_margin_left = 16
	normal.content_margin_right = 16
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10
	normal.shadow_size = SHADOW_SIZE
	normal.shadow_offset = Vector2(0, SHADOW_OFFSET)
	normal.shadow_color = Color(0, 0, 0, 0.2)
	btn.add_theme_stylebox_override("normal", normal)

	var hover = normal.duplicate()
	hover.bg_color = bg_color.lightened(0.1)
	hover.shadow_offset = Vector2(0, SHADOW_OFFSET + 1)
	btn.add_theme_stylebox_override("hover", hover)

	var pressed = normal.duplicate()
	pressed.bg_color = bg_color.darkened(0.15)
	pressed.shadow_offset = Vector2(0, 1)
	pressed.shadow_size = 2
	btn.add_theme_stylebox_override("pressed", pressed)

	var disabled = normal.duplicate()
	disabled.bg_color = bg_color.darkened(0.45)
	disabled.shadow_size = 0
	disabled.shadow_offset = Vector2(0, 0)
	btn.add_theme_stylebox_override("disabled", disabled)

	btn.add_theme_font_size_override("font_size", 24)
	btn.add_theme_color_override("font_color", COLOR_TEXT_LIGHT)
	btn.add_theme_color_override("font_disabled_color", Color(1, 0.97, 0.92, 0.45))

func _setup_about_dialog():
	about_dialog = AcceptDialog.new()
	about_dialog.title = _t("about_title")
	about_dialog.dialog_text = _t("about_text")
	add_child(about_dialog)

func _setup_timer_label():
	# Timer in a dark pill container
	var timer_bg = Panel.new()
	timer_bg.name = "TimerBg"
	timer_bg.size = Vector2(200, 48)
	timer_bg.position = Vector2(260, 50)
	timer_bg.add_theme_stylebox_override("panel", _make_pill_style(Color(COLOR_SURFACE_DARK.r, COLOR_SURFACE_DARK.g, COLOR_SURFACE_DARK.b, 0.85)))
	$UI.add_child(timer_bg)

	timer_label = Label.new()
	timer_label.name = "TimerLabel"
	timer_label.text = _t("timer_format", [0, 0])
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	timer_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	timer_label.add_theme_font_size_override("font_size", 28)
	timer_label.add_theme_color_override("font_color", COLOR_TEXT_LIGHT)
	timer_bg.add_child(timer_label)

# ====================== v0.4 GAME UI: SLOTS / PROPS / COMBO ======================

func _setup_slot_ui() -> void:
	var box := 100
	var gap := 20
	var total := SLOT_COUNT * box + (SLOT_COUNT - 1) * gap
	var x0 := (720 - total) / 2
	var y := 758
	for i in range(SLOT_COUNT):
		var panel := Panel.new()
		panel.name = "SlotPanel%d" % i
		panel.size = Vector2(box, box)
		panel.position = Vector2(x0 + i * (box + gap), y)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style := StyleBoxFlat.new()
		style.bg_color = Color(COLOR_SURFACE_DARK.r, COLOR_SURFACE_DARK.g, COLOR_SURFACE_DARK.b, 0.42)
		style.set_corner_radius_all(20)
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = Color(COLOR_SURFACE_DARK.r, COLOR_SURFACE_DARK.g, COLOR_SURFACE_DARK.b, 0.55)
		panel.add_theme_stylebox_override("panel", style)

		var hint := Label.new()
		hint.name = "EmptyHint"
		hint.text = "＋"
		hint.set_anchors_preset(Control.PRESET_FULL_RECT)
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hint.add_theme_font_size_override("font_size", 34)
		hint.add_theme_color_override("font_color", Color(1, 0.95, 0.85, 0.22))
		hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(hint)

		$UI.add_child(panel)
		slot_panels.append(panel)
		slot_buttons.append(null)


func _create_slot_tile(t: int, i: int) -> Control:
	if i < 0 or i >= slot_panels.size():
		return null
	var btn := Button.new()
	btn.name = "SlotTile"
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.position = Vector2(8, 8)
	btn.size = Vector2(84, 84)
	btn.pressed.connect(_on_slot_pressed.bind(i))
	var icon := TextureRect.new()
	icon.texture = icon_textures[t]
	icon.position = Vector2(0, 0)
	icon.size = Vector2(84, 84)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(icon)
	slot_panels[i].add_child(btn)
	slot_buttons[i] = btn
	return btn


func update_slot_ui() -> void:
	if slot_panels.is_empty():
		return
	for i in range(SLOT_COUNT):
		var btn = null
		for child in slot_panels[i].get_children():
			if child is Button:
				btn = child
		slot_buttons[i] = btn
		var hint = slot_panels[i].get_node_or_null("EmptyHint")
		if hint:
			var empty = (i >= slot_tiles.size() or slot_tiles[i] == null)
			hint.visible = empty
		_highlight_slot(i, selected_slot == i)


func _setup_props_ui() -> void:
	var w := 176
	var h := 64
	var gap := 18
	var total := 3 * w + 2 * gap
	var x0 := (720 - total) / 2
	var y := 886

	hint_btn = Button.new()
	hint_btn.position = Vector2(x0, y)
	hint_btn.size = Vector2(w, h)
	_make_rounded_button(hint_btn, COLOR_BTN_GREEN, RADIUS_MEDIUM)
	hint_btn.add_theme_font_size_override("font_size", 24)
	hint_btn.pressed.connect(_on_hint_pressed)
	$UI.add_child(hint_btn)

	undo_btn = Button.new()
	undo_btn.position = Vector2(x0 + w + gap, y)
	undo_btn.size = Vector2(w, h)
	_make_rounded_button(undo_btn, COLOR_BTN_BLUE, RADIUS_MEDIUM)
	undo_btn.add_theme_font_size_override("font_size", 24)
	undo_btn.pressed.connect(_on_undo_pressed)
	$UI.add_child(undo_btn)

	moveout_btn = Button.new()
	moveout_btn.position = Vector2(x0 + 2 * (w + gap), y)
	moveout_btn.size = Vector2(w, h)
	_make_rounded_button(moveout_btn, COLOR_BTN_ORANGE, RADIUS_MEDIUM)
	moveout_btn.add_theme_font_size_override("font_size", 24)
	moveout_btn.pressed.connect(_on_moveout_pressed)
	$UI.add_child(moveout_btn)


func refresh_props_ui() -> void:
	if hint_btn and is_instance_valid(hint_btn):
		hint_btn.text = "%s %d" % [_t("btn_hint"), hints_left]
		hint_btn.disabled = hints_left <= 0
	if undo_btn and is_instance_valid(undo_btn):
		undo_btn.text = "%s %d" % [_t("btn_undo"), undos_left]
		undo_btn.disabled = undos_left <= 0 or history.is_empty()
	if moveout_btn and is_instance_valid(moveout_btn):
		moveout_btn.text = "%s %d" % [_t("btn_moveout"), moveouts_left]
		moveout_btn.disabled = moveouts_left <= 0


func _setup_combo_label() -> void:
	combo_label = Label.new()
	combo_label.name = "ComboLabel"
	combo_label.visible = false
	combo_label.position = Vector2(0, 1000)
	combo_label.size = Vector2(720, 58)
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combo_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	combo_label.add_theme_font_size_override("font_size", 40)
	combo_label.add_theme_color_override("font_color", COLOR_TEXT_GOLD)
	combo_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.55))
	combo_label.add_theme_constant_override("outline_size", 6)
	$UI.add_child(combo_label)


func _on_about_pressed():
	about_dialog.title = _t("about_title")
	about_dialog.dialog_text = _t("about_text")
	about_dialog.popup_centered()



func _detect_safe_area() -> void:
	var ss := DisplayServer.screen_get_size()
	if ss.x <= 0:
		return
	var sc := 720.0 / ss.x
	var sa := DisplayServer.get_display_safe_area()
	var top_safe := sa.position.y * sc
	if top_safe > 80:
		safe_left_margin = max(safe_left_margin, int(top_safe * 2.2))
	elif sa.position.x > 40:
		safe_left_margin = max(safe_left_margin, int(sa.position.x * sc) + 10)
	var cuts := DisplayServer.get_display_cutouts()
	for cut in cuts:
		if cut.position.x < 50:
			var cr := (cut.position.x + cut.size.x) * sc
			safe_left_margin = max(safe_left_margin, int(cr) + 20)
	_safe_area_detected = true
	# Reposition player info if main menu is visible
	if main_menu and main_menu.visible:
		var info = main_menu.get_node_or_null("PlayerInfo") as Control
		if info:
			info.position.x = safe_left_margin

func _setup_bgm():
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGMPlayer"

	# Use ResourceLoader.exists() — FileAccess.file_exists() fails on exported Android APK
	# because the source .ogg file path is remapped to the imported .oggvorbisstr resource.
	if ResourceLoader.exists("res://assets/bgm.ogg"):
		bgm_player.stream = load("res://assets/bgm.ogg")
	elif ResourceLoader.exists("res://assets/bgm.mp3"):
		bgm_player.stream = load("res://assets/bgm.mp3")
	else:
		print("No BGM file found. Add one to res://assets/bgm.* to enable background music.")

	if bgm_player.stream != null:
		if bgm_player.stream is AudioStreamOggVorbis:
			bgm_player.stream.loop = true

	# Use Master bus directly — simpler and avoids routing issues on mobile
	bgm_player.bus = "Master"
	bgm_player.volume_db = linear_to_db(bgm_volume)
	add_child(bgm_player)


func _setup_settings_menu():
	settings_menu = Control.new()
	settings_menu.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Warm semi-transparent background
	var bg = ColorRect.new()
	bg.color = COLOR_OVERLAY
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP  # block clicks from passing through
	settings_menu.add_child(bg)

	# Centered rounded panel with unified style
	var panel = Panel.new()
	panel.size = Vector2(520, 430)
	panel.position = Vector2(100, 440)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	settings_menu.add_child(panel)

	# Title
	var title = Label.new()
	title.text = _t("settings_title")
	_r_settings_title = title
	title.position = Vector2(50, 25)
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", COLOR_TEXT_LIGHT)
	panel.add_child(title)

	# Volume
	var vol_label = Label.new()
	vol_label.text = _t("settings_volume")
	vol_label.position = Vector2(50, 70)
	vol_label.add_theme_font_size_override("font_size", 18)
	vol_label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	panel.add_child(vol_label)

	var vol_slider = HSlider.new()
	vol_slider.min_value = 0
	vol_slider.max_value = 1
	vol_slider.step = 0.01
	vol_slider.value = bgm_volume
	vol_slider.position = Vector2(50, 100)
	vol_slider.size = Vector2(420, 30)
	vol_slider.value_changed.connect(_on_volume_changed)
	panel.add_child(vol_slider)
	settings_vol_slider = vol_slider

	# BGM on/off checkbox
	var bgm_check = CheckBox.new()
	bgm_check.text = _t("settings_bgm")
	bgm_check.position = Vector2(50, 150)
	bgm_check.button_pressed = bgm_enabled
	bgm_check.add_theme_font_size_override("font_size", 18)
	bgm_check.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	bgm_check.toggled.connect(_on_bgm_toggled)
	panel.add_child(bgm_check)
	settings_bgm_check = bgm_check

	# Language selector
	var lang_label = Label.new()
	lang_label.text = _t("settings_lang")
	lang_label.position = Vector2(50, 205)
	lang_label.add_theme_font_size_override("font_size", 18)
	lang_label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	panel.add_child(lang_label)

	var lang_opt = OptionButton.new()
	lang_opt.position = Vector2(50, 235)
	lang_opt.size = Vector2(420, 38)
	lang_opt.add_theme_font_size_override("font_size", 18)
	for lc in LANG_LIST:
		lang_opt.add_item(LANG_NAMES[lc])
	lang_opt.select(LANG_LIST.find(current_lang))
	lang_opt.item_selected.connect(_on_language_selected)
	panel.add_child(lang_opt)
	lang_selector = lang_opt

	# Close
	var close = Button.new()
	close.text = _t("btn_close")
	close.position = Vector2(185, 330)
	close.size = Vector2(150, 55)
	_make_rounded_button(close, COLOR_BTN_NEUTRAL, RADIUS_MEDIUM)
	close.pressed.connect(func(): _fade_out(settings_menu))
	panel.add_child(close)

	main_menu.add_child(settings_menu)
	settings_menu.visible = false

func _on_settings_pressed():
	if settings_vol_slider:
		settings_vol_slider.value = bgm_volume
	if settings_bgm_check:
		settings_bgm_check.button_pressed = bgm_enabled
	if lang_selector:
		lang_selector.select(LANG_LIST.find(current_lang))
	_fade_in(settings_menu)

func _on_volume_changed(value: float):
	bgm_volume = value
	if bgm_player:
		bgm_player.volume_db = linear_to_db(value)
	# Sync the other slider if visible
	if pause_vol_slider and pause_vol_slider.visible:
		pause_vol_slider.value = value
	if settings_vol_slider and settings_vol_slider.visible:
		settings_vol_slider.value = value
	save_player_data()

func _on_bgm_toggled(enabled: bool):
	bgm_enabled = enabled
	if bgm_player:
		if enabled:
			if bgm_player.stream and not bgm_player.playing:
				bgm_player.play()
		else:
			bgm_player.stop()
	# Sync checkboxes
	if pause_bgm_check and pause_bgm_check.button_pressed != enabled:
		pause_bgm_check.set_pressed_no_signal(enabled)
	if settings_bgm_check and settings_bgm_check.button_pressed != enabled:
		settings_bgm_check.set_pressed_no_signal(enabled)
	save_player_data()

func _on_language_selected(idx: int):
	current_lang = LANG_LIST[idx]
	save_player_data()
	_refresh_language()

func _refresh_language() -> void:
	# Scene-defined buttons (from main.tscn)
	shuffle_button.text = _t("btn_shuffle")
	restart_button.text = _t("btn_restart")
	next_button.text = _t("btn_next")
	if pause_button:
		pause_button.text = _t("btn_pause")

	# Sync language selectors in both menus
	if lang_selector:
		lang_selector.select(LANG_LIST.find(current_lang))
	if lang_selector_pause:
		lang_selector_pause.select(LANG_LIST.find(current_lang))

	# Main menu — update all text elements
	if _r_menu_title:     _r_menu_title.text = _t("game_title")
	if _r_menu_subtitle:  _r_menu_subtitle.text = _t("game_subtitle")
	if _r_menu_start:     _r_menu_start.text = _t("btn_continue") if max_level > 1 else _t("btn_start")
	if _r_menu_settings:  _r_menu_settings.text = _t("btn_settings")
	if _r_menu_quit:      _r_menu_quit.text = _t("btn_quit")
	if _r_menu_about:     _r_menu_about.text = "%s · v%s" % [_t("btn_about"), VERSION]

	# Settings menu
	if _r_settings_title:     _r_settings_title.text = _t("settings_title")
	if _r_settings_vol_label: _r_settings_vol_label.text = _t("settings_volume")
	if settings_bgm_check:    settings_bgm_check.text = _t("settings_bgm")
	if _r_settings_close:     _r_settings_close.text = _t("btn_close")

	# Pause menu
	if _r_pause_title:     _r_pause_title.text = _t("pause_title")
	if _r_pause_resume:    _r_pause_resume.text = _t("btn_resume")
	if _r_pause_exit:      _r_pause_exit.text = _t("btn_exit_main")
	if _r_pause_vol_label: _r_pause_vol_label.text = _t("settings_volume")
	if pause_bgm_check:    pause_bgm_check.text = _t("settings_bgm")

	# Level select
	if _r_level_select_title: _r_level_select_title.text = _t("select_level")
	if _r_level_select_back:  _r_level_select_back.text = _t("btn_back")
	if level_select and level_select.visible:
		_show_level_select()  # re-runs stars/text updates with _t()

	# v0.4 widgets
	if daily_btn and is_instance_valid(daily_btn):
		daily_btn.text = _t("btn_daily")
	if hint_btn and is_instance_valid(hint_btn):
		hint_btn.text = "%s %d" % [_t("btn_hint"), hints_left]
	if undo_btn and is_instance_valid(undo_btn):
		undo_btn.text = "%s %d" % [_t("btn_undo"), undos_left]
	if moveout_btn and is_instance_valid(moveout_btn):
		moveout_btn.text = "%s %d" % [_t("btn_moveout"), moveouts_left]
	refresh_props_ui()
	_refresh_daily_badge()
	if combo_label and is_instance_valid(combo_label):
		combo_label.visible = false

	# Game HUD (re-call update functions which use _t())
	if is_daily:
		run_label = _t("daily_title")
	else:
		run_label = _t("lbl_level", [level])
	update_ui()
	_update_timer_display()

	# About dialog
	if about_dialog:
		about_dialog.title = _t("about_title")
		about_dialog.dialog_text = _t("about_text")

	# Player info on main menu
	if main_menu:
		var info = main_menu.get_node_or_null("PlayerInfo") as Control
		if info and info.visible:
			var prog = info.get_node_or_null("LevelLabel") as Label
			if prog:
				prog.text = _t("lbl_level_progress", [max_level])

func _on_avatar_selected(idx: int, btn: Button, buttons: Array):
	selected_avatar_for_profile = idx
	for b in buttons:
		b.modulate = Color(1,1,1)
	btn.modulate = Color(1.3, 1.3, 0.5)

# ====================== PLAYER PROFILE & PROGRESS SAVE ======================

func save_player_data():
	var config = ConfigFile.new()
	config.set_value("player", "name", player_name)
	config.set_value("player", "avatar", player_avatar)
	config.set_value("progress", "max_level", max_level)
	config.set_value("progress", "total_score", total_score)
	config.set_value("progress", "level_stars", level_stars)
	config.set_value("settings", "volume", bgm_volume)
	config.set_value("settings", "bgm_enabled", bgm_enabled)
	config.set_value("settings", "lang", current_lang)
	config.set_value("daily", "last_played", daily_last_played)
	config.set_value("daily", "best", daily_best)
	config.set_value("daily", "streak", daily_streak)
	config.set_value("meta", "schema", 2)
	config.save("user://player_data.cfg")

func load_player_data():
	var config = ConfigFile.new()
	if config.load("user://player_data.cfg") == OK:
		player_name = config.get_value("player", "name", "")
		player_avatar = config.get_value("player", "avatar", 0)
		max_level = config.get_value("progress", "max_level", 1)
		level_stars = config.get_value("progress", "level_stars", [])
		# Backfill: levels completed before star tracking get 1 star (baseline)
		var backfilled = false
		while level_stars.size() < max_level - 1:
			level_stars.append(1)
			backfilled = true
		total_score = config.get_value("progress", "total_score", 0)
		if backfilled:
			save_player_data()
		bgm_volume = config.get_value("settings", "volume", 0.7)
		bgm_enabled = config.get_value("settings", "bgm_enabled", true)
		current_lang = config.get_value("settings", "lang", "zh_CN")
		daily_last_played = config.get_value("daily", "last_played", "")
		daily_best = config.get_value("daily", "best", 0)
		daily_streak = config.get_value("daily", "streak", 0)
	else:
		# First time launch - profile creation will handle
		pass

func apply_volume():
	if bgm_player:
		bgm_player.volume_db = linear_to_db(bgm_volume)
	# Apply BGM enabled state
	if not bgm_enabled and bgm_player and bgm_player.playing:
		bgm_player.stop()

func show_profile_creation():
	# Full screen profile creation overlay
	var profile = Control.new()
	profile.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg = ColorRect.new()
	bg.color = COLOR_OVERLAY_DEEP
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	profile.add_child(bg)

	# Rounded centered panel with unified style
	var panel = Panel.new()
	var pw := 560
	var ph := 510
	panel.size = Vector2(pw, ph)
	panel.position = Vector2((720 - pw) / 2, (1280 - ph) / 2)
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	profile.add_child(panel)

	var prompt = Label.new()
	prompt.text = _t("profile_create")
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.position = Vector2(0, 25)
	prompt.size = Vector2(pw, 40)
	prompt.add_theme_font_size_override("font_size", 28)
	prompt.add_theme_color_override("font_color", COLOR_TEXT_LIGHT)
	panel.add_child(prompt)

	var name_label = Label.new()
	name_label.text = _t("profile_username")
	name_label.position = Vector2(40, 78)
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	panel.add_child(name_label)

	var name_edit = LineEdit.new()
	name_edit.placeholder_text = _t("profile_name_placeholder")
	name_edit.position = Vector2(40, 108)
	name_edit.size = Vector2(pw - 80, 42)
	name_edit.add_theme_font_size_override("font_size", 20)
	panel.add_child(name_edit)

	var avatar_label = Label.new()
	avatar_label.text = _t("profile_avatar")
	avatar_label.position = Vector2(40, 162)
	avatar_label.add_theme_font_size_override("font_size", 18)
	avatar_label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	panel.add_child(avatar_label)

	selected_avatar_for_profile = 0
	var av_buttons = []
	# 3x2 grid centered in panel
	var btn_size := 100
	var av_spacing := 130
	var grid_w := 3 * btn_size + 2 * (av_spacing - btn_size)
	var av_start_x := (pw - grid_w) / 2
	var av_start_y := 200
	for i in range(6):
		var col = i % 3
		var row = i / 3
		var btn = Button.new()
		btn.size = Vector2(btn_size, btn_size)
		btn.position = Vector2(av_start_x + col * av_spacing, av_start_y + row * av_spacing)
		btn.flat = true
		var tex = TextureRect.new()
		tex.texture = icon_textures[i]
		tex.size = Vector2(btn_size - 10, btn_size - 10)
		tex.position = Vector2(5, 5)
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(tex)
		btn.pressed.connect(_on_avatar_selected.bind(i, btn, av_buttons))
		panel.add_child(btn)
		av_buttons.append(btn)

	# Initial selection
	av_buttons[0].modulate = Color(1.3, 1.3, 0.5)

	var confirm = Button.new()
	confirm.text = _t("profile_confirm_create")
	confirm.position = Vector2((pw - 260) / 2, ph - 65)
	confirm.size = Vector2(260, 55)
	_make_rounded_button(confirm, COLOR_BTN_GREEN, RADIUS_MEDIUM)
	confirm.pressed.connect(func():
		var nm = name_edit.text.strip_edges()
		if nm == "":
			nm = _t("default_name") + str(randi() % 900 + 100)
		player_name = nm
		player_avatar = selected_avatar_for_profile
		max_level = 1
		total_score = 0
		save_player_data()
		profile.queue_free()
		show_main_menu()
	)
	panel.add_child(confirm)

	main_menu.add_child(profile)

func show_main_menu():
	main_menu.visible = true
	level_select.visible = false
	pause_menu.visible = false
	settings_menu.visible = false

	# 更新已有的 PlayerInfo，而不是删除重建（避免 queue_free 延迟导致半透明背景叠加变黑）
	var info = _find_or_create_player_info()
	# Reposition for camera cutout (may change between app launches)
	info.position.x = safe_left_margin

	# 刷新头像按钮里的贴图
	for child in info.get_children():
		if child is Button:
			# 清除旧头像贴图，放新的
			for gc in child.get_children():
				if gc is TextureRect:
					gc.texture = icon_textures[player_avatar]
			break

	# 刷新文字
	var name_lbl = info.get_node_or_null("NameLabel") as Label
	if name_lbl:
		name_lbl.text = player_name
	var lvl_lbl = info.get_node_or_null("LevelLabel") as Label
	if lvl_lbl:
		lvl_lbl.text = _t("lbl_level_progress", [max_level])

	# Update start button text based on progress
	for child in main_menu.get_children():
		if child is Button and child.name == "StartContinueBtn":
			child.text = _t("btn_continue") if max_level > 1 else _t("btn_start")
			break

	if daily_btn and is_instance_valid(daily_btn):
		daily_btn.text = _t("btn_daily")
	_refresh_daily_badge()

func _find_or_create_player_info() -> Control:
	# 查找已存在的 PlayerInfo
	for child in main_menu.get_children():
		if child is Control and child.name == "PlayerInfo":
			return child

	# 首次创建
	var info = Control.new()
	info.name = "PlayerInfo"
	info.position = Vector2(safe_left_margin, 15)

	# Subtle semi-transparent background pill behind the player area
	var info_bg = Panel.new()
	info_bg.name = "InfoBg"
	info_bg.size = Vector2(76, 108)
	info_bg.position = Vector2(-8, -6)
	info_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var info_bg_style = StyleBoxFlat.new()
	info_bg_style.bg_color = Color(0.1, 0.06, 0.03, 0.45)
	info_bg_style.set_corner_radius_all(16)
	info_bg.add_theme_stylebox_override("panel", info_bg_style)
	info.add_child(info_bg)

	# Clickable avatar button (click to re-select avatar and edit name)
	var avatar_btn = Button.new()
	avatar_btn.size = Vector2(60, 60)
	avatar_btn.position = Vector2(0, 0)
	avatar_btn.pressed.connect(_on_main_avatar_pressed)
	var av = TextureRect.new()
	av.texture = icon_textures[player_avatar]
	av.size = Vector2(60, 60)
	av.position = Vector2(0, 0)
	avatar_btn.add_child(av)
	info.add_child(avatar_btn)

	var nl = Label.new()
	nl.name = "NameLabel"
	nl.text = player_name
	nl.position = Vector2(0, 66)
	nl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nl.size = Vector2(60, 20)
	nl.add_theme_font_size_override("font_size", 16)
	nl.add_theme_color_override("font_color", COLOR_TEXT_LIGHT)
	info.add_child(nl)

	# Progress info
	var prog = Label.new()
	prog.name = "LevelLabel"
	prog.text = _t("lbl_level_progress", [max_level])
	prog.position = Vector2(0, 84)
	prog.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prog.size = Vector2(60, 18)
	prog.add_theme_font_size_override("font_size", 13)
	prog.add_theme_color_override("font_color", COLOR_ACCENT_GOLD)
	info.add_child(prog)

	main_menu.add_child(info)
	return info

func _yesterday_string() -> String:
	return Time.get_date_string_from_unix_time(int(Time.get_unix_time_from_system()) - 86400)


func update_progress_on_complete():
	if is_daily:
		daily_best = max(daily_best, score)
		var today := Time.get_date_string_from_system()
		if daily_last_played != today:
			if daily_last_played == _yesterday_string():
				daily_streak += 1
			else:
				daily_streak = 1
			daily_last_played = today
		elif daily_streak <= 0:
			daily_streak = 1
		save_player_data()
		return

	# Calculate stars for this level completion (uses the real tile count, not a formula)
	var pairs = max(level_total_cards / 2, 1)
	var avg_secs_per_pair = elapsed_time / pairs
	var stars := 1
	if avg_secs_per_pair <= 3.5:
		stars = 3
	elif avg_secs_per_pair <= 7.0:
		stars = 2
	# Store stars for this level (keep best)
	while level_stars.size() < level:
		level_stars.append(0)
	var idx = level - 1
	level_stars[idx] = max(level_stars[idx], stars)
	max_level = max(max_level, level + 1)
	total_score += score
	save_player_data()

func _on_main_avatar_pressed():
	show_edit_profile()

func show_edit_profile():
	# Re-use similar UI to creation, but pre-filled for editing name + avatar
	# Clicking avatar on main menu opens this
	var profile = Control.new()
	profile.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg = ColorRect.new()
	bg.color = COLOR_OVERLAY_DEEP
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	profile.add_child(bg)

	# Rounded centered panel with unified style
	var panel = Panel.new()
	var pw := 560
	var ph := 510
	panel.size = Vector2(pw, ph)
	panel.position = Vector2((720 - pw) / 2, (1280 - ph) / 2)
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	profile.add_child(panel)

	var prompt = Label.new()
	prompt.text = _t("profile_edit")
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.position = Vector2(0, 25)
	prompt.size = Vector2(pw, 40)
	prompt.add_theme_font_size_override("font_size", 28)
	prompt.add_theme_color_override("font_color", COLOR_TEXT_LIGHT)
	panel.add_child(prompt)

	var name_label = Label.new()
	name_label.text = _t("profile_username")
	name_label.position = Vector2(40, 78)
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	panel.add_child(name_label)

	var name_edit = LineEdit.new()
	name_edit.placeholder_text = _t("profile_name_placeholder")
	name_edit.text = player_name
	name_edit.position = Vector2(40, 108)
	name_edit.size = Vector2(pw - 80, 42)
	name_edit.add_theme_font_size_override("font_size", 20)
	panel.add_child(name_edit)

	var avatar_label = Label.new()
	avatar_label.text = _t("profile_avatar")
	avatar_label.position = Vector2(40, 162)
	avatar_label.add_theme_font_size_override("font_size", 18)
	avatar_label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	panel.add_child(avatar_label)

	var selected_av = player_avatar
	var av_buttons = []
	# 3x2 grid centered in panel
	var btn_size := 100
	var av_spacing := 130
	var grid_w := 3 * btn_size + 2 * (av_spacing - btn_size)
	var av_start_x := (pw - grid_w) / 2
	var av_start_y := 200
	for i in range(6):
		var col = i % 3
		var row = i / 3
		var btn = Button.new()
		btn.size = Vector2(btn_size, btn_size)
		btn.position = Vector2(av_start_x + col * av_spacing, av_start_y + row * av_spacing)
		btn.flat = true
		var tex = TextureRect.new()
		tex.texture = icon_textures[i]
		tex.size = Vector2(btn_size - 10, btn_size - 10)
		tex.position = Vector2(5, 5)
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(tex)
		btn.pressed.connect(_on_avatar_selected.bind(i, btn, av_buttons))
		panel.add_child(btn)
		av_buttons.append(btn)

	# Initial highlight current
	for b in av_buttons:
		b.modulate = Color(1,1,1)
	av_buttons[player_avatar].modulate = Color(1.3, 1.3, 0.5)
	selected_avatar_for_profile = player_avatar

	var confirm = Button.new()
	confirm.text = _t("profile_confirm_save")
	confirm.position = Vector2((pw - 260) / 2, ph - 65)
	confirm.size = Vector2(260, 55)
	_make_rounded_button(confirm, COLOR_BTN_GREEN, RADIUS_MEDIUM)
	confirm.pressed.connect(func():
		var nm = name_edit.text.strip_edges()
		if nm == "":
			nm = player_name
		player_name = nm
		player_avatar = selected_avatar_for_profile
		save_player_data()
		profile.queue_free()
		show_main_menu()
	)
	panel.add_child(confirm)

	main_menu.add_child(profile)
