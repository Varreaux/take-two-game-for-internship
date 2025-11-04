extends Area2D



func _on_body_entered(body) -> void:
	if body.name == "Enemy":
		print("Player reached the exit!")
		_trigger_win()

func _trigger_win():
	# Pause the game
	get_tree().paused = true
	
	# Create win screen
	_create_win_screen()
	
	# Restart game after 3 seconds
	await get_tree().create_timer(3.0).timeout
	_restart_game()

func _create_win_screen():
	# Create a CanvasLayer for the win screen
	var win_layer = CanvasLayer.new()
	win_layer.layer = 100  # Very high layer to be on top of everything
	get_tree().current_scene.add_child(win_layer)
	
	# Create a dark background
	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.8)  # Semi-transparent black
	background.size = get_viewport().size
	background.position = Vector2.ZERO
	win_layer.add_child(background)
	
	# Create win label
	var win_label = Label.new()
	win_label.text = "YOU WIN!"
	win_label.add_theme_font_size_override("font_size", 72)
	win_label.add_theme_color_override("font_color", Color.GREEN)
	win_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	win_label.add_theme_constant_override("shadow_offset_x", 4)
	win_label.add_theme_constant_override("shadow_offset_y", 4)
	win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	win_label.position = Vector2(0, 0)
	win_label.size = get_viewport().size
	win_layer.add_child(win_label)
	
	# Create restart countdown label
	var countdown_label = Label.new()
	countdown_label.text = "Restarting in 3 seconds..."
	countdown_label.add_theme_font_size_override("font_size", 24)
	countdown_label.add_theme_color_override("font_color", Color.WHITE)
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.position = Vector2(0, get_viewport().size.y - 100)
	countdown_label.size = Vector2(get_viewport().size.x, 50)
	win_layer.add_child(countdown_label)
	
	# Animate the win text
	var tween = create_tween()
	tween.parallel().tween_property(win_label, "scale", Vector2(1.2, 1.2), 0.5)
	tween.parallel().tween_property(win_label, "scale", Vector2(1.0, 1.0), 0.3)
	
	print("Win screen created")

func _restart_game():
	print("Restarting game...")
	# Unpause the game
	get_tree().paused = false
	# Reload the current scene
	get_tree().reload_current_scene()
