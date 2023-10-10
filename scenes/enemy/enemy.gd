extends StaticBody2D

signal die(body)

const SPEED = 40
const SPRITE_SIZE2 = 29
const MIN_X = 23 + SPRITE_SIZE2
const MAX_X = Lib.PLAY_FIELD_WIDTH - 20 - SPRITE_SIZE2
const MIN_Y = 16 + SPRITE_SIZE2
var MAX_Y = Lib.PLAY_WIDTH_HEIGHT

@onready var sprite: AnimatedSprite2D = $Sprite

var is_active := false
# position where to move
var target_pos := Vector2.ZERO

func start(start_direction: Vector2):
	var list := sprite.sprite_frames.get_animation_names()
	var i := randi_range(0, list.size() - 1)
	var animation := list[i]

	prints(name, "Enemy randi:", i, animation)

	if animation == &"fire":
		$CollisionShape.disabled = true
		$CollisionShapeSmall.disabled = false
		$Area2D/CollisionShape.disabled = true
		$Area2D/CollisionShapeSmall.disabled = false
	target_pos = start_direction * 60
	sprite.play(animation)
	is_active = true


func set_target(dir: Vector2):
	target_pos = position + (dir * randf_range(SPRITE_SIZE2 * 2, MAX_X / 2))


func update_target():
	var list := [Vector2.UP, Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT] as Array[Vector2]
	var is_dir_found := false

	while list.size() > 0 and not is_dir_found:
		var i = randi_range(0, list.size() - 1)
		var dir = list[i]
		list.remove_at(i)
		if is_direction_free(dir):
			set_target(dir)
			is_dir_found = true
	if not is_dir_found:
		target_pos = position


func punch(silent := false):
	is_active = false
	sprite.hide()
	$Explosion.show()
	$Explosion.play(&"default")
	if not silent:
		$AudioExplosion.play()


func _process(delta):
	if is_active:
		if position.distance_to(target_pos) <= 10.0:
			update_target()
		position += (target_pos - position).normalized() * SPEED * delta


func _on_body_entered(body):
	if not is_active: return
	prints(name, "collision:", body.name, position)
	if body.is_in_group(&"destructor"):
		punch()
	else:
		update_target()


func is_direction_free(dir: Vector2):
	var space_state := get_world_2d().direct_space_state
	var aim: Vector2 = global_position + (dir * 30)
	var query := PhysicsRayQueryParameters2D.create(global_position, aim, 0b100)

	return space_state.intersect_ray(query).is_empty()


func _on_explosion_finished():
	die.emit(self)
