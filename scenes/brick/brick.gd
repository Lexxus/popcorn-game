extends StaticBody2D

enum BrickType {NONE, GEN1, GEN2, EXTRA1, EXTRA2, EXTRA3, EXTRA4, STATIC, ESCAPE, COVER, TELEPORT}

signal hit(brick: StaticBody2D, body: Node2D)
signal crashed(body)


const INACTIVE_DELAY_IN = 4.0
const INACTIVE_DELAY_OUT = 7.0

var extra1_texture: Texture2D = preload("res://sprites/bricks/brick-1.png")
var extra2_texture: Texture2D = preload("res://sprites/bricks/brick-2.png")
var extra3_texture: Texture2D = preload("res://sprites/bricks/brick-3.png")
var extra4_texture: Texture2D = preload("res://sprites/bricks/brick-4.png")
var escape_texture: Texture2D = preload("res://sprites/bricks/brick-escape.png")
var cover_texture: Texture2D = preload("res://sprites/bricks/brick-cover.png")
var gen_texture: Texture2D

var color: Color
var color1 := Color(1, 0, 1, 1)
var color2 := Color(0, 1, 1, 1)

var is_teleporting := false
var is_active := true
var teleporting_ball: CollisionObject2D

@export var type: BrickType = BrickType.GEN1
@export var score: int = 20
@export var hits: int = 1

@onready var sprite: Sprite2D = $Sprite2D


func init(brick_type: BrickType):
	sprite = $Sprite2D
	type = brick_type
	gen_texture = sprite.texture;
	match brick_type:
		BrickType.GEN1:
			sprite.self_modulate = color1
			color = color1
		BrickType.GEN2:
			sprite.self_modulate = color2
			color = color2
		BrickType.EXTRA1:
			sprite.texture = extra1_texture
			score = 100
		BrickType.EXTRA2:
			sprite.texture = extra2_texture
			score = 50
			hits = 2
		BrickType.EXTRA3:
			sprite.texture = extra3_texture
			score = 30
			hits = 3
		BrickType.EXTRA4:
			sprite.texture = extra4_texture
			hits = 4
		BrickType.STATIC:
			init_special_brick(&"ice")
		BrickType.ESCAPE:
			sprite.texture = escape_texture
		BrickType.COVER:
			sprite.texture = cover_texture
		BrickType.TELEPORT:
			init_special_brick(&"teleport")


func init_special_brick(key: StringName):
	sprite.hide()
	$Animations.show()
	$Animations.set_animation(key)
	hits = 0
	score = 0


func punch(body: Node2D):
	if type == BrickType.TELEPORT:
		# ignore if the TELEPORT brick has been hit by a bullet
		if not body.is_in_group(&"destructor") or not is_active:
			return
		body.stop()
		body.hide()
		wait_inactive(INACTIVE_DELAY_IN)
	hit.emit(self, body)
	if type == BrickType.STATIC:
		$AudioStatic.play()
	else:
		$AudioCrash.play()
	if type == BrickType.STATIC or type == BrickType.TELEPORT:
		$Animations.play()
		return
	hits -= 1
	match hits:
		1:
			sprite.texture = extra1_texture
			type = BrickType.EXTRA1
			score = 100
		2:
			sprite.texture = extra2_texture
			type = BrickType.EXTRA2
			score = 50
		3:
			sprite.texture = extra3_texture
			type = BrickType.EXTRA3
			score = 30


func is_teleport():
	return type == BrickType.TELEPORT


func teleport_in(ball: CollisionObject2D):
	if type == BrickType.TELEPORT:
		is_teleporting = true
		teleporting_ball = ball
		$Animations.play_backwards()
		wait_inactive(INACTIVE_DELAY_OUT)


func wait_inactive(timeout: float):
	is_active = false
	await get_tree().create_timer(timeout).timeout
	is_active = true


func _on_animation_finished():
	if is_teleporting:
		is_teleporting = false
		var dir := Lib.get_free_direction(self)
		var target = position + (dir * 36)
		teleporting_ball.move_to(target)
		teleporting_ball.show()
		teleporting_ball.release()


func _on_area_2d_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body.is_in_group(&"destructor"):
		punch(body)
		if type == BrickType.ESCAPE:
			body.fall_down()
		else:
			body.correct_speed()


func _on_audio_crash_finished():
	if hits <= 0 and type != BrickType.STATIC and type != BrickType.TELEPORT:
		crashed.emit(self)
