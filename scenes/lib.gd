extends Node

const PLAY_FIELD_WIDTH = 748.0
var PLAY_WIDTH_HEIGHT: int = ProjectSettings["display/window/size/viewport_height"]

enum Bonus {NONE, EXTEND, INIT, GLUE, SLOW, FIRE, FREEZE, SPLIT, WALL, LIFE}

static var list: Dictionary = {
	Bonus.NONE: 200,
	Bonus.EXTEND: 2,
	Bonus.INIT: 2,
	Bonus.GLUE: 2,
	Bonus.SLOW: 2,
	Bonus.FIRE: 1,
	Bonus.FREEZE: 2,
	Bonus.SPLIT: 1,
	Bonus.WALL: 1,
	Bonus.LIFE: 1,
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
