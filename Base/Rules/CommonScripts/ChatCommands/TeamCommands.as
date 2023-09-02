
#include "WaffleUtilities"
#include "CTF_SharedClasses.as"
#include "ChatCommand.as"

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
    CPlayer@ target = player.isMod() && args.length > 0 ? GetPlayerByIdent(args[0]) : player;
    if (!isServer() || target is null)
    {
        return;
    }
    RulesCore@ core;
    getRules().get("core", @core);
    if (core !is null)
    {
        core.ChangePlayerTeam(target, team);
    }
}