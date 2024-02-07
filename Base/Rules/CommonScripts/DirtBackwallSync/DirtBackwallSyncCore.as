
#include "MapFlag.as"
#include "DirtBackwallSyncCommon.as"

void onInit(CRules@ this)
{
    this.addCommandID(DIRT_BACKWALL_SYNC_COMMAND);
    onRestart(this);
}

void onRestart(CRules@ this)
{
    CMap@ map = getMap();
    if (map is null)
    {
        return;
    }

    if (!map.hasScript("DirtBackwallMapUpdates"))
    {
        map.AddScript("DirtBackwallMapUpdates");
    }

    if (!isServer())
    {
        this.set(DIRT_BACKWALL_FLAGS, null);
        return;
    }

    MapFlag@ dirt_backwall_flags = MapFlag(map.tilemapwidth * map.tilemapheight);
    for (int x = 0; x < map.tilemapwidth; x++)
    {
        for (int y = 0; y < map.tilemapheight; y++)
        {
            u32 offset = map.getTileOffsetFromTileSpace(Vec2f(x, y));
            dirt_backwall_flags.flags[offset] = hasDirtBackwall(map.getTile(offset).type);
        }
    }
    this.set(DIRT_BACKWALL_FLAGS, @dirt_backwall_flags);
    dirt_backwall_flags.Sync(this, null, DIRT_BACKWALL_SYNC_COMMAND);
}

bool hasDirtBackwall(TileType type)
{
    return type == CMap::tile_bedrock     ||
           type == CMap::tile_gold        ||
           type == CMap::tile_ground      ||
           type == CMap::tile_ground_back ||
           type == CMap::tile_stone       ||
           type == CMap::tile_thickstone;
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
    MapFlag@ dirt_backwall_flags;
    this.get(DIRT_BACKWALL_FLAGS, @dirt_backwall_flags);
    if (isServer() && dirt_backwall_flags !is null)
    {
        dirt_backwall_flags.Sync(this, player, DIRT_BACKWALL_SYNC_COMMAND);
    }
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
    if (isClient() && cmd == this.getCommandID(DIRT_BACKWALL_SYNC_COMMAND))
    {
        u32 length;
        if (!params.saferead_u32(length))
        {
            return;
        }
        MapFlag@ dirt_backwall_flags = MapFlag(length);
        for (u32 i = 0; i < length; i++)
        {
            bool dirt_backwall_flag;
            if (!params.saferead_bool(dirt_backwall_flag))
            {
                return;
            }
            dirt_backwall_flags.flags[i] = dirt_backwall_flag;
        }
        this.set(DIRT_BACKWALL_FLAGS, dirt_backwall_flags);
    }
}