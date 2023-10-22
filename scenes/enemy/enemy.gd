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
var proc_cycles_to_off: int = 10


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
	if value:
		sprite.pause()
	else:
		sprite.play()


func update_direction():
	if not timer.is_stopped():
		timer.stop()

	direction = Lib.get_free_direction(self)
	timer.start(randi_range(MIN_TIMEOUT, MAX_TIMEOUT))


func punch(_body: Node2D):
	if not is_active: return
	if not timer.is_stopped(): timer.stop()
	is_active = false
	sprite.hide()
	$Explosion.show()
	$Explosion.play(&"default")
	$AudioExplosion.play()


func _process(delta):
	if is_active and not is_freezed:
		var collide := move_and_collide(direction * SPEED * delta)
		if collide:
			update_direction()
	elif not is_active and proc_cycles_to_off > 0:
		proc_cycles_to_off -= 1
		if proc_cycles_to_off == 0:
			# remove from the collision layer to not collide while explosive animation is playing
			set_deferred("collision_layer", 0b0)


func _on_body_entered(body):
	if not is_active: return
	if body.is_in_group(&"destructor"):
		prints(enemy_type, "collision:", body.name, position)
		call_deferred("punch", body)


func _on_explosion_finished():
	die.emit(self)
