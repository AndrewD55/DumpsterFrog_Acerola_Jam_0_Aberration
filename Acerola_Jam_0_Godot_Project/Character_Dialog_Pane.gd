extends Control

@onready var Dialog_Text = $TextureRect/Dialog_Text_Label_Container/Dialog_Text_Label
@onready var Inspector_Animated_Sprite = $TextureRect/Portrait_Container/Sprite2D

@export var Character_Delay_Seconds:float = 0.25


var sequential_text_flag = false
var sequential_text_char_array = []
var time:float=0.0 
var next_character_time:float=0.0


func _physics_process(delta):
	time += delta
	
	if sequential_text_flag == true:	
			if sequential_text_char_array.size() > 0:
				if time > next_character_time:
					next_character_time = time+Character_Delay_Seconds
				
					var character = sequential_text_char_array.pop_front()
					Dialog_Text.text += character
					#play character voice sound?


func display_text_sequential(sequential_text:String, character_delay_seconds:float):
	sequential_text_flag = true
	self.clear_text()
	Character_Delay_Seconds = character_delay_seconds
	for character in sequential_text:
		sequential_text_char_array.append(character)
	
func clear_text():
	sequential_text_char_array = []
	Dialog_Text.text = ""
	
	
func change_inspector_face(frame_num:int):
	Inspector_Animated_Sprite.frame = frame_num
