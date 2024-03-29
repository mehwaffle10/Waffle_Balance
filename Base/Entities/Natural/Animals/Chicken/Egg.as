
const int grow_time = 20 * getTicksASecond(); // Waffle: Decrease time to hatch

const int MAX_CHICKENS_TO_HATCH = 10; // Waffle: Increase number of chickens we can hatch nearby
const f32 CHICKEN_LIMIT_RADIUS = 120.0f;

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 120;
	this.addCommandID("hatch");
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}

void onTick(CBlob@ this)
{
	if (getNet().isServer() && this.getTickSinceCreated() > grow_time)
	{
		int chickenCount = 0;
		CBlob@[] blobs;
		this.getMap().getBlobsInRadius(this.getPosition(), CHICKEN_LIMIT_RADIUS, @blobs);
		for (uint step = 0; step < blobs.length; ++step)
		{
			CBlob@ other = blobs[step];
			if (other.getName() == "chicken")
			{
				chickenCount++;
			}
		}

		if (chickenCount < MAX_CHICKENS_TO_HATCH)
		{
			this.SendCommand(this.getCommandID("hatch"));
		}
	}
}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("hatch"))
	{
		CSprite@ s = this.getSprite();
		if (s !is null)
		{
			s.Gib();
		}

		if (getNet().isServer())
		{
			this.server_SetHealth(-1);
			this.server_Die();
			server_CreateBlob("chicken", this.getTeamNum(), this.getPosition() + Vec2f(0, -5.0f));  // Waffle: Make chickens hatch to the correct team
		}
	}
}
