extends Resource
class_name GameStats

signal stats_changed()

const HP = "h"
const STAMINA = "s"
const MIGHT = "m"
const AGILITY = "a"
const FORTITUDE = "f"
const ARMOR = "ac"
const WIZARDLYNESS = "w"
const LEVEL = "l"

enum ModTypes {Add, Subtract, Multiply, Divide}

enum ModSources {StatusEffect, Equipment}

enum DamageTypes {Blunt, Sharp, Fire, Lightning, Ice, Acid, Poison}

export(int) var hp
export(int) var stamina
export(int) var might
export(int) var agility
export(int) var fortitude
export(int) var armor
export(int) var wizardlyness
export(int) var level
export(int) var xp
export(Array, Array) var basic_attack = [["1d4;s:m", DamageTypes.Blunt]] 

var current_mod_id = -INF
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var stats = {
}

var resources = [HP, STAMINA]

var cur_resources = {
}

var eff_stats = {}

var stat_mods = {}

func initialize():
	stats[HP] = hp
	stats[STAMINA] = stamina
	stats[MIGHT] = might
	stats[AGILITY] = agility
	stats[FORTITUDE] = fortitude
	stats[WIZARDLYNESS] = wizardlyness
	stats[ARMOR] = armor
	stats[LEVEL] = level
	for stat in stats.keys():
		eff_stats[stat] = stats[stat]
		stat_mods[stat] = []
		if resources.has(stat):
			cur_resources[stat] = stats[stat]

func change_resource(res, amount, supress_update=false):
	cur_resources[res] = clamp(cur_resources[res] + amount,0, eff_stats[res])
	if not supress_update:
		emit_signal("stats_changed")
	return cur_resources[res]

func change_stat(stat, amount, supress_update=false):
	stats[stat] += amount
	recalc_eff_stat(stat, supress_update)

func set_stat(stat, value, supress_update=false):
	stats[stat] = value
	recalc_eff_stat(stat, supress_update)

func get_resource(res):
	return cur_resources[res]

func recalc_eff_stat(stat, supress_update=false):
	var base = stats[stat]
	var new_effective = base
	for mod in stat_mods[stat]:
		match mod[2]:
			ModTypes.Add:
				new_effective += mod[3]
			ModTypes.Subtract:
				new_effective -= mod[3]
			ModTypes.Multiply:
				new_effective *= mod[3]
	eff_stats[stat] = new_effective
	if not supress_update:
		emit_signal("stats_changed")

func add_mod(stat, amount, type, source_type, source, supress_update=false):
	var next_id = current_mod_id
	current_mod_id += 1
	stat_mods[stat].append([next_id, stat, type, amount, source_type, source])
	recalc_eff_stat(stat, supress_update)

func remove_mod(id, supress_update=false):
	var found_stat
	var found_i = -1
	for stat in stat_mods.keys():
		for i in range(stat_mods[stat].size()):
			if stat_mods[stat][i][0] == id:
				found_stat = stat
				found_i = i
				break
		if found_i >= 0:
			break
	if found_i >= 0:
		stat_mods[found_stat].remove(found_i)
		recalc_eff_stat(found_stat, supress_update)
		return true
	else:
		return false

func get_stat(stat):
	return eff_stats[stat]

func get_raw_stat(stat):
	return stats[stat]
