extends Control

@onready var Dialog_Text = $HBoxContainer/Dialog_Text_Label

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

			
			
		
		
		
	
	
func display_text_sequential(sequential_text:String):
	sequential_text_flag = true
	for character in sequential_text:
		sequential_text_char_array.append(character)
	
	

	
func  clear_text():
	Dialog_Text.text = ""
