#include "EatCommon.as";

void onInit(CBlob@ this)
{
	if (!this.exists("eat sound"))
	{
		this.set_string("eat sound", "/Eat.ogg");
	}

	this.addCommandID("heal command client");

	this.Tag("pushedByDoor");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("heal command client") && isClient())
	{
		this.getSprite().PlaySound(this.get_string("eat sound"));
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null)
	{
		return;
	}

	// Waffle: Make it so food only collide with teammates
	if (getNet().isServer() && !blob.hasTag("dead") && (this.getTeamNum() < 0 || this.getTeamNum() >= 255 || this.getTeamNum() == blob.getTeamNum() || this.getName() == "flowers" || (!getRules().get_bool("hearts do not collide") && this.getName() == "heart")))
	{
		Heal(blob, this);
	}
}


void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (this is null || attached is null) {return;}

    // Waffle: Convert to your team on pickup
	this.server_setTeamNum(attached.getTeamNum());

	if (isServer())
	{
		Heal(attached, this);
	}

	CPlayer@ p = attached.getPlayer();
	if (p is null){return;}

	this.set_u16("healer", p.getNetworkID());
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @attachedPoint)
{
	if (this is null || detached is null) {return;}

	if (isServer())
	{
		Heal(detached, this);
	}

	CPlayer@ p = detached.getPlayer();
	if (p is null){return;}

	this.set_u16("healer", p.getNetworkID());
}
