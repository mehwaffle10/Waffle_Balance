
#define SERVER_ONLY

#include "MaterialsPauseCommon.as"
#include "CTF_SharedClasses.as"

void onInit(CRules@ this)
{
    this.set_bool(PAUSE_MATERIALS, true);
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
    updateIfPaused(this);
}

void onPlayerChangedTeam(CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam)
{
    updateIfPaused(this);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
    updateIfPaused(this);
}

void updateIfPaused(CRules@ this)
{
    CTFCore@ core;
	this.get("core", @core);
    this.set_bool(PAUSE_MATERIALS, core !is null && !core.allTeamsHavePlayers());
}