extends Node
class_name RepairFeedback

# Create floating text above a target node
static func show_feedback(target: Node2D, text: String, duration: float = 2.0):
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color.RED)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	
	# Position above the target
	label.global_position = target.global_position + Vector2(-50, -50)
	
	# Add to scene
	target.get_tree().current_scene.add_child(label)
	
	# Animate the text
	var tween = target.create_tween()
	tween.parallel().tween_property(label, "global_position", label.global_position + Vector2(0, -30), duration)
	tween.parallel().tween_property(label, "modulate", Color(1, 1, 1, 0), duration)
	
	# Remove after animation
	tween.tween_callback(label.queue_free)