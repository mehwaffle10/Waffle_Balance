
#include "CTF_Structs.as";
#include "RulesCore.as";

void onInit(CRules@ this)
{
    reset(this);
}

void onRestart(CRules@ this)
{
    reset(this);
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
    resetPlayer(this, player);
}

void reset(CRules@ this)
{
    for (u8 i = 0; i < getPlayerCount(); i++)
    {
        resetPlayer(this, getPlayer(i));
    }
}

void resetPlayer(CRules@ this, CPlayer@ player)
{
    RulesCore@ core;
	this.get("core", @core);   
    if (player !is null)
    {
        CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (core.getInfoFromPlayer(player));
        if (info !is null)
        {
            info.blob_name = "builder";
        }
    }
}