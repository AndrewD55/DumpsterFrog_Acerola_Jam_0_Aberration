extends Node3D
class_name On_Belt_Object

enum enum_belt_object_type {UNDEF, RAW, REFINED, DEFECT}

@export var initial_object_type:enum_belt_object_type=enum_belt_object_type.UNDEF
@export var initial_velocity:float=0.0
@export var follow_collision_distance:float=0.75
var move_velocity:float

var belt_object_type:enum_belt_object_type=initial_object_type
var next_path_node:Node=null

var Colliding_ObjectNode:Node
var Colliding_ObjectNode_Current_Path:Node

var manage_collision:bool=false

func _ready():
	#assuming this is my Linked_Path3D, get the next_path_node now.
	next_path_node = get_parent().get_exit_path_node()
	#make sure the object doesn't return to the start of the belt segment
	self.loop = false 
	move_velocity=initial_velocity

func _physics_process(delta):
	if manage_collision == true:
		var Collision_Distance:float = 0.0
		var Ahead_of_Collision:bool=false
		##if both objects are on the same belt.
		#if Colliding_ObjectNode_Current_Path == self.get_parent():
#
			#Collision_Distance = self.progress - Colliding_ObjectNode.progress
			#print("Collided with Object on Same Belt")
			#print(Colliding_ObjectNode_Current_Path)
			#print(Colliding_ObjectNode.progress)
			#print(self.get_parent())
			#print(self.progress)
		##if object is one the belt ahead
		#elif Colliding_ObjectNode_Current_Path == next_path_node: 
			#var our_path_length = self.progress/self.progress_ratio
			##their_path_length = Colliding_ObjectNode.progress/Colliding_ObjectNode.progress_ratio
			#Collision_Distance = -(our_path_length-self.progress) - Colliding_ObjectNode.progress
			#print("Collided with Object on Next Belt")
		##if object is one the belt behind
		#elif Colliding_ObjectNode_Current_Path.get_exit_path_node() == self.get_parent():
			#var their_path_length = Colliding_ObjectNode.progress/Colliding_ObjectNode.progress_ratio
			#Collision_Distance = (their_path_length-Colliding_ObjectNode.progress) + self.progress
			#print("Collided with Object on Previous Belt")
		#else:
		print("Collided with Object")
			#I could use a physical distance? 
			# STILL NEED TO GET DIRECTION SOMEHOW USING THAT DIRECTION VECTOR LOGIC.. 
			#otherwise this got too complext to work every time since next path node is usually assigned later
			
		var Collision_Direction = Colliding_ObjectNode.global_transform.origin - self.global_transform.origin
		if Collision_Direction.dot(Colliding_ObjectNode.basis.z) < 0:
			Ahead_of_Collision = true
		print(Collision_Direction)
		
		Collision_Distance = Colliding_ObjectNode.global_transform.origin.distance_to(self.global_transform.origin)

#GETTING STUCK SOMEWHERE AND IM NOT SURE WHY

		print(Collision_Distance)
		#if Collision_Distance < 0.0: #we are behind
		if Ahead_of_Collision == false: #we are behind
			move_velocity = 0.0
			if Collision_Distance > follow_collision_distance:
				print("FAR ENOUGH TO START AGAIN")
				move_velocity = initial_velocity
				manage_collision = false
				#Colliding_ObjectNode = null
				#Colliding_ObjectNode_Current_Path = null

		#elif Collision_Distance > 0.0: # we are in front
		elif Ahead_of_Collision == true: # we are in front
			manage_collision = false
			#Colliding_ObjectNode = null
			#Colliding_ObjectNode_Current_Path = null
	
	self.progress += move_velocity*delta

	#at end of path, reparent and get next planned parent
	if self.progress_ratio == 1.0:
		if next_path_node != null:
			#once just in case the next_path_node has changed.
			next_path_node = get_parent().get_exit_path_node()
			self.reparent(next_path_node)
			self.progress_ratio = 0.0
		else:
			initial_velocity = 0
			#stop for now?
			#eventually I'd like the object to just limply fall


# TRY COMPARING DISTANCE ON THE BELT.
# OR IF ON DIFFERENT BELTS SEE IF IT'S ON YOUR NEXT BELT, LET IT GO.

# THIS SHOULD BE A MORE DISCRETE WAY TO SOLVE THE ISSUE WITHOUT GETTING INTO REAL-WORLD COORDINATES.

func _on_area_3d_area_entered(area):
	#handle collisions with other objects.  Should be rare, but possible
	if area.is_in_group("OnBeltObjects"):
		Colliding_ObjectNode = area.get_parent()
		Colliding_ObjectNode_Current_Path = Colliding_ObjectNode.get_parent()
		manage_collision = true
