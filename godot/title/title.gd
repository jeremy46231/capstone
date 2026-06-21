extends Node2D
const main = preload("res://main/main.tscn")

@onready var no_gold: Sprite2D = $Pyramidbg
@onready var gold: Sprite2D = $Pyramidbg2


func _ready() -> void:
	_update_bg()
	# keep the bg fit + centred on any viewport size / aspect ratio
	get_viewport().size_changed.connect(_fit_bg)
	_fit_bg()


# zoom the bg out so the whole image fits inside the viewport, and
# centre it; the tile layer behind fills whatever space is left over
func _fit_bg() -> void:
	var vp := get_viewport_rect().size
	for s: Sprite2D in [no_gold, gold]:
		if s.texture == null:
			continue
		var tex: Vector2 = s.texture.get_size()
		var fit := minf(vp.x / tex.x, vp.y / tex.y)
		s.scale = Vector2(fit, fit)
		s.global_position = vp * 0.5


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://main/main.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_play_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main/main.tscn")

func _update_bg() -> void:
	if  (!FileAccess.file_exists("user://savegame.save")):
		print("no file")
		no_gold.show()
		gold.hide()
	else:
		print("yes file")
		no_gold.hide()
		gold.show()
