extends Node

@onready var page_holder = get_node("PageHolder")
var current_page: Node = null

func _ready():
	change_page("res://scenes/ecran_titre.tscn")
	MusicController.play_music("res://assets/sounds/temporaire.ogg")
	GestionDesDossiers.verifie_dossiers(get_tree().current_scene)

func change_page(page_path: String):
	if current_page:
		for child in page_holder.get_children():
			page_holder.remove_child(child)
			child.queue_free()
	var scene = load(page_path)
	current_page = scene.instantiate()
	page_holder.add_child(current_page)
