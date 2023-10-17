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

var static_bricks_count: int = 0

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
	static_bricks_count = 0

	if not cfg.has_section(section):
		printerr("Section '$s' is not exists" % section)
		return

	var is_animation_set := false
	for row in 14:
		var line_num := String.num(row).pad_zeros(2)
		var line: StringName = cfg.get_value(section, "Line%s" % line_num, &"")
		if line == &"": continue
		for col in 12:
			var brick_type: int = line.substr(col, 1).hex_to_int()
			if brick_type == 0: continue
			var brick: StaticBody2D = brick_scene.instantiate()

			if brick_type == brick.BrickType.COVER:
				brick.position = Vector2(col * STEP_X + START_X - 2, row * STEP_Y + START_Y - 2)
				if not is_animation_set:
					is_animation_set = true
					%CoveredBody.position = brick.position + Vector2(STEP_X / 2.0, STEP_Y)
					%CoveredBody.show()
					%AnimationCovered.play()
			else:
				brick.position = Vector2(col * STEP_X + START_X, row * STEP_Y + START_Y)

			add_brick(brick, brick_type)
			if brick_type == brick.BrickType.STATIC:
				static_bricks_count += 1
