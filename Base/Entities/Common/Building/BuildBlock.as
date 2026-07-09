
shared class BuildBlock
{
	TileType tile;
	string name;
	CBitStream reqs;
	string icon;
	string description;
	bool buildOnGround;
	Vec2f size; // used by buildOnGround blobs
	bool temporaryBlob;
	bool noRotate;    // Waffle: Client side building
	bool collidable;  // Waffle: --
	bool snapToGrid;  // Waffle: --

	BuildBlock() {} // required for handles to work

	BuildBlock(TileType _tile, string _name, string _icon, string _desc, u8 teamNum, Vec2f _size = Vec2f(8, 8), bool _noRotate = false, bool _buildOnGround = false, bool _snapToGrid = true)  // Waffle: Client side building
	{
		tile = _tile;
		name = _name;
		icon = _icon;
		description = _desc;
		temporaryBlob = true;
		buildOnGround = _buildOnGround;
		size = _size;
		noRotate = _noRotate;      // Waffle: Client side building
		snapToGrid = _snapToGrid;  // Waffle: --

		// Waffle: Client side building
		if (_buildOnGround) return;

		if (isServer())
		{
			CRules@ rules = getRules();
			string supportProperty = _name + "_support";
			string collidesProperty = _name + "_collides";
			string backgroundTileProperty = _name + "_background_tile";
			if (rules.exists(supportProperty)  &&
			    rules.exists(collidesProperty) &&
				rules.exists(backgroundTileProperty)
			) return;
			
			u8 support = 0;
			bool collides = false;
			TileType backgroundTile = 0;
			if (tile == 0)
			{
				CBlob@ blob = server_CreateBlob(_name, -1, Vec2f_zero);
				if (blob !is null)
				{
					support = blob.getShape().getConsts().support;
					collides = blob.isCollidable();
					backgroundTile = blob.get_TileType("background tile");
					blob.server_Die();
				}
			}
			else
			{
				support = 1;  // TODO: Find real way to read this
				collides = name.findFirst("back_") < 0;
			}
			rules.set_u8(supportProperty, support);
			rules.Sync(supportProperty, true);
			rules.set_bool(collidesProperty, collides);
			rules.Sync(collidesProperty, true);
			rules.set_TileType(backgroundTileProperty, backgroundTile);
			rules.Sync(backgroundTileProperty, true);
		}
		
		if (!isClient() || Texture::exists(icon)) return;

		const string FILE_NAME = getIconTokenFilename(icon);
		if (!Texture::exists(FILE_NAME))
		{
			if (!Texture::createFromFile(FILE_NAME, FILE_NAME))
			{
				warn("Failed to create texture from file");
				return;
			}
		}

		ImageData@ data = Texture::data(FILE_NAME);
		if (data is null)
		{
			warn("data is null");
			return;
		}
		f32 squareSize = Maths::Max(size.x, size.y);
		if (!Texture::createBySize(icon, squareSize, squareSize))
		{
			warn("failed to create texture");
			return;
		}
		f32 difference = Maths::Abs(size.x - size.y);
		ImageData@ new = ImageData(squareSize, squareSize);
		CMap@ map = getMap();
		s32 textureTileWidth = Texture::width(FILE_NAME) / map.tilesize;
		TileType textureTile = tile;
		if (tile == CMap::tile_wood_back)
		{
			textureTile = 173;
		}
		else if (tile == CMap::tile_castle_back)
		{
			textureTile = 69;
		}

		Vec2f tileOffset = Vec2f(textureTile % textureTileWidth, textureTile / textureTileWidth) * map.tilesize;
		u8 xOffset = size.x > size.y ? 0 : difference / 2;
		u8 yOffset = size.y > size.x ? 0 : difference / 2;
		for (u8 x = 0; x < Maths::Min(Texture::width(FILE_NAME), size.x); x++)
		{
			for (u8 y = 0; y < Maths::Min(Texture::height(FILE_NAME), size.y); y++)
			{
				new.put(x + xOffset, y + yOffset, data.get(x + tileOffset.x, y + tileOffset.y));
			}
		}
		if (teamNum > 0)
		{
			const string TEAM_PALETTE = "TeamPalette.png";
			if (!Texture::exists(TEAM_PALETTE))
			{
				Texture::createFromFile(TEAM_PALETTE, TEAM_PALETTE);
			}
			ImageData@ teamPalette = Texture::data(TEAM_PALETTE);
			array<SColor> inColors;
			array<SColor> outColors;
			for(int i = 0; i < teamPalette.height(); i++)
			{
				inColors.push_back(teamPalette.get(0, i));
				outColors.push_back(teamPalette.get(teamNum, i));
			}
			new.remap(inColors, outColors, 1, false, true);
		}
		if (!Texture::update(icon, new))
		{
			warn("failed to update texture");
		}
	}
};

u8 getBlockIndexByTile(CBlob@ this, TileType tile)
{
	BuildBlock[][]@ blocks;
	if (this.get("blocks", @blocks))
	{
		const u8 PAGE = this.get_u8("build page");

		for(uint i = 0; i < blocks[PAGE].length; i++)
		{
			BuildBlock@ b = blocks[PAGE][i];
			if (b.tile == tile)
			{
				return i;
			}
		}
	}

	return 255;
}

BuildBlock@ getBlockByIndex(CBlob@ this, u8 index)
{
	BuildBlock[][]@ blocks;
	if (this.get("blocks", @blocks))
	{
		u8 page = this.get_u8("build page");
		if (index >= blocks[page].length) {
			return null;
		} else {
			return @blocks[page][index];
		}
	}

	return null;
}

/*
// not used
TileType getTileByBlockIndex(CBlob@ this, u8 index)
{
	BuildBlock[][]@ blocks;
	if (this.get("blocks", @blocks))
	{
		if (index >= 0 && index < blocks.length)
		{
			return blocks[index].tile;
		}
	}

	warn("getTileByBlockIndex() blocks not found");
	return 0;
}
*/
