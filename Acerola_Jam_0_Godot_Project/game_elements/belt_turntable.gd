extends StaticBody3D
class_name Belt_Turntable_Path3D

@onready var Highlight = $Mouseover_Highlight
var GreenHighlightTexture:Texture2D = load("res://2D_Media/Sprites/Mouseover_Highlight_V0_Green.png")
var RedHighlightTexture:Texture2D = load("res://2D_Media/Sprites/Mouseover_Highlight_V0_Red.png")

@onready var BeltMesh = $MeshInstance3D

@onready var North_Enter_Gate = $Entrance_Gates_Shutes/North_Enter_Gate
@onready var North_Enter_Shute = $Entrance_Gates_Shutes/North_Enter_Shute
@onready var East_Enter_Gate = $Entrance_Gates_Shutes/East_Enter_Gate
@onready var East_Enter_Shute = $Entrance_Gates_Shutes/East_Enter_Shute
@onready var South_Enter_Gate = $Entrance_Gates_Shutes/South_Enter_Gate
@onready var South_Enter_Shute = $Entrance_Gates_Shutes/South_Enter_Shute
@onready var West_Enter_Gate = $Entrance_Gates_Shutes/West_Enter_Gate
@onready var West_Enter_Shute = $Entrance_Gates_Shutes/West_Enter_Shute

@onready var North_Exit_Shute = $Exit_Shutes/North_Exit_Shute
@onready var East_Exit_Shute = $Exit_Shutes/East_Exit_Shute
@onready var South_Exit_Shute = $Exit_Shutes/South_Exit_Shute
@onready var West_Exit_Shute = $Exit_Shutes/West_Exit_Shute

@onready var Rear_Thru_Path = $MeshInstance3D/Thru_Paths/Rear_Thru_Path
@onready var Right_Thru_Path = $MeshInstance3D/Thru_Paths/Right_Thru_Path
@onready var Left_Thru_Path = $MeshInstance3D/Thru_Paths/Left_Thru_Path

enum global_direction {NORTH_ZPOS, EAST_XNEG, SOUTH_ZNEG, WEST_XPOS }

@export var Turntable_Global_Direction:global_direction
@export var NORTH_Destination:Path3D=null
@export var EAST_Destination:Path3D=null
@export var SOUTH_Destination:Path3D=null
@export var WEST_Destination:Path3D=null

var Exiting_ObjectNode:Node3D=null

var Entry_Direction_Queue = []
var Entrant_Object:Node=null
var Entrant_Direction:global_direction
var Latch_Gate=true

# HELPER FUNCTIONS
func set_thrupaths_exit_shute(Exit_Shute:Path3D):
	#if there's nowhere to exit.. don't allow the object to leave entrance path
	#Set the Exit_Shute to null, objects will halt at the end of the Thru
	Rear_Thru_Path.set_exit_path_node(Exit_Shute)
	Left_Thru_Path.set_exit_path_node(Exit_Shute)
	Right_Thru_Path.set_exit_path_node(Exit_Shute)
	
func set_enter_shutes_thru_paths_exit_shutes(current_direction:global_direction):
	match Turntable_Global_Direction:
		global_direction.NORTH_ZPOS:#^
			North_Enter_Shute.set_exit_path_node(null)
			East_Enter_Shute.set_exit_path_node(Right_Thru_Path)
			South_Enter_Shute.set_exit_path_node(Left_Thru_Path)
			West_Enter_Shute.set_exit_path_node(Rear_Thru_Path)
			if NORTH_Destination != null:
				set_thrupaths_exit_shute(North_Exit_Shute)
			else:
				set_thrupaths_exit_shute(null)
		global_direction.EAST_XNEG:#>
			North_Enter_Shute.set_exit_path_node(Left_Thru_Path)
			East_Enter_Shute.set_exit_path_node(Rear_Thru_Path)
			South_Enter_Shute.set_exit_path_node(Right_Thru_Path)
			West_Enter_Shute.set_exit_path_node(null)
			if EAST_Destination != null:
				set_thrupaths_exit_shute(East_Exit_Shute)
			else:
				set_thrupaths_exit_shute(null)
		global_direction.SOUTH_ZNEG:#v
			North_Enter_Shute.set_exit_path_node(Rear_Thru_Path)
			East_Enter_Shute.set_exit_path_node(Left_Thru_Path)
			South_Enter_Shute.set_exit_path_node(null)
			West_Enter_Shute.set_exit_path_node(Right_Thru_Path)
			if SOUTH_Destination != null:
				set_thrupaths_exit_shute(South_Exit_Shute)
			else:
				set_thrupaths_exit_shute(null)
		global_direction.WEST_XPOS:#<
			North_Enter_Shute.set_exit_path_node(Right_Thru_Path)
			East_Enter_Shute.set_exit_path_node(null)
			South_Enter_Shute.set_exit_path_node(Rear_Thru_Path)
			West_Enter_Shute.set_exit_path_node(Left_Thru_Path)
			if WEST_Destination != null:
				set_thrupaths_exit_shute(West_Exit_Shute)
			else:
				set_thrupaths_exit_shute(null)


#func animate_rotate(rotate_from:global_direction, rotate_to:global_direction):

func rotate_belt(LRMouse:int)->void:
	#rotate belt model and set Turntable_Global_Direction for proper input directions
	match Turntable_Global_Direction:
		global_direction.NORTH_ZPOS:#^
			match LRMouse:
				1:#rotate left
					Turntable_Global_Direction = global_direction.WEST_XPOS
					BeltMesh.rotate_object_local(Vector3(0,1,0),PI/2)
				2:#rotate right
					Turntable_Global_Direction = global_direction.EAST_XNEG
					BeltMesh.rotate_object_local(Vector3(0,1,0),-PI/2)
		global_direction.EAST_XNEG:#>
			match LRMouse:
				1:#rotate left
					Turntable_Global_Direction = global_direction.NORTH_ZPOS
					BeltMesh.rotate_object_local(Vector3(0,1,0),PI/2)
				2:#rotate right
					Turntable_Global_Direction = global_direction.SOUTH_ZNEG
					BeltMesh.rotate_object_local(Vector3(0,1,0),-PI/2)
		global_direction.SOUTH_ZNEG:#v
			match LRMouse:
				1:#rotate left
					Turntable_Global_Direction = global_direction.EAST_XNEG
					BeltMesh.rotate_object_local(Vector3(0,1,0),PI/2)
				2:#rotate right
					Turntable_Global_Direction = global_direction.WEST_XPOS
					BeltMesh.rotate_object_local(Vector3(0,1,0),-PI/2)
		global_direction.WEST_XPOS:#<
			match LRMouse:
				1:#rotate left
					Turntable_Global_Direction = global_direction.SOUTH_ZNEG
					BeltMesh.rotate_object_local(Vector3(0,1,0),PI/2)
				2:#rotate right
					Turntable_Global_Direction = global_direction.NORTH_ZPOS
					BeltMesh.rotate_object_local(Vector3(0,1,0),-PI/2)
	#Update all Enter_Shutes -> Thru_Paths -> Exit_Shutes with new Turntable Global Direction
	set_enter_shutes_thru_paths_exit_shutes(Turntable_Global_Direction)


# NORMAL INIT/INPUT/MAIN LOGIC
func _ready():
	#set initial parameters
	set_enter_shutes_thru_paths_exit_shutes(Turntable_Global_Direction)
	#Set Exit Shutes Destinations
	if NORTH_Destination != null:
		North_Exit_Shute.set_exit_path_node(NORTH_Destination)
	else:
		North_Exit_Shute.set_exit_path_node(null)
		
	if EAST_Destination != null:
		East_Exit_Shute.set_exit_path_node(EAST_Destination)
	else:
		East_Exit_Shute.set_exit_path_node(null)
		
	if SOUTH_Destination != null:
		South_Exit_Shute.set_exit_path_node(SOUTH_Destination)
	else:
		South_Exit_Shute.set_exit_path_node(null)

	if WEST_Destination != null:
		West_Exit_Shute.set_exit_path_node(WEST_Destination)
	else:
		West_Exit_Shute.set_exit_path_node(null)
		
	Highlight.texture = GreenHighlightTexture #REPLACE THIS IF THE LOCK ROTATION IS NOT NEEDED.

func _input(event):
	if Highlight.visible == true: #mouseover is occuring
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					self.rotate_belt(1)
			if event.button_index == MOUSE_BUTTON_RIGHT:
				if event.pressed:
					self.rotate_belt(2)

func monitor_path_node_for_child(PathNode:Path3D):
	if PathNode.get_child_count() > 0:
		return PathNode.get_child(0)  #Paths designed so there should only be one child at a time in Gate.
	else:
		return null

func _physics_process(_delta):
	#There is no Object Traversing the Turntable
	if Entrant_Object == null:
		#Something is Queued
		if Entry_Direction_Queue.size() > 0:
			#Monitor until something enters the gate or is in queue
			match Entry_Direction_Queue[0]:
				global_direction.NORTH_ZPOS:#^
					Entrant_Object = monitor_path_node_for_child(North_Enter_Gate)
				global_direction.EAST_XNEG:#>
					Entrant_Object = monitor_path_node_for_child(East_Enter_Gate)
				global_direction.SOUTH_ZNEG:#v
					Entrant_Object = monitor_path_node_for_child(South_Enter_Gate)
				global_direction.WEST_XPOS:#<
					Entrant_Object = monitor_path_node_for_child(West_Enter_Gate)
					
			if Entrant_Object != null:
				Entrant_Direction = Entry_Direction_Queue.pop_front()
				
				#Now, we need to set the gate's next path to it's entry shute
				#(And Reset it To null as soon as the object enters the shute)
				match Entrant_Direction:
					global_direction.NORTH_ZPOS:#^
						North_Enter_Gate.set_exit_path_node(North_Enter_Shute)
					global_direction.EAST_XNEG:#>
						East_Enter_Gate.set_exit_path_node(East_Enter_Shute)
					global_direction.SOUTH_ZNEG:#v
						South_Enter_Gate.set_exit_path_node(South_Enter_Shute)
					global_direction.WEST_XPOS:#<
						West_Enter_Gate.set_exit_path_node(West_Enter_Shute)
				Latch_Gate = false
				#print("OBJECT ENTERED")
				#print(Entrant_Object)
				#print(Entrant_Direction)

	else:
		#Entrant_Object is Known;    once Entrant_Object is null, queue will open again.
		#Entrant_Direction is known
		#Entrant_Object should be headed towards it's Entry Shute; 
		
		#RESET GATE_NEXT_PATH TO NULL AS SOON AS THE OBJECT ENTERS THE ENTER_SHUTE, OTHERWISE THE GATE WONT HOLD.
		if Latch_Gate == false:
			match Entrant_Direction:
				global_direction.NORTH_ZPOS:#^
					var monitor_not_null = monitor_path_node_for_child(North_Enter_Shute)
					if monitor_not_null != null:
						North_Enter_Gate.set_exit_path_node(null)
						Latch_Gate = true
						#print("Gate Latched!")
				global_direction.EAST_XNEG:#>
					var monitor_not_null = monitor_path_node_for_child(East_Enter_Shute)
					if monitor_not_null != null:
						East_Enter_Gate.set_exit_path_node(null)
						Latch_Gate = true
						#print("Gate Latched!")
				global_direction.SOUTH_ZNEG:#v
					var monitor_not_null = monitor_path_node_for_child(South_Enter_Shute)
					if monitor_not_null != null:
						South_Enter_Gate.set_exit_path_node(null)
						Latch_Gate = true
						#print("Gate Latched!")
				global_direction.WEST_XPOS:#<
					var monitor_not_null = monitor_path_node_for_child(West_Enter_Shute)
					if monitor_not_null != null:
						West_Enter_Gate.set_exit_path_node(null)
						Latch_Gate = true
						#print("Gate Latched!")
		else:
			#If Entry Shutes are updated upon rotation correctly it'll also be on it's way to a Thru Path;
			#If Thru Paths are updated correctly it should be on it's way to the Exit Shute;
			
			#monitor the (not null-leading) Exit Shutes, as soon as one of them contains the Entrant Object we should be clear 
			#to allow a new entrant.
			#i'm leaving it up to null path logic to make sure that the object can't leave improperly
			if NORTH_Destination !=null:
				var monitor_not_null = monitor_path_node_for_child(North_Exit_Shute)
				if monitor_not_null != null:
					Entrant_Object = null #goodbye! 
					#print("Goodbye!")
			if EAST_Destination !=null:
				var monitor_not_null = monitor_path_node_for_child(East_Exit_Shute)
				if monitor_not_null != null:
					Entrant_Object = null #goodbye! 
					#print("Goodbye!")
			if SOUTH_Destination != null:
				var monitor_not_null = monitor_path_node_for_child(South_Exit_Shute)
				if monitor_not_null != null:
					Entrant_Object = null #goodbye! 
					#print("Goodbye!")
			if WEST_Destination != null:
				var monitor_not_null = monitor_path_node_for_child(West_Exit_Shute)
				if monitor_not_null != null:
					Entrant_Object = null #goodbye! 
					#print("Goodbye!")



# GODOT SIGNALS
func _on_mouse_entered():
	Highlight.visible = true
	
func _on_mouse_exited():
	Highlight.visible = false

func get_turntable_entrance(Incoming_Obj_Global_Direction:global_direction):
#provide incoming objects which enter path to take.
#push to queue, which direction to search for incoming nodes
	var EntrancePathNode:Path3D=null
	match Incoming_Obj_Global_Direction:
			global_direction.NORTH_ZPOS:
				EntrancePathNode=North_Enter_Gate
				Entry_Direction_Queue.push_back(global_direction.NORTH_ZPOS)
			global_direction.EAST_XNEG:
				EntrancePathNode=East_Enter_Gate
				Entry_Direction_Queue.push_back(global_direction.EAST_XNEG)
			global_direction.SOUTH_ZNEG:
				EntrancePathNode=South_Enter_Gate
				Entry_Direction_Queue.push_back(global_direction.SOUTH_ZNEG)
			global_direction.WEST_XPOS:
				EntrancePathNode=West_Enter_Gate
				Entry_Direction_Queue.push_back(global_direction.WEST_XPOS)
	return EntrancePathNode




