extends Control

@onready var conteneur = $Panel/scrolleur/conteneur_infos

func _ready() -> void:
	var classes = Utils.charger_tout("classes")
	var sa_classe := {}
	for classe in classes:
		if classe.get("nom") == CurrentPersonnage.classe:
			sa_classe = classe.get("capacites_classes")
	for capacite in sa_classe:
		print(capacite)

func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/etape_5.tscn")
