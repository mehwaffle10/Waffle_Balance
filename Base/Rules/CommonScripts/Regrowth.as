#define SERVER_ONLY

void onInit(CRules@ this)
{
	Reset(this);
}

void onReset(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	this.set_s16("regrowth", 0);
	this.set_s16("regrowth delay", 10 * getTicksASecond());
}

void onTick(CRules@ this)
{
	if (this.get_s16("regrowth delay") >= 0)
	{
		this.set_s16("regrowth", this.get_s16("regrowth") + 1);

		if (this.get_s16("regrowth") > this.get_s16("regrowth delay"))
		{
			this.set_s16("regrowth", 0);

			CMap@ map = getMap();
			Vec2f pos = Vec2f(XORRandom(map.tilemapwidth*map.tilesize), 0);

			for (int y = 0; y < map.tilemapheight; y++)
			{
				pos.y = y*map.tilesize;
				TileType type = map.getTile(pos).type;

				if (map.isTileGrass(type) && !map.isInWater(pos))
				{
					CBlob@ blob = map.getBlobAtPosition(pos);
					if(blob == null || blob.getName() != "bush")
					{
						server_CreateBlob("bush", 9, pos);
						//return;
					}
				}
				else if (map.isTileGround(type))
				{
					pos.y -= map.tilesize;
					Tile tile = map.getTile(pos);

					if (!map.isTileSolid(tile) && !map.isTileBackground(tile) && !map.isInWater(pos))
					{
						map.server_SetTile(pos, 25 + XORRandom(4));
						//return;
					}
				}
			}
		}
	}
	
}