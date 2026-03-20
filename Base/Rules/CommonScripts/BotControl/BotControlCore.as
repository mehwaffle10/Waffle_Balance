
#define SERVER_ONLY

#include "BotControlCommon.as"
#include "CTF_SharedClasses.as"

void onInit(CRules@ this)
{
	this.set_s8(MINIMUM_TEAM_SIZE, -1);
}

void onPlayerChangedTeam(CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam)
{
	player.set_s32(TEAM_PROPERTY, newteam);
	s8 minimum_team_size = this.get_s8(MINIMUM_TEAM_SIZE);
	if (minimum_team_size < 0)
	{
		return;
	}

	updateTeamStats(this);
	if (this.get_u8(INGAME_COUNT) < minimum_team_size * 2)
	{
		AddBot("Henry");
	}
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	player.set_s32(TEAM_PROPERTY, this.getSpectatorTeamNum());
	s8 minimum_team_size = this.get_s8(MINIMUM_TEAM_SIZE);
	if (minimum_team_size < 0)
	{
		return;
	}

	updateTeamStats(this);
	if (this.get_u8(INGAME_COUNT) < minimum_team_size * 2)
	{
		AddBot("Henry");
	}
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	if (!victim.isBot())
	{
		return;
	}

	s8 minimum_team_size = this.get_s8(MINIMUM_TEAM_SIZE);
	if (minimum_team_size < 0)
	{
		return;
	}

	updateTeamStats(this);
	s32 team = victim.getTeamNum();
	s32 other_team = Maths::Abs(team - 1);
	if (this.get_u8(team + TEAM_SIZE_SUFFIX) > minimum_team_size)
	{
		if (this.get_u8(other_team + TEAM_SIZE_SUFFIX) < minimum_team_size)
		{
			RulesCore@ core;
			getRules().get("core", @core);
			if (core is null)
			{
				return;
			}

			victim.set_s32(TEAM_PROPERTY, other_team);
			core.ChangePlayerTeam(victim, other_team);
		}
		else
		{
			victim.set_s32(TEAM_PROPERTY, this.getSpectatorTeamNum());
			KickPlayer(victim);
		}
	}
}