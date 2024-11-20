
#include "TreeCommon.as"
#include "FireCommon.as";
#include "Help.as";

f32 segment_length = 14.0f;

void InitVars(CBlob@ this)
{
	TreeSegment[] segments;
	this.set("TreeSegments", segments);

	AddIconToken("$Tree$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16, 16), 1);
	AddIconToken("$Axe$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16, 16), 13);
	AddIconToken("$Daggar$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16, 16), 10);

	SetHelp(this, "help action2", "builder", getTranslatedString("$Axe$$Tree$Chop tree    $RMB$"), "", 3);
	SetHelp(this, "help jump", "archer", getTranslatedString("$Tree$Climb tree    $KEY_W$"), "", 2);
}

void InitTree(CBlob@ this, TreeVars@ vars)
{
	this.server_SetHealth(1.0f);
	this.set_s16(burn_duration , 1024);   //burn down
	this.Tag("tree");
	this.Tag("builder always hit");

	CShape@ shape = this.getShape();
	ShapeConsts@ consts = shape.getConsts();
	consts.mapCollisions = false;

	Vec2f pos = this.getPosition();

	//prevent building overlap
	CMap@ map = this.getMap();
	const f32 radius = map.tilesize / 2.0f;

	if (getNet().isServer())
	{
		this.set_s32("last_grew_time", vars.last_grew_time);
		this.Sync("last_grew_time", true);

        // Waffle: Break things in the way
        BreakSolids(map, this, pos - Vec2f(0, map.tilesize));
	}

	if (this.hasTag("startbig"))
	{
		int height = vars.max_height;
		int i = 0;

		while (i < height + 6)
		{
			vars.last_grew_time = getGameTime() - vars.growth_time;
			DoGrow(this, vars);
			i++;
		}

		this.getCurrentScript().tickFrequency = 0;
	}
	else if (this.exists("grown_times"))
	{
		// recreate growth
		u8 grown_times = this.get_u8("grown_times");

		for (int a = vars.grown_times; a < grown_times; a++)
		{
			DoGrow(this, vars);
		}

		if (this.exists("last_grew_time"))
		{
			vars.last_grew_time = this.get_s32("last_grew_time");
		}

	}
}

void onTick(CBlob@ this)
{
	if (!DoCollapseWhenBelow(this, 0.0f)) // if not collapsing
	{
		TreeVars@ vars;
		this.get("TreeVars", @vars);

		if (vars !is null && (getGameTime() - vars.last_grew_time >= vars.growth_time))
		{
			vars.last_grew_time = getGameTime();
			DoGrow(this, vars);
			this.set_s32("last_grew_time", vars.last_grew_time);
			this.Sync("last_grew_time", true);
		}
	}
}

bool treeBreakableTile(CMap@ map, TileType t)
{
	return map.isTileWood(t) || map.isTileCastle(t);
}

void DoGrow(CBlob@ this, TreeVars@ vars)
{
    bool start = this.hasTag("startbig");
	if (vars.height < vars.max_height)
	{
		CMap@ map = this.getMap();
		if (map !is null)
		{
            // Waffle: Break blocks and blobs smarter
            Vec2f pos = this.getPosition();
            u8 tile_count = Maths::Ceil(segment_length * (vars.height + 1) / map.tilesize);
            bool blocked = false;
            u8 offset = start ? 0 : map.tilesize / 2;
            for (u8 i = 0; i < tile_count; i++)
            {
                if (isBlockedAtPos(map, pos - Vec2f(0, map.tilesize * i - offset)))
                {
                    blocked = true;
                    break;
                }
            }

            if (blocked)
            {
                if (vars.height > 2)
                {
                    //truncate growth and continue
                    vars.max_height = vars.height;
                }
                else
                {
                    //stop growth for now, if it becomes clear we can continue
                    return;
                }
            }
            else
            {
                for (u8 i = 0; i < tile_count; i++)
                {
                    BreakSolids(map, this, pos - Vec2f(0, map.tilesize * i - offset));
                }

                vars.height++;
                addSegment(this, vars);
            }
        }
	}

	CMap@ map = getMap();
	Vec2f pos = this.getPosition();
	f32 radius = map.tilesize / 2.0f;

	if (map !is null/* && getNet().isServer()*/)
	{
		CMap::Sector@[] sectors;
		CMap::Sector@ sector_nobuild = null;
		CMap::Sector@ sector_tree = null;

		map.getSectorsAtPosition(pos, sectors); // grab all sectors

		u8 size = sectors.size();
		u16 networkID = this.getNetworkID();

		for (int a = 0; a < size; a++)
		{
			CMap::Sector@ sec = sectors[a];
			if (sec !is null)
			{
				if (sec.name == "no build" && sec.ownerID == networkID) // find one that is made by us
				{
					@sector_nobuild = @sec;
				}

				if (sec.name == "tree" && sec.ownerID == networkID)
				{
					@sector_tree = @sec;
				}
			}
		}

        u8 shift = start ? 1 : 2;  // Waffle: Fix misalignment caused by seeds
		if (sector_nobuild is null)
		{
			@sector_nobuild = map.server_AddSector(Vec2f(pos.x - radius, pos.y - radius), Vec2f(pos.x + radius, pos.y + radius * shift), "no build", "", this.getNetworkID());  // Waffle: Fix misalignment caused by seeds
		}

		if (sector_tree is null)
		{
			@sector_tree = map.server_AddSector(Vec2f(pos.x - radius, pos.y - radius), Vec2f(pos.x + radius, pos.y + radius * shift), "tree", "", this.getNetworkID());  // Waffle: Fix misalignment caused by seeds
		}

		if (sector_nobuild !is null && sector_tree !is null)
		{
			sector_nobuild.upperleft.y = sector_nobuild.lowerright.y - Maths::Ceil(segment_length * vars.height / map.tilesize) * map.tilesize;  // Waffle: Align sectors to tiles
			sector_tree.upperleft.y = sector_nobuild.upperleft.y;
		}
	}

	GrowSegments(this, vars);
	GrowSprite(this.getSprite(), vars);
	UpdateMinimapIcon(this, vars);
	vars.grown_times++;
	this.set_u8("grown_times", vars.grown_times);

	if (vars.grown_times >= 15)
		this.getCurrentScript().tickFrequency = 0;
}

void addSegment(CBlob@ this, TreeVars@ vars)
{
	TreeSegment segment;
	segment.grown_times = 0;
	segment.gotsprites = false;
	segment.height = vars.height;
	segment.flip = (vars.height + this.getNetworkID()) % 2 == 0;
	segment.length = segment_length;
	segment.r.Reset(vars.r.Next());
	TreeSegment@ tip = getLastSegment(this);

	if (tip !is null)
	{
		segment.start_pos = tip.end_pos;
		segment.angle = tip.angle;
	}
	else //first segment
	{
		segment.start_pos = Vec2f(0, 0);
		segment.angle = 0;
	}

	segment.end_pos = segment.start_pos + Vec2f(0, -segment.length).RotateBy(segment.angle, Vec2f(0, 0));
	this.push("TreeSegments", segment);
	this.server_Heal(0.666f);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	this.Damage(damage, hitterBlob);
	// tree collapse
	bool dir = velocity.x < 0.0f;
	this.set_bool("cut_down_fall_side", dir);

	if (this.getHealth() <= 0.0f)
	{
		DoCollapseWhenBelow(this, 0.0f);
	}

	return 0.0f;
}

void BreakSolids(CMap@ map, CBlob@ this, Vec2f pos)
{
    if (treeBreakableTile(map, map.getTile(pos).type))
    {
        map.server_DestroyTile(pos, 100.0f, this);
    }

    CBlob@[] blobs;
    map.getBlobsAtPosition(pos, blobs);
    for (u8 i = 0; i < blobs.length; i++)
    {
        CBlob@ blob = blobs[i];
        if (blob !is null && blob.getShape().isStatic() && (blob.hasTag("door")))  //  || blob.isPlatform()
        {
            this.server_Hit(blob, blob.getPosition(), Vec2f(0, -1.0f), 100.0f, Hitters::crush, true);
        }
    }
}

bool isBlockedAtPos(CMap@ map, Vec2f pos)
{
    return map.isTileSolid(pos) && !treeBreakableTile(map, map.getTile(pos).type);
}