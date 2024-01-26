
bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getRadius() >= this.getRadius() || blob.hasTag("projectile") && this.getNetworkID() != blob.get_u16("source_mounted_bow");  // Waffle: Mounted bows can be hit by projectiles
}