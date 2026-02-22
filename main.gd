# Music by <a href="https://pixabay.com/users/harumachimusic-13470593/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=170322">Noru</a> from <a href="https://pixabay.com/music//?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=170322">Pixabay</a>
extends Node

@export var seed_scene: PackedScene

var game_active = false
var current_highscore
var score
var round_length

const STARTING_ROUND_LENGTH = 30
const MAX_SEEDS_IN_SHOWER = 20
const RAINBOW_SEED_CHANCE = 0.1
const SAVE_PATH = "user://highscore.bin"

func _ready():
	current_highscore = load_highscore()
	$HUD.update_highscore_label(current_highscore)
	pass

func _on_pigeon_eat(seed) -> void:
	var is_rainbow = seed.is_rainbow
	var points = seed.eaten()
	#$EatSound.play()
	score += points
	print("Score: ", score)
	$HUD.update_score(score)
	if is_rainbow:
		seed_shower()
		$HUD.show_rainbow_seed_shower_label()
		$RainbowEatSound.play()
	else:
		$EatSound.play()

func game_over():
	game_active = false
	$Music.stop()
	$RoundTimer.stop()
	$SeedTimer.stop()
	$HUD.update_your_score_label(score)
	$HUD.show_game_over()
	$HUD.hide_rainbow_label()
	$Pigeon.hide()
	for child in get_children():
		if child is RigidBody2D:
			child.queue_free()
			
	current_highscore = load_highscore()
	if score > current_highscore:
		$HUD.update_highscore_label(score)
		save_highscore(score)
	
func new_game():
	game_active = true
	$Music.play()
	score = 0
	round_length = STARTING_ROUND_LENGTH
	$Pigeon.show()
	$Pigeon.start($StartPosition.position)
	$StartTimer.start()
	
	$HUD.update_round_length(round_length)
	$HUD.update_score(score)
	$HUD.show_message("Get Ready...")
	await get_tree().create_timer(1.0).timeout
	$HUD.show_message("Go!")
	
func _on_seed_timer_timeout() -> void:
	var seed_instance = seed_scene.instantiate()
	var screen_size = get_viewport().get_visible_rect().size
	
	# Target is random point on screen
	var target = Vector2(
		randf_range(50, screen_size.x - 50),
		randf_range(50, screen_size.y - 50)
	)
	
	# Start from a random screen edge
	var edge = randi() % 2
	var start = Vector2.ZERO
	match edge:
		#0: start = Vector2(randf_range(0, screen_size.x), -20)       # top
		#1: start = Vector2(randf_range(0, screen_size.x), screen_size.y + 20)  # bottom
		0: start = Vector2(-20, randf_range(0, screen_size.y))        # left
		1: start = Vector2(screen_size.x + 20, randf_range(0, screen_size.y))  # right
	
	add_child(seed_instance)
	seed_instance.setup(start, target)
	# 10% chance of rainbow seed
	if randf() < RAINBOW_SEED_CHANCE:
		seed_instance.set_rainbow()
	seed_instance.landed.connect(_on_seed_landed)

func _on_round_timer_timeout() -> void:
	round_length -= 1
	$HUD.update_round_length(round_length)
	if round_length <= 0:
		game_over()

func _on_start_timer_timeout():
	$SeedTimer.start()
	$RoundTimer.start()

func _on_seed_landed(seed):
	if $Pigeon.position.distance_to(seed.position) < 75:  # adjust radius as needed
		$Pigeon.eat.emit(seed)

func save_highscore(highscore: int) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_64(highscore)
	else:
		push_warning("Couldn't save highscore file: ", error_string(FileAccess.get_open_error()))

func load_highscore() -> int:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		return file.get_64()
	else:
		push_warning("Couldn't load highscore file: ", error_string(FileAccess.get_open_error()))
		return -1
		
func seed_shower():
	for i in range(MAX_SEEDS_IN_SHOWER):  # how many seeds in the shower
		await get_tree().create_timer(0.1).timeout  # delay between each seed
		if not game_active:  # stop spawning if game over
			return
		var seed_instance = seed_scene.instantiate()
		var screen_size = get_viewport().get_visible_rect().size
		
		var target = Vector2(
			randf_range(50, screen_size.x - 50),
			randf_range(50, screen_size.y - 50)
		)
		
		var edge = randi() % 2
		var start = Vector2.ZERO
		match edge:
			0: start = Vector2(-20, randf_range(0, screen_size.y))
			1: start = Vector2(screen_size.x + 20, randf_range(0, screen_size.y))
		
		add_child(seed_instance)
		seed_instance.setup(start, target)
		seed_instance.landed.connect(_on_seed_landed)
