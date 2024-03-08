extends StaticBody3D
class_name Belt_Object_Despawner

@onready var Despawn_Shute = $Despawn_Shute
@onready var Death_Path = $Death_Path

func get_despawner_entrance()->Path3D: #other linked paths will call this. #return our linked path
	return Despawn_Shute
	
func _on_death_path_child_entered_tree(node):
		node.queue_free()
