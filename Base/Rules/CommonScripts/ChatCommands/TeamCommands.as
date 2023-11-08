
#include "WaffleUtilities.as"
#include "CTF_SharedClasses.as"
#include "ChatCommand.as"
#include "SwitchFromSpec.as"

void onInit(CRules@ this)
{
	ChatCommands::RegisterCommand(BlueCommand());
	ChatCommands::RegisterCommand(RedCommand());
	ChatCommands::RegisterCommand(SpecCommand());
}

class BlueCommand : ChatCommand
{
	BlueCommand()
	{
		super("blue", "Change yourself or another player to blue team");
        AddAlias("b");
        SetUsage("[other player name]");
	}

	void Execute(string[] args, CPlayer@ player)
	{
		ChangeTeam(player, 0, args);
	}
}

class RedCommand : ChatCommand
{
	RedCommand()
	{
		super("red", "Change yourself or another player to red team");
        AddAlias("r");
        SetUsage("[other player name]");
	}

	void Execute(string[] args, CPlayer@ player)
	{
		ChangeTeam(player, 1, args);
	}
}

class SpecCommand : ChatCommand
{
	SpecCommand()
	{
		super("spectator", "Change yourself or another player to spectator");
        AddAlias("spec");
        AddAlias("s");
        SetUsage("[other player name]");
	}

	void Execute(string[] args, CPlayer@ player)
	{
		ChangeTeam(player, getRules().getSpectatorTeamNum(), args);
	}
}

void ChangeTeam(CPlayer@ player, u8 team, string[] args)
{
    CPlayer@ target = player !is null && player.isMod() && args.length > 0 ? GetPlayerByIdent(args[0], player) : player;
    if (target is null)
    {
        return;
    }

    if (!CanSwitchFromSpec(getRules(), player, team))
    {
        LocalError("You can not switch to that team", player);
    }

    if (player.isMod())
    {
        RulesCore@ core;
        getRules().get("core", @core);
        if (isServer() && core !is null)
        {
            core.ChangePlayerTeam(target, team);
        }
    }
    else
    {
        target.client_ChangeTeam(team);
    }
}