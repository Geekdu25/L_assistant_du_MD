extends Control

@onready var propo_force = $nombres/numbers/Nombre_1
@onready var propo_dexterite = $nombres/numbers/Nombre_2
@onready var propo_constitution = $nombres/numbers/Nombre_3
@onready var propo_intelligence = $nombres/numbers/Nombre_4
@onready var propo_sagesse = $nombres/numbers/Nombre_5
@onready var propo_charisme = $nombres/numbers/Nombre_6
@onready var bonus_force = $"Panneau/Caractéristiques/bonus/Bonus_for"
@onready var bonus_dexterite = $"Panneau/Caractéristiques/bonus/Bonus_dex"
@onready var bonus_constitution = $"Panneau/Caractéristiques/bonus/Bonus_con"
@onready var bonus_intelligence = $"Panneau/Caractéristiques/bonus/Bonus_int"
@onready var bonus_sagesse = $"Panneau/Caractéristiques/bonus/Bonus_sag"
@onready var bonus_charisme = $"Panneau/Caractéristiques/bonus/Bonus_cha"
@onready var total_force = $"Panneau/Caractéristiques/totaux/for"
@onready var total_dexterite = $"Panneau/Caractéristiques/totaux/dex"
@onready var total_constitution = $"Panneau/Caractéristiques/totaux/con"
@onready var total_intelligence = $"Panneau/Caractéristiques/totaux/int"
@onready var total_sagesse = $"Panneau/Caractéristiques/totaux/sag"
@onready var total_charisme = $"Panneau/Caractéristiques/totaux/cha"

var string_bonus := ""
var tmp := ""

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

func values_changed_for(value:float):
	new_value = int(value) + int(bonus_force[1:len(bonus_force)-1])

func values_changed_dex(value:float):
	pass

func values_changed_con(value:float):
	pass

func values_changed_int(value:float):
	pass

func values_changed_sag(value:float):
	pass

func values_changed_cha(value:float):
	pass

func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/etape_4.tscn")
