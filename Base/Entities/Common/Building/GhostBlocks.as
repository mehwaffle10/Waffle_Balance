
#define CLIENT_ONLY

#include "GhostBlocksCommon.as"

void onInit(CRules@ this)
{
	CMap@ map = getMap();
	if (map is null || map.hasScript("GhostBlocks.as")) return;
	map.AddScript("GhostBlocks.as");
}

void onBlobCreated(CRules@ this, CBlob@ blob)
{
	CMap@ map = getMap();
	if (map is null) return;
	DeleteGhostBlockTilePos(map.getTileSpacePosition(blob.getPosition()), 0, blob);
}

void onRender(CMap@ this)
{
	RenderGhostBlocks(this);
}

void onSetTile(CMap@ this, u32 index, TileType newtile, TileType oldtile)
{
	DeleteGhostBlockTilePos(this.getTileSpacePosition(index), newtile, null);
}