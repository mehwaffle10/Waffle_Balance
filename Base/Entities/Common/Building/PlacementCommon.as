
#include "canGrow.as"  // Waffle: Use the proper function instead of copy pasting it

const f32 MAX_BUILD_LENGTH = 4.0f;

shared class BlockCursor
{
	Vec2f tileAimPos;
	bool cursorClose;
	bool buildable;
	bool supported;
	bool hasReqs;
	// for gui
	bool rayBlocked;
	bool buildableAtPos;
	Vec2f rayBlockedPos;
	bool blockActive;
	bool blobActive;
	bool sameTileOnBack;
	CBitStream missing;
    string blobName;  // Waffle: Add specific type
    u16 blockType;    // Waffle: --

	BlockCursor()
	{
		blobActive = blockActive = buildableAtPos = rayBlocked = hasReqs = supported = buildable = cursorClose = sameTileOnBack = false;
        blobName = "";  // Waffle: Add specific type
        blockType = 0;  // Waffle: --
	}
};

void AddCursor(CBlob@ this)
{
	if (!this.exists("blockCursor"))
	{
		BlockCursor bc;
		this.set("blockCursor", bc);
	}
}

bool canPlaceNextTo(CMap@ map, const Tile &in tile)
{
	return tile.support > 0;
}

bool isBuildableAtPos(CBlob@ this, Vec2f p, TileType buildTile, CBlob @blob, bool &out sameTile)
{
	f32 radius = 0.0f;
	CMap@ map = this.getMap();
	sameTile = false;

	if (blob is null) // BLOCKS
	{
		radius = map.tilesize;
	}
	else // BLOB
	{
		radius = blob.getRadius();
	}

	//check height + edge proximity
	if (p.y < 2 * map.tilesize ||
			p.x < 2 * map.tilesize ||
			p.x > (map.tilemapwidth - 2.0f)*map.tilesize)
	{
		return false;
	}

	// tilemap check
	const bool buildSolid = (map.isTileSolid(buildTile) || (blob !is null && blob.isCollidable()));
	Vec2f tilespace = map.getTileSpacePosition(p);
	const int offset = map.getTileOffsetFromTileSpace(tilespace);
	Tile backtile = map.getTile(offset);
	Tile left = map.getTile(offset - 1);
	Tile right = map.getTile(offset + 1);
	Tile up = map.getTile(offset - map.tilemapwidth);
	Tile down = map.getTile(offset + map.tilemapwidth);

	if (buildTile > 0 && buildTile < 255 && blob is null && buildTile == map.getTile(offset).type)
	{
		sameTile = true;
		return false;
	}

	if (map.isTileCollapsing(offset))
	{
		return false;
	}

	if ((buildTile == CMap::tile_wood && backtile.type >= CMap::tile_wood_d1 && backtile.type <= CMap::tile_wood_d0) ||
			(buildTile == CMap::tile_castle && backtile.type >= CMap::tile_castle_d1 && backtile.type <= CMap::tile_castle_d0))
	{
		//repair like tiles
	}
	else if (buildTile == CMap::tile_castle && backtile.type >= CMap::tile_wood && backtile.type <= CMap::tile_wood_d0 && !map.isInFire(p))
	{
		// can build stone on wood when not on fire, do nothing
	}
	else if ((buildTile == CMap::tile_wood_back || buildTile == CMap::tile_castle_back) && 
			 (backtile.type == CMap::tile_castle_back || backtile.type >= CMap::tile_castle_back_moss && backtile.type <= 231))  // Waffle: Also protect moss backwall
	{
		//cant build wood on stone background
		return false;
	}
	else if (map.isTileSolid(backtile))
	{
		if (!buildSolid && !map.isTileSolid(backtile))
		{
			//skip onwards, platforms and doors don't block backwall
		}
		else
		{
			return false;
		}
	}

	if (
		!map.isTileBackgroundNonEmpty(backtile) &&      // can put against background
		!(                                              // can put sticking next to something
			canPlaceNextTo(map, left) ||
			canPlaceNextTo(map, right) ||
			canPlaceNextTo(map, up) ||
			canPlaceNextTo(map, down)
		)
	)
	{
		return false;
	}

	// no blocking actors?
	if (blob is null || !blob.hasTag("ignore blocking actors"))
	{
		bool isLadder = false;
		bool isSpikes = false;
		bool isDoor = false;
		bool isPlatform = false;
		bool isSeed = false;

		if (blob !is null)
		{
			const string bname = blob.getName();
			isLadder = bname == "ladder";
			isSpikes = bname == "spikes";
			isDoor = bname == "wooden_door" || bname == "stone_door" || bname == "bridge";
			isPlatform = bname == "wooden_platform";
			isSeed = bname == "seed";
		}

		Vec2f middle = p;

		s32 x = Maths::Floor(p.x);
		x /= map.tilesize;
		s32 y = Maths::Floor(p.y);
		y /= map.tilesize;

		CBlob@[] blobsAtPos;

		// repairing blobs
		if (map.getBlobsAtPosition(Vec2f(p.x, p.y), @blobsAtPos) && blob !is null && (isDoor || isPlatform))
		{
			for (uint i = 0; i < blobsAtPos.length; i++)
			{
				CBlob@ blobAtPos = blobsAtPos[i];
				if (blobAtPos.getName() == blob.getName() && 
					blobAtPos.getTeamNum() == blob.getTeamNum() && 
					blobAtPos.getHealth() != blobAtPos.getInitialHealth()) 
				{	
					return true;
				}
			}
		}

        // Waffle: Add no solids and no blobs
		CMap::Sector@[] sectors;
		map.getSectorsAtPosition(middle, sectors);
		bool no_build_sector = false;
		for (u8 i = 0; i < sectors.length; i++)
		{
			if (sectors[i] !is null && sectors[i].name == "no build")
			{
				if (blob !is null && blob.isPlatform())
				{
					CBlob@ owner = getBlobByNetworkID(sectors[i].ownerID);
					if (owner is null || !(owner.hasTag("tree") || owner.hasTag("scenary")))
					{
						no_build_sector = true;
						break;
					}
				}
				else
				{
					no_build_sector = true;
					break;
				}
			}
		}
        const bool no_build  = !isLadder && (buildSolid || isSpikes || isDoor || isPlatform) && no_build_sector;
        const bool no_solids = buildSolid && map.getSectorAtPosition(middle, "no solids") !is null;
        const bool no_blobs  = blob !is null && map.getSectorAtPosition(middle, "no blobs") !is null;
        const bool has_adjacent = map.isTileSolid(up) || map.isTileSolid(down) || map.isTileSolid(left) || map.isTileSolid(right);
		if (!isSeed && (no_build || (!isSpikes || has_adjacent) && (no_solids || no_blobs)))  // Waffle: Allow spike dropping at the top of the map
		{
			return false;
		}

		//if (blob is null)
		//middle += Vec2f(map.tilesize*0.5f, map.tilesize*0.5f);
        if (!isLadder)
        {
            const string name = blob !is null ? blob.getName() : "";
            CBlob@[] blobsInRadius;
            if (map.getBlobsInRadius(middle, buildSolid ? map.tilesize : 0.0f, @blobsInRadius))
            {
                for (uint i = 0; i < blobsInRadius.length; i++)
                {
                    CBlob @b = blobsInRadius[i];
                    if (!b.isAttached() && b !is blob)
                    {
                        if (blob !is null || buildSolid)
                        {
                            if (b is this && b.getName() == "spikes") continue;

                            Vec2f bpos = b.getPosition();

                            bool cantBuild = isBlocking(b) || isSeed && b.getName() == "seed";  // Waffle: Prevent seeds from being placed on each other
                            bool buildingOnTeam = isDoor && (b.getTeamNum() == this.getTeamNum() || b.getTeamNum() == 255) && !b.getShape().isStatic() && this !is b;
                            bool ladderBuild = isLadder && !b.getShape().isStatic();

                            // cant place on any other blob
                            if (!ladderBuild &&
                                !buildingOnTeam &&
                                cantBuild &&
                                !b.hasTag("dead") &&
                                !b.hasTag("material") &&
                                !b.hasTag("projectile") &&
                                !(isSeed && (b.hasTag("building") || !b.getShape().isStatic())) &&  // Waffle: Allow placing seeds on building and non-static blobs
								!(blob !is null && blob.isPlatform() && b.hasTag("tree")))  // Waffle: Allow building platforms on trees 
                            {
                                f32 angle_decomp = Maths::FMod(Maths::Abs(b.getAngleDegrees()), 180.0f);
                                bool rotated = angle_decomp > 45.0f && angle_decomp < 135.0f;
                                f32 width = rotated ? b.getHeight() : b.getWidth();
                                f32 height = rotated ? b.getWidth() : b.getHeight();
                                if ((middle.x > bpos.x - width * 0.5f) && (middle.x < bpos.x + width * 0.5f)
                                    && (middle.y > bpos.y - height * 0.5f) && (middle.y < bpos.y + height * 0.5f))
                                {
                                    return false;
                                }
                            }
                        }
                    }
                }
            }
        }

		if (isSeed)
		{
			// from canGrow.as
			return canGrowAt(blob, p, true);  // Waffle: Use the proper function instead of copy pasting it
			// return (map.isTileGround(map.getTile(p + Vec2f(0, 8)).type));

		}
	}

	return true;
}

bool isBlocking(CBlob@ blob)
{
	if ((blob.hasTag("pushedByDoor") && !blob.getShape().isStatic()) || blob.hasTag("scenary") || blob.hasTag("projectile"))  // Waffle: Don't build on static things that can be pushed by doors
		return false;

	return blob.isCollidable() || blob.getShape().isStatic();
}

void DestroyScenary(Vec2f tl, Vec2f br)
{
	if (getNet().isServer())
	{
		CMap@ map = getMap();

		CBlob@[] overlapping;
		map.getBlobsInBox(tl, br, @overlapping);
		for (uint i = 0; i < overlapping.length; i++)
		{
			CBlob@ blob = overlapping[i];
			if (blob !is null && blob.hasTag("scenary"))
			{
				blob.server_Die();
			}

		}
	}
}

void SetTileAimpos(CBlob@ this, BlockCursor@ bc)
{
	// calculate tile mouse pos
	Vec2f pos = this.getPosition();
	Vec2f aimpos = this.getAimPos();
	Vec2f mouseNorm = aimpos - pos;
	f32 mouseLen = mouseNorm.Length();
	const f32 maxLen = MAX_BUILD_LENGTH;
	mouseNorm /= mouseLen;

	if (mouseLen > maxLen * getMap().tilesize)
	{
		f32 d = maxLen * getMap().tilesize;
		Vec2f p = pos + Vec2f(d * mouseNorm.x, d * mouseNorm.y);
		p = getMap().getTileSpacePosition(p);
		bc.tileAimPos = getMap().getTileWorldPosition(p);
	}
	else
	{
		bc.tileAimPos = getMap().getTileSpacePosition(aimpos);
		bc.tileAimPos = getMap().getTileWorldPosition(bc.tileAimPos);
	}

	bc.cursorClose = (mouseLen < getMaxBuildDistance(this));
}

u32 getCurrentBuildDelay(CBlob@ this)
{
	return (getRules().getCurrentState() != GAME ? this.get_u32("warmup build delay") : this.get_u32("build delay"));
}

f32 getMaxBuildDistance(CBlob@ this)
{
	return (MAX_BUILD_LENGTH + 0.51f) * getMap().tilesize;
}

void SetupBuildDelay(CBlob@ this)
{
	this.set_u32("build time", getGameTime());
	this.set_u32("build delay", 7);
	this.set_u32("warmup build delay", 7);  // Waffle: Same building in build phase since it's short
}

bool isBuildDelayed(CBlob@ this)
{
	return (getGameTime() <= this.get_u32("build time"));
}

void SetBuildDelay(CBlob@ this)
{
	SetBuildDelay(this, this.get_u32("build delay"));
}

void SetBuildDelay(CBlob@ this, uint time)
{
	this.set_u32("build time", getGameTime() + time);
}

bool isBuildRayBlocked(Vec2f pos, Vec2f target, Vec2f &out point)
{
	CMap@ map = getMap();

	Vec2f vector = target - pos;
	vector.Normalize();
	target -= vector * map.tilesize;

	f32 halfsize = map.tilesize * 0.5f;

	return map.rayCastSolid(pos + Vec2f(0, halfsize), target, point) &&
		   map.rayCastSolid(pos + Vec2f(halfsize, 0), target, point) &&
		   map.rayCastSolid(pos + Vec2f(0, -halfsize), target, point) &&
		   map.rayCastSolid(pos + Vec2f(-halfsize, 0), target, point);
}

bool inNoBuildZone(CMap@ map, Vec2f here, TileType buildTile)
{
	return inNoBuildZone(null, map, here, buildTile);
}

bool inNoBuildZone(CBlob@ blob, CMap@ map, Vec2f here, TileType buildTile)
{
	bool isLadder = false;
	bool isSpikes = false;
	if (blob !is null)
	{
		const string bname = blob.getName();
		isLadder = bname == "ladder";
		isSpikes = bname == "spikes";
	}

	const bool buildSolid = (map.isTileSolid(buildTile) || (blob !is null && blob.isCollidable()));

	return (!isLadder && (buildSolid || isSpikes) && map.getSectorAtPosition(here, "no build") !is null);
}

// This has to exist due to an engine issue where CMap.hasTileSolidBlobs() returns false if the blobtile was placed in the previous tick
// and an engine issue where CMap.getBlobsFromTile() crashes the server 
// wonderful game
bool fakeHasTileSolidBlobs(Vec2f cursorPos)
{
	CMap@ map = getMap();
	CBlob@[] blobsAtPos;
	
	map.getBlobsAtPosition(cursorPos + Vec2f(1, 1), blobsAtPos);

	for (int i = 0; i < blobsAtPos.size(); i++)
	{
		CBlob@ blobAtPos = blobsAtPos[i];
		
		if (isRepairable(blobAtPos)) return true;
	}

	return false;
}

bool isRepairable(CBlob@ blob)
{
	// the getHealth() check is here because apparently a blob isn't null for a tick (?) after being destroyed
	if (blob !is null && 
		blob.getHealth() > 0 && (
		blob.hasTag("door") || 
		blob.getName() == "wooden_platform" || 
		blob.getName() == "bridge"))
		{
			return true;
		}

	return false;
}