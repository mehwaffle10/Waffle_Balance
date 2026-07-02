

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

		if (block.tile == 0)
		{
			DrawGhostBlock(map, block.icon, (block.tilePos + Vec2f(0.5f, 0.5f)) * map.tilesize, block.halfWidth, block.angle, GHOST_COLOR);
		}
		else
		{
			map.DrawTile(block.tilePos * map.tilesize, block.tile, GHOST_COLOR, getCamera().targetDistance, false);
		}
		i++;
	}
}

void DrawGhostBlock(CMap@ map, string icon, Vec2f pos, f32 halfWidth, f32 buildAngle, SColor color, bool setZ = false, f32 z = 0.0f)
{
	Render::SetTransformWorldspace();
	Render::SetZBuffer(setZ, setZ);
	Render::ClearZ();
	v_raw.clear();
	v_raw.push_back(Vertex(pos.x - halfWidth, pos.y - halfWidth, z, buildAngle == 270 ? 1 : 0, buildAngle > 0 && buildAngle < 270 ? 1 : 0, color));
	v_raw.push_back(Vertex(pos.x + halfWidth, pos.y - halfWidth, z, buildAngle == 90 ? 0 : 1, buildAngle > 90 ? 1 : 0, color));
	v_raw.push_back(Vertex(pos.x + halfWidth, pos.y + halfWidth, z, buildAngle == 270 ? 0 : 1, buildAngle > 0 && buildAngle < 270 ? 0 : 1, color));
	v_raw.push_back(Vertex(pos.x - halfWidth, pos.y + halfWidth, z, buildAngle == 90 ? 1 : 0, buildAngle > 90 ? 0 : 1, color));
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