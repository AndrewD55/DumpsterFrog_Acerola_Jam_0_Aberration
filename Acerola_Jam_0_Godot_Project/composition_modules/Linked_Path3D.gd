extends Path3D

#Exit to another Linked_Path3D
@export var ExitPathNode:Path3D=null

#or Exit onto a turntable
@export var ExitPathTurntable:Belt_Turntable_Path3D=null
@export var ExitPathTurntable_EnterDirection:Belt_Turntable_Path3D.global_direction

#or Exit onto a Despawner
@export var ExitPathDespawner:Belt_Object_Despawner=null

func set_exit_path_node(new_exit_path_node:Path3D) -> void:
	ExitPathNode = new_exit_path_node

func get_exit_path_node() -> Path3D:
	var Final_ExitPathNode:Path3D=null
	if ExitPathNode != null:
		Final_ExitPathNode = ExitPathNode
	elif ExitPathTurntable != null:
		Final_ExitPathNode = ExitPathTurntable.get_turntable_entrance(ExitPathTurntable_EnterDirection)
	elif ExitPathDespawner != null:
		Final_ExitPathNode = ExitPathDespawner.get_despawner_entrance()
	return Final_ExitPathNode
