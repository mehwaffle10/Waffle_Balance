
//CTF gamemode logic script

#define SERVER_ONLY

#include "CTF_Structs.as";
#include "RulesCore.as";
#include "RespawnSystem.as";

#include "CTF_PopulateSpawnList.as"

#include "CTF_SharedClasses.as"

//edit the variables in the config file below to change the basics
// no scripting required!
void Config(CTFCore@ this)
{
	string configstr = "Rules/CTF/ctf_vars.cfg";

	if (getRules().exists("ctfconfig"))
	{
		configstr = getRules().get_string("ctfconfig");
	}

	ConfigFile cfg = ConfigFile(configstr);

	//how long to wait for everyone to spawn in?
	s32 warmUpTimeSeconds = 90;  // cfg.read_s32("warmup_time", 30);  // Waffle: Override since cfg files are jank
	this.warmUpTime = (getTicksASecond() * warmUpTimeSeconds);

	s32 stalemateTimeSeconds = cfg.read_s32("stalemate_time", 30);
	this.stalemateTime = (getTicksASecond() * stalemateTimeSeconds);

	//how long for the game to play out?
	s32 gameDurationMinutes = cfg.read_s32("game_time", -1);
	if (gameDurationMinutes <= 0)
	{
		this.gameDuration = 0;
		getRules().set_bool("no timer", true);
	}
	else
	{
		this.gameDuration = (getTicksASecond() * 60 * gameDurationMinutes);
	}
	//how many players have to be in for the game to start
	this.minimum_players_in_team = cfg.read_s32("minimum_players_in_team", 2);
	//whether to scramble each game or not
	this.scramble_teams = cfg.read_bool("scramble_teams", true);

	//spawn after death time
	this.spawnTime = (getTicksASecond() * cfg.read_s32("spawn_time", 15));

}

shared string base_name() { return "tent"; }
shared string flag_name() { return "ctf_flag"; }
shared string flag_spawn_name() { return "flag_base"; }

//pass stuff to the core from each of the hooks

void Reset(CRules@ this)
{
	CBitStream stream;
	stream.write_u16(0xDEAD); //check bits rewritten when theres something useful
	this.set_CBitStream("ctf_serialised_team_hud", stream);
    this.Sync("ctf_serialized_team_hud", true);

	printf("Restarting rules script: " + getCurrentScriptName());
	CTFSpawns spawns();
	CTFCore core(this, spawns);
	Config(core);
	core.SetupBases();
	this.set("core", @core);
	this.set("start_gametime", getGameTime() + core.warmUpTime);
	this.set_u32("game_end_time", getGameTime() + core.gameDuration); //for TimeToEnd.as
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
	this.set_s32("restart_rules_after_game_time", 30 * 30);
}

// had to add it here for tutorial cause something didnt work in the tutorial script
void onBlobDie(CRules@ this, CBlob@ blob)
{
	if (this.hasTag("tutorial"))
	{
		const string name = blob.getName();
		if ((name == "archer" || name == "knight" || name == "chicken") && !blob.hasTag("dropped coins"))
		{
			server_DropCoins(blob.getPosition(), XORRandom(15) + 5);
			blob.Tag("dropped coins");
		}
	}
}

void onBlobCreated(CRules@ this, CBlob@ blob)
{
	if (blob.getName() == "mat_gold")
	{
		blob.RemoveScript("DecayQuantity.as");
	}
}