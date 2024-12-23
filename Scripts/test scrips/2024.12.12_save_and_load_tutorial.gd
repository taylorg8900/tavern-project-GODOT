extends Node2D


@onready var savebutton: Button = $CanvasLayer/VBoxContainer/savebutton
@onready var loadbutton: Button = $CanvasLayer/VBoxContainer/loadbutton

@onready var text_edit: TextEdit = $CanvasLayer/TextEdit
@onready var texture_rect: TextureRect = $CanvasLayer/TextureRect

const SAVE_FILE_PATH = "user://game_save.save"

var colors = [
	Color.WHITE,
	Color.RED,
	Color.BLUE
]
var color_index = 0

## FOR CHANGING THE WORLD
func _process(delta):
	if Input.is_action_just_pressed("ui_left"):
		color_index += 1
		color_index %= colors.size()
		update_color()
	if Input.is_action_just_pressed("ui_right"):
		texture_rect.position = get_global_mouse_position()
 
func update_color():
	texture_rect.modulate = colors[color_index]
 
## FOR SAVING AND LOADING
func _ready():
	savebutton.button_up.connect(save_game)
	loadbutton.button_up.connect(load_game)
	load_game()
 
func save_game():
	var save_data = {}
	save_data["text"] = text_edit.text
	save_data.position = var_to_str(texture_rect.position)
	save_data.color_index = color_index
 
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if save_file == null:
		print("ERROR CREATING SAVE FILE ", FileAccess.get_open_error())
		return
 
	var json_string = JSON.stringify(save_data)
	save_file.store_string(json_string)
 
func load_game():
	if !FileAccess.file_exists(SAVE_FILE_PATH):
		print("save file not found")
		return
 
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var json_string = save_file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON parse error ", json.get_error_message(), " on line ", json.get_error_line())
		return
 
	var save_data = json.get_data()
	if "text" in save_data:
		text_edit.text = save_data.text
	if "color_index" in save_data:
		color_index = int(save_data.color_index)
		update_color()
	if "position" in save_data:
		texture_rect.position = str_to_var(save_data.position)
