// TrampolineLogic.as

#include "ArcherCommon.as";
#include "FireCommon.as";
#include "Hitters.as"

// Waffle: Readd folding
namespace Trampoline
{
	enum State
	{
		folded = 0,
		idle,
		bounce
	}

	enum msg
	{
		msg_pack = 0
	}
}

// Waffle: Add angle lock toggle
const string ANGLE_IS_LOCKED = "angle is locked";
const string LOCKED_ANGLE = "locked angle";
const string LOCK_TOGGLE = "locked angle toggle";

namespace Trampoline
{
	const string TIMER = "trampoline_timer";
	const u16 COOLDOWN = 7;
	const u8 SCALAR = 11;  // Waffle: Increase bounce strength
	const bool SAFETY = true;
	const int COOLDOWN_LIMIT = 8;
}

class TrampolineCooldown{
	u16 netid;
	u32 timer;
	TrampolineCooldown(u16 netid, u16 timer){this.netid = netid; this.timer = timer;}
};

void onInit(CBlob@ this)
{
	// Waffle: Increase burn time so it one shots a trampoline
	this.set_s16(burn_duration, 30000);

	// Waffle: Start open unless explicitly told to be closed
	if (this.hasTag("start packed"))
	{
		this.set_u8("trampolineState", Trampoline::folded);
		CSprite@ sprite = this.getSprite();
		if (isClient() && sprite !is null)
		{
			sprite.SetAnimation("pack");
			sprite.SetFrameIndex(3);
		}
	}
	else
	{
		this.set_u8("trampolineState", Trampoline::idle);
	}
	TrampolineCooldown @[] cooldowns;
	this.set(Trampoline::TIMER, cooldowns);
	this.getShape().getConsts().collideWhenAttached = true;

	this.Tag("no falldamage");
	// this.Tag("medium weight");  // Waffle: Make the trampoline lighter
	// Because BlobPlacement.as is *AMAZING*
	this.Tag("place norotate");

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	// point.SetKeysToTake(key_action1 | key_action2);  // Waffle: Make it so you can do all actions while holding a trampoline
	point.SetKeysToTake(key_action3);  // Waffle: Add angle lock toggle

	this.getCurrentScript().runFlags |= Script::tick_attached;
}

void onTick(CBlob@ this)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");

	CBlob@ holder = point.getOccupied();
	if (holder is null) return;

	Vec2f ray = holder.getAimPos() - this.getPosition();
	ray.Normalize();

	f32 angle = ray.Angle();
	if (this.get_bool(ANGLE_IS_LOCKED))  // Waffle: Add angle lock toggle
	{
		angle = this.get_f32(LOCKED_ANGLE);
	}
	else if (point.isKeyPressed(key_down))  // Waffle: Add more accurate angle
	{
		angle -= 90;
	}
	else if (angle > 180)  // Waffle: Make it rotate vertical as well
	{
		angle = holder.isFacingLeft() ? 180 : 0;
		angle -= 90;
	}
	else
	{
		angle = angle > 135 || angle < 45 ? (holder.isFacingLeft() ? 135 : 45) : 90;
		angle -= 90;
	}

	this.setAngleDegrees(-angle);

	// Waffle: Add angle lock toggle
	bool lock_toggle = this.get_bool(LOCK_TOGGLE);
	if (!lock_toggle && point.isKeyPressed(key_action3))
	{
		this.set_bool(ANGLE_IS_LOCKED, !this.get_bool(ANGLE_IS_LOCKED));
		this.set_f32(LOCKED_ANGLE, angle);
		this.set_bool(LOCK_TOGGLE, true);
		CSprite@ sprite = this.getSprite();
		if (sprite !is null)
		{
			sprite.PlaySound("bone_fall" + (this.get_bool(ANGLE_IS_LOCKED) ? 1 : 2));
		}
	}
	else if (lock_toggle && !point.isKeyPressed(key_action3))
	{
		this.set_bool(LOCK_TOGGLE, false);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2)
{
	if (blob is null || blob.isAttached() || blob.getShape().isStatic() || this.get_u8("trampolineState") == Trampoline::folded) return;  // Waffle: Readd folding

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();

	//choose whether to jump on team trampolines
	if (blob.hasTag("player") && blob.isKeyPressed(key_down) && this.getTeamNum() == blob.getTeamNum()) return;

	//cant bounce holder
	if (holder is blob) return;

	//cant bounce while held by something attached to something else
	if (holder !is null && holder.isAttached()) return;

	//prevent knights from flying using trampolines
	/*  // Waffle : Bounce from any angle
	//get angle difference between entry angle and the facing angle
	Vec2f pos_delta = (blob.getPosition() - this.getPosition()).RotateBy(90);
	float delta_angle = Maths::Abs(-pos_delta.Angle() - this.getAngleDegrees());
	if (delta_angle > 180)
	{
		delta_angle = 360 - delta_angle;
	}
	//if more than 90 degrees out, no bounce
	if (delta_angle > 90)
	{
		return;
	}
	*/
	TrampolineCooldown@[]@ cooldowns;
	if (!this.get(Trampoline::TIMER, @cooldowns)) return;

	//shred old cooldown if we have too many
	if (Trampoline::SAFETY && cooldowns.length > Trampoline::COOLDOWN_LIMIT) cooldowns.removeAt(0);

	u16 netid = blob.getNetworkID();
	bool block = false;
	for(int i = 0; i < cooldowns.length; i++)
	{
		if (cooldowns[i].timer < getGameTime())
		{
			cooldowns.removeAt(i);
			i--;
		}
		else if (netid == cooldowns[i].netid)
		{
			block = true;
			break;
		}
	}
	if (!block)
	{
		Vec2f velocity_old = blob.getOldVelocity();
		if (velocity_old.Length() < 1.0f) return;

		float angle = this.getAngleDegrees();

		Vec2f direction = Vec2f(0.0f, -1.0f);
		direction.RotateBy(angle);

		float velocity_angle = direction.AngleWith(velocity_old);

		//if (Maths::Abs(velocity_angle) > 90)  // Waffle: Make always bounce
		//{
		TrampolineCooldown cooldown(netid, getGameTime() + Trampoline::COOLDOWN);
		cooldowns.push_back(cooldown);

		Vec2f velocity = Vec2f(0, -Trampoline::SCALAR);
		velocity.RotateBy(angle);

		blob.setVelocity(velocity);

		// Waffle: Trampolines on fire ignite things they launch
		if (this.hasTag(burning_tag))
		{
			this.server_Hit(blob, this.getPosition(), Vec2f(0, 0), 0.0f, Hitters::fire, true);
			CBlob@ carried = blob.getCarriedBlob();
			if (carried !is null)
			{
				this.server_Hit(carried, this.getPosition(), Vec2f(0, 0), 0.0f, Hitters::fire, true);
			}
		}

		// Waffle: Boulders enter rock and roll mode when bouncing off a trampoline held by a player
		if (holder !is null && holder.hasTag("player") && blob.getName() == "boulder")
		{
			blob.getShape().getConsts().mapCollisions = false;
			blob.getShape().getConsts().collidable = false;
		}

		CSprite@ sprite = this.getSprite();
		if (sprite !is null)
		{
			sprite.SetAnimation("default");
			sprite.SetAnimation("bounce");
			sprite.PlaySound("TrampolineJump.ogg");
		}
		//}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
}

// Waffle: Readd folding
void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getDistanceTo(this) > 32.0f)
		return;

	u8 state = this.get_u8("trampolineState");

	if (state == Trampoline::folded)
	{
		caller.CreateGenericButton(6, Vec2f(0, -2), this, Trampoline::msg_pack, "Unpack Trampoline");
	}
	else
	{
		if (!this.hasTag("static"))
		{
			caller.CreateGenericButton(4, Vec2f(0, -2), this, Trampoline::msg_pack, "Pack up to move");
		}
	}
}

// Waffle: Readd folding
void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (!isServer())
    {
        return;
    }

	string dbg = "TrampolineLogic.as: Unknown command ";
	u8 state = this.get_u8("trampolineState");

	switch (cmd)
	{
		case Trampoline::msg_pack:
			if (state != Trampoline::folded)
			{
				this.set_u8("trampolineState", Trampoline::folded);
			}
			else
			{
				this.set_u8("trampolineState", Trampoline::idle); //logic for completion of this this is in anim script
			}
            this.Sync("trampolineState", true);
			break;

		default:
			dbg += cmd;
			print(dbg);
			warn(dbg);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.hasTag("no pickup");
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
    // Waffle: Reset angle lock
	this.set_bool(ANGLE_IS_LOCKED, false);
	this.set_bool(LOCK_TOGGLE, false);
}