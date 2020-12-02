
#include "Hitters.as"

void onInit(CBlob@ this)
{
	this.addCommandID("attach");
	this.set_bool("armored", false);
	this.Sync("armored", true);
	this.set_bool("wheel", false);
	this.Sync("wheel", true);
	this.set_bool("seat", true);
	this.Sync("seat", true);
	Reset(this);
}

void Reset(CBlob@ this)
{
	this.set_s32("core", this.getNetworkID());
	this.Sync("core", true);
	this.set_s32("anchor", this.getNetworkID());
	this.Sync("anchor", true);
	this.set_s32("right", -1);
	this.Sync("right", true);
	this.set_s32("bottom", -1);
	this.Sync("bottom", true);
	this.set_s32("left", -1);
	this.Sync("left", true);
	this.set_s32("top", -1);
	this.Sync("top", true);
}

string intToDirection(int i)
{
	if (i == 0) return "right";
	if (i == 1) return "bottom";
	if (i == 2) return "left";
	if (i == 3) return "top";
	return "error";
}

void onTick(CBlob@ this)
{	
	if (this.get_bool("armored"))
	{
		this.getSprite().SetAnimation("armored");
	} 
	else
	{
		this.getSprite().SetAnimation("default");
	}

	float range = 8.0f;
	CBlob@[] neighbors = getNeighbors(this);

	// Ghost block rendering and placement
	CPlayer@ player = getLocalPlayer();
	if (player !is null)
	{
		CBlob@ player_blob = player.getBlob();
		if (player_blob !is null)
		{
			CBlob@ carried = player_blob.getCarriedBlob();
			if (this.getTeamNum() == player_blob.getTeamNum() && this.getDistanceTo(player_blob) <= 64.0f && carried !is null && carried.getName() == this.getName() && carried.get_s32("core") != this.get_s32("core"))
			{
				for (int i = 0; i < neighbors.length(); i++)
				{
					// dif = relative distance between absolute position of mouse and absolute position of ghost
					Vec2f dif = (player_blob.getAimPos() - (this.getPosition() + Vec2f(16,0).RotateByDegrees(90.0f*i+this.getAngleDegrees()))).RotateByDegrees(this.getAngleDegrees());
					if (neighbors[i] is null && Maths::Abs(dif.x) <= range && Maths::Abs(dif.y) <= range)
					{
						// Render ghost block
						if (this.getSprite().getSpriteLayer("ghost_" + i) is null)
						{
							// CSpriteLayer@ addSpriteLayer(const string&in name, const string&in filename, int frameWidth, int frameHeight, int teamColor, int skinColor)
							CSpriteLayer@ spritelayer = this.getSprite().addSpriteLayer("ghost_" + i, "SiegeBlock.png", 16, 16, player_blob.getTeamNum(), player_blob.getTeamNum());
							spritelayer.SetFrameIndex(carried.getSprite().getFrame());
							spritelayer.TranslateBy(Vec2f(16,0).RotateByDegrees(90.0f*i));
						}

						// If player clicks, attach block
						if (player_blob.isKeyPressed(key_action1))
						{
							/*
							carried.getSprite().PlaySound("ConstructShort.ogg");
							carried.set_s32(intToDirection(i), s32(this.getNetworkID()));
							this.set_s32(intToDirection((i+2)%4), s32(carried.getNetworkID()));
							carried.Sync(intToDirection(i), true);
							carried.Sync(intToDirection((i+2)%4), true);
							carried.server_DetachFromAll();
							*/
							carried.getSprite().PlaySound("ConstructShort.ogg");

							CBitStream params;
							params.write_u16(carried.getNetworkID());
							params.write_s32((i+2)%4);
							this.SendCommand(this.getCommandID("attach"), params);
														
						}
					}
					else if (this.getSprite().getSpriteLayer("ghost_" + i) !is null && (Maths::Abs(dif.x) > range || Maths::Abs(dif.y) > range))
					{
						this.getSprite().RemoveSpriteLayer("ghost_" + i);
					}
				}
			}
			else
			{
				// Clear All Ghosts
				for (int i = 0; i < neighbors.length(); i++)
				{
					if (this.getSprite().getSpriteLayer("ghost_" + i) !is null)
					{
						this.getSprite().RemoveSpriteLayer("ghost_" + i);
					}
				}
			}
		}
	}

	// Wipe core logic - whenever a block dies, we need to recheck cores
	if (this.get_bool("wiping"))
	{
		// Wipe core
		this.set_s32("core", -1);
		this.Sync("core", true);

		// Propagate wipe to neighbors
		for (int i = 0; i < neighbors.length(); i++)
		{
			if (neighbors[i] !is null && neighbors[i].getNetworkID() != this.getNetworkID() && !neighbors[i].get_bool("wiping") && neighbors[i].get_s32("core") >= 0)
			{
				neighbors[i].set_bool("wiping", true);
				neighbors[i].Sync("wiping", true);
			}
		}

		// End wipe
		this.set_bool("wiping", false);
		this.Sync("wiping", true);
	}
	
	// Check if core is valid
	if (this.get_s32("core") >= 0 && getBlobByNetworkID(u16(this.get_s32("core"))) is null)
	{
		this.set_s32("core", -1);
		this.Sync("core", true);
	}

	// Try to get core from neighbors if possible
	for (int i = 0; i < neighbors.length(); i++)
	{
		// Must be real siege block neighbor with valid core that has already been wiped
		if (neighbors[i] !is null && neighbors[i].getNetworkID() != this.getNetworkID() && neighbors[i].get_s32("core") >= 0 && !neighbors[i].get_bool("wiping") && neighbors[i].get_s32("core") != this.get_s32("core")
			&& getBlobByNetworkID(u16(neighbors[i].get_s32("core"))) !is null && getBlobByNetworkID(u16(neighbors[i].get_s32("core"))).getName() == this.getName())
		{
			this.set_s32("core", neighbors[i].get_s32("core"));
			this.Sync("core", true);
			break;
		}
	}

	// Make sure block has a valid anchor. Must be real siege block and can't be self if not a core
	if (this.get_s32("anchor") < 0 || getBlobByNetworkID(u16(this.get_s32("anchor"))) is null || getBlobByNetworkID(u16(this.get_s32("anchor"))).getName() != this.getName()
		|| (this.get_s32("core") != s32(this.getNetworkID()) && this.get_s32("anchor") == s32(this.getNetworkID())))
	{
		for (int i = 0; i <= neighbors.length(); i++)
		{
			if (i == 4 || this.get_s32("anchor") == s32(this.getNetworkID())) // No neighbors, new core
			{
				this.set_s32("anchor", s32(this.getNetworkID()));
				this.Sync("anchor", true);
				this.set_s32("core", s32(this.getNetworkID()));
				this.Sync("core", true);
				this.setVelocity(Vec2f(0,0));
				break;
			}
			else if (neighbors[i] !is null && neighbors[i].getNetworkID() != this.getNetworkID() && neighbors[i].get_s32("core") >= 0 && getBlobByNetworkID(u16(neighbors[i].get_s32("core"))) !is null && neighbors[i].get_s32("anchor") != s32(this.getNetworkID()))
			{
				this.set_s32("anchor", s32(neighbors[i].getNetworkID()));
				this.Sync("anchor", true);
				this.set_s32("core", neighbors[i].get_s32("core"));
				this.Sync("core", true);
				break;
			} 
		}
	}

	// Update position if attached
	if (s32(this.getNetworkID()) != this.get_s32("core"))
	{
		for (int i = 0; i < neighbors.length(); i++)
		{
			if (neighbors[i] !is null)
			{
				if (neighbors[i].getNetworkID() == u16(this.get_s32("anchor")) && neighbors[i].getNetworkID() != this.getNetworkID()) // shouldn't be possible but safety first
				{
					Vec2f pos = neighbors[i].getPosition() + Vec2f(-16,0).RotateBy(90.0f*i + neighbors[i].getAngleDegrees());

					// Check if colliding with map
					if (getMap().isTileSolid(pos))
					{
						if (this.get_s32("core") >= 0) // && u16(this.get_s32("core")) != this.getNetworkID())
						{
							CBlob@ core = getBlobByNetworkID(u16(this.get_s32("core")));
							if (core !is null)
							{
								core.setVelocity(core.getVelocity() + Vec2f(core.getVelocity().x > 0 ? -4 : 4, core.getVelocity().y > 0 ? -4 : 4) + Vec2f(-1*core.getVelocity().x,-1*core.getVelocity().y));
								float angVel = core.getAngularVelocity() > 0 ? -1 : 1;
								core.setAngularVelocity(angVel - core.getAngularVelocity());
							}
						}
					}

					this.setPosition(pos);
					this.setVelocity(neighbors[i].getVelocity());
					this.setAngleDegrees(neighbors[i].getAngleDegrees());
				}	
			}
			else
			{
				this.set_s32(intToDirection(i),-1);
				this.Sync(intToDirection(i), true);
			}
		}
	}
	
	// collide properly
	CBlob@[] overlapping;
	this.getOverlapping(@overlapping);
	for (int i = 0; i < overlapping.length(); i++)
	{
		if (this.doesCollideWithBlob(overlapping[i]))
		{
			Vec2f dif = overlapping[i].getPosition() - this.getPosition();
			if (Maths::Abs(dif.x) > Maths::Abs(dif.y))
			{
				dif = dif.x > 0 ? Vec2f(0.3,overlapping[i].getVelocity().y) : Vec2f(-0.3,overlapping[i].getVelocity().y);
			}
			else
			{
				dif = dif.y > 0 ? Vec2f(overlapping[i].getVelocity().x,0.3) : Vec2f(overlapping[i].getVelocity().x,-0.3);
			}
			overlapping[i].setVelocity(dif);
		}
	}

	// Check for invalid neighbors (had to do this to check for attaching to multiple siege blocks stacked in the same spot)
	for (int i = 0; i < neighbors.length(); i++)
	{
		// Disconnect if neighbor has a different core and is not anchored
		if (neighbors[i] !is null && neighbors[i].getNetworkID() != this.getNetworkID() && neighbors[i].get_s32("core") != this.get_s32("core") && neighbors[i].get_s32("anchor") != s32(this.getNetworkID()) && this.get_s32("anchor") != s32(neighbors[i].getNetworkID()))
		{
			this.set_s32(intToDirection(i), -1);
			this.Sync(intToDirection(i), true);
		}
	}

	// Update to string
	this.set_string("string",
		"ID: " + this.getNetworkID()
		+ "\nAnchor: " + this.get_s32("anchor")
		+ "\nCore: " + this.get_s32("core")
		+ "\nRight: " + this.get_s32("right")
		+ "\nBottom: " + this.get_s32("bottom")
		+ "\nLeft: " + this.get_s32("left")
		+ "\nTop: " + this.get_s32("top")
	);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (getNet().isServer() && cmd == this.getCommandID("attach"))
	{
		u16 ID = params.read_u16();
		int dir = params.read_s32();
		CBlob@ blob = getBlobByNetworkID(ID);
		if (blob !is null)
		{
			// add core from anchor to new block
			blob.set_s32("core", this.get_s32("core"));
			blob.Sync("core", true);

			// anchor new block to block
			blob.set_s32("anchor", s32(this.getNetworkID()));
			blob.Sync("anchor", true);
			
			// add neighbors to new block
			Vec2f new_pos = this.getPosition() + Vec2f(16,0).RotateByDegrees(90.0f*((dir+2)%4)+this.getAngleDegrees()); // position of new block after attaching
			for (int i = 0; i < 4; i++)
			{
				Vec2f neighbor_pos = new_pos + Vec2f(16,0).RotateByDegrees(90.0f*i+this.getAngleDegrees());
				CBlob@[] neighbors;
				getMap().getBlobsInRadius(neighbor_pos, 0.001f, @neighbors);

				for (int j = 0; j < neighbors.length(); j++)
				{
					// must be a siege block of the same team connected to the same core, avoids a weird multicore issue I don't wanna deal with yet, would likely have to reverse all anchors 
					if (neighbors[j] !is null && neighbors[j].getNetworkID() != blob.getNetworkID() && neighbors[j].getName() == blob.getName() && neighbors[j].getTeamNum() == blob.getTeamNum() && neighbors[j].get_s32("core") == blob.get_s32("core"))
					{
						blob.set_s32(intToDirection(i), s32(neighbors[j].getNetworkID()));
						blob.Sync(intToDirection(i), true);
						neighbors[j].set_s32(intToDirection((i+2)%4), s32(blob.getNetworkID()));
						neighbors[j].Sync(intToDirection((i+2)%4), true);
					}
				}
			}
			
			// make sure it's neighbor is the anchor
			blob.set_s32(intToDirection(dir), s32(this.getNetworkID()));
			blob.Sync(intToDirection(dir), true);
			this.set_s32(intToDirection((dir+2)%4), s32(blob.getNetworkID()));
			this.Sync(intToDirection((dir+2)%4), true);

			// make holder drop new block
			blob.server_DetachFromAll();
		}
	}
}

CBlob@[] getNeighbors(CBlob@ blob)
{
	CBlob@[] arr = {
		blob.get_s32("right") < 0 ? null : getBlobByNetworkID(u16(blob.get_s32("right"))),
		blob.get_s32("bottom") < 0 ? null : getBlobByNetworkID(u16(blob.get_s32("bottom"))),
		blob.get_s32("left") < 0 ? null : getBlobByNetworkID(u16(blob.get_s32("left"))),
		blob.get_s32("top") < 0 ? null : getBlobByNetworkID(u16(blob.get_s32("top")))
	};
	return arr;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (this is null || blob is null) return false;
	//return this.getName() == blob.getName();
	
	if (this.get_bool("armored"))
	{
		return this.getName() != blob.getName() || this.getTeamNum() != blob.getTeamNum();
	}

	return false;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.getTeamNum() == byBlob.getTeamNum()
		&& s32(this.getNetworkID()) == this.get_s32("core");
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	f32 dmg = damage;

	if (customData == Hitters::builder)
	{
		dmg *= 4;
	}

	return dmg;
}

void onDie(CBlob@ this)
{
	// Anim gibs on death
	this.getSprite().Gib();

	// Clean up two way connections
	CBlob@[] neighbors = getNeighbors(this);
	for (int i = 0; i < neighbors.length(); i++)
	{
		if (neighbors[i] !is null)
		{
			// Update neighbors
			neighbors[i].set_s32(intToDirection((i+2)%4), -1);
			neighbors[i].Sync(intToDirection((i+2)%4), true);

			// Initiate core check
			neighbors[i].set_bool("wiping", true);
			neighbors[i].Sync("wiping", true);

			// Update anchor
			if (neighbors[i].get_s32("anchor") == s32(this.getNetworkID()))
			{
				neighbors[i].set_s32("anchor", -1);
				neighbors[i].Sync("anchor",true);
			}
		}
	}
}
