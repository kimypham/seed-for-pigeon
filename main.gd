extends Node

@export var seed_scene: PackedScene
var score

func _ready():
	#new_game()
	pass

func _on_pigeon_eat(seed) -> void:
	seed.eaten()
	score += 1
	print("Score: ", score)
	$HUD.update_score(score)

func game_over():
	$ScoreTimer.stop()
	$SeedTimer.stop()
	$HUD.show_game_over()

func new_game():
	score = 0
	$Pigeon.start($StartPosition.position)
	$StartTimer.start()
	
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	
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
	seed_instance.landed.connect(_on_seed_landed)


func _on_score_timer_timeout() -> void:
	pass # Replace with function body.


func _on_start_timer_timeout():
	$SeedTimer.start()
	$ScoreTimer.start()

func _on_seed_landed(seed):
	var pigeon = $Pigeon
	if pigeon.position.distance_to(seed.position) < 75:  # adjust radius as needed
		pigeon.eat.emit(seed)
