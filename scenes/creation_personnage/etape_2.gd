extends Control

@onready var races_list_vbox = $Conteneur_de_races/Scrolleur/Conteneur
@onready var details_panel = $Conteneur_de_races/Panneau
@onready var name_label = $Conteneur_de_races/Panneau/VBoxContainer/RaceName
@onready var desc_label = $Conteneur_de_races/Panneau/VBoxContainer/RaceDesc
@onready var bonus_label = $Conteneur_de_races/Panneau/VBoxContainer/RaceBonus
@onready var vitesse_label = $Conteneur_de_races/Panneau/VBoxContainer/RaceVitesse
@onready var traits_label = $Conteneur_de_races/Panneau/VBoxContainer/RaceTraits
@onready var langues_label = $Conteneur_de_races/Panneau/VBoxContainer/RaceLangues
@onready var taille_label = $Conteneur_de_races/Panneau/VBoxContainer/RaceTaille

var races = []

func _ready():
	races = load_all_races()
	populate_races_list()
	if races.size() > 0:
		_on_race_selected(races[0])

func load_all_races() -> Array:
	var result = []
	# Charger races SRD
	if FileAccess.file_exists("res://assets/json/races_srd.json"):
		var data = FileAccess.get_file_as_string("res://assets/json/races_srd.json")
		result += JSON.parse_string(data)
	# Charger races personnalisées
	var dir = DirAccess.open("user://races")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".json"):
				var path = "user://races/" + file_name
				if FileAccess.file_exists(path):
					var data2 = FileAccess.get_file_as_string(path)
					result += JSON.parse_string(data2)
			file_name = dir.get_next()
		dir.list_dir_end()
	return result

func clear_vbox(vbox: VBoxContainer) -> void:
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()

func populate_races_list():
	clear_vbox(races_list_vbox)
	for race in races:
		var btn = Button.new()
		btn.text = race["nom"]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.connect("pressed", Callable(self, "_on_race_selected").bind(race))
		races_list_vbox.add_child(btn)

func _on_race_selected(race):
	name_label.text = race["nom"]
	if len(race["description"]) == 0:
		desc_label.text = "Aucune description n'a été ajoutée à cette race."
	else:
		desc_label.text = race["description"]
	var string_bonus = ""
	for key in race.get("bonus_caracs"):
		string_bonus += key.capitalize() + " : +" + str(int(race.get("bonus_caracs")[key])) + "\n"
	bonus_label.text = "Bonus : \n" + string_bonus
	vitesse_label.text = "Vitesse : " + str(int(race.get("vitesse", ""))) + "m\n"
	string_bonus = ""
	for info in race.get("autres_traits"):
		string_bonus += info + "\n"
	traits_label.text = "Traits : \n" + string_bonus
	string_bonus = ""
	for langue in race.get("langues"):
		string_bonus += langue + "\n"
	langues_label.text = "Langues : \n" + string_bonus
	taille_label.text = "Catégorie de taille : " + race.get("taille")


func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/etape_1.tscn")


func _on_continue_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/etape_3.tscn")
