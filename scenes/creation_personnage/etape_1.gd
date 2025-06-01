extends Control

@onready var fichier_a_ouvrir = $Ouverture

func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/ecran_titre.tscn")


func _on_fichier_pressed() -> void:
	print("On désire ouvrir un fichier.")
	fichier_a_ouvrir.title = "Ouvrir un fichier..."
	fichier_a_ouvrir.add_filter("*.xml", "Fichiers eXtensible Markup Language")
