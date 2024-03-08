extends StaticBody3D

class_name Belt_Turntable_Path3D

@onready var Highlight = $Mouseover_Highlight
@onready var BeltMesh = $MeshInstance3D

@onready var Rear_EntrancePathNode = $MeshInstance3D/Entrance_Path/Rear_Entrance_Path
@onready var Left_EntrancePathNode = $MeshInstance3D/Entrance_Path/Left_Entrance_Path
@onready var Right_EntrancePathNode = $MeshInstance3D/Entrance_Path/Right_Entrance_Path

@onready var Forward_ExitPathNode = $MeshInstance3D/Exit_Path/Forward_Exit_Path
@onready var Left_ExitPathNode = $MeshInstance3D/Exit_Path/Left_Exit_Path
@onready var Right_ExitPathNode = $MeshInstance3D/Exit_Path/Right_Exit_Path



enum global_direction {NORTH_ZPOS, EAST_XNEG, SOUTH_ZNEG, WEST_XPOS }
enum local_orientation {LEFT, RIGHT, FORWARD}

@export var Turntable_Global_Direction:global_direction


#offset position to unload objects onto NORTH_ExitPathNode
@export var NORTH_ExitPathNode:Path3D=null
@export var NORTH_Exit_local_orientation:local_orientation=local_orientation.FORWARD
#@export var NORTH_Exit_Position_Override:float=0.5

#offset position to unload objects onto EAST_ExitPathNode
@export var EAST_ExitPathNode:Path3D=null
@export var EAST_Exit_local_orientation:local_orientation=local_orientation.FORWARD
#@export var EAST_Exit_Position_Override:float=0.5

#offset position to unload objects onto SOUTH_ExitPathNode
@export var SOUTH_ExitPathNode:Path3D=null
@export var SOUTH_Exit_local_orientation:local_orientation=local_orientation.FORWARD
#@export var SOUTH_Exit_Position_Override:float=0.5

#offset position to unload objects onto WEST_ExitPathNode
@export var WEST_ExitPathNode:Path3D=null
@export var WEST_Exit_local_orientation:local_orientation=local_orientation.FORWARD
#@export var WEST_Exit_Position_Override:float=0.5


var current_ExitPathNode:Path3D=null
#var current_Exit_local_orientation:local_orientation=local_orientation.FORWARD
#var current_Exit_Position_Override:float=0.0


func set_exitpath(After_Exit_PathNode:Path3D,After_Exit_Direction:local_orientation):
	match After_Exit_Direction:
		local_orientation.LEFT:
			current_ExitPathNode=Left_ExitPathNode
		local_orientation.RIGHT:
			current_ExitPathNode=Right_ExitPathNode
		local_orientation.FORWARD:
			current_ExitPathNode=Forward_ExitPathNode

	Rear_EntrancePathNode.set_exit_path_node(current_ExitPathNode)
	Left_EntrancePathNode.set_exit_path_node(current_ExitPathNode)
	Right_EntrancePathNode.set_exit_path_node(current_ExitPathNode)
	
	current_ExitPathNode.set_exit_path_node(After_Exit_PathNode)


func rotate_belt(LRMouse:int)->void:
	#rotate belt model and set Turntable_Global_Direction for proper input directions
	match Turntable_Global_Direction:
		global_direction.NORTH_ZPOS:#^
			match LRMouse:
				1:#rotate left
					Turntable_Global_Direction = global_direction.WEST_XPOS
					self.set_exitpath(WEST_ExitPathNode,WEST_Exit_local_orientation)
					self.rotate_object_local(Vector3(0,1,0),PI/2)
				2:#rotate right
					Turntable_Global_Direction = global_direction.EAST_XNEG
					self.set_exitpath(EAST_ExitPathNode,EAST_Exit_local_orientation)
					self.rotate_object_local(Vector3(0,1,0),-PI/2)
		global_direction.EAST_XNEG:#>
			match LRMouse:
				1:#rotate left
					Turntable_Global_Direction = global_direction.NORTH_ZPOS
					self.set_exitpath(NORTH_ExitPathNode,NORTH_Exit_local_orientation)
					self.rotate_object_local(Vector3(0,1,0),PI/2)
				2:#rotate right
					Turntable_Global_Direction = global_direction.SOUTH_ZNEG
					self.set_exitpath(SOUTH_ExitPathNode,SOUTH_Exit_local_orientation)
					self.rotate_object_local(Vector3(0,1,0),-PI/2)
		global_direction.SOUTH_ZNEG:#v
			match LRMouse:
				1:#rotate left
					Turntable_Global_Direction = global_direction.EAST_XNEG
					self.set_exitpath(EAST_ExitPathNode,EAST_Exit_local_orientation)
					self.rotate_object_local(Vector3(0,1,0),PI/2)
				2:#rotate right
					Turntable_Global_Direction = global_direction.WEST_XPOS
					self.set_exitpath(WEST_ExitPathNode,WEST_Exit_local_orientation)
					self.rotate_object_local(Vector3(0,1,0),-PI/2)
		global_direction.WEST_XPOS:#<
			match LRMouse:
				1:#rotate left
					Turntable_Global_Direction = global_direction.SOUTH_ZNEG
					self.set_exitpath(SOUTH_ExitPathNode,SOUTH_Exit_local_orientation)
					self.rotate_object_local(Vector3(0,1,0),PI/2)
				2:#rotate right
					Turntable_Global_Direction = global_direction.NORTH_ZPOS
					self.set_exitpath(NORTH_ExitPathNode,NORTH_Exit_local_orientation)
					self.rotate_object_local(Vector3(0,1,0),-PI/2)

func _ready():
	#set initial exit parameters
	match Turntable_Global_Direction:
		global_direction.NORTH_ZPOS:#^
			self.set_exitpath(NORTH_ExitPathNode,NORTH_Exit_local_orientation)
		global_direction.EAST_XNEG:#>
			self.set_exitpath(EAST_ExitPathNode,EAST_Exit_local_orientation)
		global_direction.SOUTH_ZNEG:#v
			self.set_exitpath(SOUTH_ExitPathNode,SOUTH_Exit_local_orientation)
		global_direction.WEST_XPOS:#<
			self.set_exitpath(WEST_ExitPathNode,WEST_Exit_local_orientation)


				


		

func _input(event):
	if Highlight.visible == true: #mouseover is occuring
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					self.rotate_belt(1)
			if event.button_index == MOUSE_BUTTON_RIGHT:
				if event.pressed:
					self.rotate_belt(2)
		

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
	
