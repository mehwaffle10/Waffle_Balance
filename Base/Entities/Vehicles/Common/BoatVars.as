
const f32 BLOCK_BREAKING_SPEED_THRESHOLD = 3.0f * 2000.0f;

f32 getBlobBreakingSpeedThreshold(CBlob@ this)
{
	return BLOCK_BREAKING_SPEED_THRESHOLD / this.getMass();
}