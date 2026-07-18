# Paysant_Python_Validator.gd
extends Python_Validator_Base
class_name Paysant_Python_Validator

func get_allowed_methods() -> Array:
	# Vu que le validateur de base fait un .to_lower(), 
	# on liste ici toutes les combinaisons possibles converties en minuscules strictes.
	return [
		"unit.gather",
		"unit.deposit",
		
		"unit.get_carried_resources",
		"unit.getcarriedresources", # Pour capter getCarriedResources ou GetCarriedResources
		
		"unit.get_max_capacity",
		"unit.getmaxcapacity",      # Pour capter getMaxCapacity ou GetMaxCapacity
		
		"unit.set_max_capacity",
		"unit.setmaxcapacity",      # <-- C'est ça qui va valider magiquement ton unit.setMaxCapacity(6) !
		
		"unit.is_enemy_nearby",
		"unit.isenemynearby"        # Pour capter isEnemyNearby ou IsEnemyNearby
	]
