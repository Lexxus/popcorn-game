extends StaticBody2D

enum BrickType {GEN1, GEN2, EXTRA1, EXTRA2, EXTRA3, EXTRA4, STATIC}

signal hit(body)
signal crashed(body)

var extra1_texture: Texture2D = preload("res://sprites/bricks/brick-1.png")
var extra2_texture: Texture2D = preload("res://sprites/bricks/brick-2.png")
var extra3_texture: Texture2D = preload("res://sprites/bricks/brick-3.png")
var extra4_texture: Texture2D = preload("res://sprites/bricks/brick-4.png")
var gen_texture: Texture2D

var color: Color
var color1 := Color(1, 0, 1, 1)
var color2 := Color(0, 1, 1, 1)

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
			sprite.hide()
			$Animations.show()
			hits = 0
			score = 0


func punch(instant: bool = false):
	hit.emit(self)
	if type == BrickType.STATIC:
		$Animations.play("ice")
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
			
	if instant and hits <= 0:
		crashed.emit(self)


func _on_area_2d_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body.is_in_group(&"destructor"):
		if type == BrickType.STATIC:
			$AudioStatic.play()
		else:
			$AudioCrash.play()
		punch()


func _on_audio_crash_finished():
	if hits <= 0:
		crashed.emit(self)
