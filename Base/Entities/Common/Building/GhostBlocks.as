
#define CLIENT_ONLY

#include "GhostBlocksCommon.as"

void onInit(CRules@ this)
{
	CMap@ map = getMap();
	if (isServer() || map is null || map.hasScript("GhostBlocks.as")) return;
	map.AddScript("GhostBlocks.as");
}

void onBlobCreated(CRules@ this, CBlob@ blob)
{
	CMap@ map = getMap();
	if (map is null || isServer()) return;
	DeleteGhostBlockTilePos(map.getTileSpacePosition(blob.getPosition()), 0, blob);
}

void onRender(CMap@ this)
{
	if (isServer()) return;
	RenderGhostBlocks(this);
}

void onSetTile(CMap@ this, u32 index, TileType newtile, TileType oldtile)
{
	if (isServer()) return;
	DeleteGhostBlockTilePos(this.getTileSpacePosition(index), newtile, null);
}