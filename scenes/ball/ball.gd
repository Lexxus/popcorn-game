extends RigidBody2D

const NORMAL_SPEED = 400
const MIN_ANGLE = deg_to_rad(-20)
const MAX_ANGLE = deg_to_rad(-160)
# the koefficient of ball deviation on reflection
const BALL_DEVIATION = 80

@export var speed: int = NORMAL_SPEED

var is_speed_correction := false
var to_angle: float = 0


func _integrate_forces(_state):
	if to_angle != 0 and linear_velocity.y < 0:
		# preventing horizontal movement of the ball
		if to_angle > MIN_ANGLE:
			to_angle = MIN_ANGLE
		elif to_angle < MAX_ANGLE:
			to_angle = MAX_ANGLE
		linear_velocity = Vector2(cos(to_angle) * speed, sin(to_angle) * speed)
		to_angle = 0
	elif is_speed_correction:
		is_speed_correction = false
		linear_velocity = linear_velocity.normalized() * speed


func start(angle: float, pos: Vector2 = Vector2.ZERO):
	set_deferred("freeze", false)
	set_physics_process(true)
	var new_angle = angle if pos == Vector2.ZERO else angle + ((position.x - pos.x) / BALL_DEVIATION)
	linear_velocity = Vector2(speed * cos(new_angle), speed * sin(new_angle))


func stop():
	linear_velocity = Vector2.ZERO
	set_physics_process(false)
	set_deferred("freeze", true)


func move_to(pos: Vector2):
	var new_pos := pos - position
	var mask := collision_mask
	collision_mask = 0
	move_and_collide(new_pos)
	set_deferred("collision_mask", mask)


func reset_speed(new_speed = NORMAL_SPEED):
	speed = new_speed


func correct_speed():
	is_speed_correction = true


func correct_angle(pos: Vector2):
	to_angle = linear_velocity.angle() + ((position.x - pos.x) / BALL_DEVIATION)
