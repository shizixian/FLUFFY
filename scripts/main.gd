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
var pause_menu: Control
var pause_button: Button
var cover_texture: Texture2D
var paused = false
var about_dialog: AcceptDialog
var bgm_player: AudioStreamPlayer
var settings_menu: Control
var bgm_volume := 0.7
var bgm_enabled := true
var pause_vol_slider: HSlider
var settings_vol_slider: HSlider
var pause_bgm_check: CheckBox
var settings_bgm_check: CheckBox

# Player profile and progress
var player_name := ""
var player_avatar := 0  # 0-5 corresponding to icon_textures
var max_level := 1
var total_score := 0
var selected_avatar_for_profile := 0
var safe_left_margin := 50  # adjusted for camera cutouts on mobile
var _safe_area_detected := false

func _ready() -> void:
	shuffle_button.pressed.connect(_on_shuffle_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	next_button.pressed.connect(_on_next_level)

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

	# Sync initial slider values
	if pause_vol_slider:
		pause_vol_slider.value = bgm_volume
	if settings_vol_slider:
		settings_vol_slider.value = bgm_volume

	# Load player data and decide UI
	load_player_data()
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
		timer_label.text = "⏱ %02d:%02d" % [mins, secs]

func start_level(new_level: int) -> void:
	level = new_level
	score = 0 if level == 1 else score
	remaining_tiles = 0
	elapsed_time = 0.0
	timer_running = true
	_update_timer_display()
	message_label.text = ""
	win_panel.visible = false
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

			message_label.text = "消除成功！"
			await get_tree().create_timer(0.6).timeout
			message_label.text = ""

			# Check win
			if remaining_tiles <= 0:
				show_win()
			else:
				check_for_moves()
		else:
			message_label.text = "不匹配！"
			await get_tree().create_timer(0.8).timeout
			message_label.text = ""

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
	level_label.text = "第 %d 关" % level
	score_label.text = "得分: %d" % score
	remaining_label.text = "剩余: %d" % remaining_tiles

func update_selected_ui() -> void:
	if selected_idx == -1:
		selected1_label.text = "选中: 无"
		selected2_label.text = "选中: 无"
	else:
		var t = cards[selected_idx].type
		selected1_label.text = "选中: " + TILE_TYPES[t]
		selected2_label.text = "再选一个"

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
		shuffle_button.disabled = false
	else:
		message_label.text = "牌面已无解！点击【洗牌】继续"
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
	message_label.text = "已洗牌"
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
		message_label.text = "已洗牌（可解重排）"
	elif shuffle_attempts > 0:
		message_label.text = "已洗牌（系统已自动重排直到有解）"

	await get_tree().create_timer(1.2).timeout
	if message_label.text.begins_with("已洗牌"):
		message_label.text = ""

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
		win_label.text = "🌟 通关！"

	# 清除旧的统计标签
	for child in win_panel.get_children():
		if child.name.begins_with("Stat_"):
			child.queue_free()

	# 星级
	var star_str = ""
	for i in range(3):
		star_str += "⭐" if i < stars else "☆"

	var star_label = Label.new()
	star_label.name = "Stat_Stars"
	star_label.text = star_str
	star_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	star_label.position = Vector2(20, 160)
	star_label.size = Vector2(480, 40)
	star_label.add_theme_font_size_override("font_size", 36)
	win_panel.add_child(star_label)

	# 统计信息
	var total_secs = int(elapsed_time)
	var time_str = "%02d:%02d" % [total_secs / 60, total_secs % 60]
	var stats = [
		"第 %d 关完成" % level,
		"用时: %s" % time_str,
		"本关得分: %d (+%d 时间奖励)" % [score, time_bonus],
	]
	var stats_y = 220
	for stat in stats:
		var sl = Label.new()
		sl.name = "Stat_%s" % stat
		sl.text = stat
		sl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sl.position = Vector2(20, stats_y)
		sl.size = Vector2(480, 30)
		sl.add_theme_font_size_override("font_size", 20)
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
		_on_restart_pressed()

# ====================== NEW MENU SYSTEM ======================

func _setup_pause_button():
	pause_button = Button.new()
	pause_button.text = "暂停"
	pause_button.position = Vector2(580, 20)
	pause_button.size = Vector2(120, 60)
	pause_button.pressed.connect(_on_pause_pressed)
	$UI.add_child(pause_button)

func _setup_pause_menu():
	pause_menu = Control.new()
	pause_menu.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Semi-transparent background
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_menu.add_child(bg)

	# Centered rounded panel
	var panel = Panel.new()
	panel.size = Vector2(520, 500)
	# Center horizontally on 720px screen: (720-520)/2 = 100
	# Center vertically: (1280-500)/2 = 390
	panel.position = Vector2(100, 390)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	# Round corners
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.18, 0.2, 0.25, 0.95)
	panel_style.corner_radius_top_left = 24
	panel_style.corner_radius_top_right = 24
	panel_style.corner_radius_bottom_left = 24
	panel_style.corner_radius_bottom_right = 24
	panel.add_theme_stylebox_override("panel", panel_style)
	pause_menu.add_child(panel)

	# Title
	var title = Label.new()
	title.text = "游戏暂停"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 30)
	title.size = Vector2(520, 50)
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(1, 1, 1))
	panel.add_child(title)

	# Resume button
	var resume = Button.new()
	resume.text = "继续游戏"
	resume.position = Vector2(110, 100)
	resume.size = Vector2(300, 70)
	_make_rounded_button(resume, Color(0.3, 0.7, 0.4))
	resume.pressed.connect(_on_resume_pressed)
	panel.add_child(resume)

	# Exit to main menu
	var exit_btn = Button.new()
	exit_btn.text = "退出至主页"
	exit_btn.position = Vector2(110, 190)
	exit_btn.size = Vector2(300, 70)
	_make_rounded_button(exit_btn, Color(0.8, 0.3, 0.3))
	exit_btn.pressed.connect(_on_exit_to_main_pressed)
	panel.add_child(exit_btn)

	# Volume control
	var vol_label = Label.new()
	vol_label.text = "背景音乐音量"
	vol_label.position = Vector2(50, 280)
	vol_label.add_theme_font_size_override("font_size", 18)
	vol_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
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
	bgm_check.text = "开启背景音乐"
	bgm_check.position = Vector2(50, 360)
	bgm_check.button_pressed = bgm_enabled
	bgm_check.add_theme_font_size_override("font_size", 18)
	bgm_check.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	bgm_check.toggled.connect(_on_bgm_toggled)
	panel.add_child(bgm_check)
	pause_bgm_check = bgm_check

	$UI.add_child(pause_menu)

func _setup_main_menu():
	main_menu = CanvasLayer.new()

	# Cover background (AI generated)
	var bg = TextureRect.new()
	bg.texture = cover_texture
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_menu.add_child(bg)

	# Dark overlay for readability
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.25)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_menu.add_child(overlay)

	# No title text or subtitle on main menu (per request) — the game name is only on the cover image.

	# Start button - rounded
	var start = Button.new()
	start.text = "开始游戏"
	start.position = Vector2(160, 980)
	start.size = Vector2(400, 90)
	start.pressed.connect(_on_start_game_pressed)
	_make_rounded_button(start, Color(0.3, 0.7, 0.4))
	main_menu.add_child(start)

	# Quit button - rounded
	var quit = Button.new()
	quit.text = "退出游戏"
	quit.position = Vector2(160, 1090)
	quit.size = Vector2(400, 75)
	quit.pressed.connect(func(): get_tree().quit())
	_make_rounded_button(quit, Color(0.8, 0.3, 0.3))
	main_menu.add_child(quit)

	# Settings button on main menu
	var settings_btn = Button.new()
	settings_btn.text = "设置"
	settings_btn.position = Vector2(160, 1180)
	settings_btn.size = Vector2(400, 75)
	settings_btn.pressed.connect(_on_settings_pressed)
	_make_rounded_button(settings_btn, Color(0.4, 0.6, 0.8))
	main_menu.add_child(settings_btn)

	# Bottom right: Yellow ! about icon + "关于"
	var about_container = Control.new()
	about_container.size = Vector2(70, 65)
	about_container.position = Vector2(640, 1200)  # bottom right for 720x1280, slightly adjusted
	main_menu.add_child(about_container)

	# Yellow exclamation icon button for 关于
	var about_btn = Button.new()
	about_btn.text = "❗"
	about_btn.size = Vector2(50, 50)
	about_btn.position = Vector2(10, 0)
	var yellow_style = StyleBoxFlat.new()
	yellow_style.bg_color = Color(1, 0.85, 0)
	yellow_style.corner_radius_top_left = 18
	yellow_style.corner_radius_top_right = 18
	yellow_style.corner_radius_bottom_left = 18
	yellow_style.corner_radius_bottom_right = 18
	about_btn.add_theme_stylebox_override("normal", yellow_style)
	about_btn.add_theme_font_size_override("font_size", 22)
	about_btn.pressed.connect(_on_about_pressed)
	about_container.add_child(about_btn)

	# "关于" text below
	var about_label = Label.new()
	about_label.text = "关于"
	about_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	about_label.size = Vector2(70, 18)
	about_label.position = Vector2(0, 38)
	about_label.add_theme_font_size_override("font_size", 12)
	about_container.add_child(about_label)

	add_child(main_menu)

func _hide_game_ui():
	board_node.visible = false
	pause_button.visible = false
	level_label.visible = false
	score_label.visible = false
	remaining_label.visible = false
	shuffle_button.visible = false
	restart_button.visible = false
	message_label.visible = false
	win_panel.visible = false
	$UI/TitleLabel.visible = false
	settings_menu.visible = false
	timer_running = false
	if timer_label:
		timer_label.visible = false
	# Keep BGM playing continuously (loops in game and menus)

func _show_game_ui():
	board_node.visible = true
	pause_button.visible = true
	level_label.visible = true
	score_label.visible = true
	remaining_label.visible = true
	shuffle_button.visible = true
	restart_button.visible = true
	message_label.visible = true
	$UI/TitleLabel.visible = false
	if timer_label:
		timer_label.visible = true
	if bgm_player and bgm_player.stream and bgm_enabled and not bgm_player.playing:
		bgm_player.play()

func _on_pause_pressed():
	paused = true
	if pause_vol_slider:
		pause_vol_slider.value = bgm_volume
	if pause_bgm_check:
		pause_bgm_check.button_pressed = bgm_enabled
	pause_menu.visible = true
	pause_button.visible = false

func _on_resume_pressed():
	paused = false
	pause_menu.visible = false
	pause_button.visible = true

func _on_exit_to_main_pressed():
	paused = false
	pause_menu.visible = false
	settings_menu.visible = false
	_hide_game_ui()
	show_main_menu()
	# Optional: reset any state

func _on_start_game_pressed():
	main_menu.visible = false
	_show_game_ui()
	start_level(max_level)  # Continue from highest unlocked level (saved progress)

func _make_rounded_button(btn: Button, bg_color: Color):
	var normal = StyleBoxFlat.new()
	normal.bg_color = bg_color
	normal.corner_radius_top_left = 15
	normal.corner_radius_top_right = 15
	normal.corner_radius_bottom_left = 15
	normal.corner_radius_bottom_right = 15
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	btn.add_theme_stylebox_override("normal", normal)

	var hover = normal.duplicate()
	hover.bg_color = bg_color.lightened(0.15)
	btn.add_theme_stylebox_override("hover", hover)

	var pressed = normal.duplicate()
	pressed.bg_color = bg_color.darkened(0.1)
	btn.add_theme_stylebox_override("pressed", pressed)

func _setup_about_dialog():
	about_dialog = AcceptDialog.new()
	about_dialog.title = "关于"
	about_dialog.dialog_text = "作者：ShiZixian (Zan)\n\n编程协助：Grok & Claude Code\n\n这是一个基于《FLUFFY羊羊乐》的休闲消除类小游戏。\n感谢游玩！\n\n© 2026"
	add_child(about_dialog)

func _setup_timer_label():
	timer_label = Label.new()
	timer_label.name = "TimerLabel"
	timer_label.text = "⏱ 00:00"
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.position = Vector2(260, 80)
	timer_label.size = Vector2(200, 40)
	timer_label.add_theme_font_size_override("font_size", 34)
	timer_label.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
	$UI.add_child(timer_label)

func _on_about_pressed():
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

	# Semi-transparent background
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP  # block clicks from passing through
	settings_menu.add_child(bg)

	# Centered rounded panel
	var panel = Panel.new()
	panel.size = Vector2(520, 320)
	panel.position = Vector2(100, 480)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var sett_style = StyleBoxFlat.new()
	sett_style.bg_color = Color(0.18, 0.2, 0.25, 0.95)
	sett_style.corner_radius_top_left = 24
	sett_style.corner_radius_top_right = 24
	sett_style.corner_radius_bottom_left = 24
	sett_style.corner_radius_bottom_right = 24
	panel.add_theme_stylebox_override("panel", sett_style)
	settings_menu.add_child(panel)

	# Title
	var title = Label.new()
	title.text = "设置"
	title.position = Vector2(50, 25)
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(1, 1, 1))
	panel.add_child(title)

	# Volume
	var vol_label = Label.new()
	vol_label.text = "背景音乐音量"
	vol_label.position = Vector2(50, 70)
	vol_label.add_theme_font_size_override("font_size", 18)
	vol_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
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
	bgm_check.text = "开启背景音乐"
	bgm_check.position = Vector2(50, 150)
	bgm_check.button_pressed = bgm_enabled
	bgm_check.add_theme_font_size_override("font_size", 18)
	bgm_check.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	bgm_check.toggled.connect(_on_bgm_toggled)
	panel.add_child(bgm_check)
	settings_bgm_check = bgm_check

	# Close
	var close = Button.new()
	close.text = "关闭"
	close.position = Vector2(185, 240)
	close.size = Vector2(150, 55)
	_make_rounded_button(close, Color(0.5, 0.5, 0.5))
	close.pressed.connect(func(): settings_menu.visible = false)
	panel.add_child(close)

	main_menu.add_child(settings_menu)
	settings_menu.visible = false

func _on_settings_pressed():
	if settings_vol_slider:
		settings_vol_slider.value = bgm_volume
	if settings_bgm_check:
		settings_bgm_check.button_pressed = bgm_enabled
	settings_menu.visible = true

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
	config.set_value("settings", "volume", bgm_volume)
	config.set_value("settings", "bgm_enabled", bgm_enabled)
	config.save("user://player_data.cfg")

func load_player_data():
	var config = ConfigFile.new()
	if config.load("user://player_data.cfg") == OK:
		player_name = config.get_value("player", "name", "")
		player_avatar = config.get_value("player", "avatar", 0)
		max_level = config.get_value("progress", "max_level", 1)
		total_score = config.get_value("progress", "total_score", 0)
		bgm_volume = config.get_value("settings", "volume", 0.7)
		bgm_enabled = config.get_value("settings", "bgm_enabled", true)
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
	bg.color = Color(0.1, 0.1, 0.2, 0.95)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	profile.add_child(bg)

	# Rounded centered panel
	var panel = Panel.new()
	var pw := 560
	var ph := 510
	panel.size = Vector2(pw, ph)
	panel.position = Vector2((720 - pw) / 2, (1280 - ph) / 2)
	var ps = StyleBoxFlat.new()
	ps.bg_color = Color(0.15, 0.17, 0.22, 0.97)
	ps.corner_radius_top_left = 24
	ps.corner_radius_top_right = 24
	ps.corner_radius_bottom_left = 24
	ps.corner_radius_bottom_right = 24
	panel.add_theme_stylebox_override("panel", ps)
	profile.add_child(panel)

	var prompt = Label.new()
	prompt.text = "创建玩家档案"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.position = Vector2(0, 25)
	prompt.size = Vector2(pw, 40)
	prompt.add_theme_font_size_override("font_size", 28)
	prompt.add_theme_color_override("font_color", Color(1, 1, 1))
	panel.add_child(prompt)

	var name_label = Label.new()
	name_label.text = "用户名:"
	name_label.position = Vector2(40, 78)
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	panel.add_child(name_label)

	var name_edit = LineEdit.new()
	name_edit.placeholder_text = "输入你的名字"
	name_edit.position = Vector2(40, 108)
	name_edit.size = Vector2(pw - 80, 42)
	name_edit.add_theme_font_size_override("font_size", 20)
	panel.add_child(name_edit)

	var avatar_label = Label.new()
	avatar_label.text = "选择头像"
	avatar_label.position = Vector2(40, 162)
	avatar_label.add_theme_font_size_override("font_size", 18)
	avatar_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
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
	confirm.text = "创建并开始"
	confirm.position = Vector2((pw - 260) / 2, ph - 65)
	confirm.size = Vector2(260, 55)
	_make_rounded_button(confirm, Color(0.3, 0.7, 0.4))
	confirm.pressed.connect(func():
		var nm = name_edit.text.strip_edges()
		if nm == "":
			nm = "玩家" + str(randi() % 900 + 100)
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
		lvl_lbl.text = "Lv.%d" % max_level

	# Update start button text based on progress
	for child in main_menu.get_children():
		if child is Button and ("开始游戏" in child.text or "继续游戏" in child.text):
			child.text = "继续游戏" if max_level > 1 else "开始游戏"
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
	nl.add_theme_font_size_override("font_size", 18)
	nl.add_theme_color_override("font_color", Color(1, 1, 1))
	info.add_child(nl)

	# Progress info
	var prog = Label.new()
	prog.name = "LevelLabel"
	prog.text = "Lv.%d" % max_level
	prog.position = Vector2(0, 84)
	prog.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prog.size = Vector2(60, 18)
	prog.add_theme_font_size_override("font_size", 16)
	prog.add_theme_color_override("font_color", Color(0.9, 0.9, 0.5))
	info.add_child(prog)

	main_menu.add_child(info)
	return info

func update_progress_on_complete():
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
	bg.color = Color(0.1, 0.1, 0.2, 0.95)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	profile.add_child(bg)

	# Rounded centered panel
	var panel = Panel.new()
	var pw := 560
	var ph := 510
	panel.size = Vector2(pw, ph)
	panel.position = Vector2((720 - pw) / 2, (1280 - ph) / 2)
	var ps = StyleBoxFlat.new()
	ps.bg_color = Color(0.15, 0.17, 0.22, 0.97)
	ps.corner_radius_top_left = 24
	ps.corner_radius_top_right = 24
	ps.corner_radius_bottom_left = 24
	ps.corner_radius_bottom_right = 24
	panel.add_theme_stylebox_override("panel", ps)
	profile.add_child(panel)

	var prompt = Label.new()
	prompt.text = "修改档案"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.position = Vector2(0, 25)
	prompt.size = Vector2(pw, 40)
	prompt.add_theme_font_size_override("font_size", 28)
	prompt.add_theme_color_override("font_color", Color(1, 1, 1))
	panel.add_child(prompt)

	var name_label = Label.new()
	name_label.text = "用户名:"
	name_label.position = Vector2(40, 78)
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	panel.add_child(name_label)

	var name_edit = LineEdit.new()
	name_edit.placeholder_text = "输入你的名字"
	name_edit.text = player_name
	name_edit.position = Vector2(40, 108)
	name_edit.size = Vector2(pw - 80, 42)
	name_edit.add_theme_font_size_override("font_size", 20)
	panel.add_child(name_edit)

	var avatar_label = Label.new()
	avatar_label.text = "选择头像"
	avatar_label.position = Vector2(40, 162)
	avatar_label.add_theme_font_size_override("font_size", 18)
	avatar_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
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
	confirm.text = "保存修改"
	confirm.position = Vector2((pw - 260) / 2, ph - 65)
	confirm.size = Vector2(260, 55)
	_make_rounded_button(confirm, Color(0.3, 0.7, 0.4))
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
