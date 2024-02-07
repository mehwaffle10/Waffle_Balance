
#include "MapFlag.as"
#include "DirtBackwallSyncCommon.as"

#define CLIENT_ONLY

void onSetTile(CMap@ this, u32 index, TileType newtile, TileType oldtile)
{
    CRules@ rules = getRules();
    MapFlag@ dirt_backwall_flags;
    rules.get(DIRT_BACKWALL_FLAGS, @dirt_backwall_flags);

    if (dirt_backwall_flags is null || dirt_backwall_flags.flags.length <= 0 || index >= dirt_backwall_flags.flags.length)
    {
        return;
    }
    
    // Check for air or dirtbackwall
    if (newtile == CMap::tile_empty || newtile >= 1 && newtile <= 4 || newtile >= 32 && newtile <= 41)
    {
        this.SetTile(index, dirt_backwall_flags.flags[index] ? CMap::tile_ground_back : CMap::tile_empty);
    }
}