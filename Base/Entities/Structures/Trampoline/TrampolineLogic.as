// TrampolineLogic.as

#include "ArcherCommon.as";

// Waffle: Add angle lock toggle
const string ANGLE_IS_LOCKED = "angle is locked";
const string LOCKED_ANGLE = "locked angle";
const string LOCK_COOLDOWN = "locked angle cooldown";


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

	// Waffle: Add angle lock toggle
	u32 gametime = getGameTime();
	if (point.isKeyPressed(key_action3) && gametime > this.get_u32(LOCK_COOLDOWN))
	{
		this.set_bool(ANGLE_IS_LOCKED, !this.get_bool(ANGLE_IS_LOCKED));
		this.set_u32(LOCK_COOLDOWN, gametime + getTicksASecond() / 2);
		this.set_f32(LOCKED_ANGLE, -this.getAngleDegrees());
	}

	// Waffle: Make it rotate vertical as well
	f32 angle = ray.Angle();
	if (this.get_bool(ANGLE_IS_LOCKED))
	{
		angle = this.get_f32(LOCKED_ANGLE);
	}
	else if (angle > 180)
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
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2)
{
	if (blob is null || blob.isAttached() || blob.getShape().isStatic()) return;

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();

	//choose whether to jump on team trampolines
	if (blob.hasTag("player") && blob.isKeyPressed(key_down) && this.getTeamNum() == blob.getTeamNum()) return;

	//cant bounce holder
	if (holder is blob) return;

	//cant bounce while held by something attached to something else
	if (holder !is null && holder.isAttached()) return;

	// Waffle: Make fire arrows hit enemy trampolines
	if (this.getTeamNum() != blob.getTeamNum() && blob.getName() == "arrow" && blob.get_u8("arrow type") == ArrowType::fire)
	{
		blob.setPosition(this.getPosition());
		blob.server_Die();
		return;
	}

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

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.hasTag("no pickup");
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	this.set_bool(ANGLE_IS_LOCKED, false);
	this.set_u32(LOCK_COOLDOWN, 0);
}