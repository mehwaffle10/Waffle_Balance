//common "can a plant grow at this tile" code

bool isNotTouchingOthers(CBlob@ this)
{
	CBlob@[] overlapping;

	if (this.getOverlapping(@overlapping))
	{
		for (uint i = 0; i < overlapping.length; i++)
		{
			CBlob@ blob = overlapping[i];
			if (blob.getName() == "seed" || blob.getName() == "tree_bushy" || blob.getName() == "tree_pine")
			{
				return false;
			}
		}
	}

	return true;
}

bool canGrowAt(CBlob@ this, Vec2f pos)
{
	if (!this.getShape().isStatic()) // they can be static from grid placement
	{
		if (!this.isOnGround() || this.isInWater() || this.isAttached() || !isNotTouchingOthers(this))
		{
			return false;
		}
	}

	CMap@ map = this.getMap();

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
	u16 type = map.getTile(Vec2f(pos.x, pos.y + 8)).type;
	return map.isTileGround(type) || map.isTileStone(type) || map.isTileThickStone(type) || map.isTileBedrock(type) || map.isTileGold(type);
}
