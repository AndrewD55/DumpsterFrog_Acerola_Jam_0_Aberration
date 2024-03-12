extends StaticBody3D
class_name Belt_Object_Despawner



#On_Belt_Object.enum_belt_object_type {REFINED, DEFECT}

@export var DespawnerID:StringName="undef"


@onready var Despawn_Shute = $Despawn_Shute
@onready var Death_Path = $Death_Path

func get_despawner_entrance()->Path3D: #other linked paths will call this. #return our linked path
	return Despawn_Shute
	
func _on_death_path_child_entered_tree(node):
		var obj_type_name:StringName
		
		match node.initial_object_type:
			On_Belt_Object.enum_belt_object_type.REFINED:
				obj_type_name = "REFINED"
			On_Belt_Object.enum_belt_object_type.DEFECT:
				obj_type_name = "DEFECT"
				
		var despawn_dict:Dictionary = {
			"DespawnerID":DespawnerID,
			"Belt_Object_Type":obj_type_name} 
		
		EventBus.trigger_event("Despawned_Item", despawn_dict)
		node.queue_free()
