#include "Hitters.as"
#include "KnockedCommon.as"

shared class TreeSegment
{
	f32 angle;
	f32 length;
	Vec2f start_pos;
	Vec2f end_pos;

	u8 height;
	u8 grown_times;

	bool flip;

	bool gotsprites;

	Random r;

};

shared class TreeVars
{
	s32 growth_time;
	u8 height;
	u16 seed;
	u8 max_height;
	u8 grown_times;
	u8 max_grow_times;
	s32 last_grew_time;

	Random r;
};

TreeSegment@ getLastSegment(CBlob@ this)
{
	TreeSegment[]@ segments;
	this.get("TreeSegments", @segments);

	if (segments is null || segments.length < 1)
	{
		return null;
	}

	return segments[segments.length - 1];
}

void GrowSegments(CBlob@ this, TreeVars@ vars)
{
	TreeSegment[]@ segments;
	this.get("TreeSegments", @segments);
	if (segments is null)
	{
		return;
	}

	for (uint i = 0; i < segments.length; i++)
	{
		TreeSegment@ segment = segments[i];

		if (segment !is null && segment.grown_times < vars.max_grow_times)
		{
			segment.grown_times++;
			segment.gotsprites = false; //ask for more sprites :)
		}
	}
}

//returns if the segments are overlapping terrain
bool CollapseToGround(CBlob@ this, f32 angle)
{
	if (!this.exists("tree_fall_angle"))
	{
		this.set_f32("tree_fall_angle", angle);
	}
	else
	{
		this.set_f32("tree_fall_angle", angle + this.get_f32("tree_fall_angle"));
	}

	CSprite@ sprite = this.getSprite();
	Vec2f rotateAround = Vec2f(0.0f, -this.getHeight() * 0.5f);
	sprite.RotateAllBy(angle, rotateAround);
	CMap@ map = getMap();
	Vec2f pos = this.getPosition();

	TreeSegment[]@ segments;
	this.get("TreeSegments", @segments);
	if (segments is null)
		return false;

	// rotate all
	Vec2f segRotateAround = rotateAround * -1;

	for (uint i = 0; i < segments.length; i++)
	{
		TreeSegment@ segment = segments[i];

		if (segment !is null)
		{
			segment.start_pos.RotateBy(angle, segRotateAround);
			segment.end_pos.RotateBy(angle, segRotateAround);
		}
	}

	// collide with map and blobs

	if (segments.length > 2)
	{
		// offset the raycast angle so it doesnt look like it falls into the ground
        // Waffle: Fix issue where it can rotate the wrong way for the first tick
        const f32 arc_length = 4.0f;
        const f32 theta = arc_length / 2.0f;
        angle += this.get_bool("cut_down_fall_side") ? -theta : theta;
        /*
		if (angle > 0.0f)
		{
			angle += 5;
		}
		else
		{
			angle -= 5;
		}
        */

		bool hitsomething = false;
		Vec2f start_pos = segments[0].start_pos;
		Vec2f end_pos = segments[segments.length - 1].end_pos;
		Vec2f vector = (end_pos - start_pos);
		// HIT //
        const f32 offset = this.getWidth() / 2.0f;
		Vec2f worldpos = pos + Vec2f(this.get_bool("cut_down_fall_side") ? -offset : offset, 0.0f) + rotateAround * -0.8f;
		HitInfo@[] hitInfos;
		//printf("segRotateAround " + segRotateAround.x + " " + segRotateAround.y + " v " + vector.Length() + " a " + (-90 + this.get_f32("tree_fall_angle") + angle)  );

		const f32 hitAngle = -90 + this.get_f32("tree_fall_angle") + angle;
		//  printf("hit " + hitAngle );
		if (hitAngle < -360.0f || hitAngle > 360.0f)
			return true;

		if (map.getHitInfosFromArc(worldpos, hitAngle, arc_length, vector.Length(), this, @hitInfos))  // Waffle: Fix issue where it can rotate the wrong way for the first tick
		{
			for (uint i = 0; i < hitInfos.length; i++)
			{
				HitInfo@ hi = hitInfos[i];

				if (hi.blob !is null && hi.blob.getShape().isStatic() && (hi.blob.hasTag("door"))) // blob  // || hi.blob.isPlatform()
				{
                    // Waffle: Hit doors and platforms
                    hitsomething = true;
                    break;
					// f32 dist = (worldpos - hi.blob.getPosition()).Length();

					// if (dist > 24.0f && angle > 20.0f)
					// {
					// 	hitsomething = true;
					// 	setKnocked(hi.blob, 15);
					// }
				}
				else // map
					if (hi.blob is null)
					{
						hitsomething = true;
                        break;
					}
			}
		}

		return hitsomething;
	}

	// too small to collpase - kill
	return true;
}

bool DoCollapseWhenBelow(CBlob@ this, f32 hp)
{
	if (this.getHealth() <= hp && !this.exists("felldown"))
	{
		this.getCurrentScript().tickFrequency = 1;

		f32 COLLAPSE_TIME = 200000.0f;
		u32 fell_time;
		bool fall_switch;

		if (!this.exists("cut_down_time"))
		{
			// START COLLAPSE
			fell_time = getGameTime();
			this.set_u32("cut_down_time", fell_time);
			fall_switch = this.get_bool("cut_down_fall_side");
			// sound
			this.getSprite().SetEmitSound("Entities/Natural/Trees/TreeFall.ogg");
			this.getSprite().SetEmitSoundPaused(false);
			//remove sectors
			CMap@ map = getMap();
			Vec2f pos = this.getPosition();
			map.RemoveSectorsAtPosition(pos, "no build", this.getNetworkID());
			map.RemoveSectorsAtPosition(pos, "tree", this.getNetworkID());
		}
		else
		{
			fell_time = this.get_u32("cut_down_time");
			fall_switch = this.get_bool("cut_down_fall_side");
		}

		f32 time_diff = (getGameTime() - fell_time);
		f32 rate = (time_diff * time_diff) / COLLAPSE_TIME;
		// END COLLAPSE
		bool hitground = CollapseToGround(this, (fall_switch ? -1 : 1) * 90.0f * rate);

		if (hitground)
		{
			this.getSprite().PlaySound("Entities/Natural/Trees/TreeDestruct.ogg");
			this.getSprite().SetEmitSoundPaused(true);
			this.Tag("felldown"); // so client stops falling tree and playing sound

			if (getNet().isServer())
			{
				this.server_SetHealth(-1.0f);
				this.server_Die();                      // Tree dying too early? Did it spawn a bit underground?
			}
		}

		return true;
	}

	return false;
}
