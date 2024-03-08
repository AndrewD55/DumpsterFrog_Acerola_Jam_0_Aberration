extends Path3D

#Exit to another Linked_Path3D
@export var ExitPathNode:Path3D=null

#or Exit onto a turntable
@export var ExitPathTurntable:Belt_Turntable_Path3D=null
@export var ExitPathTurntable_EnterDirection:Belt_Turntable_Path3D.global_direction

func set_exit_path_node(new_exit_path_node:Path3D) -> void:
	ExitPathNode = new_exit_path_node

func get_exit_path_node() -> Path3D:
	var Final_ExitPathNode:Path3D=null
	if ExitPathNode != null:
		Final_ExitPathNode = ExitPathNode
	if ExitPathTurntable != null:
		Final_ExitPathNode = ExitPathTurntable.get_turntable_entrance(ExitPathTurntable_EnterDirection)
	return Final_ExitPathNode
