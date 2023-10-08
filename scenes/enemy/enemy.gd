extends StaticBody2D

const SPEED = 100
const SPRITE_SIZE2 = 29
const MIN_X = 23 + SPRITE_SIZE2
const MIN_Y = 16 + SPRITE_SIZE2

@onready var sprite: AnimatedSprite2D = $Sprite

var is_active := false
var is_dead := false
var direction := Vector2.ZERO

func start(name: StringName, pos: Vector2):
	if name == &"fire":
		$CollisionShape.disabled = true
		$CollisionShapeSmall.disabled = false
		$Area2D/CollisionShape.disabled = true
		$Area2D/CollisionShapeSmall.disabled = false
	global_position = pos
	update_direction()
	sprite.play(name)
	is_active = true


func update_direction():
	var x := randf_range(MIN_X, Lib.PLAY_FIELD_WIDTH - 20 - SPRITE_SIZE2)
	var y := randf_range(MIN_Y, Lib.PLAY_WIDTH_HEIGHT)
	direction = Vector2(x, y)


func _process(delta):
	if is_active:
		if global_position == direction:
			update_direction()
		global_position += direction.normalized() * SPEED * delta


func _on_body_entered(body):
	if body.is_in_group("destructor"):
		is_active = false
		is_dead = true
		sprite.play("explosion")
		$AudioExplosion.play()
	else:
		update_direction()


func _on_animation_finished():
	if is_dead:
		queue_free()
