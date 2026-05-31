
#define CLIENT_ONLY

#include "GhostBlocksCommon.as"

void onInit(CMap@ this)
{
	CRules@ rules = getRules();
	GhostBlocks@ ghostBlocks = GhostBlocks();
	rules.set(GHOST_BLOCKS, ghostBlocks);
}

void onRender(CMap@ this)
{
	CRules@ rules = getRules();
	GhostBlocks@ ghostBlocks = GhostBlocks();
	ghostBlocks.onRender();
	// rules.set(GHOST_BLOCKS, ghostBlocks);
}