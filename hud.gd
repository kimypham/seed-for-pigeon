extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game

const RAINBOW_SEED_BANNER_LENGTH = 5.0
const RAINBOW_SEED_BANNER_TEXT = "🌈 RAINBOW SEED SHOWER!!! 🌈"

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_game_over():
	show_message("Game Over")
	$YourScoreLabel.show()
	$HighscoreLabel.show()
	$ScoreLabel.hide()
	$RoundLengthLabel.hide()
	
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "Seed for pigeon"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	
func update_score(score):
	$ScoreLabel.text = "Score: " + str(score)

func update_your_score_label(score):
	$YourScoreLabel.text = "Your score was: " + str(score)
	
func update_highscore_label(score):
	$HighscoreLabel.text = "Highscore: " + str(score)

func update_round_length(round_length):
	$RoundLengthLabel.text = str(round_length)
	
func _on_start_button_pressed():
	$StartButton.hide()
	$YourScoreLabel.hide()
	$HighscoreLabel.hide()
	start_game.emit()
	$ScoreLabel.show()
	$RoundLengthLabel.show()

func _on_message_timer_timeout():
	$Message.hide()
	
func show_rainbow_seed_shower_label():
	var screen_width = get_viewport().get_visible_rect().size.x
	
	var label = Label.new()
	label.text = RAINBOW_SEED_BANNER_TEXT
	label.add_theme_font_size_override("font_size", 32)
	label.position = Vector2(screen_width, randf_range(80, 180))
	add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "position:x", -800, RAINBOW_SEED_BANNER_LENGTH)
	await tween.finished
	if is_instance_valid(label):  # only free if not already freed by hide_rainbow_label
		label.queue_free()

func hide_rainbow_label():
	for child in get_children():
		if child is Label and child.text == RAINBOW_SEED_BANNER_TEXT:
			child.queue_free()
