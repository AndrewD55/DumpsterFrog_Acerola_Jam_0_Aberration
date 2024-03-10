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
	
	#generate random sequence
	generate_random_pattern_2_objs(7,3)
	
	
	
	
	#This is good enought for this game!!!
	#feels like a better distributed sequence
func generate_random_pattern_2_objs(common_quantity:int, rare_quantity:int):
	#generates a random array sequence of 0s and 1s,
	#representing an order to spawn object type 1 or 2
	var total_quantity:int = common_quantity + rare_quantity
	var obj_queue: Array[bool]
	obj_queue.resize(total_quantity)  #(range 0 to total_quantity-1)
	obj_queue.fill(true) #true means quantity 1
	
	#initial placement in sequence (at least 1 common apart)
	# could optimize or create a system for increasing spacing.. but not now
	while rare_quantity > 0:
		var insert_index:int = (int(total_quantity*randf())-1)
		#if index is not false, and it's left and right neighbor are NOT false
		#(or it's okay if either of them are past the limits of the array)
		if ((obj_queue[insert_index] != false) and (obj_queue[insert_index+1] !=false or insert_index == (total_quantity-1)) and (obj_queue[insert_index-1] !=false or insert_index == 0)): 
			obj_queue[insert_index] = false
			rare_quantity -= 1
	print(obj_queue)
	
	
	
	
	
	
	
	
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
