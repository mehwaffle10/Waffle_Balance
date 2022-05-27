// spawn resources

#include "RulesCore.as";
#include "CTF_Structs.as";

const u32 materials_wait = 20; //seconds between free mats
const u32 materials_wait_warmup = 40; //seconds between free mats

//property
const string SPAWN_ITEMS_TIMER = "CTF SpawnItems:";

string base_name() { return "tent"; }

bool SetMaterials(CBlob@ blob,  const string &in name, const int quantity)
{
	CInventory@ inv = blob.getInventory();

	//avoid over-stacking arrows
	if (name == "mat_arrows")
	{
		inv.server_RemoveItems(name, quantity);
	}

	CBlob@ mat = server_CreateBlobNoInit(name);

	if (mat !is null)
	{
		mat.Tag('custom quantity');
		mat.Init();

		mat.server_SetQuantity(quantity);

		// Waffle: Make it so nonbuilder classes drop mats at their feet
		if (blob.getName() != "builder" || not blob.server_PutInInventory(mat))
		{
			mat.setPosition(blob.getPosition());
		}
	}

	return true;
}

bool GiveSpawnResources(CRules@ this, CPlayer@ player, CBlob@ blob, string name, CTFPlayerInfo@ info)
{
	bool ret = false;

	// Waffle: Refactor to spawn based on class name not player class
	if (name == "builder")
	{
		if (this.isWarmup())
		{
			ret = SetMaterials(blob, "mat_wood", 300) || ret;
			ret = SetMaterials(blob, "mat_stone", 100) || ret;

		}
		else
		{
			ret = SetMaterials(blob, "mat_wood", 100) || ret;
			ret = SetMaterials(blob, "mat_stone", 30) || ret;
		}

		if (ret)
		{
			info.items_collected |= ItemFlag::Builder;
		}
	}
	else if (name == "archer")
	{
		ret = SetMaterials(blob, "mat_arrows", 30) || ret;

		if (ret)
		{
			info.items_collected |= ItemFlag::Archer;
		}
	}
	else if (name == "knight")
	{
		if (ret)
		{
			info.items_collected |= ItemFlag::Knight;
		}
	}

	return ret;
}

//when the player is set, give materials if possible
void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	if (!getNet().isServer())
		return;

	if (blob !is null && player !is null)
	{
		RulesCore@ core;
		this.get("core", @core);
		if (core !is null)
		{
			doGiveSpawnMats(this, player, blob, core);
		}
	}
}

//when player dies, unset archer flag so he can get arrows if he really sucks :)
//give a guy a break :)
void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	if (victim !is null)
	{
		RulesCore@ core;
		this.get("core", @core);
		if (core !is null)
		{
			CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (core.getInfoFromPlayer(victim));
			if (info !is null)
			{
				info.items_collected &= ~ItemFlag::Archer;
			}
		}
	}
}

bool canGetSpawnmats(CRules@ this, CPlayer@ p, string name, RulesCore@ core)
{
	s32 next_items = getCTFTimer(this, p, name);
	s32 gametime = getGameTime();

	CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (core.getInfoFromPlayer(p));

	if (gametime > next_items)		// timer expired
	{
		u32 flag = 0;

		if (name == "builder")
		{
			flag = ItemFlag::Builder;
		}
		else if (name == "knight")
		{
			flag = ItemFlag::Knight;
		}
		else if (name == "archer")
		{
			flag = ItemFlag::Archer;
		}
		info.items_collected &= ~flag; // reset available class item
		return true;
	}

	return false;
}

string getCTFTimerPropertyName(CPlayer@ p, string name)
{
	// Waffle: Make spawn timers class specific
	return SPAWN_ITEMS_TIMER + p.getUsername() + name;
}

s32 getCTFTimer(CRules@ this, CPlayer@ p, string name)
{
	// Waffle: Make spawn timers class specific
	string property = getCTFTimerPropertyName(p, name);
	if (this.exists(property))
		return this.get_s32(property);
	else
		return 0;
}

void SetCTFTimer(CRules@ this, CPlayer@ p, string name, s32 time)
{
	// Waffle: Make spawn timers class specific
	string property = getCTFTimerPropertyName(p, name);
	this.set_s32(property, time);
	this.SyncToPlayer(property, p);
}

//takes into account and sets the limiting timer
//prevents dying over and over, and allows getting more mats throughout the game
void doGiveSpawnMats(CRules@ this, CPlayer@ p, CBlob@ b, RulesCore@ core)
{
	// Waffle: Make spawn timers class specific
	string[] names = {"builder", "knight", "archer"};

	for (u8 i = 0; i < names.length(); i++)
	{
		string name = names[i];

		if (canGetSpawnmats(this, p, name, core))
		{
			if (name == b.getName() || this.isWarmup() && name == "builder")
			{
				s32 gametime = getGameTime();

				CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (core.getInfoFromPlayer(p));

				bool gotmats = GiveSpawnResources(this, p, b, name, info);
				if (gotmats)
				{
					SetCTFTimer(this, p, name, gametime + (this.isWarmup() ? materials_wait_warmup : materials_wait)*getTicksASecond());
				}
			}
		}
	}
}

// normal hooks

void Reset(CRules@ this)
{
	// Waffle: Make spawn timers class specific
	string[] names = {"builder", "knight", "archer"};

	//restart everyone's timers
	for (uint i = 0; i < getPlayersCount(); ++i)
	{
		for (u8 j = 0; j < names.length(); j++)
		{
			SetCTFTimer(this, getPlayer(i), names[j], 0);
		}
	}
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
}

void onTick(CRules@ this)
{
	if (!getNet().isServer())
		return;

	s32 gametime = getGameTime();

	if ((gametime % 15) != 5)
		return;


	RulesCore@ core;
	this.get("core", @core);
	if (core !is null)
	{
		// Waffle: Always give spawn mats during warmup
		if (this.isWarmup())
		{
			for (u8 i = 0; i < getPlayerCount(); i++)
			{
				CPlayer@ player = getPlayer(i);
				if (player !is null)
				{
					CBlob@ blob = player.getBlob();
					if (blob !is null)
					{
						doGiveSpawnMats(this, player, blob, core);
					}
				}
			}
			
		}
		else
		{
			CBlob@[] spots;
			getBlobsByName(base_name(), @spots);
			getBlobsByName("buildershop", @spots);
			getBlobsByName("knightshop", @spots);
			getBlobsByName("archershop", @spots);
			for (uint step = 0; step < spots.length; ++step)
			{
				CBlob@ spot = spots[step];
				CBlob@[] overlapping;
				if (spot !is null && spot.getOverlapping(overlapping))
				{
					string name = spot.getName();
					bool isShop = (name.find("shop") != -1);
					for (uint o_step = 0; o_step < overlapping.length; ++o_step)
					{
						CBlob@ overlapped = overlapping[o_step];
						if (overlapped !is null && overlapped.hasTag("player"))
						{
							if (!isShop || name.find(overlapped.getName()) != -1)
							{
								CPlayer@ p = overlapped.getPlayer();
								if (p !is null)
								{
									doGiveSpawnMats(this, p, overlapped, core);
								}
							}
						}
					}
				}
			}
		}
	}
}

// render gui for the player
void onRender(CRules@ this)
{
	if (g_videorecording || this.isGameOver())
		return;

	CPlayer@ p = getLocalPlayer();
	if (p is null || !p.isMyPlayer()) { return; }

	CBlob@ b = p.getBlob();
	if (b !is null)
	{
		// Waffle: Make spawn timers class specific
		string propname = getCTFTimerPropertyName(p, b.getName());
		if (this.exists(propname))
		{
			s32 next_items = this.get_s32(propname);
			if (next_items > getGameTime())
			{
				string action = (b.getName() == "builder" ? "Go Build" : "Go Fight");
				if (this.isWarmup())
				{
					action = "Prepare for Battle";
				}

				u32 secs = ((next_items - 1 - getGameTime()) / getTicksASecond()) + 1;
				string units = ((secs != 1) ? " seconds" : " second");
				GUI::SetFont("menu");
				GUI::DrawTextCentered(getTranslatedString("Next resupply in {SEC}{TIMESUFFIX}, {ACTION}!")
								.replace("{SEC}", "" + secs)
								.replace("{TIMESUFFIX}", getTranslatedString(units))
								.replace("{ACTION}", getTranslatedString(action)),
							Vec2f(getScreenWidth() / 2, getScreenHeight() / 3 - 70.0f + Maths::Sin(getGameTime() / 3.0f) * 5.0f),
							SColor(255, 255, 55, 55));
			}
		}
	}
}
