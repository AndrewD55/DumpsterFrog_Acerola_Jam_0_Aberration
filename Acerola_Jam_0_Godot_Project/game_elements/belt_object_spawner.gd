extends StaticBody3D
class_name Belt_Object_Spawner

#Exit to another Linked_Path3D
@export var ExitPathNode:Path3D=null

@export var Number_Good_Products:int=7
@export var Number_Bad_Products:int=3
var Total_Products:int = Number_Good_Products+Number_Bad_Products

@export var Good_to_Defect_Ratio:float=0.6
#This is some biasing math to try and break up streaks and
#make the defects feel more rare..   the +2 is to make sure the bias can't go to 1.0
#(Defect_to_Good_Ratio)/Number_Bad_Products+2
var bias_rate:float = (1.0-Good_to_Defect_Ratio)/(Number_Bad_Products+2)
var bias:float = 0.0

#I'm starting to think the best statitistic solution
# is to predetermine the results and then use critera to shuffle and break up
# any massive streaks.. But I may consider this Good Enough for now. 



@export var Spawn_Rate_Seconds:float=3.0
var spawn_time:float=0.0


var On_Belt_Objects = load("res://game_elements/on_belt_object.tscn")
@onready var Spawn_Shute = $Spawn_Shute

var more_products_to_spawn = true

func _ready():
	Spawn_Shute.set_exit_path_node(ExitPathNode)
	
func _physics_process(delta):

	if more_products_to_spawn == true:
		#update current time
		spawn_time += delta
		#print(spawn_time)
				
		if spawn_time > Spawn_Rate_Seconds:
			#allow spawn object if no objects are on belt
			if Spawn_Shute.get_child_count() == 0:
				#print("SPAWN OBJECT")
		
				#still objects to spawn
				if Total_Products > 0:
					Total_Products -= 1
					
					#instantiate object
					var New_On_Belt_Obj = On_Belt_Objects.instantiate()
					
					#determine if it's REFINED or DEFECT
					var coinflip:float = randf()
					# A 60% chance spawning Good Product
					if (coinflip < Good_to_Defect_Ratio+bias and Number_Good_Products > 1) or Number_Bad_Products < 1: #HEADS
						Number_Good_Products -= 1
						New_On_Belt_Obj.initial_object_type = On_Belt_Object.enum_belt_object_type.REFINED
					else: #TAILS  
						Number_Bad_Products -= 1
						New_On_Belt_Obj.initial_object_type = On_Belt_Object.enum_belt_object_type.DEFECT
						bias += bias_rate
					
					New_On_Belt_Obj.initial_velocity = 1.0
					New_On_Belt_Obj.follow_collision_distance = 0.75
					Spawn_Shute.add_child(New_On_Belt_Obj)
					spawn_time = 0.0
					
					
				else:
					print("CANNOT SPAWN ANYMORE PRODUCTS")
					print("EMIT GAME FINISHED SIGNAL")
					more_products_to_spawn = false
		
		
func scripted_immeidate_spawn(belt_object_type:On_Belt_Object.enum_belt_object_type):
	#BE CARFEUL, YOU CAN FLOOD THE SPAWNER TOO QUICKLY
	var New_On_Belt_Obj = On_Belt_Objects.instantiate()
	New_On_Belt_Obj.initial_object_type = belt_object_type
	New_On_Belt_Obj.initial_velocity = 1.0
	New_On_Belt_Obj.follow_collision_distance = 0.75
	Spawn_Shute.add_child(New_On_Belt_Obj)
