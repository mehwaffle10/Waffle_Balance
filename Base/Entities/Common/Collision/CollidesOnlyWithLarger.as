
bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    print("NETID: " + this.getNetworkID() + " blob source_mounted_bow: " + blob.get_u16("source_mounted_bow"));
	return blob.getRadius() >= this.getRadius() || blob.hasTag("projectile") && this.getNetworkID() != blob.get_u16("source_mounted_bow");  // Waffle: Mounted bows can be hit by projectiles
}