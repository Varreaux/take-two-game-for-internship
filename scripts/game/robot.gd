extends CharacterBody2D

const GRAVITY = 980.0
const NORMAL_SPEED = 15.0  # Normal walking speed

var malfunction_manager: RobotMalfunctionManager
var is_malfunctioning = false

# Health system
var max_health = 200
var current_health = 200
var health_bar: ColorRect

func _ready():
	randomize()
	
	# Create malfunction manager
	malfunction_manager = RobotMalfunctionManager.new()
	malfunction_manager.name = "RobotMalfunctionManager"  # Give it a proper name
	add_child(malfunction_manager)
	
	# Connect to malfunction signals
	malfunction_manager.malfunction_started.connect(_on_malfunction_started)
	malfunction_manager.malfunction_ended.connect(_on_malfunction_ended)
	
	# Create health bar after a short delay to avoid timing issues
	call_deferred("_create_health_bar")

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	
	# Only move forward if not malfunctioning
	if not is_malfunctioning:
		velocity.x = NORMAL_SPEED  # Normal forward movement
	else:
		# Let malfunction behaviors control movement
		pass

	# Store velocity before move_and_slide for pushing
	var velocity_before_move = velocity.x
	
	move_and_slide()
	
	# Handle player pushing when malfunctioning
	if is_malfunctioning:
		_handle_player_pushing(velocity_before_move)
	
	# Health bar is now at fixed position, no need to update

func _input(event):
	# Test damage with Space key
	if event.is_action_pressed("ui_down"):  # Space key
		print("=== MANUAL DAMAGE TEST ===")
		take_damage(10)

func _on_malfunction_started():
	is_malfunctioning = true

func _on_malfunction_ended():
	is_malfunctioning = false

# Function for player to manually fix robot
func fix_robot():
	if malfunction_manager:
		malfunction_manager.stop_current_malfunction()

func _create_health_bar():
	print("Creating health bar...")
	print("Robot position: ", global_position)
	print("Current health: ", current_health, "/", max_health)
	
	# Create a CanvasLayer for the health bar to ensure it's always visible
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10  # High layer to be on top
	get_tree().current_scene.add_child(canvas_layer)
	
	# Create a simple colored rectangle as health bar
	health_bar = ColorRect.new()
	health_bar.size = Vector2(200, 30)  # Bigger and more visible
	health_bar.color = Color.GREEN
	health_bar.position = Vector2(50, 50)  # Fixed position on screen
	
	# Add to canvas layer
	canvas_layer.add_child(health_bar)
	
	# Make it very visible
	health_bar.modulate = Color(1, 1, 1, 1)  # Full opacity
	health_bar.visible = true
	
	# Create a label to show health text
	var health_label = Label.new()
	health_label.text = "ROBOT HEALTH: "
	health_label.add_theme_font_size_override("font_size", 24)
	health_label.add_theme_color_override("font_color", Color.WHITE)
	health_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	health_label.position = Vector2(50, 20)  # Above the health bar
	canvas_layer.add_child(health_label)
	
	print("Health bar created at fixed position: ", health_bar.position)
	print("Health bar size: ", health_bar.size)
	print("Health bar parent: ", health_bar.get_parent())
	print("Health bar visible: ", health_bar.visible)
	print("Health bar color: ", health_bar.color)

func take_damage(damage: int):
	current_health -= damage
	current_health = max(0, current_health)  # Don't go below 0
	
	print("Robot took ", damage, " damage! Health: ", current_health, "/", max_health)
	
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
	
	# Check if robot is dead
	if current_health <= 0:
		_die()

func _die():
	print("Robot has died!")
	# Add death effect here (explosion, fade out, etc.)
	queue_free()

# Test function - call this to test health bar
func test_damage():
	print("=== TESTING DAMAGE SYSTEM ===")
	take_damage(20)
	print("Test damage applied! Health: ", current_health)
	
	# Also test if we can see the health bar
	if health_bar:
		print("Health bar value: ", health_bar.value)
		print("Health bar position: ", health_bar.global_position)
		print("Health bar visible: ", health_bar.visible)
	else:
		print("ERROR: Health bar is null!")

func _handle_player_pushing(velocity_before_move: float):
	# Check for collision with player after move_and_slide
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Use distance-based pushing
		var distance = global_position.distance_to(player.global_position)
		
		# Check if robot is facing the player (robot is to the right of player when going backward)
		var robot_to_player = player.global_position - global_position
		var is_facing_player = robot_to_player.x < 0  # Robot is to the right of player
		
		# Also check if robot is colliding with player directly
		var is_colliding_with_player = false
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider() == player:
				is_colliding_with_player = true
				break
		
		if (distance <= 30 and is_facing_player) or is_colliding_with_player:
			# Directly move the player instead of setting velocity
			var push_distance = velocity_before_move * 0.8 * get_physics_process_delta_time()
			player.global_position.x += push_distance
