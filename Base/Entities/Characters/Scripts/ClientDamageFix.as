// Move the return 0 from FleshHit.as because it fixes the client logging damage as 0
f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return 0.0f;
}
