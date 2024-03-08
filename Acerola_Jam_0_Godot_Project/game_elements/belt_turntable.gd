extends StaticBody3D
class_name Belt_Turntable_Path3D

@onready var Highlight = $Mouseover_Highlight
var GreenHighlightTexture:Texture2D = load("res://2D_Media/Sprites/Mouseover_Highlight_V0_Green.png")
var RedHighlightTexture:Texture2D = load("res://2D_Media/Sprites/Mouseover_Highlight_V0_Red.png")

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
#offset position to unload objects onto EAST_ExitPathNode
@export var EAST_ExitPathNode:Path3D=null
@export var EAST_Exit_local_orientation:local_orientation=local_orientation.FORWARD
#offset position to unload objects onto SOUTH_ExitPathNode
@export var SOUTH_ExitPathNode:Path3D=null
@export var SOUTH_Exit_local_orientation:local_orientation=local_orientation.FORWARD
#offset position to unload objects onto WEST_ExitPathNode
@export var WEST_ExitPathNode:Path3D=null
@export var WEST_Exit_local_orientation:local_orientation=local_orientation.FORWARD

@export var Entrant_Resume_Velocity:float=1.0

var current_ExitPathNode:Path3D=null

var Exiting_ObjectNode:Node3D=null
var Lock_Rotation:bool=false
var Cannot_Exit_Invalid_Exit_Path:bool=false

var Entry_Direction_Queue = []
var Entry_Direction_Nodes = []
var Allow_Entrant:bool= true
var Prev_Lock_Rotation:bool = false


# HELPER FUNCTIONS
func set_exitpath(After_Exit_PathNode:Path3D,After_Exit_Direction:local_orientation):
	match After_Exit_Direction:
		local_orientation.LEFT:
			current_ExitPathNode=Left_ExitPathNode
		local_orientation.RIGHT:
			current_ExitPathNode=Right_ExitPathNode
		local_orientation.FORWARD:
			current_ExitPathNode=Forward_ExitPathNode
			
	#if there's nowhere to exit.. don't allow the object to leave entrance paths
	if After_Exit_PathNode != null:
		Rear_EntrancePathNode.set_exit_path_node(current_ExitPathNode)
		Left_EntrancePathNode.set_exit_path_node(current_ExitPathNode)
		Right_EntrancePathNode.set_exit_path_node(current_ExitPathNode)
	else:
		Rear_EntrancePathNode.set_exit_path_node(null)
		Left_EntrancePathNode.set_exit_path_node(null)
		Right_EntrancePathNode.set_exit_path_node(null)
		
	current_ExitPathNode.set_exit_path_node(After_Exit_PathNode)

func rotate_belt(LRMouse:int)->void:
	#rotate belt model and set Turntable_Global_Direction for proper input directions
	match Turntable_Global_Direction:
		global_direction.NORTH_ZPOS:#^
			match LRMouse:
				1:#rotate left
					Turntable_Global_Direction = global_direction.WEST_XPOS
					self.set_exitpath(WEST_ExitPathNode,WEST_Exit_local_orientation)
					BeltMesh.rotate_object_local(Vector3(0,1,0),PI/2)
				2:#rotate right
					Turntable_Global_Direction = global_direction.EAST_XNEG
					self.set_exitpath(EAST_ExitPathNode,EAST_Exit_local_orientation)
					BeltMesh.rotate_object_local(Vector3(0,1,0),-PI/2)
		global_direction.EAST_XNEG:#>
			match LRMouse:
				1:#rotate left
					Turntable_Global_Direction = global_direction.NORTH_ZPOS
					self.set_exitpath(NORTH_ExitPathNode,NORTH_Exit_local_orientation)
					BeltMesh.rotate_object_local(Vector3(0,1,0),PI/2)
				2:#rotate right
					Turntable_Global_Direction = global_direction.SOUTH_ZNEG
					self.set_exitpath(SOUTH_ExitPathNode,SOUTH_Exit_local_orientation)
					BeltMesh.rotate_object_local(Vector3(0,1,0),-PI/2)
		global_direction.SOUTH_ZNEG:#v
			match LRMouse:
				1:#rotate left
					Turntable_Global_Direction = global_direction.EAST_XNEG
					self.set_exitpath(EAST_ExitPathNode,EAST_Exit_local_orientation)
					BeltMesh.rotate_object_local(Vector3(0,1,0),PI/2)
				2:#rotate right
					Turntable_Global_Direction = global_direction.WEST_XPOS
					self.set_exitpath(WEST_ExitPathNode,WEST_Exit_local_orientation)
					BeltMesh.rotate_object_local(Vector3(0,1,0),-PI/2)
		global_direction.WEST_XPOS:#<
			match LRMouse:
				1:#rotate left
					Turntable_Global_Direction = global_direction.SOUTH_ZNEG
					self.set_exitpath(SOUTH_ExitPathNode,SOUTH_Exit_local_orientation)
					BeltMesh.rotate_object_local(Vector3(0,1,0),PI/2)
				2:#rotate right
					Turntable_Global_Direction = global_direction.NORTH_ZPOS
					self.set_exitpath(NORTH_ExitPathNode,NORTH_Exit_local_orientation)
					BeltMesh.rotate_object_local(Vector3(0,1,0),-PI/2)


# NORMAL INIT/INPUT/MAIN LOGIC
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
		if Lock_Rotation == false:
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT:
					if event.pressed:
						self.rotate_belt(1)
				if event.button_index == MOUSE_BUTTON_RIGHT:
					if event.pressed:
						self.rotate_belt(2)

func _physics_process(_delta):
	if Lock_Rotation == true:
		Highlight.texture = RedHighlightTexture
		#get current parent PathNode3D
		var Exiting_Object_CurrentPathNode = Exiting_ObjectNode.get_parent()
		
		#once it's on path OTHER THAN our entrance/exit path nodes, it must be on it's way. say goodbye!
		if Exiting_Object_CurrentPathNode not in [Forward_ExitPathNode, Left_ExitPathNode, Right_ExitPathNode,Rear_EntrancePathNode,Left_EntrancePathNode,Right_EntrancePathNode,null]:
			Exiting_ObjectNode=null
			Lock_Rotation = false
			Cannot_Exit_Invalid_Exit_Path = false
			
		#if object has no next path (or just an exit path), I'd like to unlock rotation so it'll kickout next valid path.. 
		elif  Exiting_ObjectNode.next_path_node == null:
			Lock_Rotation = false
			Cannot_Exit_Invalid_Exit_Path = true
			
	else:
		Highlight.texture = GreenHighlightTexture
			
	#After the lock rotation just ended, allow another object onto the belt (And Object not waiting to exit)
	if Prev_Lock_Rotation == true and Lock_Rotation == false and Cannot_Exit_Invalid_Exit_Path == false:
		Allow_Entrant = true
		
		#this is also where a delay could be added for ease of use.
		#THIS NO LONGER WORKS BECAUSE I UNLOCK ROTATION FOR NO NEXT PATH
	
	if Entry_Direction_Queue.size() > 0:
		if Allow_Entrant == true:
			#print(Entry_Direction_Queue)
			#print(Entry_Direction_Nodes)
			var Entering_Direction =Entry_Direction_Queue.pop_front()
			var Entering_Node  = Entry_Direction_Nodes.pop_front()
			Entering_Node.set_velocity(Entrant_Resume_Velocity)
			Allow_Entrant = false
			#print("ALLOW ENTRANT")
			#print(Entering_Direction)
			#print(Entering_Node)
			
			
	Prev_Lock_Rotation = Lock_Rotation
	
	
	
# GODOT SIGNALS
func _on_mouse_entered():
	Highlight.visible = true
	
func _on_mouse_exited():
	Highlight.visible = false
	
func _on_exiting_object_area_3d_area_entered(area):
		Exiting_ObjectNode = area.get_parent()
		Lock_Rotation = true
			
	#When a belt object enters this area
		#1.Get it's node
		#2 Lock Rotation
		#(Out in Monitoring Logic)
		#2 Once it's exit path becomes it's parent, then get nextpath again.
		#3 Once it's nextpath becomes it's parent forget it exists and unlock rotation
		
	#BUILD THIS NEXT
	#When objects enter the belt there needs to be an order to admit them in
	#So that the player has time to make a decision out of the possible input three objects where each should go.
	# so I need 3 different blockers, not just one.
	# I likely make up an order to admit each object, and still allow for rotation during the entry path
	# may need a speed override if that decision is far too fast for normal reflexes.
	
	
	#OKAY.. SOMETHING I SHOULD'VE KNOWN BETTER.
	# Collisions act weird whenever jumping from belt to belt. 
	#so when the object finally enters the turntable it registers as entering the 
	#speed override area again. I'll resize the areas to solve this.
func _on_north_speed_override_area_entered(area):
	if Turntable_Global_Direction != global_direction.NORTH_ZPOS:
		if area.is_in_group("OnBeltObjects"):
			Entry_Direction_Queue.push_back(global_direction.NORTH_ZPOS)
			var north_entrant = area.get_parent()
			Entry_Direction_Nodes.push_back(north_entrant)
			north_entrant.set_velocity(0.0)
		
func _on_east_speed_override_area_entered(area):
	if Turntable_Global_Direction != global_direction.EAST_XNEG:
		if area.is_in_group("OnBeltObjects"):
			Entry_Direction_Queue.push_back(global_direction.EAST_XNEG)
			var east_entrant = area.get_parent()
			Entry_Direction_Nodes.push_back(east_entrant)
			east_entrant.set_velocity(0.0)

func _on_south_speed_override_area_entered(area):
	if Turntable_Global_Direction != global_direction.SOUTH_ZNEG:
		if area.is_in_group("OnBeltObjects"):
			Entry_Direction_Queue.push_back(global_direction.SOUTH_ZNEG)
			var south_entrant = area.get_parent()
			Entry_Direction_Nodes.push_back(south_entrant)
			south_entrant.set_velocity(0.0)

func _on_west_speed_override_area_entered(area):
	if Turntable_Global_Direction != global_direction.WEST_XPOS:
		if area.is_in_group("OnBeltObjects"):
			Entry_Direction_Queue.push_back(global_direction.WEST_XPOS)
			var west_entrant = area.get_parent()
			Entry_Direction_Nodes.push_back(west_entrant)
			west_entrant.set_velocity(0.0)

	

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
