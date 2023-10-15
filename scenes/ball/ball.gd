extends RigidBody2D

const NORMAL_SPEED = 400
const MIN_ANGLE = deg_to_rad(-20)
const MAX_ANGLE = deg_to_rad(-160)
# the koefficient of ball deviation on reflection
const BALL_DEVIATION = 80

@export var speed: int = NORMAL_SPEED

var is_speed_correction := false
var is_invert := false
var angle_delta: float = 0
var velocity_backup: Vector2


func _integrate_forces(_state):
	if angle_delta != 0 and linear_velocity.angle() < 0:
		var new_angle := linear_velocity.angle() + angle_delta
		# preventing horizontal movement of the ball
		if new_angle > MIN_ANGLE:
			new_angle = MIN_ANGLE
		elif new_angle < MAX_ANGLE:
			new_angle = MAX_ANGLE
		# linear_velocity = Vector2(cos(angle_delta) * speed, sin(angle_delta) * speed)
		linear_velocity = Vector2.from_angle(new_angle) * speed
		angle_delta = 0
	elif is_speed_correction:
		is_speed_correction = false
		linear_velocity = linear_velocity.normalized() * speed
	elif is_invert:
		linear_velocity = linear_velocity.rotated(PI)
		is_invert = false


func start(angle: float, pos: Vector2 = Vector2.ZERO):
	set_deferred("freeze", false)
	set_physics_process(true)
	var new_angle = angle if pos == Vector2.ZERO else angle + ((position.x - pos.x) / BALL_DEVIATION)
	linear_velocity = Vector2.from_angle(new_angle) * speed


func stop():
	velocity_backup = linear_velocity
	linear_velocity = Vector2.ZERO
	set_physics_process(false)
	set_deferred("freeze", true)


func release():
	set_physics_process(true)
	linear_velocity = velocity_backup
	set_deferred("freeze", false)


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
	angle_delta = (position.x - pos.x) / BALL_DEVIATION


func invert():
	is_invert = true
