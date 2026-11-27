
#include "TreeLimitCommon.as"  // Waffle: All classes can place trees

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

		if (!isClient() || Texture::exists(icon) && Texture::width(icon) > 0 && Texture::height(icon) > 0) return;

		const string FILE_NAME = tile > 0 ? "Sprites/world.png" : getIconTokenFilename(icon);
		ImageData@ data = loadImageData(FILE_NAME);
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
		Vec2f offset = Vec2f(size.x > size.y ? 0 : 1, size.y > size.x ? 0 : 1) * difference / 2;
		ImageData@ new = ImageData(squareSize, squareSize);
		Vec2f frameOffset;
		if (tile > 0)
		{
			CMap@ map = getMap();
			s32 textureTileWidth = data.width() / map.tilesize;
			TileType textureTile = tile;
			if (tile == CMap::tile_wood_back)
			{
				textureTile = 173;
			}
			else if (tile == CMap::tile_castle_back)
			{
				textureTile = 69;
			}

			frameOffset = Vec2f(textureTile % textureTileWidth, textureTile / textureTileWidth) * map.tilesize;
		}
		else
		{
			frameOffset = Vec2f_zero;
			if (icon == "$Pine Seed$" || icon == "$Oak Seed$")
			{
				offset.y -= 2;
				frameOffset.x = size.x * 4;
				if (icon == "$Pine Seed$")
				{
					frameOffset.y = size.y;
				}
			}
		}
		for (u8 x = 0; x < Maths::Min(data.width(), size.x); x++)
		{
			for (u8 y = 0; y < Maths::Min(data.height(), size.y); y++)
			{
				new.put(x + offset.x, y + offset.y, data.get(x + frameOffset.x, y + frameOffset.y));
			}
		}
		if (teamNum > 0)
		{
			ImageData@ teamPalette = loadImageData("TeamPalette.png");
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
			return fakeTreeBuildBlock(this);
		} else {
			return @blocks[page][index];
		}
	}

	return fakeTreeBuildBlock(this);
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

// Waffle: Client side building
shared ImageData@ loadImageData(const string&in file)
{
    CFileImage image(file);
    if (!image.isLoaded() || image.getWidth() <= 0 || image.getHeight() <= 0) return null;

	ImageData@ data = ImageData(image.getWidth(), image.getHeight());
	while (image.nextPixel())
	{
		Vec2f pos = image.getPixelPosition();
		data.put(pos.x, pos.y, image.readPixel());
	}
	return data;
}

// Waffle: All classes can place trees
BuildBlock@ fakeTreeBuildBlock(CBlob@ this)
{
	CBlob@ carried = this.getCarriedBlob();
	if (!isTreeSeed(carried)) return null;

	const string treeType = carried.getInventoryName();
	const string blockProp = "fake build block " + treeType;
	BuildBlock@ block;
	if (this.get(blockProp, @block) && block !is null) return block;
	
	@block = BuildBlock(
		0,
		"seed",
		"$" + treeType + "$",
		treeType,
		0,
		Vec2f(16, 16),
		true
	);
	this.set(blockProp, @block);
	return block;
}