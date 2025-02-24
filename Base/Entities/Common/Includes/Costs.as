// Costs.as
//
//	defines the costs of items in the game
//	the values are set in InitCosts,
//	to prevent them from lingering between

bool costs_loaded = false;

//// CTF COSTS ////

string ctf_costs_config_file = "CTFCosts.cfg";
namespace CTFCosts
{
	// Waffle: Add quarry wood cost
	//Building.as
	s32 buildershop_wood, quarters_wood, knightshop_wood, archershop_wood,  // tunnel_gold, quarry_gold
		boatshop_wood, vehicleshop_wood, vehicleshop_gold,
		storage_stone, storage_wood, tunnel_stone, tunnel_wood,
		quarry_wood, quarry_stone, quarry_count;

	//ArcherShop.as
	s32 arrows, waterarrows, firearrows, bombarrows;

	//KnightShop.as
	s32 bomb, waterbomb, mine, keg;

	// Waffle: Trampolines and boulders only cost coins
	//BuilderShop.as
	s32 lantern_wood, bucket_wood, filled_bucket, sponge, boulder,  // boulder_stone, trampoline_wood
		trampoline, saw_wood, saw_stone, drill_stone, drill,
		crate_wood, crate;

	// Waffle: Remove warboat gold cost
	//BoatShop.as
	s32 dinghy, longboat, warboat;  // dinghy_wood, longboat_wood, warboat_gold;

	// Waffle: Remove outposts and ballista gold cost
	//VehicleShop.as
	s32 catapult, ballista, ballista_ammo, ballista_bomb_ammo;  // ballista_gold, outpost_coins, outpost_gold;

    // Waffle: Buy chickens directly instead of eggs
	//Quarters.as
	s32 beer, meal, chicken, burger, seed;  // egg

	//CommonBuilderBlocks.as
	s32 workshop_wood;
}

//// TTH COSTS ////
string war_costs_config_file = "WARCosts.cfg";
namespace WARCosts
{
	// Waffle: Trampolines cost coins alongside the wood
	//Workbench.as
	s32 lantern_wood, bucket_wood, sponge_wood, trampoline, trampoline_wood,
		crate_wood, drill_stone, saw_wood, dinghy_wood, boulder_stone;

	//Scrolls
	s32 crappiest_scroll, crappy_scroll, medium_scroll,
		big_scroll, super_scroll;

	//Builder Menu
	s32 factory_wood, workbench_wood;

	//WAR_Base.as
	s32 tunnel_stone, kitchen_wood;
}

//// BUILDER COSTS ////
string builder_costs_config_file = "BuilderCosts.cfg";
namespace BuilderCosts
{
	s32 stone_block, back_stone_block, stone_door, wood_block, back_wood_block,
		wooden_door, trap_block, bridge, ladder, wooden_platform, spikes;
}

s32 ReadCost(ConfigFile cfg, dictionary@ costs, const string &in cost_name, s32 &in cost)
{
	if (!costs.get(cost_name, cost) && cfg.exists(cost_name))
	{
		cost = cfg.read_s32(cost_name, cost);
		costs.set(cost_name, cost);
	}

	return cost;
}

void InitCosts()
{
	if (costs_loaded) return;

	costs_loaded = true;

	CRules@ rules = getRules();
	dictionary temporary;
	if (!rules.get("costs", temporary))
		rules.set("costs", temporary);

	dictionary@ costs;
	rules.get("costs", @costs);

	ConfigFile cfg;

	// ctf costs ///////////////////////////////////////////////////////////////
	if (rules.exists("ctf_costs_config"))
		ctf_costs_config_file = rules.get_string("ctf_costs_config");

	cfg.loadFile(ctf_costs_config_file);

	//Building.as
	CTFCosts::buildershop_wood =            ReadCost(cfg, costs, "cost_buildershop_wood"   , 50);
	CTFCosts::quarters_wood =               ReadCost(cfg, costs, "cost_quarters_wood"      , 50);
	CTFCosts::knightshop_wood =             ReadCost(cfg, costs, "cost_knightshop_wood"    , 50);
	CTFCosts::archershop_wood =             ReadCost(cfg, costs, "cost_archershop_wood"    , 50);
	CTFCosts::boatshop_wood =               ReadCost(cfg, costs, "cost_boatshop_wood"      , 100);
	CTFCosts::vehicleshop_wood =            ReadCost(cfg, costs, "cost_vehicleshop_wood"   , 250);  // Waffle: Vehicle shop costs 400 wood
	// CTFCosts::vehicleshop_gold =         ReadCost(cfg, costs, "cost_vehicleshop_gold"   , 50);   // Waffle: Vehicle shops no longer cost gold
	CTFCosts::storage_stone =               ReadCost(cfg, costs, "cost_storage_stone"      , 50);
	CTFCosts::storage_wood =                ReadCost(cfg, costs, "cost_storage_wood"       , 50);
	CTFCosts::tunnel_stone =                ReadCost(cfg, costs, "cost_tunnel_stone"       , 150);  // Waffle: Tunnel costs 150 stone
	CTFCosts::tunnel_wood =                 ReadCost(cfg, costs, "cost_tunnel_wood"        , 350);  // Waffle: Tunnel costs 500 wood
	// CTFCosts::tunnel_gold =              ReadCost(cfg, costs, "cost_tunnel_gold"        , 200);  // Waffle: Tunnels no longer cost gold
	CTFCosts::quarry_wood =                 ReadCost(cfg, costs, "cost_quarry_wood"        , 100);  // Waffle: Quarries cost 250 wood
	CTFCosts::quarry_stone =				ReadCost(cfg, costs, "cost_quarry_stone"       , 50);   // Waffle: Quarries cost 50 stone
	// CTFCosts::quarry_gold =			    ReadCost(cfg, costs, "cost_quarry_gold"        , 80);   // Waffle: Quarries no longer cost gold
	// CTFCosts::quarry_count =				ReadCost(cfg, costs, "cost_quarry_count"       , 1);    // Waffle: No quarry limit

	//ArcherShop.as
	CTFCosts::arrows =                      ReadCost(cfg, costs, "cost_arrows"             , 15);
	CTFCosts::waterarrows =                 ReadCost(cfg, costs, "cost_waterarrows"        , 25);  // Waffle: Increase water arrow cost
	CTFCosts::firearrows =                  ReadCost(cfg, costs, "cost_firearrows"         , 50);  // Waffle: Increase fire arrow cost
	CTFCosts::bombarrows =                  ReadCost(cfg, costs, "cost_bombarrows"         , 75);  // Waffle: Increase bomb arrow cost

	//KnightShop.as
	CTFCosts::bomb =                        ReadCost(cfg, costs, "cost_bomb"               , 25);
	CTFCosts::waterbomb =                   ReadCost(cfg, costs, "cost_waterbomb"          , 30);
	CTFCosts::mine =                        ReadCost(cfg, costs, "cost_mine"               , 60);
	CTFCosts::keg =                         ReadCost(cfg, costs, "cost_keg"                , 200);  // Waffle: Offset strength of circular kegs

	//BuilderShop.as
	CTFCosts::lantern_wood =                ReadCost(cfg, costs, "cost_lantern_wood"       , 10);
	CTFCosts::bucket_wood =                 ReadCost(cfg, costs, "cost_bucket_wood"        , 10);
	CTFCosts::filled_bucket =               ReadCost(cfg, costs, "cost_filled_bucket"      , 15);   // Waffle: Make buckets more expensive
	CTFCosts::sponge =                      ReadCost(cfg, costs, "cost_sponge"             , 10);   // Waffle: Make sponges cheaper
	CTFCosts::boulder =                     ReadCost(cfg, costs, "cost_boulder"    		   , 40);   // Waffle: Boulders only cost coins
	// CTFCosts::boulder_stone =            ReadCost(cfg, costs, "cost_boulder_stone"      , 30);   // Waffle: Boulders no longer cost materials
	CTFCosts::trampoline =             		ReadCost(cfg, costs, "cost_trampoline"    	   , 120);  // Waffle: Trampolines only cost coins
	// CTFCosts::trampoline_wood =          ReadCost(cfg, costs, "cost_trampoline_wood"    , 100);  // Waffle: Trampolines no longer cost materials
	CTFCosts::saw_wood =                    ReadCost(cfg, costs, "cost_saw_wood"           , 150);
	CTFCosts::saw_stone =                   ReadCost(cfg, costs, "cost_saw_stone"          , 100);
	CTFCosts::drill_stone =                 ReadCost(cfg, costs, "cost_drill_stone"        , 100);
	CTFCosts::drill =                       ReadCost(cfg, costs, "cost_drill"              , 25);
	CTFCosts::crate_wood =                  ReadCost(cfg, costs, "cost_crate_wood"         , 150);
	CTFCosts::crate =                       ReadCost(cfg, costs, "cost_crate"              , 20);

	//BoatShop.as
	CTFCosts::dinghy =                      ReadCost(cfg, costs, "cost_dinghy"             , 40);
	// CTFCosts::dinghy_wood =              ReadCost(cfg, costs, "cost_dinghy_wood"        , 100);  // Waffle: Remove wood cost on dinghies
	CTFCosts::longboat =                    ReadCost(cfg, costs, "cost_longboat"           , 200);  // Waffle: Increase longboat cost
	// CTFCosts::longboat_wood =            ReadCost(cfg, costs, "cost_longboat_wood"      , 200);  // Waffle: Remove wood cost on longboats
	CTFCosts::warboat =                     ReadCost(cfg, costs, "cost_warboat"            , 300);  // Waffle: Increase warboat cost
	// CTFCosts::warboat_gold =             ReadCost(cfg, costs, "cost_warboat_gold"       , 50);

	//VehicleShop.as
	CTFCosts::catapult =                    ReadCost(cfg, costs, "cost_catapult"                   , 225);  // Waffle: Increase catapult cost
	CTFCosts::ballista =                    ReadCost(cfg, costs, "cost_ballista"                   , 200);  // Waffle: Increase ballista cost
	// CTFCosts::ballista_gold =            ReadCost(cfg, costs, "cost_ballista_gold"              , 50);
	CTFCosts::ballista_ammo =               ReadCost(cfg, costs, "cost_ballista_ammo"              , 80);
	CTFCosts::ballista_bomb_ammo =          ReadCost(cfg, costs, "cost_ballista_bomb_ammo"         , 150);  // Waffle: Increase bomb bolt cost
	// CTFCosts::outpost_coins =		    ReadCost(cfg, costs, "cost_outpost_coins"			   , 150);  // Waffle: Remove outposts
	// CTFCosts::outpost_gold =				ReadCost(cfg, costs, "cost_outpost_gold"			   , 50);

	//Quarters.as
	CTFCosts::beer =                        ReadCost(cfg, costs, "cost_beer"               , 5);
	CTFCosts::meal =                        ReadCost(cfg, costs, "cost_meal"               , 10);
	CTFCosts::chicken =                     ReadCost(cfg, costs, "cost_chicken"            , 50);   // Waffle: Chickens are bought directly instead of eggs
	CTFCosts::burger =                      ReadCost(cfg, costs, "cost_burger"             , 20);
	CTFCosts::seed =                        ReadCost(cfg, costs, "cost_seed"               , 100);  // Waffle: Seeds can be bought from quarters

	//CommonBuilderBlocks.as
	CTFCosts::workshop_wood =               ReadCost(cfg, costs, "cost_workshop_wood"      , 150);

	// war costs ///////////////////////////////////////////////////////////////

	//load config
	if (rules.exists("war_costs_config"))
		war_costs_config_file = rules.get_string("war_costs_config");

	cfg.loadFile(war_costs_config_file);

	//Workbench.as
	WARCosts::lantern_wood =            ReadCost(cfg, costs, "cost_lantern_wood"       , 10);
	WARCosts::bucket_wood =             ReadCost(cfg, costs, "cost_bucket_wood"        , 10);
	WARCosts::sponge_wood =             ReadCost(cfg, costs, "cost_sponge_wood"        , 50);
	WARCosts::trampoline =         		ReadCost(cfg, costs, "cost_trampoline"    		, 80);   // Waffle: Trampolines cost coins alongside the wood
	WARCosts::trampoline_wood =         ReadCost(cfg, costs, "cost_trampoline_wood"    , 100);  // Waffle: Trampolines only cost wood from a single resupply
	WARCosts::crate_wood =              ReadCost(cfg, costs, "cost_crate_wood"         , 30);
	WARCosts::drill_stone =             ReadCost(cfg, costs, "cost_drill_stone"        , 100);
	WARCosts::saw_wood =                ReadCost(cfg, costs, "cost_saw_wood"           , 150);
	WARCosts::dinghy_wood =             ReadCost(cfg, costs, "cost_dinghy_wood"        , 100);
	WARCosts::boulder_stone =           ReadCost(cfg, costs, "cost_boulder_stone"      , 30);

	//Scrolls
	WARCosts::crappiest_scroll =        ReadCost(cfg, costs, "cost_crappiest_scroll"   , 60);
	WARCosts::crappy_scroll =           ReadCost(cfg, costs, "cost_crappy_scroll"      , 100);
	WARCosts::medium_scroll =           ReadCost(cfg, costs, "cost_medium_scroll"      , 200);
	WARCosts::big_scroll =              ReadCost(cfg, costs, "cost_big_scroll"         , 300);
	WARCosts::super_scroll =            ReadCost(cfg, costs, "cost_super_scroll"       , 500);

	//CommonBuilderBlocks.as
	WARCosts::factory_wood =            ReadCost(cfg, costs, "cost_factory_wood"       , 150);
	WARCosts::workbench_wood =          ReadCost(cfg, costs, "cost_workbench_wood"     , 120);

	//WAR_Base.as
	WARCosts::tunnel_stone =            ReadCost(cfg, costs, "cost_tunnel_stone"       , 100);
	WARCosts::kitchen_wood =            ReadCost(cfg, costs, "cost_kitchen_wood"       , 100);

	// builder costs ////////////////////////////////////////////////////////////

	cfg.loadFile(builder_costs_config_file);

	BuilderCosts::stone_block =         ReadCost(cfg, costs, "cost_stone_block"        , 10);
	BuilderCosts::back_stone_block =    ReadCost(cfg, costs, "cost_back_stone_block"   , 2);
	BuilderCosts::stone_door =          ReadCost(cfg, costs, "cost_stone_door"         , 50);
	BuilderCosts::wood_block =          ReadCost(cfg, costs, "cost_wood_block"         , 10);
	BuilderCosts::back_wood_block =     ReadCost(cfg, costs, "cost_back_wood_block"    , 2);
	BuilderCosts::wooden_door =         ReadCost(cfg, costs, "cost_wooden_door"        , 30);
	BuilderCosts::trap_block =          ReadCost(cfg, costs, "cost_trap_block"         , 25);
	BuilderCosts::bridge =              ReadCost(cfg, costs, "cost_bridge"             , 30);
	BuilderCosts::ladder =              ReadCost(cfg, costs, "cost_ladder"             , 10);
	BuilderCosts::wooden_platform =     ReadCost(cfg, costs, "cost_wooden_platform"    , 15);
	BuilderCosts::spikes =              ReadCost(cfg, costs, "cost_spikes"             , 30);
}
