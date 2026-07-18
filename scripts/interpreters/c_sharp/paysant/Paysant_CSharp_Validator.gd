# Paysant_CSharp_Validator.gd
extends CSharp_Validator_Base
class_name Paysant_CSharp_Validator

func get_allowed_methods() -> Array:
	return ["unit.Gather", "unit.Deposit", "unit.GetCarriedResources", "unit.GetMaxCapacity", "unit.SetMaxCapacity", "unit.IsEnemyNearby"]
