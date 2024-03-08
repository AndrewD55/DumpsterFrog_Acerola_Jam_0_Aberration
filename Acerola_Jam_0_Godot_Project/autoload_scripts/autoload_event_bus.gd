extends Node

#Credit to Reddit user Games2See for general event bus design
#https://www.reddit.com/r/godot/comments/131s509/comment/k1f1pcn/

#Reddit user 20millimiter quote:
#(use) Signals for communication between nodes in a single scene, 
#(use) Event System for communication between scenes.

class_name EventBus
static var events_on_bus: Dictionary = {}

static func create_event(event_id, method_bind) -> void:
	if !events_on_bus.has(event_id):
		events_on_bus[event_id] = []
	events_on_bus[event_id].append(method_bind)

static func trigger_event(event_id, event_data) -> void:
	if events_on_bus.has(event_id):
		for method_binds in events_on_bus[event_id]:
			method_binds.call(event_data)

static func remove_event(event_id) -> void:
	if events_on_bus.has(event_id):
		events_on_bus.erase(event_id)
		
static func clear_all_events_on_bus() -> void:
	events_on_bus.clear()

func print_all_events_on_bus() -> void:
	print("--PRINT EVENT BUS--")
	print(events_on_bus)
