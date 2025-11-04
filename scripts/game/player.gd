extends CharacterBody2D

const SPEED = 200
const GRAVITY = 980

# @onready var hand = $hand  # Commented out - hand node doesn't exist
var can_attack = true

# Health system
var max_health = 100
var current_health = 100
var health_bar: ColorRect

var player_behaviors = []
var player_behaviors_menu_on = false
var repair_manager: RepairBehaviorManager
func _input(event):
	if event.is_action_pressed("open_power_menu"):
		player_behaviors_menu_on = true
		player_behaviors = get_player_behaviors()
		print("Available repair behaviors: ", player_behaviors.size())
		for behavior in player_behaviors:
			print("  - ", behavior.repair_name if behavior.has_method("get") else behavior.name)
		_show_behavior_menu(player_behaviors)
	
	# Test player damage with Down arrow key
	if event.is_action_pressed("ui_down"):
		print("=== MANUAL PLAYER DAMAGE TEST ===")
		take_damage(10)
	
	# Robot fixing is now only available through the repair panel

func get_player_behaviors():
	# Get ALL repair behaviors, not just applicable ones
	if repair_manager:
		return repair_manager.get_all_repairs()
	return []

func _ready():
	add_to_group("player")
	
	# Create repair behavior manager
	repair_manager = RepairBehaviorManager.new()
	repair_manager.repair_failed.connect(_on_repair_failed)
	add_child(repair_manager)
	
	# Create health bar after a short delay to avoid timing issues
	call_deferred("_create_health_bar")
	
func _physics_process(delta):
	velocity.y += GRAVITY * delta
	velocity.x = 0

	if Input.is_action_pressed("ui_left"):
		velocity.x -= SPEED
	if Input.is_action_pressed("ui_right"):
		velocity.x += SPEED

	move_and_slide()
	
	if Input.is_action_just_pressed("ui_up") and can_attack:
		velocity.y -= SPEED *2.5
		pass






	
	

@onready var behavior_menu = $BehaviorPanel
var current_enemy = null
var enemy_behaviors = []

var behavior_on = false

func _show_behavior_menu(behaviors):
	if behavior_on:
		behavior_menu.visible = false
		behavior_on = false
		return
	print("Showing behavior menu with ", behaviors.size(), " behaviors")
	behavior_menu.visible = true
	behavior_on = true
	#get_tree().paused = true
	
	var container = behavior_menu.get_node("VBoxContainer")
	#basically just clearing the box before showing powers
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
	
	for behavior in behaviors:
		var btn = Button.new()
		# Set button size
		btn.custom_minimum_size = Vector2(200, 35)
		
		# Use repair name if it's a repair behavior
		if behavior is BaseRepairBehavior:
			btn.text = behavior.repair_name
			btn.tooltip_text = behavior.repair_description
			
			# Visual feedback: disable button if repair can't be used
			if not behavior.can_repair():
				btn.disabled = true
				btn.text = behavior.repair_name + " (Not Available)"
				btn.modulate = Color(0.5, 0.5, 0.5)  # Gray out
		else:
			btn.text = behavior.name
		btn.process_mode = Node.PROCESS_MODE_ALWAYS
		btn.set_meta("behavior_node", behavior)
		btn.pressed.connect(_on_behavior_selected.bind(behavior))
		container.add_child(btn)
	
#	Adjust panel size based on number of behaviors
	var button_height = 40  # Height per button
	var button_width = 200  # Width for buttons
	var padding = 20  # Padding around the panel
	
	behavior_menu.custom_minimum_size.y = behaviors.size() * button_height + padding
	behavior_menu.custom_minimum_size.x = button_width + padding
	
	# Position the panel above the player
	var offset_y = -40 - (behaviors.size() * button_height + padding)
	behavior_menu.global_position = global_position + Vector2(40, offset_y)



func _on_behavior_selected(behavior):
	print("Button was pressed!")
	if player_behaviors_menu_on:
		# Use the repair behavior
		if repair_manager and behavior is BaseRepairBehavior:
			repair_manager.use_repair(behavior)
			print("Player used repair:", behavior.repair_name)
			
			# Close the behavior panel after using a repair
			_close_behavior_menu()
		else:
			player_behaviors_menu_on = false
	print("Player chose:", behavior.repair_name if behavior.has_method("get") else behavior.name)

func _close_behavior_menu():
	player_behaviors_menu_on = false
	behavior_menu.visible = false
	get_tree().paused = false

func _on_repair_failed():
	# Close the behavior menu when a wrong repair is used
	_close_behavior_menu()

# Robot fixing is now only available through the repair panel system

func _create_health_bar():
	print("Creating player health bar...")
	
	# Create a CanvasLayer for the health bar to ensure it's always visible
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 11  # Higher than robot's health bar
	get_tree().current_scene.add_child(canvas_layer)
	
	# Create a simple colored rectangle as health bar
	health_bar = ColorRect.new()
	health_bar.size = Vector2(200, 30)  # Same size as robot's
	health_bar.color = Color.GREEN  # Blue for player
	health_bar.position = Vector2(50, 100)  # Below robot's health bar
	
	# Add to canvas layer
	canvas_layer.add_child(health_bar)
	
	# Make it very visible
	health_bar.modulate = Color(1, 1, 1, 1)  # Full opacity
	health_bar.visible = true
	
	# Create a label to show health text
	var health_label = Label.new()
	health_label.text = "PLAYER HEALTH: " + str(current_health)
	health_label.add_theme_font_size_override("font_size", 24)
	health_label.add_theme_color_override("font_color", Color.WHITE)
	health_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	health_label.position = Vector2(50, 70)  # Above the health bar
	canvas_layer.add_child(health_label)
	
	print("Player health bar created at fixed position: ", health_bar.position)

func take_damage(damage: int):
	current_health -= damage
	current_health = max(0, current_health)  # Don't go below 0
	
	print("Player took ", damage, " damage! Health: ", current_health, "/", max_health)
	
	# Update health bar
	if health_bar:
		# Scale the health bar based on current health
		var health_percentage = float(current_health) / float(max_health)
		health_bar.size.x = 200 * health_percentage  # Scale from 200 to 0
		
		# Change color based on health
		if current_health <= 20:
			health_bar.color = Color.RED
		elif current_health <= 50:
			health_bar.color = Color.YELLOW
		else:
			health_bar.color = Color.GREEN
		
		# Health bar updated
	
	# Check if player is dead
	if current_health <= 0:
		_die()

func _die():
	print("Player has died!")
	
	# Pause the game
	get_tree().paused = true
	
	# Create game over screen
	_create_game_over_screen()
	
	# Restart game after 3 seconds
	await get_tree().create_timer(3.0).timeout
	_restart_game()

func _create_game_over_screen():
	# Create a CanvasLayer for the game over screen
	var game_over_layer = CanvasLayer.new()
	game_over_layer.layer = 100  # Very high layer to be on top of everything
	get_tree().current_scene.add_child(game_over_layer)
	
	# Create a dark background
	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.8)  # Semi-transparent black
	background.size = get_viewport().size
	background.position = Vector2.ZERO
	game_over_layer.add_child(background)
	
	# Create game over label
	var game_over_label = Label.new()
	game_over_label.text = "GAME OVER"
	game_over_label.add_theme_font_size_override("font_size", 72)
	game_over_label.add_theme_color_override("font_color", Color.RED)
	game_over_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	game_over_label.add_theme_constant_override("shadow_offset_x", 4)
	game_over_label.add_theme_constant_override("shadow_offset_y", 4)
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_over_label.position = Vector2(0, 0)
	game_over_label.size = get_viewport().size
	game_over_layer.add_child(game_over_label)
	
	# Create restart countdown label
	var countdown_label = Label.new()
	countdown_label.text = "Restarting in 3 seconds..."
	countdown_label.add_theme_font_size_override("font_size", 24)
	countdown_label.add_theme_color_override("font_color", Color.WHITE)
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.position = Vector2(0, get_viewport().size.y - 100)
	countdown_label.size = Vector2(get_viewport().size.x, 50)
	game_over_layer.add_child(countdown_label)
	
	# Animate the game over text
	var tween = create_tween()
	tween.parallel().tween_property(game_over_label, "scale", Vector2(1.2, 1.2), 0.5)
	tween.parallel().tween_property(game_over_label, "scale", Vector2(1.0, 1.0), 0.3)
	
	print("Game over screen created")

func _restart_game():
	print("Restarting game...")
	# Unpause the game
	get_tree().paused = false
	# Reload the current scene
	get_tree().reload_current_scene()
