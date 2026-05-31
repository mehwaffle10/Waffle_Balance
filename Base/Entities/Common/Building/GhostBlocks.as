
#define CLIENT_ONLY

#include "GhostBlocksCommon.as"

void onInit(CRules@ this)
{
	CMap@ map = getMap();
	if (map !is null && !map.hasScript("GhostBlocks.as"))
	{
		map.AddScript("GhostBlocks.as");
	}
}

void onBlobCreated(CRules@ this, CBlob@ blob)
{
	CMap@ map = getMap();
	GhostBlocks@ ghostBlocks;
	this.get(GHOST_BLOCKS, @ghostBlocks);
	if (ghostBlocks is null) return;
	ghostBlocks.deleteTilePos(map.getTileSpacePosition(blob.getPosition()), 0, blob);
}

void onRender(CMap@ this)
{
	CRules@ rules = getRules();
	GhostBlocks@ ghostBlocks;
	rules.get(GHOST_BLOCKS, @ghostBlocks);
	if (ghostBlocks is null)
	{
		GhostBlocks@ ghostBlocks = GhostBlocks();
		rules.set(GHOST_BLOCKS, ghostBlocks);
	}
	ghostBlocks.onRender(this);
}

void onSetTile(CMap@ this, u32 index, TileType newtile, TileType oldtile)
{
	CRules@ rules = getRules();
	GhostBlocks@ ghostBlocks;
	rules.get(GHOST_BLOCKS, @ghostBlocks);
	if (ghostBlocks is null) return;
	ghostBlocks.deleteTilePos(this.getTileSpacePosition(index), newtile, null);
}