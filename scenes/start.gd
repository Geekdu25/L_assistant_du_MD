extends Control

@onready var musique = $musique

func _ready() -> void:
	musique.disabled = (not Utils.mpv)

func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/ecran_titre.tscn")

func _on_musique_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/musique.tscn")


func _on_personnage_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/etape_1.tscn")
