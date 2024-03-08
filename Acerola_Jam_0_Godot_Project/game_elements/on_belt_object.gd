extends Node3D

enum enum_belt_object_type {UNDEF, RAW, REFINED, DEFECT}

@export var initial_object_type:enum_belt_object_type=enum_belt_object_type.UNDEF
@export var initial_velocity:float

var belt_object_type:enum_belt_object_type=initial_object_type
var next_path_node:Node=null

func _ready():
	
	#assuming this is my Linked_Path3D, get the next_path_node now.
	next_path_node = get_parent().get_exit_path_node()
	#make sure the object doesn't return to the start of the belt segment
	self.loop = false 




func _physics_process(delta):

	self.progress += initial_velocity*delta

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
			
