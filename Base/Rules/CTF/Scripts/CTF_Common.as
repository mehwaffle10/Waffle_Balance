// spawn resources
const u32 materials_wait = 20; //seconds between free mats
const u32 materials_wait_warmup = materials_wait;  // 40; //seconds between free mats  // Waffle: Make this the same since it's only for archers now

const int warmup_wood_amount = 250;
const int warmup_stone_amount = 80;

const int matchtime_wood_amount = 100;
const int matchtime_stone_amount = 30;

// Waffle: Materials for the entire team. Drop once at the start of the game
const int crate_warmup_wood_amount = 4000;  
const int crate_warmup_stone_amount = 2000;

// Waffle: Builders no longer can resupply. Crates drop for each team with team materials
const u32 crate_wait = 10 * 60 * getTicksASecond();
const int crate_wood_amount = 500;
const int crate_stone_amount = 150;

//property
const string SPAWN_ITEMS_TIMER_BUILDER = "CTF SpawnItems Builder:";
const string SPAWN_ITEMS_TIMER_ARCHER  = "CTF SpawnItems Archer:";
const string RESUPPLY_TIME_STRING = "team resupply timer";  // Waffle: Team resupply crate

string base_name() { return "tent"; }

//resupply timers
string getCTFTimerPropertyName(CPlayer@ p, string classname)
{
	if (classname == "builder")
	{
		return SPAWN_ITEMS_TIMER_BUILDER + p.getUsername();
	}
	else
	{
		return SPAWN_ITEMS_TIMER_ARCHER + p.getUsername();
	} 
}

s32 getCTFTimer(CRules@ this, CPlayer@ p, string classname)
{
	string property = getCTFTimerPropertyName(p, classname);
	if (this.exists(property))
		return this.get_s32(property);
	else
		return 0;
}

void SetCTFTimer(CRules@ this, CPlayer@ p, s32 time, string classname)
{
	string property = getCTFTimerPropertyName(p, classname);
	this.set_s32(property, time);
	this.SyncToPlayer(property, p);
}

// Waffle: Add check
bool isBuildPhase(CRules@ this)
{
	return this.isWarmup() || this.isIntermission();
}