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
    
    string map_name = map.getMapName();
    if (map_name.find("1.png") < 0)
    {
        return;
    }

    StructurePNGLoader loader();
    loader.loadMap(map, map_name.replace("1.png", "2.png"));
}