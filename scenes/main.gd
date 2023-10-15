extends Node2D

const INITIAL_LIVES = 5

const LOGO_SPEED = 250
const BOARD_SPEED = 230
const BG_SPEED = 300
var score: int = 0
var logo_y: float = 0
var board_y: float = 0
var bg_x: float = 0

var f_progress: float = 0
var m_progress: float = 0
var is_game_paused := false

@onready var f_progress_bar = $Board/FProgressBar
@onready var m_progress_bar = $Board/MProgressBar
@onready var board = $Board
@onready var board_lives = $Board/Lives
@onready var logo = $Logo
@onready var bg = $LogoBg


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in INITIAL_LIVES:
		board_lives.add_live()
	logo_y = logo.position.y
	board_y = board.position.y
	bg_x = bg.position.x
	logo.position = Vector2(logo.position.x, -logo.position.y)
	board.position = Vector2(board.position.x, Lib.PLAY_WIDTH_HEIGHT)
	bg.position = Vector2(ProjectSettings["display/window/size/viewport_width"], bg.position.y)
	$Level.start()


func _process(delta):
	if Input.is_action_just_pressed("pause"):
		if $Level.pause(not is_game_paused):
			is_game_paused = not is_game_paused
			if is_game_paused:
				$Pause.show()
			else:
				$Pause.hide()

	if is_game_paused: return
	if bg_x > 0:
		bg.position.x -= BG_SPEED * delta
		if bg.position.x <= bg_x:
			bg.position.x = bg_x
			bg_x = 0
		return
	if logo_y > 0:
		logo.position += Vector2.DOWN * LOGO_SPEED * delta
		if logo.position.y >= logo_y:
			logo.position.y = logo_y
			logo_y = 0
	if board_y > 0:
		board.position.y -= BOARD_SPEED * delta
		if board.position.y <= board_y:
			board.position.y = board_y
			board_y = 0
	if f_progress > 0:
		f_progress -= delta
		if f_progress <= 0:
			f_progress_stop()
		else:
			f_progress_bar.value = f_progress
	if m_progress > 0:
		m_progress -= delta
		if m_progress <= 0:
			m_progress_stop()
		else:
			m_progress_bar.value = m_progress


func f_progress_stop():
	f_progress = 0
	f_progress_bar.hide()


func m_progress_stop():
	m_progress = 0
	m_progress_bar.hide()


func _on_level_score(value: int):
	score += value
	var score_str: String = String.num(score)
	$Board/ScoreLabel.text = score_str.lpad(6, '0')


func _on_level_f_start(value):
	if value > 0:
		f_progress_bar.max_value = value
		f_progress_bar.value = value
		f_progress_bar.show()
		f_progress = value


func _on_level_m_start(value: int):
	if value > 0:
		m_progress_bar.max_value = value
		m_progress_bar.value = value
		m_progress_bar.show()
		m_progress = value


func _on_level_up():
	f_progress_stop()
	m_progress_stop()
	board_lives.add_live()


func _on_level_round_fail():
	f_progress_stop()
	m_progress_stop()
	if board_lives.lives == 0:
		$GameOver.start()
	else:
		$Level.round_init()


func _on_live_add():
	board_lives.add_live()


func _on_live_remove():
	board_lives.remove_live()


func _on_play_button_pressed():
	if is_game_paused and $Level.pause(false):
		$Pause.hide()
		is_game_paused = false


func _on_quit_button_pressed():
	get_tree().quit()


func _on_level_reset():
	f_progress_stop()
	m_progress_stop()
