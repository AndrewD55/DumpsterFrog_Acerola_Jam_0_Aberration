extends StaticBody3D

@onready var Highlight = $Mouseover_Highlight
@onready var BeltMesh = $MeshInstance3D

@onready var Forward_EntrancePathNode = $MeshInstance3D/Entrance_Path/Forward_Entrance_Path
@onready var Left_EntrancePathNode = $MeshInstance3D/Entrance_Path/Left_Entrance_Path
@onready var Right_EntrancePathNode = $MeshInstance3D/Entrance_Path/Right_Entrance_Path


#hmm.. how do I link all these entrance/exit path nodes?
#OH. I DIDNT EVEN UPDATE THESE PATH NODES WITH LINKED PATH NODES..

#SOMEHOW I'll NEED TO BE ABLE TO LINK ANY PATH TO ANY ENTRANCE, 
FIND A BETTER SOLUTION


enum enum_orientation {LEFT, RIGHT, FORWARD}

#offset position to unload objects onto Left_ExitPathNode
@export var Left_ExitPathNode:Path3D=null
@export var Left_Exit_Orientation:enum_orientation=enum_orientation.FORWARD
@export var Left_Exit_Position_Override:float=0.5

#offset position to unload objects onto Forward_ExitPathNode
@export var Forward_ExitPathNode:Path3D=null
@export var Forward_Exit_Orientation:enum_orientation=enum_orientation.FORWARD
@export var Forward_Exit_Position_Override:float=0.5

#offset position to unload objects onto Right_ExitPathNode
@export var Right_ExitPathNode:Path3D=null
@export var Right_Exit_Orientation:enum_orientation=enum_orientation.FORWARD
@export var Right_Exit_Position_Override:float=0.5

@export var Initial_Exit_Orientation:enum_orientation=enum_orientation.FORWARD

var current_ExitPathNode:Path3D=null
var current_Exit_Orientation:enum_orientation=enum_orientation.FORWARD
var current_Exit_Position_Override:float=0.0


func rotate_belt(orientation:enum_orientation):
	if   orientation == enum_orientation.LEFT:
		self.rotate_object_local(Vector3(0,1,0),PI/2)
		current_ExitPathNode=Left_ExitPathNode
		current_Exit_Orientation=Left_Exit_Orientation
		current_Exit_Position_Override=Left_Exit_Position_Override
	elif orientation == enum_orientation.RIGHT:
		self.rotate_object_local(Vector3(0,1,0),-PI/2)
		current_ExitPathNode=Right_ExitPathNode
		current_Exit_Orientation=Right_Exit_Orientation
		current_Exit_Position_Override=Right_Exit_Position_Override
	elif orientation == enum_orientation.FORWARD:
		self.rotate_object_local(Vector3(0,1,0),0.0)
		current_ExitPathNode=Forward_ExitPathNode
		current_Exit_Orientation=Forward_Exit_Orientation
		current_Exit_Position_Override=Forward_Exit_Position_Override
		
		Forward_EntrancePathNode.ExitPathNode = current_ExitPathNode
		Left_EntrancePathNode.ExitPathNode = current_ExitPathNode
		Right_EntrancePathNode.ExitPathNode = current_ExitPathNode
		
		


func _ready():
	rotate_belt(Initial_Exit_Orientation)
	#lock in 

#func _physics_process(delta):

func _on_mouse_entered():
	Highlight.visible = true


func _on_mouse_exited():
	Highlight.visible = false
	
	
