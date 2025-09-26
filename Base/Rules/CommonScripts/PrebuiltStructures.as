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

    // Waffle: Janky hack to workaround the tile meshing issue
    map.server_SetTile(Vec2f_zero, CMap::tile_castle_back_moss);
    map.server_SetTile(Vec2f_zero, map.getTile(Vec2f(map.tilesize, 0)).type);
    Vec2f bottom_left = Vec2f(map.tilemapwidth - 1, map.tilemapheight - 1) * map.tilesize;
    map.server_SetTile(bottom_left, CMap::tile_castle_back_moss);
    map.server_SetTile(bottom_left, map.getTile(bottom_left - Vec2f(map.tilesize, 0)).type);
}