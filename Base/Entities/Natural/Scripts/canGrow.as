//common "can a plant grow at this tile" code

bool isNotTouchingOthers(CBlob@ this, CMap@ map, Vec2f pos)
{
	CBlob@[] overlapping;
    map.getBlobsAtPosition(pos, overlapping);
    for (uint i = 0; i < overlapping.length; i++)
    {
        CBlob@ blob = overlapping[i];
        if (blob !is this && (blob.getName() == "seed" || (!blob.hasTag("building") && blob.getShape().isStatic() && !blob.hasTag("scenary"))))
        {
            return false;
        }
    }

	return true;
}

bool canGrowAt(CBlob@ this, Vec2f pos, bool prospective=false)
{
    CMap@ map = getMap();
    // Waffle: Add prospective checking for another position
    if (prospective)
    {
        if (!map.isTileSolid(pos + Vec2f(0, map.tilesize)) || map.isInWater(pos) || !isNotTouchingOthers(this, map, pos))
        {
            return false;
        }
    }
    else if (!(this.getShape().isStatic() || this.isOnGround()) || this.isInWater() || this.isAttached() || !isNotTouchingOthers(this, map, pos))  // Waffle: Still check for static blobs
    {
        return false;
    }

	/*if ( map.isTileGrass( map.getTile( pos ) )) {
	return false;
	}*/   // waiting for better days

	// Waffle: Ignore no build from buildings
	CMap::Sector@[] sectors;
	map.getSectorsAtPosition(pos, sectors);
	for (u8 i = 0; i < sectors.length; i++)
	{
		if (sectors[i] !is null && sectors[i].name == "no build")
		{
			CBlob@ owner = getBlobByNetworkID(sectors[i].ownerID);
			if (owner is null || !owner.hasTag("building"))
			{
				return false;
			}
		}
	}

	// Waffle: Prevent trees from growing near more than one tree
	if (map.getSectorAtPosition(pos, "tree limit") !is null)
	{
		return false;
	}

	// this block of code causes a crash
	/*CBlob@[] blobs;
	map.getBlobsFromTile(map.getTile(pos), blobs);
	for (uint i = 0; i < blobs.length; i++)
	{
		CBlob@ b = blobs[i];
		string bname = b.getName();
		if ((b.isCollidable() ||
			bname == "wooden_door" ||
			bname == "stone_door"))
			return false;

	}*/

	// Waffle: Let trees grow on natural blocks
	u16 type = map.getTile(Vec2f(pos.x, pos.y + (this.getHeight() + map.tilesize) * 0.5f)).type;
	return map.isTileGround(type) || map.isTileStone(type) || map.isTileThickStone(type) || map.isTileBedrock(type) || map.isTileGold(type);
}
