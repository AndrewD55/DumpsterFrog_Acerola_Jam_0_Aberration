extends Node3D
class_name On_Belt_Object

enum enum_belt_object_type {UNDEF, RAW, REFINED, DEFECT}

@export var initial_object_type:enum_belt_object_type=enum_belt_object_type.UNDEF
@export var initial_velocity:float=0.0
@export var follow_collision_distance:float=0.55
var move_velocity:float

var belt_object_type:enum_belt_object_type=initial_object_type
var next_path_node:Node=null

var Ahead_Colliding_ObjectNode:Node=null
var Behind_Colliding_ObjectNode:Node=null


func get_velocity() -> float:
	return move_velocity

func set_velocity(new_velocity) -> void:
	move_velocity = new_velocity

func _ready():
	#assuming this is my Linked_Path3D, get the next_path_node now.
	#next_path_node = get_parent().get_exit_path_node()
	#make sure the object doesn't return to the start of the belt segment
	self.loop = false 
	move_velocity=initial_velocity




func _physics_process(delta):
	if Ahead_Colliding_ObjectNode !=null:
		#almost match the Ahead Colliding Object's Velocity
		move_velocity = Ahead_Colliding_ObjectNode.move_velocity
		
		#get distance between this collider's origin and the other collider
		var Ahead_Collision_Distance:float = 0.0
		Ahead_Collision_Distance = Ahead_Colliding_ObjectNode.global_transform.origin.distance_to(self.global_transform.origin)
		
		#once the Ahead object gets far enough away, go to full velocity and forget who's ahead
		if Ahead_Collision_Distance > follow_collision_distance:
			move_velocity = initial_velocity
			Ahead_Colliding_ObjectNode = null

	# JUST IGNORE OBJECTS BEHIND YOU, THEY SEE YOU IN FRONT
	#if Behind_Colliding_ObjectNode !=null:
		##get distance between this collider's origin and the other collider
		#var Behind_Collision_Distance:float = 0.0
		#Behind_Collision_Distance = Behind_Colliding_ObjectNode.global_transform.origin.distance_to(self.global_transform.origin)
		##once the Behind object gets far enough away, forget who's behind
		#if Behind_Collision_Distance > follow_collision_distance:
			#Behind_Colliding_ObjectNode = null

	self.progress += move_velocity*delta

	#at end of path, reparent and get next planned parent
	if self.progress_ratio == 1.0:
		if next_path_node != null:
			#once just in case the next_path_node has changed.
			next_path_node = get_parent().get_exit_path_node()
			if next_path_node != null:
				self.reparent(next_path_node)
				self.progress_ratio = 0.0
		else:
			initial_velocity = 0.0
			next_path_node = get_parent().get_exit_path_node()
			#stop for now?

func _on_area_3d_area_entered(area):
	#handle collisions with other objects.  Should be rare, but possible
	if area.is_in_group("OnBeltObjects"):
		var Colliding_ObjectNode = area.get_parent()
		var Collision_Position_Difference = Colliding_ObjectNode.global_transform.origin - self.global_transform.origin
		var Collision_Direction = Collision_Position_Difference.dot(Colliding_ObjectNode.basis.z)
		if Collision_Direction < 0.3:
			#Colliding_Node is Ahead
			Ahead_Colliding_ObjectNode = Colliding_ObjectNode
		#else:
			##Colliding_Node is Behind IGNORE THEM
			#Behind_Colliding_ObjectNode = Colliding_ObjectNode

#func _on_area_3d_area_exited(area):
	#pass # Replace with function body.
