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


enum enum_collision_order {UNDEF, AHEAD, BEHIND}
var Collision_Order:enum_collision_order=enum_collision_order.UNDEF

func _physics_process(delta):
	if manage_collision == true:
		var Collision_Distance:float = 0.0
		

		if Collision_Order == enum_collision_order.UNDEF:
			#get other collider's direction relative to my local Z+ axis
			var Collision_Position_Difference = Colliding_ObjectNode.global_transform.origin - self.global_transform.origin
			var Collision_Direction = Collision_Position_Difference.dot(Colliding_ObjectNode.basis.z)
			if Collision_Direction < 0.3:
				Collision_Order = enum_collision_order.AHEAD
			else:
				Collision_Order = enum_collision_order.BEHIND
			print(Collision_Direction)
			
		#get distance between this collider's origin and the other collider
		Collision_Distance = Colliding_ObjectNode.global_transform.origin.distance_to(self.global_transform.origin)

		#if this is the collider behind another object, delay until enough distance is in between
		if Collision_Order == enum_collision_order.BEHIND: #we are behind
			move_velocity = 0.0
			if Collision_Distance > follow_collision_distance:
				move_velocity = initial_velocity
				manage_collision = false
				Collision_Order = enum_collision_order.UNDEF
		#if this is the collider ahead of another object, carry on
		elif Collision_Order == enum_collision_order.AHEAD: 
			manage_collision = false
			Collision_Order = enum_collision_order.UNDEF

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
			initial_velocity = 0
			next_path_node = get_parent().get_exit_path_node()
			#stop for now?
			#eventually I'd like the object to just limply fall

func _on_area_3d_area_entered(area):
	#handle collisions with other objects.  Should be rare, but possible
	if area.is_in_group("OnBeltObjects"):
		Colliding_ObjectNode = area.get_parent()
		manage_collision = true
