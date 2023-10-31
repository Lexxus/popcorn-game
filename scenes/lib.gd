extends Node

signal message(name: StringName, param)

const PLAY_FIELD_WIDTH = 748.0
var PLAY_WIDTH_HEIGHT: int = ProjectSettings["display/window/size/viewport_height"]

enum Bonus {NONE, EXTEND, IMPULSE, RESET, GLUE, SLOW, FIRE, FREEZE, SPLIT, WALL, LIFE, NEXT}

static var list: Dictionary = {
	Bonus.NONE: 200,
	Bonus.EXTEND: 4,
	Bonus.IMPULSE: 4,
	Bonus.RESET: 4,
	Bonus.GLUE: 4,
	Bonus.SLOW: 4,
	Bonus.FIRE: 2,
	Bonus.FREEZE: 3,
	Bonus.SPLIT: 2,
	Bonus.WALL: 3,
	Bonus.LIFE: 1,
	Bonus.NEXT: 1
}

var total: int = list.values().reduce(func(acc, val): return acc + val, 0)


func generate_bonus_type() -> Bonus:
	var n: int = randi_range(0, total)
	var v: int = 0
	var result: Bonus = Bonus.NONE
	
	for i in list.keys():
		v += list[i]
		if n < v:
			result = i
			break;
	
	return result


func is_direction_free(body: CanvasItem, direction: Vector2, distance: int):
	var space_state := body.get_world_2d().direct_space_state
	var aim: Vector2 = body.global_position + (direction * distance)
	var query := PhysicsRayQueryParameters2D.create(body.global_position, aim, 0b100)

	return space_state.intersect_ray(query).is_empty()


func get_free_direction(body: CanvasItem, distance: int = 40) -> Vector2:
	var dir_list := [Vector2.UP, Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT] as Array[Vector2]

	while dir_list.size() > 0:
		var i = randi_range(0, dir_list.size() - 1)
		var dir = dir_list[i]
		dir_list.remove_at(i)
		if is_direction_free(body, dir, distance):
			return dir
	printerr("!Direction is not found")
	return Vector2.ZERO


func sendMessage(msg: StringName, param):
	message.emit(msg, param)