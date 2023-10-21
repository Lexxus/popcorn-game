extends RigidBody2D

const NORMAL_SPEED = 400
const FALLING_SPEED = 100
const MIN_ANGLE = deg_to_rad(-20)
const MAX_ANGLE = deg_to_rad(-160)
# the koefficient of ball deviation on reflection
const BALL_DEVIATION = 80
# angle range to consider as vertical or horizontal movement
const ANGLE_DEAD_ZONE = deg_to_rad(5)
const MAX_STUCK_CHECK = 2

@export var speed: int = NORMAL_SPEED

var is_speed_correction := false
var is_invert := false
var is_falling_down := false
var angle_delta: float = 0
var velocity_backup: Vector2
var collision_layer_backup: int = 0
var stuck_check_count: int = 0


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
		var angle = abs(linear_velocity.angle())
		if angle <= ANGLE_DEAD_ZONE or abs(PI - angle) <= ANGLE_DEAD_ZONE or abs(PI / 2 - angle) <= ANGLE_DEAD_ZONE:
			stuck_check_count += 1
			if stuck_check_count > MAX_STUCK_CHECK:
				linear_velocity =  linear_velocity.rotated((ANGLE_DEAD_ZONE if randf() > 0.5 else -ANGLE_DEAD_ZONE) * 2)
		else:
			stuck_check_count = 0
		linear_velocity = linear_velocity.normalized() * speed
	elif is_invert:
		linear_velocity = linear_velocity.rotated(PI)
		is_invert = false


func _process(delta):
	if is_falling_down:
		move_and_collide(Vector2.DOWN * FALLING_SPEED * delta)


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


func fall_down():
	set_deferred("freeze", true)
	collision_layer_backup = collision_layer
	collision_layer = 0b10000
	is_falling_down = true
	$Sprite2D.hide()
	$Parashute.show()
	$Parashute.play()


func catch():
	if is_falling_down:
		is_falling_down = false
		$Parashute.stop()
		$Parashute.hide()
		$Sprite2D.show()
		collision_layer = collision_layer_backup
		set_deferred("freeze", false)
