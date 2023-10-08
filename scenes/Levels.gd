extends Node2D

const MIN_X = 28
const MIN_Y = 22
const BRICK_WIDTH2 = 27
const BRICK_HEIGHT2 = 13
const STEP_X = 58
const STEP_Y = 29

var brick_scene = preload("res://scenes/brick/brick.tscn")

func add_brick(brick, brick_type):
	var root: Node2D = $".."
	brick.init(brick_type)
	brick.connect("hit", root._on_brick_hit)
	brick.connect("crashed", root._on_brick_crashed)
	$"../Bricks".add_child(brick)

func setup_bricks(level: int):
	match level:
		1:
			const START_X = MIN_X + BRICK_WIDTH2
			const START_Y = 166 + BRICK_HEIGHT2
			
			for row in 8:
				for col in 12:
					var brick: StaticBody2D = brick_scene.instantiate()
					brick.position = Vector2(col * STEP_X + START_X, row * STEP_Y + START_Y)
					if row == 2 or row == 3 or row > 5:
						add_brick(brick, brick.BrickType.GEN2)
					else:
						add_brick(brick, brick.BrickType.GEN1)
		2:
			const START_X = MIN_X + BRICK_WIDTH2
			const START_Y = 108 + BRICK_HEIGHT2
			
			for row in 9:
				for col in 12:
					var brick: StaticBody2D = brick_scene.instantiate()
					brick.position = Vector2(col * STEP_X + START_X, row * STEP_Y + START_Y)
					if col == 1 || col == 10 || ((col == 3 || col == 8) && row != 0 && row != 8):
						add_brick(brick, brick.BrickType.GEN1)
					elif (row == 1 || row == 7) && col > 2 && col < 9:
						add_brick(brick, brick.BrickType.GEN1)
					elif (col == 5 || col == 6) && row > 2 && row < 6:
						add_brick(brick, brick.BrickType.GEN1)
					else:
						add_brick(brick, brick.BrickType.GEN2)
		3:
			const START_X = MIN_X + BRICK_WIDTH2
			const START_Y = 166 + BRICK_HEIGHT2
			
			for row in 5:
				for col in 12:
					var brick: StaticBody2D = brick_scene.instantiate()
					brick.position = Vector2(col * STEP_X + START_X, row * STEP_Y + START_Y)
					if row == 1 || row == 3:
						add_brick(brick, brick.BrickType.EXTRA2)
					else:
						add_brick(brick, brick.BrickType.GEN1)
		4:
			const START_X = MIN_X + BRICK_WIDTH2
			const START_Y = 22 + BRICK_HEIGHT2
			
			for row in 12:
				if row == 9 || row == 10: continue
				for col in 12:
					if col > 2 && col < 9 && row > 2 && row < 8: continue
					var brick: StaticBody2D = brick_scene.instantiate()
					brick.position = Vector2(col * STEP_X + START_X, row * STEP_Y + START_Y)
					if row == 11 || (row == 8 && col > 1 && col < 10):
						add_brick(brick, brick.BrickType.EXTRA3)
					elif (col == 1 || col == 10) && row > 0:
						add_brick(brick, brick.BrickType.GEN2)
					elif row == 1 && col > 1 && col < 10:
						add_brick(brick, brick.BrickType.GEN2)
					else:
						add_brick(brick, brick.BrickType.GEN1)
		_:
			prints("Level", level, "is not exists")
