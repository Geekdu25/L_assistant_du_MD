extends Control

@onready var propo_force = $nombres/numbers/Nombre_1
@onready var propo_dexterite = $nombres/numbers/Nombre_2
@onready var propo_constitution = $nombres/numbers/Nombre_3
@onready var propo_intelligence = $nombres/numbers/Nombre_4
@onready var propo_sagesse = $nombres/numbers/Nombre_5
@onready var propo_charisme = $nombres/numbers/Nombre_6
@onready var bonus_force = $"Panneau/Caractéristiques/conteneur_de_valeurs/bonus/Bonus_for"
@onready var bonus_dexterite = $"Panneau/Caractéristiques/conteneur_de_valeurs/bonus/Bonus_dex"
@onready var bonus_constitution = $"Panneau/Caractéristiques/conteneur_de_valeurs/bonus/Bonus_con"
@onready var bonus_intelligence = $"Panneau/Caractéristiques/conteneur_de_valeurs/bonus/Bonus_int"
@onready var bonus_sagesse = $"Panneau/Caractéristiques/conteneur_de_valeurs/bonus/Bonus_sag"
@onready var bonus_charisme = $"Panneau/Caractéristiques/conteneur_de_valeurs/bonus/Bonus_cha"
@onready var total_force = $"Panneau/Caractéristiques/conteneur_de_valeurs/totaux/for"
@onready var total_dexterite = $"Panneau/Caractéristiques/conteneur_de_valeurs/totaux/dex"
@onready var total_constitution = $"Panneau/Caractéristiques/conteneur_de_valeurs/totaux/con"
@onready var total_intelligence = $"Panneau/Caractéristiques/conteneur_de_valeurs/totaux/int"
@onready var total_sagesse = $"Panneau/Caractéristiques/conteneur_de_valeurs/totaux/sag"
@onready var total_charisme = $"Panneau/Caractéristiques/conteneur_de_valeurs/totaux/cha"

var string_bonus := ""
var tmp := ""

var toutes_races = Utils.charger_tout("races")
var race_joueur = CurrentPersonnage.race
var bonus = {}

func _ready():
	var nombres_generes = Utils.roll_stats_array()
	for i in range(6):
		tmp = ""
		for j in range(4):
			tmp += str(nombres_generes[i]["rolls"][j])
			if j < 3:
				tmp += ", "
		string_bonus = str(nombres_generes[i]["value"]) + " (" + tmp + ")"
		if i == 0:
			propo_force.text = string_bonus
		elif i == 1:
			propo_dexterite.text = string_bonus
		elif i == 2:
			propo_constitution.text = string_bonus
		elif i == 3:
			propo_intelligence.text = string_bonus
		elif i == 4:
			propo_sagesse.text = string_bonus
		else:
			propo_charisme.text = string_bonus
	for race in toutes_races:
		if race["nom"] == race_joueur:
			bonus = race["bonus_caracs"]
	toutes_races = null
	race_joueur = null
	for j in Utils.all_carac:
		if j in bonus:
			if j == "Force":
				bonus_force.text = "+"+str(int(bonus[j]))
			elif j == "Dextérité":
				bonus_dexterite.text = "+"+str(int(bonus[j]))
			elif j == "Constitution":
				bonus_constitution.text = "+"+str(int(bonus[j]))
			elif j == "Intelligence":
				bonus_intelligence.text = "+"+str(int(bonus[j]))
			elif j == "Sagesse":
				bonus_sagesse.text = "+"+str(int(bonus[j]))
			else:
				bonus_charisme.text = "+"+str(int(bonus[j]))
	update_total("all", 10)

func update_total(quoi, valeur):
	var a := 10
	if quoi == "all":
		for carac in Utils.all_carac:
			update_total(carac, valeur)
	elif quoi == "Force":
		if "Force" in bonus:
			a = int(valeur+bonus["Force"])
		else:
			a = int(valeur)
		total_force.text = str(a)
		CurrentPersonnage.force_carac = a
	elif quoi == "Dextérité":
		if "Dextérité" in bonus:
			a = int(valeur+bonus["Dextérité"])
		else:
			a = int(valeur)
		total_dexterite.text = str(a)
		CurrentPersonnage.dexterite_carac = a
	elif quoi == "Constitution":
		if "Constitution" in bonus:
			a = int(valeur+bonus["Constitution"])
		else:
			a = int(valeur)
		total_constitution.text = str(a)
		CurrentPersonnage.constitution_carac = a
	elif quoi == "Intelligence":
		if "Intelligence" in bonus:
			a = int(valeur+bonus["Intelligence"])
		else:
			a = int(valeur)
		total_intelligence.text = str(a)
		CurrentPersonnage.intelligence_carac = a
	elif quoi == "Sagesse":
		if "Sagesse" in bonus:
			a = int(valeur+bonus["Sagesse"])
		else:
			a = int(valeur)
		total_sagesse.text = str(a)
		CurrentPersonnage.sagesse_carac = a
	elif quoi == "Charisme":
		if "Charisme" in bonus:
			a = int(valeur+bonus["Charisme"])
		else:
			a = int(valeur)
		total_charisme.text = str(a)
		CurrentPersonnage.charisme_carac = a

func values_changed_for(value:float):
	update_total("Force", value)

func values_changed_dex(value:float):
	update_total("Dextérité", value)

func values_changed_con(value:float):
	update_total("Constitution", value)

func values_changed_int(value:float):
	update_total("Intelligence", value)

func values_changed_sag(value:float):
	update_total("Sagesse", value)

func values_changed_cha(value:float):
	update_total("Charisme", value)

func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/etape_4.tscn")


func _on_continuer_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/etape_6.tscn")


func _on_niveau_changed(value: float) -> void:
	CurrentPersonnage.niveau = int(value)
