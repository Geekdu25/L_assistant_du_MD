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
			lbl.text = "%d - %s :\n%s" % [capacite.get("niveau", 0), capacite.get("nom", ""), capacite.get("description", "")]
			lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			conteneur.add_child(lbl)
			if capacite.has("type") and capacite.type == "choix":
				var opt_button = OptionButton.new()
				for opt in capacite.options:
					opt_button.add_item(opt.get("nom", ""))
				# Teste la présence de la propriété sans utiliser .has()
				if "sous_classe" in CurrentPersonnage and CurrentPersonnage.sous_classe != "":
					var idx = -1
					for i in capacite.options.size():
						if capacite.options[i].nom == CurrentPersonnage.sous_classe:
							idx = i
							break
					if idx >= 0:
						opt_button.selected = idx
				opt_button.connect("item_selected", Callable(self, "_on_sous_classe_selected").bind(capacite))
				conteneur.add_child(opt_button)
	# Force la largeur après ajout pour que les labels prennent toute la place
	call_deferred("_resize_labels")

func _resize_labels():
	var width = conteneur.size.x
	for child in conteneur.get_children():
		if child is Label:
			child.custom_minimum_size = Vector2(width, 0)

func clear_container(container):
	for child in container.get_children():
		child.queue_free()

func _on_sous_classe_selected(index, capacite):
	var sous_classe = capacite.options[index].nom
	CurrentPersonnage.sous_classe = sous_classe
	# Optionnel : affiche la description
	var desc = capacite.options[index].description
	var desc_label = Label.new()
	desc_label.text = desc
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	conteneur.add_child(desc_label)


func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/etape_5.tscn")
