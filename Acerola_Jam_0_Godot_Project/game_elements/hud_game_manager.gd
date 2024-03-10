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

var game_state:int = 0




#Record of Spawn Sequences Completed.
var Spawn_Sequences_Completed:Array[StringName] = []

#This is intended to specify spawn sequence parameters, and multiple could be defined in a state machine
#however, the random sequence generation needs to be done in _ready
var Spawn_Sequence_A_Dict:Dictionary = {
		"SpawnerID": StringName("SpawnA"),
		"Spawn_Rate_Seconds_float": float(2.0),
		"Belt_Obj_Sequence_array": [],
		"Belt_Obj1_enum": On_Belt_Object.enum_belt_object_type.REFINED,
		"Belt_Obj2_enum": On_Belt_Object.enum_belt_object_type.DEFECT}
		
		
var Spawn_Sequence_A_WAVE2_Dict:Dictionary = {
		"SpawnerID": StringName("SpawnA"),
		"Spawn_Rate_Seconds_float": float(2.0),
		"Belt_Obj_Sequence_array": [],
		"Belt_Obj1_enum": On_Belt_Object.enum_belt_object_type.DEFECT,
		"Belt_Obj2_enum": On_Belt_Object.enum_belt_object_type.REFINED}


func _ready():	
	#Begin Droning Noise
	Audio_Droning.play()
	
	#Create Score tally functions for the despawner
	EventBus.create_event("Add_Refined_Score",_Add_Refined_Score.bind())
	EventBus.create_event("Add_Defect_Score",_Add_Refined_Score.bind())
	
	#Record Spawn Sequences that have completed to inform game state changes. 
	EventBus.create_event("Completed_Scripted_Spawn_Sequence",_Completed_Scripted_Spawn_Sequence.bind())
	
	
	#generate random sequence for Spawn_Sequence_A_Dict
	Spawn_Sequence_A_Dict["Belt_Obj_Sequence_array"] = generate_random_pattern_2_objs(7,3)
	
	
	
	

var time:float = 0.0
func _physics_process(delta):
	time += delta
	
	# I don't know if there's a better way to make a long scripted sequence for purely linear games?
	match game_state:
		0:
			if time > 0.2:
				game_state = 1
		1:
			print("WAVE1")
			EventBus.trigger_event("Start_Scripted_Spawn_Sequence", Spawn_Sequence_A_Dict)
			game_state = 2
		2: 
			if "SpawnA" in Spawn_Sequences_Completed:
				Spawn_Sequences_Completed = []
				time = 0.0
				game_state = 3
		3:
			if time > 10.0:
				print("WAVE2")
				Spawn_Sequence_A_WAVE2_Dict["Belt_Obj_Sequence_array"] = generate_random_pattern_2_objs(15,7)
				EventBus.trigger_event("Start_Scripted_Spawn_Sequence", Spawn_Sequence_A_WAVE2_Dict)
				game_state = 4
		4:
			if "SpawnA" in Spawn_Sequences_Completed:
				Spawn_Sequences_Completed = []
				print("ALL WAVES COMPLETED")
				game_state = 5
			






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
	if rare_quantity == 0:
		return obj_queue
	
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



#events from spawner to return it's complete state
func _Completed_Scripted_Spawn_Sequence(Completed_Spawner_Name:StringName):
	Spawn_Sequences_Completed.append(Completed_Spawner_Name)


#reminder:these are events from the Despawner; I need to manage them here next.
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
