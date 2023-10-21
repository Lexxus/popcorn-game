extends CharacterBody2D

signal active
signal fire(body)
signal falled

enum Mode {NORMAL, INPROGRESS, EXTENDED, FIRE, GLUE}

const ROLLING_SPEED = 150.0
const SPEED = 500.0
const CENTER_X = Lib.PLAY_FIELD_WIDTH / 2.0

var fire_texture := preload("res://sprites/player/roket-fire.png") as Texture2D
var stick_texture := preload("res://sprites/player/roket-stick.png") as Texture2D
var init_texture: Texture2D

var is_active := false
var is_rolling_in := false
var mode := Mode.NORMAL
var deffered_set_mode := ""

var y: float
var glued_ball: RigidBody2D = null
var is_fire_allow := true


func _ready():
	init_texture = $Roket.texture
	y = position.y


func start():
	$Roket.show()
	$Animations.hide()
	$AnimatedFall.hide()
	is_active = true


func stop():
	is_active = false
	set_normal_mode()


func pause():
	is_active = false


func release():
	is_active = true


func fall():
	set_normal_mode(false, true)
	$AnimatedFall.show()
	$Animations.hide()
	$Roket.hide()
	$AnimatedFall.play()


func move_to_center():
	position.x = CENTER_X


func roll_in(pos: Vector2):
	$Roket.hide()
	position = pos
	$Animations.show()
	is_rolling_in = true
	$Animations.play("roll")


func open():
	$Animations.play("open")


func _process(delta):
	if is_rolling_in:
		position.x -= ROLLING_SPEED * delta
		if position.x <= CENTER_X:
			position.x = CENTER_X
			process_mode = Node.PROCESS_MODE_INHERIT
			is_rolling_in = false
			$Animations.stop()
			open()
		return
	
	if not is_active: return
	# move the rocket
	var direction: int = 0

	if Input.is_action_pressed("left"):
		direction = -1
	if Input.is_action_pressed("right"):
		direction += 1
	if Input.is_action_just_pressed("fire"):
		if mode == Mode.FIRE and is_fire_allow:
			is_fire_allow = false
			$Timer.start()
			fire.emit(self)
		if mode == Mode.GLUE:
			release_ball()
	
	if direction:
		velocity.x = direction * SPEED
		velocity.y = 0
		move_and_slide()
		if glued_ball:
			glued_ball.move_and_collide(Vector2(direction * SPEED * delta, 0))


func _physics_process(_delta):
	position.y = y


func _unhandled_input(event):
	if is_active and event is InputEventMouseMotion:
		var delta_x: float = event.relative.x
		if delta_x != 0:
			move_and_collide(Vector2(delta_x, 0))
			if glued_ball:
				glued_ball.move_and_collide(Vector2(delta_x, 0))


func release_ball():
	if glued_ball:
		glued_ball.start(-PI / 2, position)
		glued_ball = null


func set_normal_mode(skip_texture = false, skip_animation = false):
	if mode == Mode.NORMAL: return true
	release_ball()
	if mode == Mode.EXTENDED and not skip_animation:
		$Animations.play_backwards("expand")
		mode = Mode.INPROGRESS
		deffered_set_mode = "set_normal_mode"
		return false
	$Roket.show()
	$Animations.hide()
	if !skip_texture:
		$Roket.texture = init_texture
	if mode == Mode.EXTENDED or mode == Mode.INPROGRESS:
		$CollisionNormal.set_deferred("disabled", false)
		$CollisionWide.set_deferred("disabled", true)
		$Area2D/CollisionNormal.set_deferred("disabled", false)
		$Area2D/CollisionWide.set_deferred("disabled", true)
	mode = Mode.NORMAL
	return true


func set_extend_mode():
	if mode == Mode.EXTENDED: return
	if not set_normal_mode(true):
		deffered_set_mode = "set_extend_mode"
		return
	$Roket.hide()
	$Animations.show()
	$CollisionWide.set_deferred("disabled", false)
	$CollisionNormal.set_deferred("disabled", true)
	$Area2D/CollisionWide.set_deferred("disabled", false)
	$Area2D/CollisionNormal.set_deferred("disabled", true)
	$Animations.play("expand")
	mode = Mode.EXTENDED


func set_fire_mode():
	if mode == Mode.FIRE: return
	if not set_normal_mode(true):
		deffered_set_mode = "set_fire_mode"
		return
	$Roket.texture = fire_texture
	mode = Mode.FIRE


func set_stick_mode():
	if mode == Mode.GLUE: return
	if not set_normal_mode(true):
		deffered_set_mode = "set_stick_mode"
		return
	$Roket.texture = stick_texture
	mode = Mode.GLUE


func _on_area_2d_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	position.y = y
	if body.is_in_group("destructor"):
		body.catch()
		if mode == Mode.GLUE:
			$AudioGlue.play()
			release_ball()
			glued_ball = body
			body.stop()
		else:
			$AudioBall.play()
			body.correct_angle(position)


func _on_timer_timeout():
	is_fire_allow = true


func _on_animation_finished():
	match $Animations.get_animation():
		"open":
			start()
			active.emit()
		"expand":
			if deffered_set_mode != "":
				callv(deffered_set_mode, [])
				deffered_set_mode = ""


func _on_fall_animation_finished():
	falled.emit()
