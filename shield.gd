extends Area2D

func _ready():
	# Connect to both body_entered and area_entered signals to detect bullets
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	print("Shield ready! Collision layer: ", collision_layer, " Collision mask: ", collision_mask)

func _on_body_entered(body: Area2D):
	print("Shield detected body: ", body.name, " Groups: ", body.get_groups())
	# Check if the body is a bullet
	if body.is_in_group("bullets"):
		print("Shield blocked bullet!")
		# Destroy the bullet
		body.queue_free()
		# Get collision position
		var collision_pos = body.global_position
		# Show spark effect at collision point
		_show_block_effect(collision_pos)
	else:
		print("Shield detected non-bullet: ", body.name)

func _on_area_entered(area: Area2D):
	print("Shield detected area: ", area.name, " Groups: ", area.get_groups())
	# Check if the area is a bullet
	if area.is_in_group("bullets"):
		print("Shield blocked bullet (area)!")
		# Get collision position
		var collision_pos = area.global_position
		# Destroy the bullet
		area.queue_free()
		# Show spark effect at collision point
		_show_block_effect(collision_pos)
	else:
		print("Shield detected non-bullet area: ", area.name)

func _show_block_effect(collision_position: Vector2):
	# Create a spark effect at the collision point
	var spark = Label.new()
	spark.text = "★"
	spark.add_theme_font_size_override("font_size", 4)
	spark.add_theme_color_override("font_color", Color.YELLOW)
	spark.add_theme_color_override("font_shadow_color", Color.ORANGE)
	spark.add_theme_constant_override("shadow_offset_x", 1)
	spark.add_theme_constant_override("shadow_offset_y", 1)
	# Position spark at collision point with small random offset
	spark.global_position = collision_position + Vector2(randf_range(-5, 5), randf_range(-5, 5))
	get_tree().current_scene.add_child(spark)
	
	print("Spark effect created at collision point: ", spark.global_position)
	
	# Animate the spark
	var tween = create_tween()
	tween.parallel().tween_property(spark, "scale", Vector2(2, 2), 0.1)
	tween.parallel().tween_property(spark, "modulate", Color(1, 1, 1, 0), 0.4)
	tween.parallel().tween_property(spark, "global_position", spark.global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20)), 0.4)
	tween.tween_callback(spark.queue_free)
