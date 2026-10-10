extends Screen
## Title screen: poster-style logo and the four big choices.


func _ready() -> void:
	var bd := StageBackdrop.new()
	add_child(UI.full_rect(bd))
	var m := UI.margin(null, 72, 48, 72, 40)
	add_child(UI.full_rect(m))
	var root := UI.hbox(40)
	m.add_child(root)
	var left := UI.vbox(14)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(left)

	# Badger-soft presents...
	var brand := UI.hbox(12)
	var logo := TextureRect.new()
	logo.texture = BadgerLogo.texture()
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.custom_minimum_size = Vector2(44, 44)
	brand.add_child(logo)
	var bv := UI.vbox(-4)
	bv.add_child(UI.label("BADGER-SOFT", "CapsBig", UITheme.TEXT))
	bv.add_child(UI.label("PRESENTS", "Caps", UITheme.MUTED))
	brand.add_child(bv)
	left.add_child(brand)

	# The logo lock-up: BAND MANAGER + a red "27" stamp.
	var title_row := UI.hbox(18)
	var tv := UI.vbox(-34)
	var t1 := UI.label("BAND", "H1")
	t1.add_theme_font_size_override("font_size", 132)
	var t2 := UI.label("MANAGER", "H1")
	t2.add_theme_font_size_override("font_size", 132)
	tv.add_child(t1)
	tv.add_child(t2)
	title_row.add_child(tv)
	var stamp := PanelContainer.new()
	stamp.add_theme_stylebox_override("panel", UITheme.box(UITheme.ACCENT, 14, Color(0, 0, 0, 0), 0, 18, 0))
	var n27 := UI.label("27", "H1", Color("#140808"))
	n27.add_theme_font_size_override("font_size", 150)
	stamp.add_child(n27)
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(170, 190)
	holder.size_flags_vertical = Control.SIZE_SHRINK_END
	holder.add_child(stamp)
	stamp.position = Vector2(6, 4)
	stamp.rotation_degrees = -6.0
	stamp.pivot_offset = Vector2(80, 90)
	title_row.add_child(holder)
	left.add_child(title_row)
	left.add_child(UI.label("From Nan's garden shed to Wombley Stadium. Manage the band. Survive the egos. Get famous.", "BodyMuted", null, true))

	# Buttons.
	var right := UI.vbox(12)
	right.custom_minimum_size.x = 380
	right.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(right)
	var go_btn := UI.button("LET'S GET FAMOUS", "play", "Primary", _new_game)
	go_btn.add_theme_font_size_override("font_size", 40)
	go_btn.custom_minimum_size.y = 76
	right.add_child(go_btn)
	if Game.has_save():
		var cont := UI.button("CONTINUE", "refresh", "Menu", _continue)
		cont.tooltip_text = "Carry on where you left off"
		right.add_child(cont)
	right.add_child(UI.button("INFORMATION", "info", "Menu", func(): go("info")))
	right.add_child(UI.button("SETTINGS", "sliders", "Menu", func(): go("settings")))
	right.add_child(UI.button("HALL OF FAME", "trophy", "Menu", func(): go("hall")))
	if not OS.has_feature("mobile") and not OS.has_feature("web"):
		right.add_child(UI.button("QUIT", "exit", "Menu", func(): get_tree().quit()))
	for b in right.get_children():
		if b is Button:
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	go_btn.alignment = HORIZONTAL_ALIGNMENT_CENTER

	var foot := UI.label("v%s  ·  © Badger-soft  ·  No badgers were harmed in the making of this game." % ProjectSettings.get_setting("application/config/version", "1.0"), "Small", UITheme.DIM)
	foot.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	foot.offset_left = 72
	foot.offset_top = -34
	add_child(foot)


func _new_game() -> void:
	if Game.has_save():
		main.confirm("Start a new career?", "You have a band in progress. Starting again will [b]overwrite[/b] your saved game.", "START AGAIN", func():
			Game.delete_save()
			Game.new_game()
			go("managers"))
		return
	Game.new_game()
	go("managers")


func _continue() -> void:
	if Game.load_game():
		go("hq")
	else:
		main.show_toast("That save couldn't be loaded.", "bad")


func on_back() -> void:
	pass
