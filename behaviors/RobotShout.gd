extends Node
class_name RobotShout

# Keep track of current label to remove old ones
static var current_label: Label = null

# Create floating text above the robot
static func shout(robot: Node2D, text: String, duration: float = 3.0):
	# Remove any existing label first
	if current_label and is_instance_valid(current_label):
		current_label.queue_free()
		current_label = null
	# Create text label directly
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 28)  # Even bigger font
	label.add_theme_color_override("font_color", Color.WHITE)  # White text
	label.add_theme_color_override("font_shadow_color", Color.BLACK)  # Black shadow
	label.add_theme_constant_override("shadow_offset_x", 3)
	label.add_theme_constant_override("shadow_offset_y", 3)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Position text above robot
	label.global_position = robot.global_position + Vector2(0, -120)
	robot.get_tree().current_scene.add_child(label)
	
	# Store reference to current label
	current_label = label
	
	# Animate the text with shout effect
	var tween = robot.create_tween()
	# Shout entrance - dramatic scale up and bounce
	tween.parallel().tween_property(label, "scale", Vector2(1.4, 1.4), 0.15)
	tween.parallel().tween_property(label, "global_position", label.global_position + Vector2(0, -15), 0.15)
	tween.parallel().tween_property(label, "scale", Vector2(0.9, 0.9), 0.1)
	tween.parallel().tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Add a dramatic shake effect to the text
	var shake_tween = robot.create_tween()
	var original_position = label.global_position
	
	# Check if label still exists before shake animation
	if not is_instance_valid(label) or not label:
		return
		
	for i in range(12):
		var shake_offset = Vector2(randf_range(-3, 3), randf_range(-2, 2))
		shake_tween.tween_property(label, "global_position", original_position + shake_offset, 0.04)
	shake_tween.tween_property(label, "global_position", original_position, 0.1)
	
	# Wait for duration, then fade out
	await robot.get_tree().create_timer(duration).timeout
	
	# Check if label still exists before animating
	if not is_instance_valid(label) or not label:
		return
	
	var fade_tween = robot.create_tween()
	var final_position = original_position + Vector2(0, -30)
	fade_tween.parallel().tween_property(label, "modulate", Color(1, 1, 1, 0), 1.0)
	fade_tween.parallel().tween_property(label, "global_position", final_position, 1.0)
	
	# Remove after fade and clear reference
	fade_tween.tween_callback(_cleanup_current_label)

# Helper function to clean up current label
static func _cleanup_current_label():
	if current_label and is_instance_valid(current_label):
		current_label.queue_free()
		current_label = null
