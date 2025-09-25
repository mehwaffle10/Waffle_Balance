
void onInit(CRules@ this)
{
    addFireScript();
    this.addCommandID("Display Fire");
}

void onRestart(CRules@ this)
{
    addFireScript();
}

void addFireScript()
{
    getMap().AddScript("FireSpreadMap.as");
}

void onBlobCreated(CRules@ this, CBlob@ blob)
{
    if (!blob.hasTag("player") && !blob.hasTag("vehicle") && blob.isFlammable())
    {
        blob.AddScript("FireSpreadBlob.as");
    }
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
    if (isClient() && cmd == this.getCommandID("Display Fire"))
    {
        for (u8 i = 0; i < 2; i++)
        {
            Vec2f target;
            if (!params.saferead_Vec2f(target))
            {
                return;
            }

            ParticleAnimated(XORRandom(2) == 0 ? "SmallFire1.png" : "SmallFire2.png", target, Vec2f(0, 0), 0.0f, 1.0f, 5, 0.0f, true);
        }
    }
}