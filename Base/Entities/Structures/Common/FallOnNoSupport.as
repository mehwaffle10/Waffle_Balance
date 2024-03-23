// FallOnNoSupport.as

void onInit(CBlob@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 17;

	this.addCommandID("static on");
	this.addCommandID("static off");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point)
{
	if (isServer() && solid && !this.getShape().isStatic() && !this.isAttached())
	{
		if (this.getOldVelocity().y < 1.0f && !this.hasTag("can settle"))
		{
			this.server_SetTimeToDie(2);
		}
		else
		{
			this.server_Hit(this, this.getPosition(), this.getVelocity() * -1.0f, 10.0f, 0);
		}
	}
}

void onBlobCollapse(CBlob@ this)
{
	if (!isServer() || getGameTime() < 60 || this.hasTag("fallen")) return;

	CShape@ shape = this.getShape();
	if (shape.getCurrentSupport() < 0.001f)
	{
		CMap@ map = getMap();
		bool laddersupport = false;

		// check if blob is ladder and it is vertical
		if(map !is null && (this.getAngleDegrees() == 0 || this.getAngleDegrees() == 180) && this.getName().toLower() == "ladder"){
			Vec2f pos = this.getPosition();

			// left and right spots to check for support in
			Vec2f[] spotstocheck = {
					Vec2f(pos.x - (1 * map.tilesize), pos.y),
					Vec2f(pos.x + (1 * map.tilesize), pos.y)
				};

			// check if any of the spots have support
			for(int i = 0; i < spotstocheck.length; ++i)
			{
				if(map.getTileSupport(map.getTileOffset(spotstocheck[i])) > 0.001f)
				{
					laddersupport = true;
					break;
				}
			}
		}
		
		// if the shape is static, and there is no support or blob name is not ladder, turn off static
		if (shape.isStatic() && (!laddersupport || this.getName().toLower() != "ladder"))
		{
			this.SendCommand(this.getCommandID("static off"));
		}
	}
	else
	{
		if (!shape.isStatic())
		{
			this.SendCommand(this.getCommandID("static on"));
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("static off"))
	{
		CShape@ shape = this.getShape();
		shape.SetStatic(false);
		shape.SetGravityScale(1.0f);

		ShapeConsts@ consts = shape.getConsts();
		consts.mapCollisions = true;

		if (!this.hasTag("fallen"))
		{
			this.Tag("fallen");
			this.server_SetTimeToDie(3.0f);
            ShapeVars@ vars = this.getShape().getVars();
            if (vars.isladder)
            {
                vars.isladder = false;

            }

		}
	}
	else if (cmd == this.getCommandID("static on"))
	{
		CShape@ shape = this.getShape();
		shape.SetStatic(true);
		shape.SetGravityScale(0.0f);
	}
}
