extends Node3D
class_name On_Belt_Object

@onready var FrontBumper = $Area3D/Front_Bumper
@onready var BackBumper = $Area3D/Back_Bumper

enum enum_belt_object_type {REFINED, DEFECT}

var Good_Product = preload("res://3D_Media/Good_Product/Good_Donut_V0.glb").instantiate()
var Bad_Product = preload("res://3D_Media/Bad_Product/Bad_Donut_V0.glb").instantiate()

@export var initial_object_type:enum_belt_object_type=enum_belt_object_type.REFINED
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
	
	match initial_object_type:
		enum_belt_object_type.REFINED:
			self.add_child(Good_Product)
		enum_belt_object_type.DEFECT:
			self.add_child(Bad_Product)


func _physics_process(delta):
	#at end of path, reparent and get next planned parent
	if self.progress_ratio == 1.0:
		next_path_node = get_parent().get_exit_path_node()
		if next_path_node != null:
			self.reparent(next_path_node)
			self.progress_ratio = 0.0
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
			move_velocity = 0.0
			#print("CollisionAhead")
			#print(self)
			#print(Ahead_Colliding_ObjectNode)

func _on_area_3d_area_exited(area):
	if area.is_in_group("OnBeltObjects"):
		var Exiting_ObjectNode = area.get_parent()
		if Exiting_ObjectNode == Ahead_Colliding_ObjectNode:
			Ahead_Colliding_ObjectNode = null
			move_velocity = initial_velocity
			#print("EndCollision")
			#print(self)
			#print(Ahead_Colliding_ObjectNode)
