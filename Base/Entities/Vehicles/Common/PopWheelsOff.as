//Wheeled vehicle deactivate script

#include "GenericButtonCommon.as"

void onInit(CBlob@ this)
{
	this.addCommandID("pop_wheels");
	this.addCommandID("add_wheels");  // Waffle: Add support for readding wheels
	if (this.hasTag("immobile"))
	{
		PopWheels(this, false);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	// if (this.getAttachments().getAttachmentPointByName("DRIVER").getOccupied() !is null) return;  // Waffle: Gunner is also driver

	if (this.getTeamNum() == caller.getTeamNum() && isOverlapping(this, caller) && !caller.isAttached() && !this.isAttached())  // Waffle: Don't show buttons if attached
	{
		// Waffle: Add support for readding wheels
		if (this.hasTag("immobile"))
		{
			caller.CreateGenericButton(3, Vec2f(0.0f, 8.0f), this, this.getCommandID("add_wheels"), getTranslatedString("Mobilise"));
		}
		else
		{
			caller.CreateGenericButton(2, Vec2f(0.0f, 8.0f), this, this.getCommandID("pop_wheels"), getTranslatedString("Immobilise"));
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("pop_wheels"))
	{
		if (!this.hasTag("immobile"))
		{
			// Waffle: Gunner is also driver
			// CBlob@ chauffeur = this.getAttachments().getAttachmentPointByName("DRIVER").getOccupied();

			// if (chauffeur !is null) return;

			this.Tag("immobile");
			PopWheels(this, false);
		}
	}
	else if (cmd == this.getCommandID("add_wheels"))  // Waffle: Add support for readding wheels
	{
		if (this.hasTag("immobile"))
		{
			this.Untag("immobile");
			AddWheels(this);
		}
	}
}

void PopWheels(CBlob@ this, bool addparticles = true)
{
	this.getShape().setFriction(0.75f);   //grippy now

	if (!getNet().isClient()) //don't bother w/o graphics
		return;

	CSprite@ sprite = this.getSprite();

	// Waffle: Never launch wheels
	// Vec2f pos = this.getPosition();
	// Vec2f vel = this.getVelocity();

	//remove wheels
	for (int i = 0; i < sprite.getSpriteLayerCount(); ++i)
	{
		CSpriteLayer@ wheel = sprite.getSpriteLayer(i);

		if (wheel !is null && wheel.name.substr(0, 2) == "!w")
		{
			// Waffle: Never launch wheels
			// if (addparticles)
			// {
			// 	//todo: wood falling sounds...
			// 	makeGibParticle("Entities/Vehicles/Common/WoodenWheels.png", pos + wheel.getOffset(), vel + getRandomVelocity(90, 5, 80), 0, 0, Vec2f(16, 16), 2.0f, 20, "/material_drop", 0);
			// }

			// Waffle: Just hide wheels
			wheel.SetVisible(false);
			// sprite.RemoveSpriteLayer(wheel.name);
		}
	}

	//add chocks
	CSpriteLayer@ chocks = sprite.addSpriteLayer("!chocks", "Entities/Vehicles/Common/WoodenChocks.png", 32, 16);

	if (chocks !is null)
	{
		Animation@ anim = chocks.addAnimation("default", 0, false);
		anim.AddFrame(0);
		chocks.SetOffset(Vec2f(0, this.getHeight() * 0.5f - 2.5f));
	}
}

// Waffle: Add support for readding wheels
void AddWheels(CBlob@ this)
{
	this.getShape().setFriction(0.01);   //slippy now

	if (!getNet().isClient()) //don't bother w/o graphics
		return;

	CSprite@ sprite = this.getSprite();

	//add wheels
	for (int i = 0; i < sprite.getSpriteLayerCount(); ++i)
	{
		CSpriteLayer@ wheel = sprite.getSpriteLayer(i);

		if (wheel !is null && wheel.name.substr(0, 2) == "!w")
		{
			wheel.SetVisible(true);
		}
	}

	//remove chocks
	sprite.RemoveSpriteLayer("!chocks");
}

// Waffle: Don't show buttons if attached
void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (attachedPoint !is null && attachedPoint.name == "VEHICLE")
	{
		this.Tag("immobile");
		PopWheels(this, false);
	}
}

// Blame Fuzzle.
bool isOverlapping(CBlob@ this, CBlob@ blob)
{

	Vec2f tl, br, _tl, _br;
	this.getShape().getBoundingRect(tl, br);
	blob.getShape().getBoundingRect(_tl, _br);
	return br.x > _tl.x
	       && br.y > _tl.y
	       && _br.x > tl.x
	       && _br.y > tl.y;

}