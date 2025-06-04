extends Control

@onready var fichier_a_ouvrir = $FileDialog
var mode = ""

func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/etape_1.tscn")

func _on_files_selected(paths: PackedStringArray) -> void:
	for file in paths:
		var special_path = "/" + file.get_file() # Récupère juste le nom du fichier
		special_path = mode + special_path
		Utils.copy_file(file, "user://" + special_path)

func _on_races_pressed() -> void:
	mode = "races"
	fichier_a_ouvrir.popup()

func _on_classes_pressed() -> void:
	mode = "classes"
	fichier_a_ouvrir.popup()

func _on_historiques_pressed() -> void:
	mode = "historiques"
	fichier_a_ouvrir.popup()
