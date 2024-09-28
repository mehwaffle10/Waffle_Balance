
//script for a chicken

#include "AnimalConsts.as";
#include "KnockedCommon.as";  // Waffle: Fix issue with HitHeld + shieldbashing
#include "RunnerCommon.as";           // Waffle: Add chicken jump
#include "ActivationThrowCommon.as";  // Waffle: --
#include "MaterialsPauseCommon.as";  // Waffle: Only generate materials with enough players
#include "ChickenCommon.as";  // Waffle: Rework breeding

const u8 DEFAULT_PERSONALITY = SCARED_BIT;

// Waffle: Refactor sound/eggs
const string ALLOW_SOUND_TIME = "last sound time";
const u8 SOUND_DELAY = getTicksASecond();
const string EGG_INTERVAL = "egg interval";

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
    this.Tag("activatable");
	this.Tag("dont deactivate");
    Activate@ func = @onActivate;
	this.set("activate handle", @func);
	this.addCommandID("activate client");

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
    
    // Waffle: Refactor sound/eggs
    this.set_u32(ALLOW_SOUND_TIME, 0);
    this.set_u8(EGG_INTERVAL, 0);
	// this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	// this.getCurrentScript().runProximityTag = "player";
	// this.getCurrentScript().runProximityRadius = 320.0f;

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

    // Waffle: Refactor sound/eggs
    u32 allow_sound_time = this.get_u32(ALLOW_SOUND_TIME);

    // Waffle: Add chicken jump
	// RunnerMoveVars@ moveVars;
    // CBlob@ inventory_blob = this.getInventoryBlob();
	// if (inventory_blob !is null && inventory_blob.get("moveVars", @moveVars))
	// {
    // 	TryResetJump(inventory_blob, moveVars);
	// }

	if (this.isAttached())
	{
		AttachmentPoint@ att = this.getAttachmentPoint(0);   //only have one
		if (att !is null)
		{
			CBlob@ b = att.getOccupied();
			if (b !is null)
			{
				Vec2f vel = b.getVelocity();
				// Waffle: Add chicken jump
				RunnerMoveVars@ moveVars;
				if (b.get("moveVars", @moveVars))
				{
					TryResetJump(b, moveVars);
					AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");

					// Waffle: Add hover limit
					if (!b.isKeyPressed(key_down) && vel.y > 0.5f && moveVars.chicken_hover_counter > 0)  // Waffle: Allow holding down to not hover
					{
						b.AddForce(Vec2f(0, Maths::Max(-35, -moveVars.chicken_hover_counter)));  // Waffle: Increase chicken hover strength
						--moveVars.chicken_hover_counter;
					}
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
	else if (XORRandom(128) == 0 && allow_sound_time < getGameTime())
	{
		this.getSprite().PlaySound("/Pluck");
		this.set_u32(ALLOW_SOUND_TIME, getGameTime() + SOUND_DELAY);

		// lay eggs
		if (getNet().isServer() && !materialsPaused())
		{
			u8 egg_interval = this.get_u8(EGG_INTERVAL) + 1;
            this.set_u8(EGG_INTERVAL, egg_interval);
			if (egg_interval % 13 == 0)
			{
				// Waffle: Rework breeding
				Vec2f pos = this.getPosition();
				bool otherChicken = false;
				int count = 1;
				string name = this.getName();
				CBlob@[] blobs;
				this.getMap().getBlobsInRadius(pos, CHICKEN_LIMIT_RADIUS, @blobs);
				for (uint step = 0; step < blobs.length; ++step)
				{
					CBlob@ other = blobs[step];
					if (other is this || other.isAttached() || other.isInInventory())
						continue;

					const string otherName = other.getName();
					if (otherName == name)
					{
						if (this.getDistanceTo(other) < 32.0f)
						{
							otherChicken = true;
						}
						count++;
					}
					else if (otherName == "egg")
					{
						count++;
					}
				}

				if (otherChicken && count < MAX_CHICKENS)
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

	if (blob.getRadius() > this.getRadius() && this.get_u32(ALLOW_SOUND_TIME) < getGameTime() && blob.hasTag("flesh"))
	{
		this.getSprite().PlaySound("/ScaredChicken");
		this.set_u32(ALLOW_SOUND_TIME, getGameTime() + SOUND_DELAY);
	}
}

// Waffle: Add chicken jump
// void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
// {
// 	this.doTickScripts = true;
// }

void TryResetJump(CBlob@ blob, RunnerMoveVars@ moveVars)
{
    if (blob !is null && (blob.isOnGround() || blob.isOnLadder() || blob.isInWater()))
    {
        ResetChickenJump(blob, moveVars);
    }
}

void onActivate(CBitStream@ params)
{
	if (!isServer()) return;

	u16 this_id, caller_id;
	if (!params.saferead_u16(this_id) || !params.saferead_u16(caller_id)) return;

	CBlob@ this = getBlobByNetworkID(this_id);
    CBlob@ caller = getBlobByNetworkID(caller_id);
	if (this is null || caller is null) return;

	RunnerMoveVars@ moveVars;
	if (!caller.get("moveVars", @moveVars) || moveVars.chicken_jump_timer > 0) return;

	this.SendCommand(this.getCommandID("activate client"));
	moveVars.chicken_jump_timer = CHICKEN_JUMP_RESET_TIME;

	CBitStream client_params;
	client_params.write_netid(caller.getNetworkID());
	this.SendCommand(this.getCommandID("activate client"), client_params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate client") && isClient())
	{
		u16 caller_id;
        if (!params.saferead_u16(caller_id)) return;

        CBlob@ caller = getBlobByNetworkID(caller_id);
        if (caller is null) return;

        RunnerMoveVars@ moveVars;
        if (caller.get("moveVars", @moveVars))
        {
            moveVars.walljumped = false;
            moveVars.walljumped_side = Walljump::NONE;
            moveVars.wallclimbing = false;
            moveVars.wallsliding = false;
			moveVars.chicken_jump_timer = CHICKEN_JUMP_RESET_TIME;
			caller.setVelocity(Vec2f(0, -6));
        }
        if (this.get_u32(ALLOW_SOUND_TIME) < getGameTime())
        {
            this.set_u32(ALLOW_SOUND_TIME, getGameTime() + SOUND_DELAY);
            this.getSprite().PlaySound("/ScaredChicken0" + (XORRandom(3) + 1));
        }
	}
}