extends Control

func _ready():
	var nombres_generes = Utils.genere_caracteristiques()

func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/etape_4.tscn")
