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

func add_brick(brick, brick_type):
	var root: Node2D = $".."
	brick.init(brick_type)
	brick.connect("hit", root._on_brick_hit)
	brick.connect("crashed", root._on_brick_crashed)
	%Bricks.add_child(brick)

func setup_bricks(level: int):
	match level:
		1:
			const start_y = 166 + BRICK_HEIGHT2
			
			for row in 8:
				for col in 12:
					var brick: StaticBody2D = brick_scene.instantiate()
					brick.position = Vector2(col * STEP_X + START_X, row * STEP_Y + start_y)
					if row == 2 or row == 3 or row > 5:
						add_brick(brick, brick.BrickType.GEN2)
					else:
						add_brick(brick, brick.BrickType.GEN1)
		2:
			const start_y = 108 + BRICK_HEIGHT2
			
			for row in 9:
				for col in 12:
					var brick: StaticBody2D = brick_scene.instantiate()
					brick.position = Vector2(col * STEP_X + START_X, row * STEP_Y + start_y)
					if col == 1 or col == 10 or ((col == 3 or col == 8) && row != 0 and row != 8):
						add_brick(brick, brick.BrickType.GEN1)
					elif (row == 1 or row == 7) and col > 2 and col < 9:
						add_brick(brick, brick.BrickType.GEN1)
					elif (col == 5 or col == 6) and row > 2 and row < 6:
						add_brick(brick, brick.BrickType.GEN1)
					else:
						add_brick(brick, brick.BrickType.GEN2)
		3:
			const start_y = 166 + BRICK_HEIGHT2
			
			for row in 5:
				for col in 12:
					var brick: StaticBody2D = brick_scene.instantiate()
					brick.position = Vector2(col * STEP_X + START_X, row * STEP_Y + start_y)
					if row == 1 or row == 3:
						add_brick(brick, brick.BrickType.EXTRA2)
					else:
						add_brick(brick, brick.BrickType.GEN1)
		4:
			for row in 12:
				if row == 9 or row == 10: continue
				for col in 12:
					if col > 2 and col < 9 and row > 2 and row < 8: continue
					var brick: StaticBody2D = brick_scene.instantiate()
					brick.position = Vector2(col * STEP_X + START_X, row * STEP_Y + START_Y)
					if row == 11 or (row == 8 and col > 1 and col < 10):
						add_brick(brick, brick.BrickType.EXTRA3)
					elif (col == 1 or col == 10) and row > 0:
						add_brick(brick, brick.BrickType.GEN2)
					elif row == 1 and col > 1 and col < 10:
						add_brick(brick, brick.BrickType.GEN2)
					else:
						add_brick(brick, brick.BrickType.GEN1)
		5:
			for row in 12:
				if row == 3 or row == 4: continue
				for col in 12:
					if (row == 8 and col > 2 and col < 9) or (row > 8 and col > 0 and col < 11): continue
					var brick: StaticBody2D = brick_scene.instantiate()
					brick.position = Vector2(col * STEP_X + START_X, row * STEP_Y + START_Y)
					if row > 4 and row < 8 and (col == 5 or col == 6):
						add_brick(brick, brick.BrickType.EXTRA1)
					elif row < 3 or row == 5 or row == 7:
						add_brick(brick, brick.BrickType.GEN1)
					elif row == 6:
						add_brick(brick, brick.BrickType.EXTRA4)
					elif row == 8 and (col == 2 or col == 9):
						add_brick(brick, brick.BrickType.STATIC)
					else:
						add_brick(brick, brick.BrickType.GEN2)
		_:
			prints("Level", level, "is not exists")
