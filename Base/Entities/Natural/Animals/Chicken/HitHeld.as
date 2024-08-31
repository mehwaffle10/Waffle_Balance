
void onInit(CBlob@ this)
{
    this.getCurrentScript().runFlags = Script::tick_attached;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
    AttachmentPoint@ attachment = this.getAttachmentPoint(0);
    if (damage > 0.0f && attachment !is null && attachment.socket)
    {
        CBlob@ attached = attachment.getOccupied();
        if (attached !is null && hitterBlob !is null && hitterBlob.getTeamNum() != this.getTeamNum() && attached.getName() == "chicken")
        {
            hitterBlob.server_Hit(attached, worldPoint, velocity, 10.0f, customData);
        }
    }
    return damage;
}