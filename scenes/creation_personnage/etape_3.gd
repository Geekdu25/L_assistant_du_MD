extends Control

@onready var classes_list_vbox = $Conteneur_de_classes/Scrolleur/Conteneur
@onready var details_panel = $Conteneur_de_classes/Panneau
@onready var name_label = $Conteneur_de_classes/Panneau/VBoxContainer/ClasseName
@onready var desc_label = $Conteneur_de_classes/Panneau/VBoxContainer/ClasseDesc
@onready var de_label = $Conteneur_de_classes/Panneau/VBoxContainer/ClasseDe
@onready var jds_label = $Conteneur_de_classes/Panneau/VBoxContainer/ClasseJds
@onready var competences_label = $Conteneur_de_classes/Panneau/VBoxContainer/ClasseCompetences
@onready var maitrises_label = $Conteneur_de_classes/Panneau/VBoxContainer/ClasseMaitrise

var classes = []

func _ready():
	classes = Utils.charger_tout("classes")
	populate_classes_list()
	if classes.size() > 0:
		_on_classe_selected(classes[0])

func populate_classes_list():
	Utils.clear_vbox(classes_list_vbox)
	for classe in classes:
		var btn = Button.new()
		btn.text = classe["nom"]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.connect("pressed", Callable(self, "_on_classe_selected").bind(classe))
		classes_list_vbox.add_child(btn)

func _on_classe_selected(classe):
	var string_bonus = ""
	name_label.text = classe["nom"]
	if len(classe["description"]) == 0:
		desc_label.text = "Aucune description n'a été ajoutée à cette classe."
	else:
		desc_label.text = classe["description"]
	de_label.text = "Dé de vie : 1d" + str(int(classe.get("de_vie")))
	for j in classe.get("sauvegardes"):
		string_bonus += j+"\n"
	jds_label.text = "Jets de sauvegarde : \n" + string_bonus
	string_bonus = ""
	for j in classe.get("competences"):
		if j is String:
			string_bonus += j + "\n"
	competences_label.text = "Compétences : \n" + string_bonus
	string_bonus = ""
	var k = ""
	for j in classe.get("maitrises"):
		string_bonus += j + " : \n"
		for i in classe.get("maitrises")[j]:
			if i.begins_with("#"):
				if "legere" in i:
					k = "Armures légères"
				elif "intermediaire" in i:
					k = "Armures intermédiaires"
				elif "courante" in i:
					k = "Armes courantes"
				elif "guerre" in i:
					k = "Armes de guerre"
				string_bonus += "- " + k + "\n"
			else:
				string_bonus += "- " + i + "\n"
	maitrises_label.text = "Maîtrises : \n" + string_bonus


func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/etape_3.tscn")
