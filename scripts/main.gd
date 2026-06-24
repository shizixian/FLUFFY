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
# --- Sizing ---
const RADIUS_LARGE  = 24
const RADIUS_MEDIUM = 18
const RADIUS_PILL   = 28
const SHADOW_SIZE   = 6
const SHADOW_OFFSET = 3

# ====================== LOCALIZATION ======================
const LOCALE = {
	"zh_CN": {
		"tile_sheep": "羊", "tile_grass": "草", "tile_rice": "米",
		"tile_field": "田", "tile_rabbit": "兔", "tile_wolf": "狼",
		"game_title": "FLUFFY羊羊乐",
		"game_subtitle": "可爱配对消除 · 休闲小游戏",
		"btn_start": "开始游戏", "btn_continue": "继续游戏",
		"btn_settings": "设置", "btn_quit": "退出游戏",
		"btn_about": "关于 · v0.3.3", "btn_close": "关闭",
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
		"btn_about": "關於 · v0.3.3", "btn_close": "關閉",
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
		"btn_about": "About · v0.3.3", "btn_close": "Close",
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

# Fixed layout for FLUFFY羊羊乐 style - 2D positions with layers. This keeps the "board size" (行数/布局) constant.
# Deeper stacks added for increased difficulty (more tiles buried, fewer exposed at once).
var layout = [
  # top rows
  {"gx":2, "gy":0, "layer":0}, {"gx":3, "gy":0, "layer":0},
  # next
  {"gx":1, "gy":1, "layer":0}, {"gx":2, "gy":1, "layer":0}, {"gx":3, "gy":1, "layer":0}, {"gx":4, "gy":1, "layer":0},
  # main with layers (deeper stacks for higher difficulty)
  {"gx":0, "gy":2, "layer":0}, {"gx":1, "gy":2, "layer":0}, {"gx":1, "gy":2, "layer":1},
  {"gx":2, "gy":2, "layer":0}, {"gx":2, "gy":2, "layer":1}, {"gx":2, "gy":2, "layer":2}, {"gx":2, "gy":2, "layer":3},
  {"gx":3, "gy":2, "layer":0}, {"gx":3, "gy":2, "layer":1}, {"gx":3, "gy":2, "layer":2}, {"gx":3, "gy":2, "layer":3},
  {"gx":4, "gy":2, "layer":0}, {"gx":4, "gy":2, "layer":1}, {"gx":4, "gy":2, "layer":2},
  {"gx":5, "gy":2, "layer":0}, {"gx":5, "gy":2, "layer":1},
  # bottom
  {"gx":0, "gy":3, "layer":0}, {"gx":1, "gy":3, "layer":0}, {"gx":2, "gy":3, "layer":0}, {"gx":3, "gy":3, "layer":0}, {"gx":4, "gy":3, "layer":0}, {"gx":5, "gy":3, "layer":0},
  # extra for more
  {"gx":1, "gy":4, "layer":0}, {"gx":2, "gy":4, "layer":0}, {"gx":3, "gy":4, "layer":0}, {"gx":4, "gy":4, "layer":0},
]

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
@onready var selected1_label: Label = $UI/Selected1
@onready var selected2_label: Label = $UI/Selected2
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
	_add_pill_behind(selected1_label)
	_add_pill_behind(selected2_label)

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
	level = new_level
	score = 0 if level == 1 else score
	remaining_tiles = 0
	elapsed_time = 0.0
	timer_running = true
	_update_timer_display()
	message_label.text = ""
	message_label.visible = false
	win_panel.visible = false
	selected1_label.visible = false
	selected2_label.visible = false
	selected_idx = -1
	selected_node = null
	update_ui()

	# Clear previous
	for child in board_node.get_children():
		child.queue_free()

	cards.clear()

	# Create fixed slots from layout
	for pos in layout:
		cards.append( {"gx": pos.gx, "gy": pos.gy, "layer": pos.layer, "type": -1, "node": null } )

	# Number of cards for this level (even).
	# We now place *exactly the right quantity* of tiles so that a full solution exists.
	# Faster growth + more types early + deeper stacks = higher difficulty (reaches cap faster, more variety on surface).
	var target_cards = clamp(16 + (level - 1) * 5, 8, cards.size())
	if target_cards % 2 == 1:
		target_cards += 1

	# Build types with *even count per type* (critical: every tile must have a same-type partner).
	# No loners that can never be matched.
	# More types earlier for higher difficulty (harder to find matches on surface).
	var types_pool: Array = []
	var num_types = min(4 + level, TILE_TYPES.size())
	var pairs_total = target_cards / 2
	var pairs_per = pairs_total / num_types
	var extra_pairs = pairs_total % num_types
	for i in range(num_types):
		var this_pairs = pairs_per + (1 if i < extra_pairs else 0)
		for k in range(this_pairs * 2):
			types_pool.append(i)
	# types_pool.size() == target_cards and every used type has even count.

	# Build count map for the generator
	var needed: Dictionary = {}
	for t in types_pool:
		needed[t] = needed.get(t, 0) + 1

	# Generate a *guaranteed solvable* layout using reverse pair placement.
	# This fulfills the request: the initial deal uses the exact right number of blocks
	# arranged so you can clear everything without being forced into "no moves but tiles left".
	# (Suboptimal play can still create temporary blocks — that's when the retained shuffle helps.)
	var generated := generate_solvable_layout(needed)
	if not generated:
		# Rare fallback: spread randomly (old behavior)
		var slot_indices = range(cards.size())
		slot_indices.shuffle()
		for i in range(target_cards):
			cards[ slot_indices[i] ].type = types_pool[i]

	render_cards()

	remaining_tiles = target_cards
	update_ui()
	check_for_moves()

func render_cards() -> void:
	for i in range(cards.size()):
		var c = cards[i]
		if c.type == -1:
			continue
		var node = create_tile_node(c.type, i)
		# Position based on fixed gx gy layer
		var pos_x = 25 + c.gx * 104 + (c.gy % 2) * 24
		var pos_y = 110 + c.gy * 82 - c.layer * 22
		node.position = Vector2(pos_x, pos_y)
		board_node.add_child(node)
		c.node = node

func create_tile_node(type_idx: int, card_idx: int) -> Node2D:
	var node = Node2D.new()

	var icon_size := 72
	var half := icon_size / 2.0

	# Selection border (behind the button)
	var sel_border = ColorRect.new()
	sel_border.name = "SelBorder"
	sel_border.size = Vector2(icon_size, icon_size)
	sel_border.color = Color(1, 0.85, 0, 0)
	sel_border.position = Vector2(-half, -half)
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
	node.add_child(icon)

	return node

func _on_card_button_pressed(card_idx: int) -> void:
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
	# Free check is already done in _input before calling us
	var c = cards[card_idx]

	if selected_idx == -1:
		# First selection
		selected_idx = card_idx
		selected_node = c.node
		highlight_tile(selected_node, true)
		update_selected_ui()
	else:
		# Second selection
		if selected_idx == card_idx:
			# Same card, deselect
			if selected_node and is_instance_valid(selected_node):
				highlight_tile(selected_node, false)
			selected_idx = -1
			selected_node = null
			update_selected_ui()
			return

		var first_type = cards[selected_idx].type
		var second_type = c.type

		if first_type == second_type:
			# Match! Remove both
			# Clear selection state FIRST
			var idx1 = selected_idx
			var node1 = selected_node
			selected_idx = -1
			selected_node = null
			update_selected_ui()

			remove_card(idx1)
			remove_card(card_idx)

			score += 10 + level * 2
			# remaining already decreased in remove_card

			message_label.text = _t("msg_match")
			message_label.visible = true
			await get_tree().create_timer(0.6).timeout
			message_label.text = ""
			message_label.visible = false

			# Check win
			if remaining_tiles <= 0:
				show_win()
			else:
				check_for_moves()
		else:
			message_label.text = _t("msg_no_match")
			message_label.visible = true
			await get_tree().create_timer(0.8).timeout
			message_label.text = ""
			message_label.visible = false

			# Deselect old
			if selected_node and is_instance_valid(selected_node):
				highlight_tile(selected_node, false)
			selected_idx = card_idx
			selected_node = c.node
			highlight_tile(selected_node, true)
			update_selected_ui()

			# Re-check moves in case the board state changed the "stuck" status
			check_for_moves()

	update_ui()

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

func _is_slot_placeable(idx: int) -> bool:
	var c = cards[idx]
	if c.type != -1:
		return false

	# Covered by higher layer at same (gx,gy)?
	for j in range(cards.size()):
		var o = cards[j]
		if o.type != -1 and o.gx == c.gx and o.gy == c.gy and o.layer > c.layer:
			return false

	# Has at least one clear side (left or right same layer/row has no tile)
	# This mirrors the "free" rule used for selection.
	var left_clear = true
	var right_clear = true
	for j in range(cards.size()):
		var o = cards[j]
		if o.type != -1 and o.layer == c.layer and o.gy == c.gy:
			if o.gx == c.gx - 1:
				left_clear = false
			if o.gx == c.gx + 1:
				right_clear = false
	return left_clear or right_clear


func generate_solvable_layout(needed: Dictionary) -> bool:
	# Reverse-build a guaranteed solvable board by placing pairs onto positions
	# that are "placeable" (would be free/selectable in the reverse of elimination).
	# This is the core of "放数量正好的方块": we only ever introduce matched pairs
	# onto spots that respect the current free rules, so a complete clearing sequence
	# is guaranteed to exist by construction.
	# Every type count in 'needed' must be even.
	var total_to_place: int = 0
	for cnt in needed.values():
		total_to_place += cnt
	if total_to_place == 0 or total_to_place % 2 != 0:
		return false

	var max_attempts := 120
	for attempt in range(max_attempts):
		# Start this attempt with a completely empty board (only layout slots exist)
		for c in cards:
			c.type = -1

		var current_needed: Dictionary = needed.duplicate()
		var placed := 0
		var stuck := false

		while placed < total_to_place:
			# Find currently placeable empty slots under the free rules
			var placeables: Array = []
			for i in range(cards.size()):
				if _is_slot_placeable(i):
					placeables.append(i)

			if placeables.size() < 2:
				stuck = true
				break

			# Pick a type that still has at least a pair left to place
			var avail_types: Array = []
			for t in current_needed.keys():
				if current_needed[t] >= 2:
					avail_types.append(t)

			if avail_types.size() == 0:
				stuck = true
				break

			# Random choices give good variety while staying solvable
			placeables.shuffle()
			avail_types.shuffle()

			var p1: int = placeables[0]
			var p2: int = placeables[1]
			var chosen: int = avail_types[0]

			cards[p1].type = chosen
			cards[p2].type = chosen
			current_needed[chosen] -= 2
			if current_needed[chosen] <= 0:
				current_needed.erase(chosen)
			placed += 2

		if not stuck and placed == total_to_place:
			return true

	# Could not find a solvable arrangement in the attempts (very rare with current layout sizes).
	return false


func update_ui() -> void:
	level_label.text = _t("lbl_level", [level])
	score_label.text = _t("lbl_score", [score])
	remaining_label.text = _t("lbl_remaining", [remaining_tiles])

func update_selected_ui() -> void:
	if selected_idx == -1:
		selected1_label.visible = false
		selected2_label.visible = false
		$UI/Selected1Pill.visible = false
		$UI/Selected2Pill.visible = false
	else:
		var t = cards[selected_idx].type
		selected1_label.text = _t("selected_one", [_tile_name(t)])
		selected1_label.visible = true
		selected2_label.text = _t("select_another")
		selected2_label.visible = true
		$UI/Selected1Pill.visible = true
		$UI/Selected2Pill.visible = true

func has_possible_move() -> bool:
	# Returns true if there exists at least one pair of free cards with the same type.
	# This is the proper "can I clear more?" check so the game doesn't get stuck unplayably.
	var free_list = []
	for i in range(cards.size()):
		if is_card_free(i):
			free_list.append(i)
	for a in range(free_list.size()):
		for b in range(a + 1, free_list.size()):
			if cards[free_list[a]].type == cards[free_list[b]].type:
				return true
	return false

func check_for_moves() -> void:
	if remaining_tiles == 0:
		return
	if has_possible_move():
		message_label.text = ""
		message_label.visible = false
		shuffle_button.disabled = false
	else:
		message_label.text = _t("msg_no_moves")
		message_label.visible = true
		shuffle_button.disabled = false

func _on_shuffle_pressed() -> void:
	# Collect remaining types
	var remaining_types: Array = []
	for c in cards:
		if c.type != -1:
			remaining_types.append(c.type)

	if remaining_types.size() == 0:
		return

	remaining_types.shuffle()

	# Clear all current nodes and types
	for c in cards:
		if c.node and is_instance_valid(c.node):
			c.node.queue_free()
		c.node = null
		c.type = -1

	# Try to re-deal the remaining tiles using the solvable generator first.
	# This makes shuffle not only give you an immediate move, but a full solvable
	# endgame layout for the remaining cards (aligns with the "exact right quantity" goal).
	var remaining_needed: Dictionary = {}
	for t in remaining_types:
		remaining_needed[t] = remaining_needed.get(t, 0) + 1

	var used_solvable_shuffle := false
	if generate_solvable_layout(remaining_needed):
		used_solvable_shuffle = true
	else:
		# Fallback to classic random spread across full layout
		var slot_indices = range(cards.size())
		slot_indices.shuffle()
		for j in range(remaining_types.size()):
			var slot = slot_indices[j]
			cards[slot].type = remaining_types[j]

	# Re-render (nodes were cleared inside generate or we clear here for fallback)
	# Note: generate_solvable_layout already set types but did not touch nodes.
	# We still need to clear old nodes and re-render.
	for c in cards:
		if c.node and is_instance_valid(c.node):
			c.node.queue_free()
		c.node = null
	render_cards()

	remaining_tiles = remaining_types.size()
	message_label.text = _t("msg_shuffled")
	message_label.visible = true
	_shuffle_message_showing = true
	update_ui()
	check_for_moves()

	# Robust endgame handling (kept for safety): if still no immediate move after the
	# above, do limited random re-shuffles (this path is now very unlikely).
	var shuffle_attempts = 0
	const MAX_SHUFFLE_ATTEMPTS = 8
	while remaining_tiles > 0 and not has_possible_move() and shuffle_attempts < MAX_SHUFFLE_ATTEMPTS:
		shuffle_attempts += 1
		remaining_types.shuffle()
		for c in cards:
			c.type = -1
			if c.node and is_instance_valid(c.node):
				c.node.queue_free()
			c.node = null
		var slot_indices = range(cards.size())
		slot_indices.shuffle()
		for j in range(remaining_types.size()):
			cards[slot_indices[j]].type = remaining_types[j]
		render_cards()
		remaining_tiles = remaining_types.size()
		check_for_moves()

	if used_solvable_shuffle:
		message_label.text = _t("msg_shuffled_solvable")
	elif shuffle_attempts > 0:
		message_label.text = _t("msg_shuffled_auto")

	await get_tree().create_timer(1.2).timeout
	if _shuffle_message_showing:
		message_label.text = ""
		_shuffle_message_showing = false
		message_label.visible = false

func _on_restart_pressed() -> void:
	start_level(level)

func _on_next_level() -> void:
	win_panel.visible = false
	start_level(level + 1)

func show_win() -> void:
	timer_running = false
	message_label.text = ""

	# 计算星级：基于通关用时和关卡难度
	var pairs = (16 + (level - 1) * 5) / 2  # 本关牌对数
	# 快速线：每对牌平均用时
	var avg_secs_per_pair = elapsed_time / max(pairs, 1)
	var stars := 1
	if avg_secs_per_pair <= 3.5:
		stars = 3
	elif avg_secs_per_pair <= 7.0:
		stars = 2

	# 时间奖励分
	var time_bonus = 0
	if stars == 3:
		time_bonus = int(200 * level - elapsed_time * 2)
	elif stars == 2:
		time_bonus = int(100 * level - elapsed_time)
	time_bonus = max(time_bonus, 10 * level)

	score += time_bonus
	update_ui()

	# 更新胜利面板
	var win_label = $UI/WinPanel/WinLabel
	if win_label:
		win_label.text = _t("win_title")
		win_label.add_theme_color_override("font_color", COLOR_TEXT_GOLD)
		win_label.add_theme_font_size_override("font_size", 52)

	# 清除旧的统计标签
	for child in win_panel.get_children():
		if child.name.begins_with("Stat_"):
			child.queue_free()

	# 星级 — centered HBoxContainer with individual star labels
	var star_container = HBoxContainer.new()
	star_container.name = "Stat_StarsContainer"
	star_container.alignment = BoxContainer.ALIGNMENT_CENTER
	star_container.size = Vector2(400, 60)
	star_container.position = Vector2(120, 150)
	for i in range(3):
		var star_lbl = Label.new()
		star_lbl.text = "⭐" if i < stars else "☆"
		star_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		star_lbl.add_theme_font_size_override("font_size", 42)
		star_lbl.size = Vector2(100, 56)
		star_container.add_child(star_lbl)
	win_panel.add_child(star_container)

	# 统计信息
	var total_secs = int(elapsed_time)
	var time_str = "%02d:%02d" % [total_secs / 60, total_secs % 60]
	var stats = [
		_t("win_level_done", [level]),
		_t("win_time", [time_str]),
		_t("win_score", [score, time_bonus]),
	]
	var stats_y = 225
	for stat in stats:
		var sl = Label.new()
		sl.name = "Stat_%s" % stat
		sl.text = stat
		sl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sl.position = Vector2(20, stats_y)
		sl.size = Vector2(480, 30)
		sl.add_theme_font_size_override("font_size", 20)
		sl.add_theme_color_override("font_color", COLOR_TEXT_LIGHT)
		win_panel.add_child(sl)
		stats_y += 35

	win_panel.visible = true

	# Save progress
	update_progress_on_complete()

	print("Level %d cleared! Score: %d, Time: %s, Stars: %d" % [level, score, time_str, stars])

func _input(event: InputEvent) -> void:
	# Card touch handled by Button.pressed signals (see _on_card_button_pressed).
	# Only global shortcuts here.
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if level_select.visible:
			_fade_out(level_select)
			show_main_menu()
			main_menu.modulate.a = 0.0
			var t = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			t.tween_property(main_menu, "modulate:a", 1.0, 0.2)
		elif pause_menu.visible:
			_on_resume_pressed()
		elif settings_menu.visible:
			_fade_out(settings_menu)
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
	start.position = Vector2(40, 35)
	start.size = Vector2(400, 80)
	start.pressed.connect(_on_start_game_pressed)
	_r_menu_start = start
	_make_rounded_button(start, COLOR_BTN_GREEN, RADIUS_PILL)
	btn_card.add_child(start)
	start.name = "StartContinueBtn"
	# Settings button
	var settings_btn = Button.new()
	settings_btn.text = _t("btn_settings")
	settings_btn.position = Vector2(40, 135)
	settings_btn.size = Vector2(400, 70)
	settings_btn.pressed.connect(_on_settings_pressed)
	_r_menu_settings = settings_btn
	_make_rounded_button(settings_btn, COLOR_BTN_BLUE, RADIUS_MEDIUM)
	btn_card.add_child(settings_btn)

	# Quit button
	var quit = Button.new()
	quit.text = _t("btn_quit")
	quit.position = Vector2(40, 225)
	quit.size = Vector2(400, 70)
	quit.pressed.connect(func(): get_tree().quit())
	_r_menu_quit = quit
	_make_rounded_button(quit, COLOR_BTN_RED, RADIUS_MEDIUM)
	btn_card.add_child(quit)

	# Version / About — subtle text link at bottom of card
	var about_btn = Button.new()
	about_btn.text = _t("btn_about")
	about_btn.position = Vector2(140, 340)
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
		_fade_out(level_select)
		show_main_menu()
		main_menu.modulate.a = 0.0
		var tb = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tb.tween_property(main_menu, "modulate:a", 1.0, 0.2)
	)
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
	selected1_label.visible = false
	selected2_label.visible = false
	$UI/Selected1Pill.visible = false
	$UI/Selected2Pill.visible = false
	$UI/LevelLabelPill.visible = false
	$UI/ScoreLabelPill.visible = false
	$UI/RemainingLabelPill.visible = false
	win_panel.visible = false
	$UI/TitleLabel.visible = false
	settings_menu.visible = false
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

	btn.add_theme_font_size_override("font_size", 24)
	btn.add_theme_color_override("font_color", COLOR_TEXT_LIGHT)

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
	if _r_menu_about:     _r_menu_about.text = _t("btn_about")

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

	# Game HUD (re-call update functions which use _t())
	update_ui()
	update_selected_ui()
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

func update_progress_on_complete():
	# Calculate stars for this level completion
	var pairs = (16 + (level - 1) * 5) / 2
	var avg_secs_per_pair = elapsed_time / max(pairs, 1)
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
