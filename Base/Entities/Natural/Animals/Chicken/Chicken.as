
//script for a chicken

#include "AnimalConsts.as";
#include "KnockedCommon.as";  // Waffle: Fix issue with HitHeld + shieldbashing
#include "RunnerCommon.as";  // Waffle: Add chicken jump

const u8 DEFAULT_PERSONALITY = SCARED_BIT;
const int MAX_EGGS = 4; //maximum symultaneous eggs  // 2  // Waffle: Increase chicken spawning
const int MAX_CHICKENS = 10;                         // 6  // Waffle: --
const f32 CHICKEN_LIMIT_RADIUS = 120.0f;

int g_lastSoundPlayedTime = 0;
int g_layEggInterval = 0;

const string CAN_JUMP = "can chicken jump";              // Waffle: Add chicken jump
const string LAST_JUMP_TIME = "last chicken jump time";  // Waffle: --

//sprite

// Waffle: Not always blue
// void onInit(CSprite@ this)
// {
// 	this.ReloadSprites(0, 0); //always blue

// }

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (!blob.hasTag("dead"))
	{
		f32 x = Maths::Abs(blob.getVelocity().x);
		if (blob.isAttached())
		{
			AttachmentPoint@ ap = blob.getAttachmentPoint(0);
			if (ap !is null && ap.getOccupied() !is null)
			{
				// Waffle: Make chicken fly in the air if held
				if (!blob.isOnGround()) //Maths::Abs(ap.getOccupied().getVelocity().y) > 0.2f)
				{
					this.SetAnimation("fly");
				}
				else
					this.SetAnimation("idle");
			}
		}
		else if (!blob.isOnGround())
		{
			this.SetAnimation("fly");
		}
		else if (x > 0.02f)
		{
			this.SetAnimation("walk");
		}
		else
		{
			if (this.isAnimationEnded())
			{
				uint r = XORRandom(20);
				if (r == 0)
					this.SetAnimation("peck_twice");
				else if (r < 5)
					this.SetAnimation("peck");
				else
					this.SetAnimation("idle");
			}
		}
	}
	else
	{
		this.SetAnimation("dead");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
		this.PlaySound("/ScaredChicken");
	}
}

//blob

void onInit(CBlob@ this)
{
	InitKnockable(this);  // Waffle: Fix issue with HitHeld + shieldbashing
	this.set_f32("bite damage", 0.25f);

    // Waffle: Add chicken jump
    AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
    if (point !is null)
    {
        point.SetKeysToTake(key_action3);
    }
    this.set_bool(CAN_JUMP, true);
    this.set_u32(LAST_JUMP_TIME, getGameTime());

	//brain
	this.set_u8(personality_property, DEFAULT_PERSONALITY);
	this.getBrain().server_SetActive(true);
	this.set_f32(target_searchrad_property, 30.0f);
	this.set_f32(terr_rad_property, 75.0f);
	this.set_u8(target_lose_random, 14);

	//for shape
	this.getShape().SetRotationsAllowed(false);

	//for flesh hit
	this.set_f32("gib health", -0.0f);
	this.Tag("flesh");

	this.getShape().SetOffset(Vec2f(0, 6));
    
	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 320.0f;

	// attachment

	//todo: some tag-based keys to take interference (doesn't work on net atm)
	/*AttachmentPoint@ att = this.getAttachments().getAttachmentPointByName("PICKUP");
	att.SetKeysToTake(key_action1);*/

	// movement

	AnimalVars@ vars;
	if (!this.get("vars", @vars))
		return;
	vars.walkForce.Set(1.0f, -0.1f);
	vars.runForce.Set(2.0f, -1.0f);
	vars.slowForce.Set(1.0f, 0.0f);
	vars.jumpForce.Set(0.0f, -20.0f);
	vars.maxVelocity = 1.1f;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true; //maybe make a knocked out state? for loading to cata?
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return !blob.hasTag("flesh");
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	// Waffle: Prevent friendly players from killing your chicken
	this.server_setTeamNum(attached.getTeamNum());
}

void onTick(CBlob@ this)
{
	// Waffle: Prevent chickens dying during build phase by setting them to their respective teams
	if (isServer())
	{
		CMap@ map = getMap();
		uint gametime = getGameTime();
		if (map !is null && gametime > 30 && gametime < 35 && !this.get_bool("team swap init"))
		{
			Vec2f pos = this.getPosition();
			this.set_bool("team swap init", true);
			this.server_setTeamNum(map.getSectorAtPosition(pos, "barrier") !is null ? -1
								: pos.x < map.tilemapwidth * map.tilesize / 2 ? 0 : 1);
		}
	}

	f32 x = this.getVelocity().x;
	if (Maths::Abs(x) > 1.0f)
	{
		this.SetFacingLeft(x < 0);
	}
	else
	{
		if (this.isKeyPressed(key_left))
		{
			this.SetFacingLeft(true);
		}
		if (this.isKeyPressed(key_right))
		{
			this.SetFacingLeft(false);
		}
	}

    // Waffle: Add chicken jump
    bool can_reset_jump = getGameTime() > this.get_u32(LAST_JUMP_TIME) + 5;
    CBlob@ inventory_blob = this.getInventoryBlob();
    if (inventory_blob !is null && can_reset_jump && inventory_blob.isOnGround())
    {
        this.set_bool(CAN_JUMP, true);
    }

	if (this.isAttached())
	{
		AttachmentPoint@ att = this.getAttachmentPoint(0);   //only have one
		if (att !is null)
		{
			CBlob@ b = att.getOccupied();
			if (b !is null)
			{
                if (can_reset_jump && b.isOnGround())
                {
                    this.set_bool(CAN_JUMP, true);
                }

				// too annoying

				//if (g_lastSoundPlayedTime+20+XORRandom(10) < getGameTime())
				//{
				//	if (XORRandom(2) == 1)
				//		this.getSprite().PlaySound("/ScaredChicken");
				//	else
				//		this.getSprite().PlaySound("/Pluck");
				//
				//	g_lastSoundPlayedTime = getGameTime();
				//}

                // Waffle: Add chicken jump
                AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
                if (point !is null && this.get_bool(CAN_JUMP) && point.isKeyJustPressed(key_action3))
                {
                    this.set_bool(CAN_JUMP, false);
                    this.set_u32(LAST_JUMP_TIME, getGameTime());
                    b.setVelocity(Vec2f(0, -6));
                    RunnerMoveVars@ moveVars;
                    if (b.get("moveVars", @moveVars))
                    {
                        moveVars.walljumped = false;
                        moveVars.walljumped_side = Walljump::NONE;
                        moveVars.wallclimbing = false;
                        moveVars.wallsliding = false;
                    }
                    
                    if (g_lastSoundPlayedTime + 30 < getGameTime())
                    {
                        g_lastSoundPlayedTime = getGameTime();
                        this.getSprite().PlaySound("/ScaredChicken0" + (XORRandom(3) + 1));
                    }
                }

				Vec2f vel = b.getVelocity();
				if (!b.isKeyPressed(key_down) && vel.y > 0.5f)  // Waffle: Allow holding down to not hover
				{
					// Waffle: Increase chicken hover strength
					b.AddForce(Vec2f(0, -35));
				}

				// Waffle: Strong horizontal movement decay
				if (!b.isOnGround() && Maths::Abs(vel.x) > 2.0f)
				{
					b.AddForce(Vec2f(35 * (vel.x > 0 ? -1 : 1), 0));
				}
			}
		}
	}
	else if (!this.isOnGround())
	{
		Vec2f vel = this.getVelocity();
		if (vel.y > 0.5f)
		{
			this.AddForce(Vec2f(0, -10));
		}
	}
	else if (XORRandom(128) == 0 && g_lastSoundPlayedTime + 30 < getGameTime())
	{
		this.getSprite().PlaySound("/Pluck");
		g_lastSoundPlayedTime = getGameTime();

		// lay eggs
		if (getNet().isServer())
		{
			g_layEggInterval++;
			if (g_layEggInterval % 13 == 0)
			{
				Vec2f pos = this.getPosition();
				bool otherChicken = false;
				int eggsCount = 0;
				int chickenCount = 0;
				string name = this.getName();
				CBlob@[] blobs;
				this.getMap().getBlobsInRadius(pos, CHICKEN_LIMIT_RADIUS, @blobs);
				for (uint step = 0; step < blobs.length; ++step)
				{
					CBlob@ other = blobs[step];
					if (other is this)
						continue;

					const string otherName = other.getName();
					if (otherName == name)
					{
						if (this.getDistanceTo(other) < 32.0f)
						{
							otherChicken = true;
						}
						chickenCount++;
					}
					if (otherName == "egg")
					{
						eggsCount++;
					}
				}

				if (otherChicken && eggsCount < MAX_EGGS && chickenCount < MAX_CHICKENS)
				{
					server_CreateBlob("egg", this.getTeamNum(), this.getPosition() + Vec2f(0.0f, 5.0f));
				}
			}
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob is null)
		return;

	if (blob.getRadius() > this.getRadius() && g_lastSoundPlayedTime + 25 < getGameTime() && blob.hasTag("flesh"))
	{
		this.getSprite().PlaySound("/ScaredChicken");
		g_lastSoundPlayedTime = getGameTime();
	}
}

// Waffle: Add chicken jump
void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	this.doTickScripts = true;
}