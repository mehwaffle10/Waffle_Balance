

const string GHOST_BLOCKS = "client_ghost_blocks";
const u8 GHOST_TRANSPARENCY = 120;

Vertex[] v_raw;

class GhostBlock
{
	string name;
	string icon;
	Vec2f pos;
	f32 halfWidth;
	f32 angle;
	f32 z;
}

class GhostBlocks
{
    GhostBlock[] blocks;

    GhostBlocks()
    {
        blocks = GhostBlock[]();
    }

	void onRender()
	{
		for (u8 i = 0; i < blocks.length; i++)
		{
			GhostBlock@ block = blocks[i];
			if (block is null) return;

			DrawGhostBlock(block.icon, block.pos, block.halfWidth, block.angle, block.z, SColor(GHOST_TRANSPARENCY, 255, 255, 255));
		}
	}
}

void DrawGhostBlock(string icon, Vec2f pos, f32 halfWidth, f32 buildAngle, f32 z, SColor color)
{
	Render::SetTransformWorldspace();
	v_raw.clear();
	v_raw.push_back(Vertex(pos.x - halfWidth, pos.y - halfWidth, z, buildAngle == 270 ? 1 : 0, buildAngle > 0 && buildAngle < 270 ? 1 : 0, color));
	v_raw.push_back(Vertex(pos.x + halfWidth, pos.y - halfWidth, z, buildAngle == 90 ? 0 : 1, buildAngle > 90 ? 1 : 0, color));
	v_raw.push_back(Vertex(pos.x + halfWidth, pos.y + halfWidth, z, buildAngle == 270 ? 0 : 1, buildAngle > 0 && buildAngle < 270 ? 0 : 1, color));
	v_raw.push_back(Vertex(pos.x - halfWidth, pos.y + halfWidth, z, buildAngle == 90 ? 1 : 0, buildAngle > 90 ? 0 : 1, color));
	Render::RawQuads(icon, v_raw);
}