
#include "BoatVars.as"  // Waffle: Only render rear splash when you can break blocks

void onInit(CBlob@ this)
{
	// Waffle: Add boat tag
	this.Tag("boat");

	// add oar sprites to ROWER attachment points
	CSprite@ sprite = this.getSprite();
	AttachmentPoint@[] aps;

	f32 oar_offset = 2.0f;
	if (this.exists("oar offset"))
		oar_offset = this.get_f32("oar offset");

	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ oar = aps[i];

			//oar sprites added automatically
			//sails must be added by the blob script

			if (oar.socket && oar.name == "ROWER")
			{
				CSpriteLayer@ oarSprite = sprite.addSpriteLayer("oar " + i , "/Oar.png", 32, 16);

				if (oarSprite !is null)
				{
					Animation@ anim = oarSprite.addAnimation("default", 8, false);
					int[] frames = {0, 1, 2, 3};
					anim.AddFrames(frames);
					oarSprite.SetOffset(Vec2f(-oar.offset.x, oar.offset.y) + Vec2f(0.0f, 13.0f));
					oarSprite.SetVisible(false);
					oarSprite.SetRelativeZ(oar_offset);
				}
			}

			// disable acion keys when carrying this
			if (oar.name == "PICKUP")
			{
				oar.SetKeysToTake(key_action1 | key_action2);
			}
		}
	}

	this.getSprite().SetZ(50.0f);
    // this.getCurrentScript().runFlags |= Script::tick_hasattached;  // Waffle: Prevent bobbing

	// Waffle: Add boat kills/assists
	dictionary riderHistory;
	this.set("RiderHistory", riderHistory);
}

void Splash(Vec2f pos, Vec2f vel, int randomnum)
{
	Vec2f randomVel = getRandomVelocity(90, 0.5f , 40);
	CParticle@ p = ParticleAnimated("Splash.png", pos,
	                                Vec2f(-vel.x, -0.4f) + randomVel, 0.0f, Maths::Max(1.0f, 0.5f * (1.0f + Maths::Abs(vel.x / 2))),
	                                2 + randomnum,
	                                0.1f, false);
	if (p !is null)
	{
		p.rotates = true;
		p.rotation.y = ((XORRandom(333) > 150) ? -1.0f : 1.0f);
		p.Z = 100;
	}
}

void onTick(CBlob@ this)
{
    // Waffle: Prevent bobbing
    if (this.isInWater())
    {
        Vec2f velocity = this.getVelocity();
        velocity.y *= 0.75f;
        this.setVelocity(velocity);
    }

	// rower controls
	AttachmentPoint@[] aps;

	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];

			if (ap.getOccupied() !is null)
			{
				const bool left = ap.isKeyPressed(key_left);
				const bool right = ap.isKeyPressed(key_right);

				if (ap.name == "ROWER")
				{
					// manage oar sprite animation
					CSpriteLayer@ oar = this.getSprite().getSpriteLayer("oar " + i);

					bool splash = false;

					if (oar !is null)
					{
						Animation@ anim = oar.getAnimation("default");

						if (anim !is null)
						{
							anim.loop = (left || right);
							anim.backward = ((!this.isFacingLeft() && right) || (this.isFacingLeft() && left));

							ap.getOccupied().SetFacingLeft(!this.isFacingLeft());

							if (oar.isFrameIndex(2))
								splash = true;
						}
						//make splashes when rowing
						if (this.isInWater() && (left || right) && splash)
						{
							Vec2f pos = oar.getWorldTranslation();
							Vec2f vel = this.getVelocity();
							for (int particle_step = 0; particle_step < 3; ++particle_step)
							{
								Splash(pos, vel, particle_step);
							}
						}
					}

				// Waffle: Any rower enables sail
				// }
				// else if (ap.name == "SAIL")
				// {
					// manage oar sprite animation
					CSpriteLayer@ sail = this.getSprite().getSpriteLayer("sail 0");  // Waffle: Any rower enables sail
					if (sail !is null)
					{
						Animation@ anim = sail.getAnimation("default");

						if (anim !is null)
						{
							anim.loop = (left || right);
							anim.backward = ((!this.isFacingLeft() && right) || (this.isFacingLeft() && left));

							ap.getOccupied().SetFacingLeft(this.isFacingLeft());
						}
					}
				}

				// always play sound when rowing
				if (this.isInWater() && (left || right))
				{
					this.getSprite().SetEmitSoundPaused(false);
				}
			}
		}
	}

	// rear splash

	if (this.isInWater() && Maths::Abs(this.getVelocity().x) > getBlobBreakingSpeedThreshold(this))  // this.getShape().vellen > 2.0f)  // Waffle: Only render rear splash when you can break blocks
	{
		Vec2f pos = this.getPosition();
		f32 side = this.isFacingLeft() ? this.getWidth() : -this.getWidth();
		side *= 0.45f;
		pos.x += side;
		pos.y += this.getHeight() * 0.5f + 4.0f;
		Splash(pos, this.getVelocity(), XORRandom(3));
	}
}

// show oars when someone hopped in as rower

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (attachedPoint.name == "ROWER")
	{
		// Waffle: Add boat kills/assists
		dictionary riderHistory;
		this.get("RiderHistory", riderHistory);
		CPlayer@ rider = attached.getPlayer();
		if (riderHistory !is null && rider !is null)
		{
			riderHistory.set(rider.getUsername(), getGameTime());
			this.set("RiderHistory", riderHistory);
		}

		CSpriteLayer@ oar = this.getSprite().getSpriteLayer("oar " + attachedPoint.getID());

		if (oar !is null)
		{
			oar.SetVisible(true);
			Animation@ anim = oar.getAnimation("default");

			if (anim !is null)
			{
				anim.loop = false;
			}
		}
	// Waffle: Any rower enables sail
	// }
	// else if (attachedPoint.name == "SAIL")
	// {
		if (!this.hasTag("no sail"))
		{
			CSpriteLayer@ sail = this.getSprite().getSpriteLayer("sail 0");  // Waffle: Any rower enables sail

			if (sail !is null)
			{
				sail.SetVisible(true);
				Animation@ anim = sail.getAnimation("default");

				if (anim !is null)
				{
					anim.loop = false;
				}
			}
		}
	}
}
void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (attachedPoint.name == "ROWER")
	{
		// Waffle: Add boat kills/assists
		dictionary riderHistory;
		this.get("RiderHistory", riderHistory);
		CPlayer@ rider = detached.getPlayer();
		if (riderHistory !is null && rider !is null)
		{
			riderHistory.set(rider.getUsername(), getGameTime());
			this.set("RiderHistory", riderHistory);
		}

		CSpriteLayer@ oar = this.getSprite().getSpriteLayer("oar " + attachedPoint.getID());

		if (oar !is null)
		{
			oar.SetVisible(false);
		}
	// Waffle: Any rower enables sail
	// }
	// else if (attachedPoint.name == "SAIL")
	// {
		if (!this.hasTag("no sail") && !hasRower(this))
		{
			CSpriteLayer@ sail = this.getSprite().getSpriteLayer("sail 0");  // Waffle: Any rower enables sail

			if (sail !is null)
			{
				sail.SetVisible(false);
			}
		}
	}
}

// Waffle: Any rower enables sail
bool hasRower(CBlob@ this)
{
	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];

			if (ap.name == "ROWER" && ap.getOccupied() !is null)
			{
				return true;
			}
		}
	}
	return false;
}