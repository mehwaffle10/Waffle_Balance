

const string GHOST_BLOCKS = "client_ghost_blocks";
const u16 GHOST_LIFESPAN = 500;
const SColor GHOST_COLOR = SColor(120, 255, 255, 255);

Vertex[] v_raw;

class GhostBlock
{
	TileType tile;
	string name;
	string icon;
	Vec2f tilePos;
	f32 halfWidth;
	f32 angle;
	bool flip;
	u32 expires;
	u8 support;
	u16 woodCost;
	u16 stoneCost;

	GhostBlock(TileType _tile, string _name, string _icon, Vec2f _tilePos, f32 _halfWidth, f32 _angle, bool _flip, u8 _support, u16 _woodCost, u16 _stoneCost)
	{
		tile = _tile;
		name = _name;
		icon = _icon;
		tilePos = _tilePos;
		halfWidth = _halfWidth;
		angle = _angle;
		flip = _flip;
		support = _support;
		woodCost = _woodCost;
		stoneCost = _stoneCost;
		expires = getGameTime() + GHOST_LIFESPAN;
	}
}

class GhostBlocks
{
    GhostBlock[] blocks;

    GhostBlocks()
    {
        blocks = GhostBlock[]();
    }

	void add(TileType tile, string name, string icon, Vec2f tilePos, f32 halfWidth, f32 angle, bool flip, u8 support, u16 woodCost, u16 stoneCost)
	{
		blocks.push_back(GhostBlock(tile, name, icon, tilePos, halfWidth, angle, flip, support, woodCost, stoneCost));
	}
}

GhostBlocks@ getGhostBlocks()
{
	CRules@ rules = getRules();
	GhostBlocks@ ghostBlocks;
	rules.get(GHOST_BLOCKS, @ghostBlocks);
	if (ghostBlocks is null)
	{
		@ghostBlocks = GhostBlocks();
		rules.set(GHOST_BLOCKS, @ghostBlocks);
	}
	return ghostBlocks;
}

void RenderGhostBlocks(CMap@ map)
{
	GhostBlocks@ ghostBlocks = getGhostBlocks();
	u8 i = 0;
	while (i < ghostBlocks.blocks.length)
	{
		GhostBlock@ block = ghostBlocks.blocks[i];
		if (block is null) return;

		if (getGameTime() >= block.expires)
		{
			ghostBlocks.blocks.removeAt(i);
			continue;
		}

		DrawGhostBlock(block.icon, (block.tilePos + Vec2f(0.5f, 0.5f)) * map.tilesize, block.halfWidth, block.angle, block.flip, GHOST_COLOR);
		i++;
	}
}

SColor getInterpolatedColorAtPosition(CMap@ map, SColor color, Vec2f pos, bool interporlateColor, CBlob@ localBlob)
{
	if (!interporlateColor) return color;

	// This returns RGBA instead of ARGB for some reason so rotate values
	SColor posColor = map.getColorLight(pos);
	uint alpha = posColor.getBlue();
	posColor.setBlue(posColor.getGreen());
	posColor.setGreen(posColor.getRed());
	posColor.setRed(posColor.getAlpha());
	posColor.setAlpha(alpha);

	// Players illuminate themselves locally, keep the block somewhat lit
	f32 lowerBound = 0.0f;
	if (localBlob !is null)
	{
		f32 length = (localBlob.getPosition() - pos).Length();
		const u8 start = 30;
		const u8 end = 18;
		if (length < start)
		{
			if (length < end)
			{
				lowerBound = 0.5f;
			}
			else
			{
				lowerBound = Maths::Lerp(0.5f, 0.0f, (length - end) / (start - end));
			}
		}
	}

	// Luminance is a value from 0 to 255, whereas getInterpolated wants a percent
	return color.getInterpolated(color_black, Maths::Lerp(lowerBound, 1.2f, posColor.getLuminance() / 255));
}

// Screen corners and texture (UV) corners, both clockwise from top-left
const Vec2f[] QUAD_CORNERS = { Vec2f(-1, -1), Vec2f(1, -1), Vec2f(1, 1), Vec2f(-1, 1) };
const Vec2f[] UV_CORNERS   = { Vec2f( 0,  0), Vec2f(1,  0), Vec2f(1, 1), Vec2f( 0, 1) };

void DrawGhostBlock(string icon, Vec2f pos, f32 halfWidth, f32 buildAngle, bool flip, SColor color, bool setZ = false, f32 z = 0.0f, bool interporlateColor = false)
{
    CMap@ map = getMap();
    if (map is null) return;

    CPlayer@ localPlayer = getLocalPlayer();
    CBlob@ localBlob = localPlayer !is null ? localPlayer.getBlob() : null;

    const u8 minimumHalfWidth = 2;
    const u8 steps = (u16(buildAngle) / 90) % 4;  // 0, 90, 180, 270 -> 0..3

    Render::SetTransformWorldspace();
    Render::SetZBuffer(setZ, setZ);
    v_raw.clear();
    for (u8 i = 0; i < 4; i++)
    {
        Vec2f corner = QUAD_CORNERS[i];
        Vec2f uv = UV_CORNERS[(i + 4 - steps) % 4];  // rotate by shifting which UV corner goes where
        if (flip) uv.x = 1.0f - uv.x;                // mirror the texture horizontally

        SColor c = getInterpolatedColorAtPosition(map, color, pos + corner * minimumHalfWidth, interporlateColor, localBlob);
        v_raw.push_back(Vertex(pos + corner * halfWidth, z, uv, c));
    }
    Render::RawQuads(icon, v_raw);
}

void AddGhostBlock(TileType tile, string name, string icon, Vec2f tilePos, f32 halfWidth, f32 angle, bool flip, u8 support, u16 woodCost, u16 stoneCost)
{
	GhostBlocks@ ghostBlocks = getGhostBlocks();
	ghostBlocks.add(tile, name, icon, tilePos, halfWidth, angle, flip, support, woodCost, stoneCost);
}

void DeleteGhostBlockTilePos(Vec2f tilePos, TileType tile, CBlob@ blob)
{
	GhostBlocks@ ghostBlocks = getGhostBlocks();
	for (u8 i = 0; i < ghostBlocks.blocks.length; i++)
	{
		GhostBlock@ block = ghostBlocks.blocks[i];
		if (block is null || block.tilePos != tilePos) continue;
		if (tile != block.tile && (blob is null || blob.getName() != block.name)) continue;
		block.expires = getGameTime();
		break;
	}
}

bool isGhostBlocked(Vec2f tilePos)
{
	GhostBlocks@ ghostBlocks = getGhostBlocks();
	for (u8 i = 0; i < ghostBlocks.blocks.length; i++)
	{
		GhostBlock@ block = ghostBlocks.blocks[i];
		if (block is null) return false;
		if (tilePos == block.tilePos) return true;
	}
	return false;
}

bool hasGhostSupport(Vec2f tilePos)
{
	GhostBlocks@ ghostBlocks = getGhostBlocks();
	for (u8 i = 0; i < ghostBlocks.blocks.length; i++)
	{
		GhostBlock@ block = ghostBlocks.blocks[i];
		if (block is null) return false;
		if (block.support == 0) continue;
		Vec2f difference = tilePos - block.tilePos;
		if (difference.getLength() != 1) continue;
		if (difference.y <= 0) return true;
	}
	return false;
}

u16 getTotalGhostBlockCost(string blobName)
{
	GhostBlocks@ ghostBlocks = getGhostBlocks();
	u16 sum = 0;
	for (u8 i = 0; i < ghostBlocks.blocks.length; i++)
	{
		GhostBlock@ block = ghostBlocks.blocks[i];
		if (block is null) continue;
		if (blobName == "mat_wood")  sum += block.woodCost;
		if (blobName == "mat_stone") sum += block.stoneCost;
	}
	return sum;
}