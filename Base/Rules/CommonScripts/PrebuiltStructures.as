#include "StructurePNGLoader.as"

#define SERVER_ONLY

void onInit(CRules@ this)
{
    onRestart(this);
}

void onRestart(CRules@ this)
{
    // Waffle: Add structures post gen
    CMap@ map = getMap();
    if (map is null)
    {
        return;
    }
    
    StructurePNGLoader loader();
    loader.loadMap(map, map.getMapName());
}