#include "/Entities/Common/Attacks/Hitters.as";
#include "/Entities/Common/Attacks/LimitedAttacks.as";

// Waffle: Increase limit to include backwall
const int pierce_amount = 15;

const f32 hit_amount_ground = 0.5f;
const f32 hit_amount_air = 1.0f;
const f32 hit_amount_air_fast = 3.0f;
const f32 hit_amount_cata = 10.0f;

void onInit(CBlob @ this)
{
	this.set_u8("launch team", 255);
	this.server_setTeamNum(-1);
	this.Tag("medium weight");

	LimitedAttack_setup(this);

	this.set_u8("blocks_pierced", 0);
	u32[] tileOffsets;
	this.set("tileOffsets", tileOffsets);

	// damage
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 1;  // Waffle: Make tick every tick to do more damage up front rather than periodically while clipping through stuff
}

void onTick(CBlob@ this)
{
	//rock and roll mode
	if (!this.getShape().getConsts().collidable)
	{
		Vec2f vel = this.getVelocity();
		f32 angle = vel.Angle();
		Slam(this, angle, vel, this.getShape().vellen * 1.5f);
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	this.set_u8("launch team", detached.getTeamNum());
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (attached.getPlayer() !is null)
	{
		this.SetDamageOwnerPlayer(attached.getPlayer());
	}

	if (attached.getName() != "catapult") // end of rock and roll
	{
		this.getShape().getConsts().mapCollisions = true;
		this.getShape().getConsts().collidable = true;
	}
	this.set_u8("launch team", attached.getTeamNum());
}

void Slam(CBlob @this, f32 angle, Vec2f vel, f32 vellen)
{
	if (vellen < 0.1f)
		return;

	CMap@ map = this.getMap();
	Vec2f pos = this.getPosition();
	HitInfo@[] hitInfos;
	u8 team = this.get_u8("launch team");

	if (map.getHitInfosFromArc(pos, -angle, 360, 8.0f, this, true, @hitInfos))  // Waffle: Rock and roll hits a full circle and a fixed distance
	{
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			f32 dmg = 2.0f;

			if (hi.blob is null) // map
			{
				if (BoulderHitMap(this, hi.hitpos, hi.tileOffset, vel, dmg, Hitters::cata_boulder))
					return;
			}
			else if (team != u8(hi.blob.getTeamNum()) || hi.blob.getShape() !is null && hi.blob.getShape().isStatic())
			{
				this.server_Hit(hi.blob, pos, vel, dmg, Hitters::cata_boulder, true);
				this.setVelocity(vel * 0.9f); //damp

				// die when hit something large
				if (hi.blob.getRadius() > 32.0f)
				{
					this.server_Hit(this, pos, vel, 10, Hitters::cata_boulder, true);
				}
			}
		}
	}

	// chew through backwalls

	// Waffle: Fix bug where it could break dirt and bedrock when trying to hit backwall bouncing off a trampoline
	Vec2f center_tile = map.getTileSpacePosition(pos) * map.tilesize;
	s8 size = 1;
	for (s8 x = -size; x <= size; x++)
	{
		s8 bound = size - Maths::Abs(x);
		for (s8 y = -bound; y <= bound; y++)
		{
			Vec2f tile_pos = center_tile + Vec2f(x, y) * map.tilesize;
			u16 type = map.getTile(tile_pos).type;
			if (type == CMap::tile_wood_back   ||  	  // Wood Backwall
				type == 207 				   ||  	  // Damaged Wood Backwall
				type == CMap::tile_castle_back ||  	  // Stone Backwall
				type >= 76 && type <= 79       ||  	  // Damaged Stone Backwall
				type == CMap::tile_castle_back_moss)  // Mossy Stone Backwall
			{
				// Waffle: Ignore no build zones
				// if (map.getSectorAtPosition(pos, "no build") !is null)
				// {
				// 	return;
				// }

				// Waffle: Backwall counts towards total too
				u8 blocks_pierced = this.get_u8("blocks_pierced");
				if (blocks_pierced < pierce_amount)
				{
					map.server_DestroyTile(tile_pos, 10.0f, this);
					this.set_u8("blocks_pierced", blocks_pierced + 1);
				}
				else
				{
					this.server_Hit(this, this.getPosition(), vel, 10, Hitters::crush, true);
				}
			}
		}
	}
}

bool BoulderHitMap(CBlob@ this, Vec2f worldPoint, int tileOffset, Vec2f velocity, f32 damage, u8 customData)
{
	//check if we've already hit this tile
	u32[]@ offsets;
	this.get("tileOffsets", @offsets);

	if (offsets.find(tileOffset) >= 0) { return false; }

	this.getSprite().PlaySound("ArrowHitGroundFast.ogg");
	f32 angle = velocity.Angle();
	CMap@ map = getMap();
	TileType t = map.getTile(tileOffset).type;
	u8 blocks_pierced = this.get_u8("blocks_pierced");
	bool stuck = false;

	if (map.isTileCastle(t) || map.isTileWood(t))
	{
		Vec2f tpos = this.getMap().getTileWorldPosition(tileOffset);
		// Waffle: Ignore no build zones
		// if (map.getSectorAtPosition(tpos, "no build") !is null)
		// {
		// 	return false;
		// }

		//make a shower of gibs here

		map.server_DestroyTile(tpos, 100.0f, this);
		Vec2f vel = this.getVelocity();
		// this.setVelocity(vel * 0.8f); //damp  // Waffle: No longer slows down when hitting blocks
		this.push("tileOffsets", tileOffset);

		if (blocks_pierced < pierce_amount)
		{
			blocks_pierced++;
			this.set_u8("blocks_pierced", blocks_pierced);
		}
		else
		{
			stuck = true;
		}
	}
	else
	{
		stuck = true;
	}

	if (velocity.LengthSquared() < 5)
		stuck = true;

	if (stuck)
	{
		this.server_Hit(this, worldPoint, velocity, 10, Hitters::crush, true);
	}

	return stuck;
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	// Waffle: Hit static blobs in rock and roll mode
	if (!this.getShape().getConsts().collidable && blob !is null && blob.getShape() !is null && blob.getShape().isStatic())
	{
		u8 blocks_pierced = this.get_u8("blocks_pierced");
		if (blocks_pierced < pierce_amount)
		{
			this.server_Hit(blob, point1, this.getOldVelocity(), 10, Hitters::boulder, true);
			this.set_u8("blocks_pierced", blocks_pierced + 1);
		}
		else
		{
			this.server_Hit(this, point1, this.getOldVelocity(), 10, Hitters::crush, true);
		}
	}

	if (solid && blob !is null)
	{
		Vec2f hitvel = this.getOldVelocity();
		Vec2f hitvec = point1 - this.getPosition();
		f32 coef = hitvec * hitvel;

		if (coef < 0.706f) // check we were flying at it
		{
			return;
		}

		f32 vellen = hitvel.Length();

		//fast enough
		if (vellen < 1.0f)
		{
			return;
		}

		u8 tteam = this.get_u8("launch team");
		CPlayer@ damageowner = this.getDamageOwnerPlayer();

		//not teamkilling (except self)
		if (damageowner is null || damageowner !is blob.getPlayer())
		{
			if (
			    (blob.getName() != this.getName() &&
			     (blob.getTeamNum() == this.getTeamNum() || blob.getTeamNum() == tteam))
			)
			{
				return;
			}
		}

		//not hitting static stuff
		if (blob.getShape() !is null && blob.getShape().isStatic())
		{
			return;
		}

		//hitting less or similar mass
		if (this.getMass() < blob.getMass() - 1.0f)
		{
			return;
		}

		//get the dmg required
		hitvel.Normalize();
		f32 dmg = vellen > 8.0f ? 5.0f : (vellen > 4.0f ? 1.5f : 0.5f);

		//bounce off if not gibbed
		if (dmg < 4.0f)
		{
			this.setVelocity(blob.getOldVelocity() + hitvec * -Maths::Min(dmg * 0.33f, 1.0f));
		}

		//hurt
		this.server_Hit(blob, point1, hitvel, dmg, Hitters::boulder, true);

		return;

	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    // Waffle: Don't collide with friendly players
    return blob !is null && !(blob.hasTag("player") && blob.getTeamNum() == this.getTeamNum());
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::sword || customData == Hitters::arrow)
	{
		return damage *= 0.5f;
	}

	return damage;
}

//sprite

void onInit(CSprite@ this)
{
	this.animation.frame = (this.getBlob().getNetworkID() % 4);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
