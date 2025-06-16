extends Control

@onready var conteneur = $Panel/scrolleur/conteneur_infos

func _ready() -> void:
	clear_container(conteneur)
	var classes = Utils.charger_tout("classes")
	var capacites := []
	var niveau = CurrentPersonnage.niveau

	# Trouver la classe du personnage
	for classe in classes:
		if classe.get("nom") == CurrentPersonnage.classe:
			capacites = classe.get("capacites_classe", [])

	# Afficher les capacités pour le niveau choisi
	for capacite in capacites:
		if capacite.get("niveau", 0) <= niveau:
			var lbl = Label.new()
			lbl.text = "Niveau %d - %s :\n%s" % [capacite.get("niveau", 0), capacite.get("nom", ""), capacite.get("description", "")]
			lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # <-- Ajouté
			conteneur.add_child(lbl)
			if capacite.has("options"):
				for opt in capacite.options:
					var opt_lbl = Label.new()
					opt_lbl.text = "    • %s : %s" % [opt.get("nom", ""), opt.get("description", "")]
					opt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
					opt_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # <-- Ajouté
					conteneur.add_child(opt_lbl)

func clear_container(container):
	for child in container.get_children():
		child.queue_free()

func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/etape_5.tscn")
