extends CharacterBody3D

signal hit

# How fast the player moves in m/s
@export var speed = 14
# The downward acceleration when in the air, in m/s^2
@export var fall_acceleration = 75
@export var jump_impulse = 20
@export var bounce_impulse = 16

var target_velocity = Vector3.ZERO

func _physics_process(delta):
	# input direction
	var direction = Vector3.ZERO
	
	# We check for each move input and update the direction accordingly
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_backward"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.look_at(position + direction, Vector3.UP)
		$AnimationPlayer.speed_scale = 4
	else:
		$AnimationPlayer.speed_scale = 1
	
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	
	# Jumping
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
	
	for collision_index in range(get_slide_collision_count()):
		var collision = get_slide_collision(collision_index)
		var collider = collision.get_collider()
		if (collider == null):
			printerr("why is collider null?")
			continue
		if (collider.is_in_group("mob")):
			var mob = collider
			# Check we're hitting it from above
			if Vector3.UP.dot(collision.get_normal()) > 0.5:
				mob.squash()
				target_velocity.y = bounce_impulse
	
	velocity = target_velocity
	move_and_slide()

	# jump animation
	$Pivot.rotation.x = PI / 6 * velocity.y / jump_impulse	

func die():
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(_body):
	die()
