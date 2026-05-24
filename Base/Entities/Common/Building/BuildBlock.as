
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

	BuildBlock() {} // required for handles to work

	BuildBlock(TileType _tile, string _name, string _icon, string _desc, u8 teamNum, Vec2f _size = Vec2f(8, 8))
	{
		tile = _tile;
		name = _name;
		icon = _icon;
		description = _desc;
		temporaryBlob = true;
		buildOnGround = false;
		size = _size;

		// Waffle: Client side building
		if (isClient() && tile == 0 && !Texture::exists(icon))
		{
			const string FILE_NAME = getIconTokenFilename(icon);
			if (!Texture::exists(FILE_NAME))
			{
				if (!Texture::createFromFile(FILE_NAME, FILE_NAME))
				{
					print("Failed to create texture from file");
					return;
				}
			}

			ImageData@ data = Texture::data(FILE_NAME);
			if (data is null)
			{
				print("data is null");
				return;
			}
			f32 squareSize = Maths::Max(size.x, size.y);
			if (!Texture::createBySize(icon, squareSize, squareSize))
			{
				print("failed to create texture");
				return;
			}
			f32 difference = Maths::Abs(size.x - size.y);
			ImageData@ new = ImageData(squareSize, squareSize);
			u8 xOffset = size.x > size.y ? 0 : difference / 2;
			u8 yOffset = size.y > size.x ? 0 : difference / 2;
			for (u8 x = 0; x < Maths::Min(Texture::width(FILE_NAME), size.x); x++)
			{
				for (u8 y = 0; y < Maths::Min(Texture::height(FILE_NAME), size.y); y++)
				{
					new.put(x + xOffset, y + yOffset, data.get(x, y));
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
				print("failed to update texture");
			}
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
