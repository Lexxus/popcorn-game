extends Node

const PLAY_FIELD_WIDTH = 748.0
var PLAY_WIDTH_HEIGHT: int = ProjectSettings["display/window/size/viewport_height"]

enum Bonus {NONE, EXTEND, INIT, STICK, SLOW, FIRE, FREEZE, SPLIT, NARROW, FAST, WALL, LIFE, POWER}

static var list: Dictionary = {
	Bonus.NONE: 70,
	Bonus.EXTEND: 2,
	Bonus.INIT: 2,
	Bonus.STICK: 0,
	Bonus.SLOW: 2,
	Bonus.FIRE: 2,
#	Bonus.FREEZE: 2,
	Bonus.SPLIT: 20,
#	Bonus.NARROW: 1,
	Bonus.FAST: 2,
	Bonus.WALL: 2,
	Bonus.LIFE: 0,
#	Bonus.POWER: 1
}

var total: int = list.values().reduce(func(acc, val): return acc + val, 0)


func generate_bonus_type() -> Bonus:
	var n: int = randi() % total
	var v: int = 0
	var result: Bonus = Bonus.NONE
	
	for i in list.keys():
		v += list[i]
		if n < v:
			result = i
			break;
	
	return result
