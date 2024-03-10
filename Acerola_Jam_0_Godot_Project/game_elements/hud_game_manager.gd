extends Control

#This node should act as the hud and game manager.
#eventually I could have this handle 
# main menu -> game HUD 
# pause menu <-> game HUD
# GameComplete <- game HUD

@onready var ScoreLabel = $Score_Label
@onready var WinLabel = $Win_Label
@onready var Audio_Droning = $AudioStreamPlayer_Droning



var product_count:int = 0
var current_score:int = 0

func _ready():
	#Begin Droning Noise
	Audio_Droning.play()
	
	#Create Score tally functions for the despawner
	EventBus.create_event("Add_Refined_Score",_Add_Refined_Score.bind())
	EventBus.create_event("Add_Defect_Score",_Add_Refined_Score.bind())
	
	
	
func check_game_end():
	if product_count > 19:
		ScoreLabel.text = ("Score: %5d/170" % current_score)
		if current_score < 30:
			WinLabel.text = "You're Fired. Don't come back to Work"
		elif current_score > 30 and current_score < 150:
			WinLabel.text = "Good Job! That's a Decent Score"
		elif current_score > 150:
			WinLabel.text = "Congratulations! You've Beaten the Game!"



func update_score():
	ScoreLabel.text = ("Score: %5d" % current_score)

func _Add_Refined_Score(score:int):
	current_score += score
	product_count += 1
	self.update_score()
	self.check_game_end()

func _Add_Defect_Score(score:int):
	current_score += score
	product_count += 1
	self.update_score()
	self.check_game_end()
