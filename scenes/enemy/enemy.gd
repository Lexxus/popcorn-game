extends CharacterBody2D

signal die(body: CharacterBody2D)

const SPEED = 40
const SPRITE_SIZE2 = 29
const MIN_X = 23 + SPRITE_SIZE2
const MAX_X = Lib.PLAY_FIELD_WIDTH - 20 - SPRITE_SIZE2
const MIN_Y = 16 + SPRITE_SIZE2
var MAX_Y = Lib.PLAY_WIDTH_HEIGHT

@onready var sprite: AnimatedSprite2D = $Sprite

var is_active := false
var is_freezed := false
var direction := Vector2.ZERO
var enemy_type: StringName

func start(start_direction: Vector2):
	var list := sprite.sprite_frames.get_animation_names()
	var i := randi_range(0, list.size() - 1)
	enemy_type = list[i]

	if enemy_type == &"fire":
		$CollisionShape.disabled = true
		$CollisionShapeSmall.disabled = false
		$Area2D/CollisionShape.disabled = true
		$Area2D/CollisionShapeSmall.disabled = false
	direction = start_direction
	sprite.play(enemy_type)
	is_active = true
	var timer := get_tree().create_timer(randf_range(2, 10))
	timer.connect("timeout", update_direction)


func freeze(value: bool):
	is_freezed = value


func update_direction():
	var list := [Vector2.UP, Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT] as Array[Vector2]
	var is_dir_found := false

	while list.size() > 0 and not is_dir_found:
		var i = randi_range(0, list.size() - 1)
		var dir = list[i]
		list.remove_at(i)
		if is_direction_free(dir):
			prints(enemy_type, "direction", dir, "is free")
			direction = dir
			is_dir_found = true
	if not is_dir_found:
		direction = Vector2.ZERO
		print("!!!Enemy direction is not found")


func punch(silent := false):
	if not is_active: return
	is_active = false
	$CollisionShape.disabled = true
	$CollisionShapeSmall.disabled = true
	sprite.hide()
	$Explosion.show()
	$Explosion.play(&"default")
	if not silent:
		$AudioExplosion.play()


func _process(_delta):
	if is_active and not is_freezed:
		velocity = direction * SPEED
		move_and_slide()


func _on_body_entered(body):
	if not is_active: return
	prints(enemy_type, "collision:", body.name, position)
	if body.is_in_group(&"destructor"):
		call_deferred("punch")
	else:
		update_direction()


func is_direction_free(dir: Vector2):
	var space_state := get_world_2d().direct_space_state
	var aim: Vector2 = global_position + (dir * 40)
	var query := PhysicsRayQueryParameters2D.create(global_position, aim, 0b100)

	return space_state.intersect_ray(query).is_empty()


func _on_explosion_finished():
	die.emit(self)
