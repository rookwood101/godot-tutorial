extends CharacterBody3D

@export var min_speed = 10
@export var max_speed = 18

signal squashed

# This function will be called from the Main scene
func initialize(start_position, player_position):
	look_at_from_position(start_position, player_position, Vector3.UP)
	rotate_y(randf_range(-PI/8, PI/8))
	
	var random_speed = randi_range(min_speed, max_speed)
	velocity = Vector3.FORWARD * random_speed
	velocity.rotated(Vector3.UP, rotation.y)

func _physics_process(delta):
	move_and_slide()


func _on_screen_exited():
	queue_free()

func squash():
	squashed.emit()
	queue_free()
