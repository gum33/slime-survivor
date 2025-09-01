extends Node
class_name UpgradeTypes

enum UpgradeType {
	MOVE_SPEED,
	BULLET_SPEED,
	DAMAGE,
	RICOCHET,
	KNOCKBACK,
	LIFESTEAL,
}

var all_upgrades: Array[UpgradeType] = [
	UpgradeType.MOVE_SPEED,
	UpgradeType.BULLET_SPEED,
	UpgradeType.DAMAGE,
	UpgradeType.KNOCKBACK,
	UpgradeType.LIFESTEAL,
	UpgradeType.RICOCHET,
]

var common_upgrades: Array[UpgradeType] = [
	UpgradeType.MOVE_SPEED,
	UpgradeType.BULLET_SPEED,
	UpgradeType.DAMAGE,
]

var rare_upgrades: Array[UpgradeType] = [
	UpgradeType.KNOCKBACK,
	UpgradeType.LIFESTEAL,
	UpgradeType.RICOCHET,
]
var rarities = {
	common_upgrades: 80,
	rare_upgrades: 20,
}
var rng = RandomNumberGenerator.new()


var upgrade_names: Dictionary[UpgradeType, String] = {
	UpgradeType.MOVE_SPEED: "Move speed",
	UpgradeType.BULLET_SPEED: "Fire Rate",
	UpgradeType.DAMAGE: "Damage",
	UpgradeType.KNOCKBACK: "Knockback!",
	UpgradeType.LIFESTEAL: "Lifesteal!",
	UpgradeType.RICOCHET: "Ricochet!",
}

func get_item_weighted() -> UpgradeType:
	var rarity: Array[UpgradeType] = get_rarity()
	var item = rarity[randi() % rarity.size()]
	return item
	
func get_rarity() -> Array[UpgradeType]:
	rng.randomize()
	
	var weighted_sum = 0
	
	for n in rarities:
		weighted_sum += rarities[n]
	var item = rng.randi_range(0, weighted_sum)
	for n in rarities:
		if item <= rarities[n]:
			return n
		item -= rarities[n]
	return common_upgrades
