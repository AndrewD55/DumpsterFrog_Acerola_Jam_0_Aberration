extends StaticBody3D
class_name Belt_Object_Despawner



#On_Belt_Object.enum_belt_object_type {REFINED, DEFECT}

#
@export var Object_Type_REFINED_Score:int=0
@export var Object_Type_DEFECT_Score:int=0


@onready var Despawn_Shute = $Despawn_Shute
@onready var Death_Path = $Death_Path

func get_despawner_entrance()->Path3D: #other linked paths will call this. #return our linked path
	return Despawn_Shute
	
func _on_death_path_child_entered_tree(node):
		if node.initial_object_type == On_Belt_Object.enum_belt_object_type.REFINED:
			print("EMIT REFINED SCORE")
			print(Object_Type_REFINED_Score)
		elif node.initial_object_type == On_Belt_Object.enum_belt_object_type.DEFECT:
			print("EMIT DEFECT SCORE")
			print(Object_Type_REFINED_Score)
		node.queue_free()
