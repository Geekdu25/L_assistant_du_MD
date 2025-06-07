extends Control

@onready var classes_list_vbox = $Conteneur_d_historiques/Scrolleur/Conteneur
@onready var details_panel = $Conteneur_d_historiques/Panneau
@onready var name_label = $Conteneur_d_historiques/Panneau/VBoxContainer/HistoName
@onready var desc_label = $Conteneur_d_historiques/Panneau/VBoxContainer/HistoDesc
@onready var comp_label = $Conteneur_d_historiques/Panneau/VBoxContainer/HistoComp
@onready var lang_label = $Conteneur_d_historiques/Panneau/VBoxContainer/HistoLangues
@onready var money_label = $Conteneur_d_historiques/Panneau/VBoxContainer/HistoAr
@onready var aptitudes_label = $Conteneur_d_historiques/Panneau/VBoxContainer/HistoAp

var historiques = []

func _ready():
	historiques = Utils.charger_tout("historiques")
	populate_historiques_list()
	if historiques.size() > 0:
		_on_historique_selected(historiques[0])


func populate_historiques_list():
	Utils.clear_vbox(classes_list_vbox)
	for historique in historiques:
		var btn = Button.new()
		btn.text = historique["nom"]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.connect("pressed", Callable(self, "_on_classe_selected").bind(historique))
		classes_list_vbox.add_child(btn)

func _on_historique_selected(historique):
	var string_bonus = ""
	name_label.text = historique["nom"]
	if len(historique["description"]) == 0:
		desc_label.text = "Aucune description n'a été ajoutée à cette classe."
	else:
		desc_label.text = historique["description"]
	for comp in historique["competences"]:
		string_bonus += "- " + comp + "\n"
	comp_label.text = "Compétences données : \n" + string_bonus
	string_bonus = ""
	lang_label.text = "Langues supplémentaires : " + str(int(historique["langues_supplementaires"]))
	money_label.text = "Argent de départ : " + str(int(historique["fonds"])) + "po."
	for comp in historique["aptitude"]:
		string_bonus += "- " + comp + "\n"
	aptitudes_label.text = "Aptitudes : \n" + string_bonus

func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/etape_3.tscn")
