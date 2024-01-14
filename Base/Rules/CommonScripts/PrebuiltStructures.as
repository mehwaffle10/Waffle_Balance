#include "StructurePNGLoader.as"

void onInit(CRules@ this)
{
    onRestart(this);
}

void onRestart(CRules@ this)
{
    // Waffle: Add structures post gen
    if (isServer())
    {
        CMap@ map = getMap();
        if (map is null)
        {
            return;
        }
        
        StructurePNGLoader loader();
	    loader.loadMap(map, map.getMapName());
    }
}