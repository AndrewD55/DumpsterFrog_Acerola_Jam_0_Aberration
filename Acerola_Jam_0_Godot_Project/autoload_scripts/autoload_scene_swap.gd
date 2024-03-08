extends Node

#Credit to Godot Documentation
#https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html

var current_scene = null

func _ready() -> void:
	#reminder: root is the main viewport
	var root = get_tree().root # Access via scene main loop.
			#get_node("/root") # Access via absolute path
	current_scene = root.get_child(root.get_child_count()-1)
	
	
#for swapping small scenes
func swap_small_scene(small_scene_path) -> void:
	#wait to call until current scene has stopped running
	call_deferred("_deferred_swap_small_scene", small_scene_path)

func _deferred_swap_small_scene(small_scene_path):
	current_scene.free()
	var s = ResourceLoader.load(small_scene_path)
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene



#for swapping large scenes
func large_scene_preload(large_scene_path) -> void:
	ResourceLoader.load_threaded_request(large_scene_path)

#for swapping large scenes, (DISPLAY LOADING SCREEN BEFORE THIS CALL)
func swap_large_scene(large_scene_path) -> void:
	#wait to call until current scene has stopped running
	call_deferred("_deferred_swap_large_scene", large_scene_path)

func _deferred_swap_large_scene(large_scene_path) -> void:
	current_scene.free()
	var s = ResourceLoader.load_threaded_get(large_scene_path)
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene






#Decided to ignore hibernated scenes for now.. 
#Unlikely to swap main scene in tree fast enough for that to matter.
#func remove_scene(rm_scene, rm_type):
	##rm_type=0 : "delete scene"
	##rm_type=1 : "hide scene"
	##rm_type=2 : "hibernate scene"
	#if   rm_type == 0:
		##completely remove current scene
		#rm_scene.free()
	#elif rm_type == 1:
		##only hide current scene, still exists just hidden from viewport
		#rm_scene.visible = false  #no idea if this will always work
	#elif rm_type == 2:
		##remove scene from tree, still exists in memory, no updates
		#var hiber_scene = rm_scene
		#hibernated_scenes.append(hiber_scene)
		#rm_scene.remove_child(rm_scene)
