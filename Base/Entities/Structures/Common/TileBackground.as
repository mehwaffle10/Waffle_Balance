// Blame Fuzzle.

#define SERVER_ONLY

void onSetStatic(CBlob@ this, const bool isStatic)
{

	if (!isStatic)
		return;

	if (this.exists("background tile"))
	{

		CMap@ map = getMap();
		Vec2f position = this.getPosition();
		const u16 type = this.get_TileType("background tile");

		// Waffle: Don't replace moss backwall either
		TileType existing_type = map.getTile(position).type;
		if (existing_type != CMap::tile_castle_back && !(existing_type >= CMap::tile_castle_back_moss && existing_type <= 231))
		{
			map.server_SetTile(position, type);
		}
	}

	this.getCurrentScript().runFlags |= Script::remove_after_this;

}
