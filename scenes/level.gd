extends Node2D

signal score(value: int)
signal f_start(value: int)
signal level_up()
signal round_fail()
signal live_add()
signal live_remove()

const BALL_SLOW_SPEED = 300

var brick_scene = preload("res://scenes/brick/brick.tscn")
var bonus_scene = preload("res://scenes/bonus/bonus.tscn")
var brick_crash_scene = preload("res://scenes/brick/brick_crash.tscn")
var bullet_scene = preload("res://scenes/player/bullet.tscn")

var level: int = 1
var balls: int = 1
var is_ready_to_start := false

var handler_gate_finish := ""
var handler_timer_timeout := ""

@onready var balls_node = $Balls
@onready var player = $Player


func _ready():
	$Wall.hide_wall()


func _process(_delta):
	if Input.is_action_just_pressed("fire") and is_ready_to_start:
		is_ready_to_start = false
		var ball := balls_node.get_child(0) as RigidBody2D
		ball.reset_speed()
		ball.start(-PI / 2, player.position)


func start():
	balls = 1
	$Wall.show_wall()


func stop():
	var is_extra := false
	for ball in balls_node.get_children():
		ball.stop()
		if is_extra:
			ball.queue_free()
		else:
			is_extra = true
	move_ball_to_player()
	balls_node.hide()
	player.stop()
	player.hide()
	$Wall.toggle_bottom_wall(false)
	for node in $Enemies.get_children():
		node.queue_free()
	for node in $Bonuses.get_children():
		node.queue_free()


func next_level():
	level += 1
	level_up.emit()
	$Piston.start()


func apply_bonus(bonus: Lib.Bonus):
	match bonus:
		Lib.Bonus.EXTEND:
			player.set_extend_mode()
		Lib.Bonus.INIT:
			player.set_normal_mode()
			for ball in balls_node.get_children():
				ball.reset_speed()
		Lib.Bonus.FIRE:
			player.set_fire_mode()
		Lib.Bonus.STICK:
			player.set_stick_mode()
		Lib.Bonus.WALL:
			$Wall.toggle_bottom_wall(true)
			f_start.emit($Wall/Bottom/Timer.wait_time)
		Lib.Bonus.LIFE:
			live_add.emit()
		Lib.Bonus.SLOW:
			for ball in balls_node.get_children():
				ball.reset_speed(BALL_SLOW_SPEED)
		Lib.Bonus.SPLIT:
			var ball := balls_node.get_child(0) as RigidBody2D
			var b1 := ball.duplicate() as RigidBody2D
			var b2 := ball.duplicate() as RigidBody2D
			var dir = ball.linear_velocity.rotated(PI / 2).normalized()
			b1.translate(dir * 16)
			b2.translate(dir.rotated(PI) * 16)
			b1.linear_velocity = ball.linear_velocity.rotated(PI / 4)
			b2.linear_velocity = ball.linear_velocity.rotated(-PI / 4)
			balls_node.call_deferred("add_child", b1)
			balls_node.call_deferred("add_child", b2)


func remove_brick(body):
	$Bricks.remove_child(body)
	body.queue_free()
	if $Bricks.get_child_count() == 0:
		stop()
		$AudioSuccess.play()


func move_ball_to_player():
	var ball := balls_node.get_child(0) as RigidBody2D
	var pos = player.position
	pos.y -= 20
	ball.move_to(pos)


func round_init():
	$Gates/GateRight4.open()
	handler_gate_finish = "player_roll_in"


func player_roll_in(_body):
	live_remove.emit()
	player.show()
	player.roll_in($Gates/GateRight4.position)
	handler_timer_timeout = "close_gate"
	$Timer.start()


func close_gate():
	$Gates/GateRight4.close()


func _on_piston_top():
	balls_node.hide()
	$Levels.setup_bricks(level)
	$LevelPanel.show()
	$LevelPanel/Label.text = "LEVEL %s" % level


func _on_piston_bottom():
	round_init()


func _on_player_fire(body: CharacterBody2D):
	var bullet1 := bullet_scene.instantiate() as Area2D
	var bullet2 := bullet_scene.instantiate() as Area2D
	$Bonuses.add_child(bullet1)
	$Bonuses.add_child(bullet2)
	bullet1.connect("hit", _on_bullet_hit)
	bullet2.connect("hit", _on_bullet_hit)
	bullet1.start(Vector2(body.position.x - 38, body.position.y - 13))
	bullet2.start(Vector2(body.position.x + 38, body.position.y - 13))


func _on_bullet_hit(body):
	body.queue_free()


func _on_audio_success_finished():
	next_level()


func _on_gate_finish(body):
	if handler_gate_finish != "":
		callv(handler_gate_finish, [body])
		handler_gate_finish = ""


func _on_timer_timeout():
	if handler_timer_timeout != "":
		callv(handler_timer_timeout, [])
		handler_timer_timeout = ""


func _on_player_active():
	$LevelPanel.hide()
	move_ball_to_player()
	balls_node.show()
	is_ready_to_start = true


func _on_brick_hit(body: StaticBody2D):
	score.emit(body.score)


func _on_brick_crashed(body: StaticBody2D):
	var crash: Node2D = brick_crash_scene.instantiate()
	crash.connect("timeout", _on_brick_crash_timeout)
	crash.position = body.position
	$Enemies.add_child(crash)
	if body.score == 100:
		crash.extra_score()
	else:
		crash.crash(body.color)
	
	# generate bonus
	var bonus_type := Lib.generate_bonus_type()
	if bonus_type != Lib.Bonus.NONE:
		var bonus := bonus_scene.instantiate() as Area2D
		bonus.init(bonus_type, body.position)
		bonus.connect("catch", _on_player_catch_bonus)
		bonus.connect("out", _on_bonus_out)
		$Bonuses.add_child(bonus)
	remove_brick(body)


func _on_out_of_field_body_entered(body):
	if body.is_class("RigidBody2D"):
		if balls_node.get_child_count() == 1:
			$OutOfField/AudioOut.play()
			$Player.fall()
		else:
			body.stop()
			body.queue_free()


func _on_wall_ready():
	$Gates.show()
	for gate in $Gates.get_children():
		gate.grow()
	$Piston.start()


func _on_player_catch_bonus(body):
	apply_bonus(body.type)
	body.queue_free()


func _on_bonus_out(body):
	body.queue_free()


func _on_brick_crash_timeout(body):
	body.queue_free()


func _on_player_falled():
	stop()
	round_fail.emit()
