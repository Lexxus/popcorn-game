extends Node2D

const MIN_X = 28
const MIN_Y = 22
const BRICK_WIDTH2 = 27
const BRICK_HEIGHT2 = 13
const STEP_X = 58
const STEP_Y = 29

const START_X = MIN_X + BRICK_WIDTH2
const START_Y = MIN_Y + BRICK_HEIGHT2

var brick_scene = preload("res://scenes/brick/brick.tscn")

var cfg := ConfigFile.new()
var status := cfg.load("res://levels.cfg")

func add_brick(brick, brick_type):
	var root: Node2D = $".."
	brick.init(brick_type)
	brick.connect("hit", root._on_brick_hit)
	brick.connect("crashed", root._on_brick_crashed)
	%Bricks.add_child(brick)

func setup_bricks(level: int):
	if status != OK:
		printerr("File 'levels.cfg' is not found")
		return
	var section := "Level%s" % String.num(level).pad_zeros(2)

	if not cfg.has_section(section):
		printerr("Section '$s' is not exists" % section)
		return

	for row in 14:
		var line_num := String.num(row).pad_zeros(2)
		var line: StringName = cfg.get_value(section, "Line%s" % line_num, &"")
		if line == &"": continue
		for col in 12:
			var chr: int = line.substr(col, 1).to_int()
			if chr == 0: continue
			var brick: StaticBody2D = brick_scene.instantiate()
			brick.position = Vector2(col * STEP_X + START_X, row * STEP_Y + START_Y)
			add_brick(brick, chr)
