extends Area2D

@export var speed := 600.0
@export var direction := Vector2.ZERO
var timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("bullets")
	# Get the timer node and configure it
	timer = get_node("Timer")
	if timer:
		timer.wait_time = 3.0  # Bullet disappears after 3 seconds
		timer.start()
	else:
		print("Error: Timer node not found in bullet scene")
	
	# Make bullet more visible with a bright color
	modulate = Color.YELLOW
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed * delta
	


func _on_body_entered(body) -> void:
	if body.is_in_group("turrets"):
		body.slow_down()
	if body.name == "player":
		body.take_damage(1)  # Call the player's die function
	if body.is_in_group("enemies"):
		body.take_damage()
	if body.name == "Enemy":  # Robot is named "Enemy" in the scene
		body.take_damage(1)  # Deal 10 damage to robot
	queue_free()
		


func _on_timer_timeout() -> void:
	queue_free()
