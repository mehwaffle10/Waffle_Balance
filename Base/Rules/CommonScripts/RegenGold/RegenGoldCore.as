
#include "RegenGoldCommon.as"

#define SERVER_ONLY

const string NEXT_REGEN_TIME = "next regen time";

void onTick(CRules@ this)
{
	if (this.isMatchRunning() && this.get_u32(NEXT_REGEN_TIME) <= getGameTime())
	{
		CMap@ map = getMap();
		if (map is null)
		{
			return;
		}

		MapLocations@ gold_locations;
   		this.get(GOLD_LOCATIONS, @gold_locations);
		for (u16 i = 0; i < gold_locations.locations.length; i++)
		{
			Vec2f gold_location = gold_locations.locations[i];
			u16 tile_type = map.getTile(gold_location).type;

			if (tile_type < 91 || tile_type > 94)
			{
				continue;
			}

			map.server_SetTile(gold_location, tile_type == 91 ? CMap::tile_gold : tile_type - 1);
		}

		SetNextRegenTime(this);
	}
}

void onStateChange(CRules@ this, const u8 oldState)
{
	if (!this.isMatchRunning())
	{
		return;
	}
	SetNextRegenTime(this);
}

void SetNextRegenTime(CRules@ this)
{
	this.set_u32(NEXT_REGEN_TIME, getGameTime() + GOLD_REGEN_SECONDS * getTicksASecond());
}