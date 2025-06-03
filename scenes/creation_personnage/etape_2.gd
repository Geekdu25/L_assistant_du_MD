extends Control

@onready var races_list_vbox = $Conteneur_de_races/Scrolleur/Conteneur
@onready var details_panel = $Conteneur_de_races/Panneau
@onready var name_label = details_panel.get_node("RaceName")
@onready var desc_label = details_panel.get_node("RaceDesc")
@onready var bonus_label = details_panel.get_node("RaceBonus")
@onready var vitesse_label = details_panel.get_node("RaceVitesse")
@onready var traits_label = details_panel.get_node("RaceTraits")

var races = []

func _ready():
	races = load_all_races()
	print("Races chargées : ", races)
	populate_races_list()

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
	desc_label.text = race["description"]
	bonus_label.text = "Bonus : " + str(race.get("bonus_caracs", {}))
	vitesse_label.text = "Vitesse : " + str(race.get("vitesse", ""))
	traits_label.text = "Traits : " + ", ".join(race.get("autres_traits", []))


func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/etape_1.tscn")
