extends CharacterBody2D

signal die(body: CharacterBody2D)

const SPEED = 40
const SPRITE_SIZE2 = 29
const MIN_X = 23 + SPRITE_SIZE2
const MAX_X = Lib.PLAY_FIELD_WIDTH - 20 - SPRITE_SIZE2
const MIN_Y = 16 + SPRITE_SIZE2
var MAX_Y = Lib.PLAY_WIDTH_HEIGHT

const MIN_TIMEOUT = 2
const MAX_TIMEOUT = 10

@onready var sprite: AnimatedSprite2D = $Sprite

var is_active := false
var is_freezed := false
var direction := Vector2.ZERO
@onready var timer: Timer = $Timer
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
	# how long the enemy will be moving at one direction
	timer.start(randi_range(MIN_TIMEOUT, MAX_TIMEOUT))


func freeze(value: bool):
	is_freezed = value


func update_direction():
	var list := [Vector2.UP, Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT] as Array[Vector2]
	var is_dir_found := false

	if not timer.is_stopped():
		timer.stop()

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
	timer.start(randi_range(MIN_TIMEOUT, MAX_TIMEOUT))


func punch(silent := false):
	if not is_active: return
	if not timer.is_stopped(): timer.stop()
	is_active = false
	# remove from the collision layer to not collide while explosive animation is playing
	set_deferred("collision_layer", 0b0)
	sprite.hide()
	$Explosion.show()
	$Explosion.play(&"default")
	if not silent:
		$AudioExplosion.play()


func _process(delta):
	if is_active and not is_freezed:
		var collide := move_and_collide(direction * SPEED * delta)
		if collide:
			update_direction()


func _on_body_entered(body):
	if not is_active: return
	if body.is_in_group(&"destructor"):
		prints(enemy_type, "collision:", body.name, position)
		call_deferred("punch")


func is_direction_free(dir: Vector2):
	var space_state := get_world_2d().direct_space_state
	var aim: Vector2 = global_position + (dir * 40)
	var query := PhysicsRayQueryParameters2D.create(global_position, aim, 0b100)

	return space_state.intersect_ray(query).is_empty()


func _on_explosion_finished():
	die.emit(self)
