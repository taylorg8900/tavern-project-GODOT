extends Node
@onready var score_label: Label = $"score label"

var score = 0

func add_point():
	score += 1
	score_label.text = "You collected " + str(score) + " gems."
