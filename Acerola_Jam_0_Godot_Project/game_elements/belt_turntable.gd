extends StaticBody3D

class_name Belt_Turntable_Path3D

@onready var Highlight = $Mouseover_Highlight
@onready var BeltMesh = $MeshInstance3D

@onready var Rear_EntrancePathNode = $MeshInstance3D/Entrance_Path/Rear_Entrance_Path
@onready var Left_EntrancePathNode = $MeshInstance3D/Entrance_Path/Left_Entrance_Path
@onready var Right_EntrancePathNode = $MeshInstance3D/Entrance_Path/Right_Entrance_Path


@onready var ExitEntrancePathNode = $MeshInstance3D/Entrance_Path/Left_Entrance_Path

#hmm.. how do I link all these entrance/exit path nodes?
#OH. I DIDNT EVEN UPDATE THESE PATH NODES WITH LINKED PATH NODES..

#SOMEHOW I'll NEED TO BE ABLE TO LINK ANY PATH TO ANY ENTRANCE, 
#FIND A BETTER SOLUTION



enum global_direction {NORTH_ZPOS, EAST_XNEG, SOUTH_ZNEG, WEST_XPOS }
enum local_orientation {LEFT, RIGHT, FORWARD}

@export var Turntable_Global_Direction:global_direction


#offset position to unload objects onto Left_ExitPathNode
@export var Left_ExitPathNode:Path3D=null
@export var Left_Exit_local_orientation:local_orientation=local_orientation.FORWARD
@export var Left_Exit_Position_Override:float=0.5

#offset position to unload objects onto Forward_ExitPathNode
@export var Forward_ExitPathNode:Path3D=null
@export var Forward_Exit_local_orientation:local_orientation=local_orientation.FORWARD
@export var Forward_Exit_Position_Override:float=0.5

#offset position to unload objects onto Right_ExitPathNode
@export var Right_ExitPathNode:Path3D=null
@export var Right_Exit_local_orientation:local_orientation=local_orientation.FORWARD
@export var Right_Exit_Position_Override:float=0.5



var current_ExitPathNode:Path3D=null
var current_Exit_local_orientation:local_orientation=local_orientation.FORWARD
var current_Exit_Position_Override:float=0.0


func rotate_belt(orientation:local_orientation):
	if   orientation == local_orientation.LEFT:
		self.rotate_object_local(Vector3(0,1,0),PI/2)
		current_ExitPathNode=Left_ExitPathNode
		current_Exit_local_orientation=Left_Exit_local_orientation
		current_Exit_Position_Override=Left_Exit_Position_Override
	elif orientation == local_orientation.RIGHT:
		self.rotate_object_local(Vector3(0,1,0),-PI/2)
		current_ExitPathNode=Right_ExitPathNode
		current_Exit_local_orientation=Right_Exit_local_orientation
		current_Exit_Position_Override=Right_Exit_Position_Override
	elif orientation == local_orientation.FORWARD:
		self.rotate_object_local(Vector3(0,1,0),0.0)
		current_ExitPathNode=Forward_ExitPathNode
		current_Exit_local_orientation=Forward_Exit_local_orientation
		current_Exit_Position_Override=Forward_Exit_Position_Override
		
		#Forward_EntrancePathNode.ExitPathNode = current_ExitPathNode
		#Left_EntrancePathNode.ExitPathNode = current_ExitPathNode
		#Right_EntrancePathNode.ExitPathNode = current_ExitPathNode
		#
		


func _ready():
	pass

#func _physics_process(delta):

func _on_mouse_entered():
	Highlight.visible = true


func _on_mouse_exited():
	Highlight.visible = false
	
	

func get_turntable_entrance(Incoming_Obj_Global_Direction:global_direction):
#This is used to provide incoming objects which enter path to take.
# I know this is a large nasty state logic to solve the problem.. 
#But I think it's performant, two switches to get direct path node ref
#probably could make a cleaner dict[turntable_dir][incoming_obj_dir] lookup?
	var EntrancePathNode:Path3D=null
	match Turntable_Global_Direction:
		global_direction.NORTH_ZPOS: #^
				match Incoming_Obj_Global_Direction:
					global_direction.NORTH_ZPOS:
						EntrancePathNode=null
					global_direction.EAST_XNEG:
						EntrancePathNode=Right_EntrancePathNode
					global_direction.SOUTH_ZNEG:
						EntrancePathNode=Left_EntrancePathNode
					global_direction.WEST_XPOS:
						EntrancePathNode=Rear_EntrancePathNode
		global_direction.EAST_XNEG:#>
				match Incoming_Obj_Global_Direction:
					global_direction.NORTH_ZPOS:
						EntrancePathNode=Left_EntrancePathNode
					global_direction.EAST_XNEG:
						EntrancePathNode=Rear_EntrancePathNode
					global_direction.SOUTH_ZNEG:
						EntrancePathNode=Right_EntrancePathNode  
					global_direction.WEST_XPOS:
						EntrancePathNode=null 
		global_direction.SOUTH_ZNEG:#v
				match Incoming_Obj_Global_Direction:
					global_direction.NORTH_ZPOS:
						EntrancePathNode=Rear_EntrancePathNode
					global_direction.EAST_XNEG:
						EntrancePathNode=Left_EntrancePathNode  
					global_direction.SOUTH_ZNEG:
						EntrancePathNode=null
					global_direction.WEST_XPOS:
						EntrancePathNode= Right_EntrancePathNode
		global_direction.WEST_XPOS:#<
			match Incoming_Obj_Global_Direction:
					global_direction.NORTH_ZPOS:
						EntrancePathNode=Right_EntrancePathNode
					global_direction.EAST_XNEG:
						EntrancePathNode=null 
					global_direction.SOUTH_ZNEG:
						EntrancePathNode=Rear_EntrancePathNode
					global_direction.WEST_XPOS:
						EntrancePathNode=Left_EntrancePathNode
	return EntrancePathNode
	
