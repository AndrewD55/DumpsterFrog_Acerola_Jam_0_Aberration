extends Node3D
class_name On_Belt_Object

@onready var FrontBumper = $Area3D/Front_Bumper
@onready var BackBumper = $Area3D/Back_Bumper

enum enum_belt_object_type {UNDEF, RAW, REFINED, DEFECT}
@export var initial_object_type:enum_belt_object_type=enum_belt_object_type.UNDEF
@export var initial_velocity:float=0.0
@export var follow_collision_distance:float=0.75
var move_velocity:float

var belt_object_type:enum_belt_object_type=initial_object_type
var next_path_node:Node=null

var Ahead_Colliding_ObjectNode:Node=null

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
		move_velocity = Ahead_Colliding_ObjectNode.get_velocity()
		#get distance between this collider's origin and the other collider
		var Ahead_Collision_Distance:float = 0.0
		Ahead_Collision_Distance = Ahead_Colliding_ObjectNode.global_transform.origin.distance_to(self.global_transform.origin)
		#once the Ahead object gets far enough away, go to full velocity and forget who's ahead
		if Ahead_Collision_Distance > follow_collision_distance:
			print("Goodbye Collided Object")
			move_velocity = initial_velocity
			Ahead_Colliding_ObjectNode = null

	#at end of path, reparent and get next planned parent
	if self.progress_ratio == 1.0:
		next_path_node = get_parent().get_exit_path_node()
		if next_path_node != null:
			self.reparent(next_path_node)
			self.progress_ratio = 0.0
		else:
			move_velocity = 0.0  
			#stop for now?
	
	#Move
	self.progress += move_velocity*delta

func _on_area_3d_area_entered(area):
	#handle collisions with other objects.  Should be rare, but possible
	if area.is_in_group("OnBeltObjects"):
		var Colliding_ObjectNode = area.get_parent()
		var Distance_to_FrontBumper = Colliding_ObjectNode.global_transform.origin.distance_to(FrontBumper.global_transform.origin)
		var Distance_to_BackBumper = Colliding_ObjectNode.global_transform.origin.distance_to(BackBumper.global_transform.origin)
		
		if Distance_to_FrontBumper < Distance_to_BackBumper:
			Ahead_Colliding_ObjectNode = Colliding_ObjectNode

#func _on_area_3d_area_exited(area):
	#pass # Replace with function body.
