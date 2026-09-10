

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
	u32 expires;
	u8 support;
	u16 woodCost;
	u16 stoneCost;

	GhostBlock(TileType _tile, string _name, string _icon, Vec2f _tilePos, f32 _halfWidth, f32 _angle, u8 _support, u16 _woodCost, u16 _stoneCost)
	{
		tile = _tile;
		name = _name;
		icon = _icon;
		tilePos = _tilePos;
		halfWidth = _halfWidth;
		angle = _angle;
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

	void add(TileType tile, string name, string icon, Vec2f tilePos, f32 halfWidth, f32 angle, u8 support, u16 woodCost, u16 stoneCost)
	{
		blocks.push_back(GhostBlock(tile, name, icon, tilePos, halfWidth, angle, support, woodCost, stoneCost));
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

		DrawGhostBlock(block.icon, (block.tilePos + Vec2f(0.5f, 0.5f)) * map.tilesize, block.halfWidth, block.angle, GHOST_COLOR);
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

void DrawGhostBlock(string icon, Vec2f pos, f32 halfWidth, f32 buildAngle, SColor color, bool setZ = false, f32 z = 0.0f, bool interporlateColor = false)
{
	CMap@ map = getMap();
	if (map is null) return;

	CPlayer@ localPlayer = getLocalPlayer();
	CBlob@ localBlob;
	if (localPlayer !is null)
	{
		@localBlob = localPlayer.getBlob();
	}

	const u8 minimumHalfWidth = 4;
	SColor topLeftColor     = getInterpolatedColorAtPosition(map, color, Vec2f(pos.x - minimumHalfWidth, pos.y - minimumHalfWidth), interporlateColor, localBlob);
	SColor topRightColor    = getInterpolatedColorAtPosition(map, color, Vec2f(pos.x + minimumHalfWidth, pos.y - minimumHalfWidth), interporlateColor, localBlob);
	SColor bottomRightColor = getInterpolatedColorAtPosition(map, color, Vec2f(pos.x + minimumHalfWidth, pos.y + minimumHalfWidth), interporlateColor, localBlob);
	SColor bottomLeftColor  = getInterpolatedColorAtPosition(map, color, Vec2f(pos.x - minimumHalfWidth, pos.y + minimumHalfWidth), interporlateColor, localBlob);

	Render::SetTransformWorldspace();
	Render::SetZBuffer(setZ, setZ);
	v_raw.clear();
	v_raw.push_back(Vertex(Vec2f(pos.x - halfWidth, pos.y - halfWidth), z, Vec2f(buildAngle == 270 ? 1 : 0, buildAngle > 0 && buildAngle < 270 ? 1 : 0), topLeftColor));
	v_raw.push_back(Vertex(Vec2f(pos.x + halfWidth, pos.y - halfWidth), z, Vec2f(buildAngle == 90 ? 0 : 1,  buildAngle > 90                    ? 1 : 0), topRightColor));
	v_raw.push_back(Vertex(Vec2f(pos.x + halfWidth, pos.y + halfWidth), z, Vec2f(buildAngle == 270 ? 0 : 1, buildAngle > 0 && buildAngle < 270 ? 0 : 1), bottomRightColor));
	v_raw.push_back(Vertex(Vec2f(pos.x - halfWidth, pos.y + halfWidth), z, Vec2f(buildAngle == 90 ? 1 : 0,  buildAngle > 90                    ? 0 : 1), bottomLeftColor));
	Render::RawQuads(icon, v_raw);
}

void AddGhostBlock(TileType tile, string name, string icon, Vec2f tilePos, f32 halfWidth, f32 angle, u8 support, u16 woodCost, u16 stoneCost)
{
	GhostBlocks@ ghostBlocks = getGhostBlocks();
	ghostBlocks.add(tile, name, icon, tilePos, halfWidth, angle, support, woodCost, stoneCost);
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