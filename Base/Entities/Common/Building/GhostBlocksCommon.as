

const string GHOST_BLOCKS = "client_ghost_blocks";
const u16 GHOST_LIFESPAN = 500;

Vertex[] v_raw;

class GhostBlock
{
	TileType tile;
	string name;
	string icon;
	Vec2f tilePos;
	f32 halfWidth;
	f32 angle;
	f32 z;
	u32 expires;

	GhostBlock(TileType _tile, string _name, string _icon, Vec2f _tilePos, f32 _halfWidth, f32 _angle, f32 _z, u32 _expires)
	{
		tile = _tile;
		name = _name;
		icon = _icon;
		tilePos = _tilePos;
		halfWidth = _halfWidth;
		angle = _angle;
		z = _z;
		expires = _expires;
	}
}

class GhostBlocks
{
    GhostBlock[] blocks;

    GhostBlocks()
    {
        blocks = GhostBlock[]();
    }

	void onRender(CMap@ map)
	{
		u8 i = 0;
		while (i < blocks.length)
		{
			GhostBlock@ block = blocks[i];
			if (block is null) return;

			if (getGameTime() >= block.expires)
			{
				blocks.removeAt(i);
				continue;
			}

			DrawGhostBlock(map, block.icon, (block.tilePos + Vec2f(0.5f, 0.5f)) * map.tilesize, block.halfWidth, block.angle, block.z, SColor(120, 255, 255, 255));
			i++;
		}
	}

	void addGhostBlock(TileType tile, string name, string icon, Vec2f tilePos, f32 halfWidth, f32 angle, f32 z, u32 expires)
	{
		blocks.push_back(GhostBlock(tile, name, icon, tilePos, halfWidth, angle, z, expires));
	}

	void deleteTilePos(Vec2f tilePos, TileType tile, CBlob@ blob)
	{
		for (u8 i = 0; i < blocks.length; i++)
		{
			GhostBlock@ block = blocks[i];
			if (block is null || block.tilePos != tilePos) continue;
			if (tile != block.tile && (blob is null || blob.getName() != block.name)) continue;
			blocks.removeAt(i);
			break;
		}
	}
}

void DrawGhostBlock(CMap@ map, string icon, Vec2f pos, f32 halfWidth, f32 buildAngle, f32 z, SColor color)
{
	Render::SetTransformWorldspace();
	v_raw.clear();
	v_raw.push_back(Vertex(pos.x - halfWidth, pos.y - halfWidth, z, buildAngle == 270 ? 1 : 0, buildAngle > 0 && buildAngle < 270 ? 1 : 0, color));
	v_raw.push_back(Vertex(pos.x + halfWidth, pos.y - halfWidth, z, buildAngle == 90 ? 0 : 1, buildAngle > 90 ? 1 : 0, color));
	v_raw.push_back(Vertex(pos.x + halfWidth, pos.y + halfWidth, z, buildAngle == 270 ? 0 : 1, buildAngle > 0 && buildAngle < 270 ? 0 : 1, color));
	v_raw.push_back(Vertex(pos.x - halfWidth, pos.y + halfWidth, z, buildAngle == 90 ? 1 : 0, buildAngle > 90 ? 0 : 1, color));
	Render::RawQuads(icon, v_raw);
}