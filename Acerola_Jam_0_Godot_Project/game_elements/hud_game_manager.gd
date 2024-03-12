extends Control

#This node should act as the hud and game manager.
@onready var Audio_Droning = $AudioStreamPlayer_Droning
@onready var Character_Dialog_Pane = $Character_Dialog_Pane

var product_count:int = 0
var current_score:int = 0

var game_state:int = 0


#Record of Spawn Sequences Completed.
var Spawn_Sequences_Completed:Array[StringName] = []

#So.. I guess I'm going to give this dict all the necessary keys.
# in the future I could use a bunch of .has functions to search for things that don't exist yet.
var Despawned_Items_Record:Dictionary = {
	"GoodDepot" :   {"REFINED" : 0 , "DEFECT" : 0 },
	"Incinerator" : {"REFINED" : 0 , "DEFECT" : 0 }}

#This is intended to specify spawn sequence parameters, and multiple could be defined in a state machine
#however, the random sequence generation needs to be done in _ready


var Sequence_Tutorial:Array[bool] = [false,true]
var Spawn_Sequence_Tutorial:Dictionary = {
		"SpawnerID": StringName("SpawnB"),
		"Spawn_Rate_Seconds_float": float(2.5),
		"Belt_Obj_Sequence_array": Sequence_Tutorial,
		"Belt_Obj1_enum": On_Belt_Object.enum_belt_object_type.REFINED,
		"Belt_Obj2_enum": On_Belt_Object.enum_belt_object_type.DEFECT}


 #Game Wave 1 ((24 total)  21 normal donuts, 3 bad donuts) 
			# Start BURN path by burning more than 10 normal donuts. 
			# Start NORMAL path by missing any number of donuts.
			# Start PERFECT path by sorting all donuts perfectly.
var Spawn_Sequence_A_WAVE1:Dictionary = {
		"SpawnerID": StringName("SpawnA"),
		"Spawn_Rate_Seconds_float": float(2.5),
		"Belt_Obj_Sequence_array": [],
		"Belt_Obj1_enum": On_Belt_Object.enum_belt_object_type.REFINED,
		"Belt_Obj2_enum": On_Belt_Object.enum_belt_object_type.DEFECT}
		
var Spawn_Sequence_B_WAVE1:Dictionary = {
		"SpawnerID": StringName("SpawnB"),
		"Spawn_Rate_Seconds_float": float(2.5),
		"Belt_Obj_Sequence_array": [],
		"Belt_Obj1_enum": On_Belt_Object.enum_belt_object_type.REFINED,
		"Belt_Obj2_enum": On_Belt_Object.enum_belt_object_type.DEFECT}


 #Game Wave 2 (36 total, 20 bad donuts, 16 good donuts)
			# Continue BURN path by burning more than 26 normal donuts. 
			# Continue/Start NORMAL path by missing any number of donuts.
			# Continue PERFECT path by sorting all donuts perfectly.
var Spawn_Sequence_A_WAVE2:Dictionary = {
		"SpawnerID": StringName("SpawnA"),
		"Spawn_Rate_Seconds_float": float(1.8),
		"Belt_Obj_Sequence_array": [],
		"Belt_Obj1_enum": On_Belt_Object.enum_belt_object_type.DEFECT,
		"Belt_Obj2_enum": On_Belt_Object.enum_belt_object_type.REFINED}
		
var Spawn_Sequence_B_WAVE2:Dictionary = {
		"SpawnerID": StringName("SpawnB"),
		"Spawn_Rate_Seconds_float": float(1.8),
		"Belt_Obj_Sequence_array": [],
		"Belt_Obj1_enum": On_Belt_Object.enum_belt_object_type.DEFECT,
		"Belt_Obj2_enum": On_Belt_Object.enum_belt_object_type.REFINED}


 #Game Wave 3 (36 total, 20 cats, 16 dogs)
			#	FAIL BURN path by sparing EVEN A SINGLE ANIMAL
			#  Continue Normal path 
			#	FAIL PERFECT path by BURINING EVEN A SINGLE ANIMAL
var Spawn_Sequence_A_WAVE3:Dictionary = {
		"SpawnerID": StringName("SpawnA"),
		"Spawn_Rate_Seconds_float": float(1.5),
		"Belt_Obj_Sequence_array": [],
		"Belt_Obj1_enum": On_Belt_Object.enum_belt_object_type.REFINED,
		"Belt_Obj2_enum": On_Belt_Object.enum_belt_object_type.DEFECT}
		
var Spawn_Sequence_B_WAVE3:Dictionary = {
		"SpawnerID": StringName("SpawnB"),
		"Spawn_Rate_Seconds_float": float(1.5),
		"Belt_Obj_Sequence_array": [],
		"Belt_Obj1_enum": On_Belt_Object.enum_belt_object_type.REFINED,
		"Belt_Obj2_enum": On_Belt_Object.enum_belt_object_type.DEFECT}



func _ready():	
	#Begin Droning Noise
	Audio_Droning.play()
	
	#Create Score tally functions for the despawner
	EventBus.create_event("Despawned_Item",_Despawned_Item.bind())
	
	#Record Spawn Sequences that have completed to inform game state changes. 
	EventBus.create_event("Completed_Scripted_Spawn_Sequence",_Completed_Scripted_Spawn_Sequence.bind())
	

# player_path=3 perfect run
# player_path=2 nomral run
# player_path=1 burn run
enum enum_player_path {UNDEF, BURN, NORMAL, PERFECT}
var player_path:enum_player_path = enum_player_path.UNDEF


var time:float = 0.0

var state_timer:float = 0.0
var state_timer_reset:bool = false

#Dialog Timer Counts Down, To eaily facilitate new delays.
var dialog_timer:float = 0.0
var dialog_state:int = 0
var dialog_timer_waiting:bool = false


func _physics_process(delta):
	#Total timer
	time += delta
	#State timer  (Reset every state change)
	state_timer += delta
	#dialog state timer  (Reset every dialog change)
	dialog_timer += delta
	
	
	# I don't know if there's a better way to make a long scripted sequence for purely linear games?
	match game_state:
		0: #Game Tutorial Sequence
			
			if state_timer_reset == false:
				state_timer = 0.0
				state_timer_reset = true
				
				dialog_timer = 0.0
				dialog_state = 0
				dialog_timer_waiting = false

			match dialog_state:
				0: #Sequential State
					if dialog_timer > 0.1 and dialog_timer_waiting == false:
						Character_Dialog_Pane.display_text_sequential("Ahh, Hello there, you must be our new employee.",0.05)
						dialog_timer_waiting = true
					if dialog_timer > 5.0 and dialog_timer_waiting == true:
						dialog_timer_waiting = false
						dialog_timer = 0.0
						dialog_state += 1
				1:  #Sequential State
					if dialog_timer > 0.1 and dialog_timer_waiting == false:
						Character_Dialog_Pane.display_text_sequential("Your job is to sort out good donuts from bad donuts",0.05)
						dialog_timer_waiting = true
					if dialog_timer > 5.0 and dialog_timer_waiting == true:
						dialog_timer_waiting = false
						dialog_timer = 0.0
						dialog_state += 1
				2:  #Sequential State
					if dialog_timer > 0.1 and dialog_timer_waiting == false:
						Character_Dialog_Pane.display_text_sequential("To rotate the yellow belt use R+Click to rotate the belt Clockwise and L+Click to rotate the belt CounterClockwise",0.05)
						dialog_timer_waiting = true
					if dialog_timer > 8.0 and dialog_timer_waiting == true:
						dialog_timer_waiting = false
						dialog_timer = 0.0
						dialog_state += 1
				3:  #Sequential State
					if dialog_timer > 0.1 and dialog_timer_waiting == false:
						Character_Dialog_Pane.display_text_sequential("Here, I'll ask the cooks to send you one good donut and one bad moldy donut as an example,",0.05)
						EventBus.trigger_event("Start_Scripted_Spawn_Sequence", Spawn_Sequence_Tutorial)
						dialog_timer_waiting = true
					if (Despawned_Items_Record["GoodDepot"]["REFINED"] == 1) and (Despawned_Items_Record["Incinerator"]["DEFECT"] == 1) and (dialog_timer_waiting == true) and ("SpawnB" in Spawn_Sequences_Completed):
						self.reset_despawned_items_counts()
						Spawn_Sequences_Completed = []
						dialog_timer_waiting = false
						dialog_timer = 0.0
						dialog_state = 5
					elif (Despawned_Items_Record["GoodDepot"]["DEFECT"] > 0) or (Despawned_Items_Record["Incinerator"]["REFINED"] > 0) and self.total_despawned_items() == 2  and (dialog_timer_waiting == true) and ("SpawnB" in Spawn_Sequences_Completed):
						self.reset_despawned_items_counts()
						Spawn_Sequences_Completed = []
						dialog_timer_waiting = false
						dialog_timer = 0.0
						dialog_state = 4
					
				4:  #Tutorial Fail State
					if dialog_timer > 0.1 and dialog_timer_waiting == false:
						Character_Dialog_Pane.display_text_sequential("Uhh, let's try that again... put the moldy donut in the incinerator and the good donut in the packaging area,",0.05)
						##Reload the Sequence Array, as it is popped during a spawn sequence
						#Spawn_Sequence_Tutorial["Belt_Obj_Sequence_array"] = Sequence_Tutorial
						EventBus.trigger_event("Start_Scripted_Spawn_Sequence", Spawn_Sequence_Tutorial)
						dialog_timer_waiting = true
					if (Despawned_Items_Record["GoodDepot"]["REFINED"] == 1) and (Despawned_Items_Record["Incinerator"]["DEFECT"] == 1) and (dialog_timer_waiting == true) and ("SpawnB" in Spawn_Sequences_Completed):
						self.reset_despawned_items_counts()
						Spawn_Sequences_Completed = []
						dialog_timer_waiting = false
						dialog_timer = 0.0
						dialog_state = 5
					elif (Despawned_Items_Record["GoodDepot"]["DEFECT"] > 0) or (Despawned_Items_Record["Incinerator"]["REFINED"] > 0) and self.total_despawned_items() == 2  and (dialog_timer_waiting == true) and ("SpawnB" in Spawn_Sequences_Completed):
						self.reset_despawned_items_counts()
						Spawn_Sequences_Completed = []
						dialog_timer_waiting = false
						dialog_timer = 0.0
						dialog_state = 4
						
				5:  #Tutorial Succeed State
					if dialog_timer > 0.1 and dialog_timer_waiting == false:
						Character_Dialog_Pane.display_text_sequential("Good work! Now you know the ropes,",0.05)
						dialog_timer_waiting = true
					if dialog_timer > 3.0 and dialog_timer_waiting == true:
						dialog_timer_waiting = false
						state_timer_reset = false
						game_state = 1
						
						
						
		1: #Game Wave 1 ((24 total)  21 normal donuts, 3 bad donuts) 
			# Start BURN path by burning more than 15 normal donuts. 
			# Start NORMAL path by missing any number of donuts.
			# Start PERFECT path by sorting all donuts perfectly.
			if state_timer_reset == false:
				state_timer = 0.0
				state_timer_reset = true
				
				dialog_timer = 0.0
				dialog_state = 0
				dialog_timer_waiting = false


			match dialog_state:
				0: #Sequential State
					if dialog_timer > 0.1 and dialog_timer_waiting == false:
						Character_Dialog_Pane.display_text_sequential("I'll have you work on sorting this normal batch of donuts",0.05)
						Spawn_Sequence_A_WAVE1["Belt_Obj_Sequence_array"] = generate_random_pattern_2_objs(21,3)
						EventBus.trigger_event("Start_Scripted_Spawn_Sequence", Spawn_Sequence_A_WAVE1)
						Spawn_Sequence_B_WAVE1["Belt_Obj_Sequence_array"] = generate_random_pattern_2_objs(21,3)
						EventBus.trigger_event("Start_Scripted_Spawn_Sequence", Spawn_Sequence_B_WAVE1)
						dialog_timer_waiting = true
						
					#if player has made a mistake, they are put on the "Normal path" and a short dialog plays
					if (player_path == enum_player_path.UNDEF) and ((Despawned_Items_Record["GoodDepot"]["DEFECT"] > 0) or (Despawned_Items_Record["Incinerator"]["REFINED"] > 0)) and (dialog_timer_waiting == true):
						Character_Dialog_Pane.display_text_sequential("Oops, Looks like you missed one",0.05)
						player_path = enum_player_path.NORMAL
						
					#if player has been burning too many donuts, they are put on the "Burn path" and a short dialog plays
					if (player_path == enum_player_path.UNDEF or player_path == enum_player_path.NORMAL) and (Despawned_Items_Record["Incinerator"]["REFINED"] > 15) and (dialog_timer_waiting == true):
						Character_Dialog_Pane.display_text_sequential("You.. You're burning everything..",0.05)
						player_path = enum_player_path.BURN
						
					if (self.total_despawned_items() == 48) and (dialog_timer_waiting == true) and ("SpawnB" in Spawn_Sequences_Completed) and ("SpawnA" in Spawn_Sequences_Completed):
						#if neither Normal or Burn conditions and you're here, you must be perfect!
						if player_path == enum_player_path.UNDEF:
							player_path = enum_player_path.PERFECT
						self.reset_despawned_items_counts()
						Spawn_Sequences_Completed = []
						dialog_timer_waiting = false
						dialog_timer = 0.0
						dialog_state += 1
						
				1: #Sequential State
					if dialog_timer > 0.1 and dialog_timer_waiting == false:
						match player_path:
							enum_player_path.UNDEF:
								Character_Dialog_Pane.display_text_sequential("THIS IS AN ERROR enum_player_path.UNDEF ",0.05)
							enum_player_path.NORMAL:
								Character_Dialog_Pane.display_text_sequential("You did Good, I think you're getting the hang of it",0.05)
							enum_player_path.BURN:
								Character_Dialog_Pane.display_text_sequential("You burned so many.. The flames.. I think.. we should burn more",0.05)
							enum_player_path.PERFECT:
								Character_Dialog_Pane.display_text_sequential("That was Perfect! Good Job!",0.05)
						
						dialog_timer_waiting = true
					if dialog_timer > 8.0 and dialog_timer_waiting == true:
						dialog_timer_waiting = false
						dialog_timer = 0.0
						dialog_state += 1
				
	
		2: #Game Wave 2 (36 total, 20 bad donuts, 16 good donuts)
			# Continue BURN path by burning more than 26 normal donuts. 
			# Continue/Start NORMAL path by missing any number of donuts.
			# Continue PERFECT path by sorting all donuts perfectly.
			#Spawn_Sequence_A_WAVE2
			#Spawn_Sequence_B_WAVE2
			pass
			
			
		3: #Game Wave 3 (36 total, 20 cats, 16 dogs)
			#	FAIL BURN path by sparing EVEN A SINGLE ANIMAL
			#  Continue Normal path 
			#	FAIL PERFECT path by BURINING EVEN A SINGLE ANIMAL
			#Spawn_Sequence_A_WAVE3
			#Spawn_Sequence_B_WAVE3
			pass
			
			


#helper functions for the despawned_items_record, as it's not as managable line by line.
#this goes heavily against modularity and future expansion.. but it's a game jam and I'm running out of time
func total_despawned_items()->int:
	return (Despawned_Items_Record["GoodDepot"]["REFINED"] + Despawned_Items_Record["GoodDepot"]["DEFECT"] + Despawned_Items_Record["Incinerator"]["REFINED"] + Despawned_Items_Record["Incinerator"]["DEFECT"])

func reset_despawned_items_counts()->void:
	Despawned_Items_Record["GoodDepot"]["REFINED"] = 0
	Despawned_Items_Record["GoodDepot"]["DEFECT"] = 0
	Despawned_Items_Record["Incinerator"]["REFINED"] = 0
	Despawned_Items_Record["Incinerator"]["DEFECT"] = 0
	
	

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
	


#events from spawner to return it's complete state
func _Completed_Scripted_Spawn_Sequence(Completed_Spawner_Name:StringName):
	Spawn_Sequences_Completed.append(Completed_Spawner_Name)


#reminder:these are events from the Despawner; I need to manage them here next.
func _Despawned_Item(Despawn_Dict:Dictionary):
	if not Despawned_Items_Record.has(Despawn_Dict["DespawnerID"]):
		Despawned_Items_Record[Despawn_Dict["DespawnerID"]] = Dictionary()
	if not Despawned_Items_Record[Despawn_Dict["DespawnerID"]].has(Despawn_Dict["Belt_Object_Type"]):
		Despawned_Items_Record[Despawn_Dict["DespawnerID"]][Despawn_Dict["Belt_Object_Type"]] = int(0)
	Despawned_Items_Record[Despawn_Dict["DespawnerID"]][Despawn_Dict["Belt_Object_Type"]] += 1
	

