
#include "FireSpreadCommon.as"

void onSetTile(CMap@ this, u32 index, TileType newtile, TileType oldtile)
{
    Vec2f pos = this.getTileSpacePosition(index);
    if (this.isTileInFire(pos.x, pos.y))
    {
        FireSpread(pos * this.tilesize);
    }
}
