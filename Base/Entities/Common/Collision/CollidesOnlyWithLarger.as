
bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.getRadius() >= this.getRadius()) || blob.hasTag("projectile");  // Waffle: Mounted bows can be hit by projectiles
}