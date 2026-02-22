extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game

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
