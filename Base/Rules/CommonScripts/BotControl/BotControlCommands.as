
#include "WaffleUtilities.as"
#include "BotControlCommon.as"
#include "ChatCommand.as"

void onInit(CRules@ this)
{
	ChatCommands::RegisterCommand(TeamSizeCommand());
}

class TeamSizeCommand : ChatCommand
{
	TeamSizeCommand()
	{
		super("teamsize", "Set minimum team size, using bots to fill slots");
        SetUsage("<team size>");
	}

	void Execute(string[] args, CPlayer@ player)
	{
		if (!player.isMod())
		{
			LocalError("Admin permissions required", player);
		}

		if (args.length == 0)
		{
			LocalError("Team size required", player);
		}

		if (!isServer())
		{
			return;
		}

		CRules@ rules = getRules();
		s8 teamsize = parseInt(args[0]);
		rules.set_s8(MINIMUM_TEAM_SIZE, teamsize);
		if (rules.get_u8(INGAME_COUNT) < teamsize * 2)
		{
			AddBot("Henry");
		}
	}
}