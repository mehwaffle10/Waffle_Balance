// spawn resources

#include "RulesCore.as";
#include "CTF_Structs.as";
#include "CTF_Common.as"; // resupply stuff

const u32 materials_wait = 20; //seconds between free mats
const u32 materials_wait_warmup = materials_wait; //seconds between free mats  // Waffle: Set to same cooldown since it's only for archers

const int warmup_wood_amount = 250;
const int warmup_stone_amount = 80;

const int matchtime_wood_amount = 100;
const int matchtime_stone_amount = 30;

//property
const string SPAWN_ITEMS_TIMER_BUILDER = "CTF SpawnItems Builder:";
const string SPAWN_ITEMS_TIMER_ARCHER  = "CTF SpawnItems Archer:";

const string RESUPPLY_TIME_STRING = "team resupply timer";

// Waffle: Materials for the entire team. Drop once at the start of the game
const int crate_warmup_wood_amount = 4000;  
const int crate_warmup_stone_amount = 2000;

// Waffle: Builders no longer can resupply. Crates drop for each team with team materials
const u32 crate_wait = 10 * 60 * getTicksASecond();
const int crate_wood_amount = 500;
const int crate_stone_amount = 150;

string base_name() { return "tent"; }

bool SetMaterials(CBlob@ blob,  const string &in name, const int quantity, bool drop = false)
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
		
		if (drop || not blob.server_PutInInventory(mat))
		{
			mat.setPosition(blob.getPosition());
		}
	}
	
	return true;
}

//when the player is set, give materials if possible
void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	if (!isServer()) return;
	
	if (blob is null) return;
	if (player is null) return;
	
	doGiveSpawnMats(this, player, blob);
}

//when player dies, unset archer flag so he can get arrows if he really sucks :)
//give a guy a break :)
void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	if (victim !is null)
	{
		SetCTFTimer(this, victim, 0, "archer");
	}
}

//takes into account and sets the limiting timer
//prevents dying over and over, and allows getting more mats throughout the game
void doGiveSpawnMats(CRules@ this, CPlayer@ p, CBlob@ b)
{
	s32 gametime = getGameTime();
	string name = b.getName();
	
	// Waffle: Remove builder resupplies
	/*
	if (name == "builder" || this.isWarmup()) 
	{
		if (gametime > getCTFTimer(this, p, "builder")) 
		{
			int wood_amount = matchtime_wood_amount;
			int stone_amount = matchtime_stone_amount;
			
			if (this.isWarmup()) 
			{
				wood_amount = warmup_wood_amount;
				stone_amount = warmup_stone_amount;
			}

			bool drop_mats = (name != "builder");
			
			bool did_give_wood = SetMaterials(b, "mat_wood", wood_amount, drop_mats);
			bool did_give_stone = SetMaterials(b, "mat_stone", stone_amount, drop_mats);
			
			if (did_give_wood || did_give_stone)
			{
				SetCTFTimer(this, p, gametime + (this.isWarmup() ? materials_wait_warmup : materials_wait)*getTicksASecond(), "builder");
			}
		}
	}
	*/

	if (name == "archer") 
	{
		if (gametime > getCTFTimer(this, p, "archer")) 
		{
			CInventory@ inv = b.getInventory();
			if (inv.isInInventory("mat_arrows", 30)) 
			{
				return; // don't give arrows if they have 30 already
			}
			else if (SetMaterials(b, "mat_arrows", 30)) 
			{
				SetCTFTimer(this, p, gametime + (isBuildPhase(this) ? materials_wait_warmup : materials_wait)*getTicksASecond(), "archer");
			}
		}
	}
}

void Reset(CRules@ this)
{
	// Waffle: Do build phase resupply
	this.set_s32(RESUPPLY_TIME_STRING, 1);
	
	//restart everyone's timers
	for (uint i = 0; i < getPlayersCount(); ++i) {
		// SetCTFTimer(this, getPlayer(i), 0, "builder");  // Waffle: No need to track this
		SetCTFTimer(this, getPlayer(i), 0, "archer");
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
	s32 gametime = getGameTime();
	
	if ((gametime % 15) != 5)
		return;
	
	// Waffle: Drop periodic crates of materials
	if (gametime > this.get_s32(RESUPPLY_TIME_STRING))
	{
		SpawnResupplies(this);
		this.set_s32(RESUPPLY_TIME_STRING, isBuildPhase(this) ? 9999999999 : gametime + crate_wait);
	}

	if(!isServer())
	{
		return;
	}

	if (isBuildPhase(this)) 
	{
		// during building time, give everyone resupplies no matter where they are
		for (int i = 0; i < getPlayerCount(); i++) 
		{
			CPlayer@ player = getPlayer(i);
			CBlob@ blob = player.getBlob();
			if (blob !is null) 
			{
				doGiveSpawnMats(this, player, blob);
			}
		}
	}
	else 
	{
		CBlob@[] spots;
		getBlobsByName(base_name(),   @spots);
		getBlobsByName("outpost",	@spots);
		getBlobsByName("warboat",	 @spots);
		// getBlobsByName("buildershop", @spots);  // Waffle: No builder resupplies
		getBlobsByName("archershop",  @spots);
		// getBlobsByName("knightshop",  @spots);
		for (uint step = 0; step < spots.length; ++step) 
		{
			CBlob@ spot = spots[step];
			if (spot is null) continue;

			CBlob@[] overlapping;
			if (!spot.getOverlapping(overlapping)) continue;

			string name = spot.getName();
			bool isShop = (name.find("shop") != -1);

			for (uint o_step = 0; o_step < overlapping.length; ++o_step) 
			{
				CBlob@ overlapped = overlapping[o_step];
				if (overlapped is null) continue;
				
				if (!overlapped.hasTag("player")) continue;
				CPlayer@ p = overlapped.getPlayer();
				if (p is null) continue;

				string class_name = overlapped.getName();
				
				if (isShop && name.find(class_name) == -1) continue; // NOTE: builder doesn't get wood+stone at archershop, archer doesn't get arrows at buildershop

				doGiveSpawnMats(this, p, overlapped);
			}
		}
	}
}

// Reset timer in case player who joins has an outdated timer
void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	s32 next_add_time = getGameTime() + (isBuildPhase(this) ? materials_wait_warmup : materials_wait) * getTicksASecond();

	if (next_add_time < getCTFTimer(this, player, "archer"))  // next_add_time < getCTFTimer(this, player, "builder") ||  // Waffle: No need to track this
	{
		// SetCTFTimer(this, player, getGameTime(), "builder");  // Waffle: No need to track this
		SetCTFTimer(this, player, getGameTime(), "archer");
	}
}

// Waffle: Spawn crates at each tent with team materials
void SpawnResupplies(CRules@ this)
{
    CMap@ map = getMap();
    if (map is null)
    {
        print("Failed to spawn resupplies, map was null");
        return;
    }

    bool parachute = !this.get_bool("collide with ceiling") && !isBuildPhase(this);  // From KAG.as
    f32 auto_distance_from_edge_tents = Maths::Min(map.tilemapwidth * 0.15f * 8.0f, 100.0f) * map.tilesize;
    Vec2f blue_resupply_location, red_resupply_location;
    if (!map.getMarker("blue main spawn", blue_resupply_location))
    {
        blue_resupply_location.x = auto_distance_from_edge_tents;
    }
    if (!map.getMarker("red main spawn", red_resupply_location))
    {
        red_resupply_location.x = map.tilemapwidth * map.tilesize - auto_distance_from_edge_tents;
    }

    if (parachute)
    {
        blue_resupply_location.y = -10 * map.tilesize;
        red_resupply_location.y = blue_resupply_location.y;
    }
    SpawnResupply(this, blue_resupply_location, 0, parachute);
    SpawnResupply(this, red_resupply_location,  1, parachute);
			
}

// Waffle: Spawn crate at location with team materials
void SpawnResupply(CRules@ this, Vec2f pos, u8 team, bool parachute)
{
    if (isServer())
    {
        CBlob@ crate = server_CreateBlob("crate", team, pos);
        if (crate !is null)
        {
			if (parachute)
			{
				crate.Tag("parachute");
			}
            crate.SetFacingLeft(team == 1);
            SetMaterials(crate, "mat_wood",  isBuildPhase(this) ? crate_warmup_wood_amount  : crate_wood_amount);
            SetMaterials(crate, "mat_stone", isBuildPhase(this) ? crate_warmup_stone_amount : crate_stone_amount);
        }
    }
    else
    {
        Sound::Play("spawn.ogg");
    }
}

// Waffle: Set timer on state change
void onStateChange(CRules@ this, const u8 oldState)
{
    if (!isBuildPhase(this))
    {
		this.set_s32(RESUPPLY_TIME_STRING, getGameTime() + crate_wait);
    }
}

bool isBuildPhase(CRules@ this)
{
	return this.isWarmup() || this.isIntermission();
}