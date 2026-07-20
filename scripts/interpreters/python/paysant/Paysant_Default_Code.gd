extends Node
class_name PaysantDefaultCode

const DEFAULT_PYTHON_CODE = """def run(unit):
	unit.setMaxCapacity(5) 
	maRessource = "wood"

	if unit.getCarriedResources() >= unit.getMaxCapacity():
		unit.deposit()
	else:
		unit.gather(maRessource)"""

const DEFAULT_CSHARP_CODE = """namespace Paysant;

public class Paysant : Unit 
{
    public void Run() 
    {
        // 1. Le joueur configure son unité en début de boucle
        unit.SetMaxCapacity(5); 

		string maRessource = "wood";

        // 2. L'unité s'adapte automatiquement !
        if (unit.GetCarriedResources() >= unit.GetMaxCapacity())
        {
            unit.Deposit();
        }
        else
        {
            unit.Gather(maRessource);
        }
    }
}"""
