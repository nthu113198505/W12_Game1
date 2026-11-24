extends Control

const BG := Color("11172b")
const INK := Color("17233e")
const CREAM := Color("fff7e8")
const GOLD := Color("f6c86c")
const MINT := Color("8bd6b3")
const PINK := Color("f49caa")
const BLUE := Color("92b7f3")
const LAVENDER := Color("c1a6ed")

var current_level := 0
var score := [0, 0]
var attempts := [0, 0]
var keys := [false, false]
var prompt: Label
var score_label: Label
var status_label: Label
var choices: Array[Button] = []
var door_label: Label
var progress_label: Label
var level_tabs: Array[Button] = []
var level_title: Label
var room_name: Label
var question_label: Label

var lessons := [
	{
		"title": "第一關・零錢迷宮",
		"room": "失物銀行",
		"intro": "小夢在口袋找到 50 元。她想買 30 元的點心，也想為下週的圖書日存錢。怎麼安排比較好？",
		"question": "哪個做法能同時照顧今天與未來？",
		"options": ["花光 50 元，剩下的事下週再說", "先存 20 元，再用 30 元買點心", "把 50 元借給陌生人，等他加倍還"],
		"answer": 1,
		"right": "答對了！先把目標存款留下，再用剩下的錢消費，叫做先存後花。",
		"wrong": "再想一想：點心 30 元，50 元還能留下多少呢？"
	},
	{
		"title": "第二關・星光花園",
		"room": "小小投資站",
		"intro": "小夢有 100 枚星星點數，想讓它慢慢長大。園丁提醒：投資可能有收穫，也可能會減少。",
		"question": "哪個選擇最能分散風險、安心學習？",
		"options": ["全部押在一株陌生種子上，保證會變多", "分散到幾種植物，先了解風險並請家人討論", "借很多點數來投資，越多越容易賺"],
		"answer": 1,
		"right": "太好了！分散投資、先了解風險，並和信任的大人討論，是更謹慎的選擇。",
		"wrong": "想想看：投資沒有保證獲利，全部押一種或借很多點數會怎麼樣？"
	}
]

func _ready() -> void:
	_build_scene()
	_show_level(0)

func _build_scene() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = BG
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var glow := ColorRect.new()
	glow.color = Color("1b2745")
	glow.position = Vector2(0, 0)
	glow.size = Vector2(1280, 390)
	add_child(glow)

	# Misty layered windows and warm glimmers create an original dreamlike world.
	for i in range(6):
		var star := Label.new()
		star.text = ["✦", "·", "✧", "⋆"][i % 4]
		star.add_theme_font_size_override("font_size", 18 + (i % 3) * 8)
		star.add_theme_color_override("font_color", Color(0.97, 0.81, 0.49, 0.72))
		star.position = Vector2(55 + i * 218, 82 + (i % 2) * 68)
		add_child(star)

	var title := Label.new()
	title.text = "小小夢魔　✦　星光存錢屋"
	title.position = Vector2(48, 24)
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", CREAM)
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "生活理財 × 小小冒險　｜　每答對一題，點亮一把鑰匙"
	subtitle.position = Vector2(52, 65)
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color("c4cbe0"))
	add_child(subtitle)

	var room := Panel.new()
	room.position = Vector2(48, 112)
	room.size = Vector2(1184, 550)
	var room_style := StyleBoxFlat.new()
	room_style.bg_color = Color("202a43")
	room_style.border_color = Color("596480")
	room_style.set_border_width_all(2)
	room_style.set_corner_radius_all(26)
	room.add_theme_stylebox_override("panel", room_style)
	add_child(room)

	# Stylized original arched doorway and lantern.
	var door := Panel.new()
	door.position = Vector2(72, 68)
	door.size = Vector2(214, 388)
	var door_style := StyleBoxFlat.new()
	door_style.bg_color = Color("313b59")
	door_style.border_color = Color("7784a2")
	door_style.set_border_width_all(3)
	door_style.corner_radius_top_left = 105
	door_style.corner_radius_top_right = 105
	door_style.corner_radius_bottom_left = 16
	door_style.corner_radius_bottom_right = 16
	door.add_theme_stylebox_override("panel", door_style)
	room.add_child(door)

	var moon := Label.new()
	moon.text = "☾"
	moon.position = Vector2(136, 35)
	moon.add_theme_font_size_override("font_size", 50)
	moon.add_theme_color_override("font_color", GOLD)
	room.add_child(moon)

	door_label = Label.new()
	door_label.position = Vector2(52, 220)
	door_label.size = Vector2(260, 90)
	door_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	door_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	door_label.add_theme_font_size_override("font_size", 20)
	door_label.add_theme_color_override("font_color", CREAM)
	room.add_child(door_label)

	var panel := Panel.new()
	panel.position = Vector2(330, 42)
	panel.size = Vector2(806, 462)
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color("f7f1e5")
	card_style.set_corner_radius_all(22)
	panel.add_theme_stylebox_override("panel", card_style)
	room.add_child(panel)

	level_title = Label.new()
	level_title.name = "LevelTitle"
	level_title.position = Vector2(30, 18)
	level_title.size = Vector2(570, 42)
	level_title.add_theme_font_size_override("font_size", 26)
	level_title.add_theme_color_override("font_color", INK)
	panel.add_child(level_title)

	score_label = Label.new()
	score_label.position = Vector2(590, 22)
	score_label.size = Vector2(180, 36)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.add_theme_font_size_override("font_size", 18)
	score_label.add_theme_color_override("font_color", Color("8b6024"))
	panel.add_child(score_label)

	room_name = Label.new()
	room_name.name = "RoomName"
	room_name.position = Vector2(32, 67)
	room_name.size = Vector2(700, 30)
	room_name.add_theme_font_size_override("font_size", 15)
	room_name.add_theme_color_override("font_color", Color("64718a"))
	panel.add_child(room_name)

	prompt = Label.new()
	prompt.position = Vector2(32, 112)
	prompt.size = Vector2(740, 76)
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.add_theme_font_size_override("font_size", 19)
	prompt.add_theme_color_override("font_color", INK)
	panel.add_child(prompt)

	question_label = Label.new()
	question_label.name = "Question"
	question_label.position = Vector2(32, 200)
	question_label.size = Vector2(740, 34)
	question_label.add_theme_font_size_override("font_size", 18)
	question_label.add_theme_color_override("font_color", Color("80623b"))
	panel.add_child(question_label)

	for i in range(3):
		var button := Button.new()
		button.position = Vector2(32, 246 + i * 62)
		button.size = Vector2(742, 50)
		button.add_theme_font_size_override("font_size", 17)
		button.add_theme_color_override("font_color", INK)
		button.add_theme_color_override("font_hover_color", INK)
		button.add_theme_stylebox_override("normal", _button_style(Color("fffdf8"), Color("d9d3c8")))
		button.add_theme_stylebox_override("hover", _button_style(Color("f6e8c9"), GOLD))
		button.add_theme_stylebox_override("pressed", _button_style(Color("e5d6b7"), GOLD))
		button.pressed.connect(_choose.bind(i))
		panel.add_child(button)
		choices.append(button)

	status_label = Label.new()
	status_label.position = Vector2(32, 440)
	status_label.size = Vector2(740, 30)
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color("59745e"))
	panel.add_child(status_label)

	var progress_title := Label.new()
	progress_title.text = "夢的進步旅程"
	progress_title.position = Vector2(356, 515)
	progress_title.add_theme_font_size_override("font_size", 17)
	progress_title.add_theme_color_override("font_color", CREAM)
	room.add_child(progress_title)

	progress_label = Label.new()
	progress_label.position = Vector2(520, 515)
	progress_label.size = Vector2(590, 30)
	progress_label.add_theme_font_size_override("font_size", 16)
	progress_label.add_theme_color_override("font_color", Color("d7deee"))
	room.add_child(progress_label)

	for i in range(2):
		var tab := Button.new()
		tab.text = "關卡 %d　%s" % [i + 1, "✓" if keys[i] else "○"]
		tab.position = Vector2(348 + i * 184, 552)
		tab.size = Vector2(172, 38)
		tab.add_theme_font_size_override("font_size", 15)
		tab.pressed.connect(_show_level.bind(i))
		room.add_child(tab)
		level_tabs.append(tab)

func _button_style(color: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	return style

func _show_level(index: int) -> void:
	current_level = index
	var lesson: Dictionary = lessons[index]
	level_title.text = lesson["title"]
	room_name.text = "✦　%s" % lesson["room"]
	question_label.text = lesson["question"]
	prompt.text = lesson["intro"]
	status_label.text = "選一個你覺得最好的做法，解鎖這一關的鑰匙！" if not keys[index] else "鑰匙已取得！可以再次挑戰，練習得更熟。"
	status_label.add_theme_color_override("font_color", Color("59745e"))
	for i in range(3):
		choices[i].text = "　%s　%s" % [ ["A", "B", "C"][i], lesson["options"][i] ]
		choices[i].disabled = false
		choices[i].visible = true
	score_label.text = "得分　%d / 100" % score[index]
	if index == 0:
		door_label.text = "失物銀行\n%s" % ("🗝 已開啟" if keys[0] else "🔒 待解鎖")
	else:
		door_label.text = "星光花園\n%s" % ("🗝 已開啟" if keys[1] else "🔒 待解鎖")
	_update_progress()

func _choose(choice: int) -> void:
	var lesson: Dictionary = lessons[current_level]
	attempts[current_level] += 1
	if choice == int(lesson["answer"]):
		var points := 100 if attempts[current_level] == 1 else 80
		score[current_level] = maxi(score[current_level], points)
		keys[current_level] = true
		status_label.text = "✓ %s　+%d 分，取得星光鑰匙！" % [lesson["right"], points]
		status_label.add_theme_color_override("font_color", Color("3d795d"))
		for button in choices:
			button.disabled = true
			score_label.text = "得分　%d / 100" % score[current_level]
		if current_level == 0:
			door_label.text = "失物銀行\n🗝 已開啟"
		else:
			door_label.text = "星光花園\n🗝 已開啟"
	else:
		status_label.text = "○ %s" % lesson["wrong"]
		status_label.add_theme_color_override("font_color", Color("a44f56"))
	_update_progress()

func _update_progress() -> void:
	var total: int = score[0] + score[1]
	var stars := int(score[0] > 0) + int(score[1] > 0)
	progress_label.text = "鑰匙 %d / 2　✦　理財星星 %d / 2　✦　總分 %d / 200" % [int(keys[0]) + int(keys[1]), stars, total]
	for i in range(2):
		level_tabs[i].text = "關卡 %d　%s　%d分" % [i + 1, "🗝" if keys[i] else "○", score[i]]
	if keys[0] and keys[1]:
		progress_label.text = "完成！先存後花・分散風險　✦　總分 %d / 200" % total
