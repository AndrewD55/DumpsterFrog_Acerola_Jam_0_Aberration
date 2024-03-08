extends StaticBody3D
class_name Belt_Object_Spawner

#Exit to another Linked_Path3D
@export var ExitPathNode:Path3D=null

@export var Spawn_Rate_Seconds:float=3.0
var spawn_time:float=0.0


var On_Belt_Objects = load("res://game_elements/on_belt_object.tscn")
@onready var Spawn_Shute = $Spawn_Shute


func _ready():
	Spawn_Shute.set_exit_path_node(ExitPathNode)
	
func _physics_process(delta):
	#update current time
	spawn_time += delta
	#print(spawn_time)
	
	if spawn_time > Spawn_Rate_Seconds:
		#allow spawn object if no objects are on belt
		if Spawn_Shute.get_child_count() == 0:
			#print("SPAWN OBJECT")
			var New_On_Belt_Obj = On_Belt_Objects.instantiate()
			New_On_Belt_Obj.initial_object_type = On_Belt_Object.enum_belt_object_type.UNDEF
			New_On_Belt_Obj.initial_velocity = 1.0
			New_On_Belt_Obj.follow_collision_distance = 0.75
			Spawn_Shute.add_child(New_On_Belt_Obj)
			spawn_time = 0.0
		
		
		
	
		
		
		
