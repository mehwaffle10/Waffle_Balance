//tree making logs on death script

#include "MakeSeed.as"
#include "FireCommon.as"

void onDie(CBlob@ this)
{
	if (!getNet().isServer()) return; //SERVER ONLY

	Vec2f pos = this.getPosition();

	// Waffle: Don't drop saplings if on fire
	if (!this.hasTag(burning_tag) && !this.hasTag("no seed"))
	{
		server_MakeSeed(pos, this.getName());
	}
}
