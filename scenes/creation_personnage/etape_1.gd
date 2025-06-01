extends Control

@onready var fichier_a_ouvrir = $Ouverture
#fichier_a_ouvrir.connect("file_selected", self, "_on_file_selected")

func _on_file_selected(path):
	print("Fichier sélectionné :", path)


func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/ecran_titre.tscn")


func _on_fichier_pressed() -> void:
	print("On désire ouvrir un fichier.")
	fichier_a_ouvrir.popup()
