extends HBoxContainer

@onready var player_name_label: Label = $PlayerNameLabel
@onready var player_score_label: Label = $PlayerScoreLabel

var player_name: String = ""
var player_score: String = ""


func _ready(): 
	player_name_label.text = player_name
	player_score_label.text = player_score
