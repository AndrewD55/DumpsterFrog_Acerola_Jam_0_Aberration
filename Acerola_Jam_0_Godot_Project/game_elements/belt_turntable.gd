extends StaticBody3D


#@onready var mesh = $MeshInstance3D
@onready var Highlight = $Mouseover_Highlight

#intended to have only one or none defined.
@export var Left_Left_ExitPathNode : Path3D = null
@export var Left_Forward_ExitPathNode : Path3D = null
@export var Left_Right_ExitPathNode : Path3D = null
#offset position to unload objects onto Left_ExitPathNode
@export var Left_Exit_Position_Override : float = 0.0

#intended to have only one or none defined.
@export var Forward_Left_ExitPathNode : Path3D = null
@export var Forward_Forward_ExitPathNode : Path3D = null
@export var Forward_Right_ExitPathNode : Path3D = null
#offset position to unload objects onto Forward_ExitPathNode
@export var Forward_Exit_Position_Override : float = 0.0

#intended to have only one or none defined.
@export var Right_Left_ExitPathNode : Path3D = null
@export var Right_Forward_ExitPathNode : Path3D = null
@export var Right_Right_ExitPathNode : Path3D = null
#offset position to unload objects onto Right_ExitPathNode
@export var Right_Exit_Position_Override : float = 0.0

enum enum_rotation_state {LEFT, RIGHT, FORWARD}

@export var init_rotation_state:enum_rotation_state=enum_rotation_state.FORWARD

func _on_mouse_entered():
	Highlight.visible = true


func _on_mouse_exited():
	Highlight.visible = false
