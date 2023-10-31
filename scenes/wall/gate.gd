extends AnimatedSprite2D

enum DirectionEnum { Left, Right }

signal finish(body: AnimatedSprite2D)
signal enemy_die(enemy_type: StringName)

var enemy_scene := preload("res://scenes/enemy/enemy.tscn")

@export var direction: DirectionEnum = DirectionEnum.Left
var dir_vector: Vector2

# the distance to check the exit is free
var ray_distance: float = 57 + 15
var handle_animation_finished = &""
var has_enemy := false
var is_enemy_freezed := false
var is_anim_paused := false


func _ready():
	dir_vector = Vector2.LEFT if direction == DirectionEnum.Left else Vector2.RIGHT;
	Lib.connect(&"message", _on_message)


func open():
	play_backwards(&"open")


func close():
	play(&"open")


func grow():
	play(&"grow")


func open_enemy():
	play(&"open_enemy")


func close_enemy():
	play_backwards(&"open_enemy")


func freeze_enemy(value: bool):
	is_enemy_freezed = value
	if has_enemy:
		get_child(0).freeze(value)


func is_exit_blocked(source_shift: Vector2, ray: Vector2):
	var space_state := get_world_2d().direct_space_state
	var source: Vector2 = global_position + source_shift
	var target: Vector2 = source + ray
	var query := PhysicsRayQueryParameters2D.create(source, target, 0b100)
	return not space_state.intersect_ray(query).is_empty()


func create_enemy():
	if has_enemy or is_enemy_freezed: return
	var ray: Vector2 = dir_vector * ray_distance

	# check 3 parallel directions from the gate to cover all gate's height
	if is_exit_blocked(Vector2.ZERO, ray):
		return
	if is_exit_blocked(Vector2.UP * 24, ray):
		return
	if is_exit_blocked(Vector2.DOWN * 24, ray):
		return
	handle_animation_finished = &"_create_enemy"
	play(&"open_enemy")


func _create_enemy():
	var enemy := enemy_scene.instantiate() as CharacterBody2D
	add_child(enemy)
	enemy.position = dir_vector * 38
	has_enemy = true
	enemy.connect(&"die", _on_enemy_die)
	enemy.start(dir_vector)
	await get_tree().create_timer(1.0).timeout
	play_backwards(&"open_enemy")


func kill_enemy():
	stop()
	if has_enemy:
		get_child(0).queue_free()
		has_enemy = false
		is_enemy_freezed = false


func _on_enemy_die(body: CharacterBody2D):
	prints("Enemy dead:", body.enemy_type)
	has_enemy = false
	remove_child(body)
	body.queue_free()
	enemy_die.emit(body.enemy_type)


func _on_animation_finished():
	if animation == &"grow":
		set_animation(&"open_enemy")
		set_frame(0)
	if handle_animation_finished != "":
		callv(handle_animation_finished, [])
		handle_animation_finished = &""
	finish.emit(self)


func _on_message(msg: StringName, param):
	if msg == &"pause":
		if param:
			if is_playing():
				stop()
				is_anim_paused = true
		elif is_anim_paused:
			play()
			is_anim_paused = false
