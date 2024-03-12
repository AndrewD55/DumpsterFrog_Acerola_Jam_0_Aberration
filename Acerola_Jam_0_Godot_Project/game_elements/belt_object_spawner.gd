extends StaticBody3D
class_name Belt_Object_Spawner

#Exit to another Linked_Path3D
@export var ExitPathNode:Path3D=null
@export var SpawnerID:StringName="undef"

var On_Belt_Objects = load("res://game_elements/on_belt_object.tscn")
@onready var Spawn_Shute = $Spawn_Shute

var time:float
var spawn_shute_vacant:bool = true


#scripted_spawn_sequence local variables
var initialize_spawn_sequence:bool=false
var spawn_sequence_active:bool=false
var spawn_rate_seconds:float=0.0
var belt_obj_sequence:Array[bool]= []
var belt_obj_sequence_index:int =0 
var belt_object1_type:On_Belt_Object.enum_belt_object_type = On_Belt_Object.enum_belt_object_type.REFINED
var belt_object2_type:On_Belt_Object.enum_belt_object_type = On_Belt_Object.enum_belt_object_type.REFINED

func _ready():
	Spawn_Shute.set_exit_path_node(ExitPathNode)
	EventBus.create_event("Start_Scripted_Spawn_Sequence", _start_spawn_sequence.bind())
	

func _physics_process(delta):
	#update current time
	time += delta

	if initialize_spawn_sequence == true:
		time = 0.0
		initialize_spawn_sequence = false
		spawn_sequence_active = true

	if belt_obj_sequence_index > 0:
		if time > spawn_rate_seconds:
			if spawn_shute_vacant == true:
				var New_On_Belt_Obj = On_Belt_Objects.instantiate()
				
				belt_obj_sequence_index -= 1
				match belt_obj_sequence[belt_obj_sequence_index]:
					true: #Common Object Type 
						New_On_Belt_Obj.initial_object_type = belt_object1_type
					false: #Rarer Object Type
						New_On_Belt_Obj.initial_object_type = belt_object2_type
						
				New_On_Belt_Obj.initial_velocity = 1.0
				New_On_Belt_Obj.follow_collision_distance = 0.75
				Spawn_Shute.add_child(New_On_Belt_Obj)
				#set to wait until next spawn time.
				time = 0.0
	else:
		if spawn_sequence_active == true:
				#Notify spawn sequence completed
			EventBus.trigger_event("Completed_Scripted_Spawn_Sequence", SpawnerID)
			initialize_spawn_sequence=false
			spawn_sequence_active=false
			belt_obj_sequence_index = 0
			belt_obj_sequence=[]



func _start_spawn_sequence(Spawn_Sequence_Dict:Dictionary):
	#spawn_rate_seconds - used to specify when spawns should occur
	#belt_obj_sequence  - an array of booleans that specifies which object should spawn next
	#belt_object1_type  - what type of object should be used for type1
	#belt_object2_type  - what type of object should be used for type2
	if Spawn_Sequence_Dict["SpawnerID"] == SpawnerID:
		initialize_spawn_sequence = true
		spawn_rate_seconds = Spawn_Sequence_Dict["Spawn_Rate_Seconds_float"]
		belt_obj_sequence = Spawn_Sequence_Dict["Belt_Obj_Sequence_array"]
		belt_obj_sequence_index = belt_obj_sequence.size()
		belt_object1_type = Spawn_Sequence_Dict["Belt_Obj1_enum"]
		belt_object2_type = Spawn_Sequence_Dict["Belt_Obj2_enum"]
		#print("SpawnerID matches! Begin Spawn!")
	#else:
		#print("SpawnerID does not match")
		#print(SpawnerID)
		
		
func scripted_immeidate_spawn(belt_object_type:On_Belt_Object.enum_belt_object_type):
	#BE CARFEUL, YOU CAN FLOOD THE SPAWNER TOO QUICKLY
	var New_On_Belt_Obj = On_Belt_Objects.instantiate()
	New_On_Belt_Obj.initial_object_type = belt_object_type
	New_On_Belt_Obj.initial_velocity = 1.0
	New_On_Belt_Obj.follow_collision_distance = 0.75
	Spawn_Shute.add_child(New_On_Belt_Obj)


func _on_spawn_shute_child_exiting_tree(node):
	spawn_shute_vacant = true

func _on_spawn_shute_child_entered_tree(node):
	spawn_shute_vacant = false
