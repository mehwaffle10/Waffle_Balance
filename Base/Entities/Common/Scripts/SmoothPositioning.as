// Waffle: Better interpolation
class RemoteSmooth
{
    Vec2f prevPos, latestPos;
    float prevTick, latestTick;
}

Vec2f smoothPos(CBlob@ blob, float delay = 1.0f)
{
    if (!isClient())
    {
        return Vec2f_zero;
    }

    Vec2f interpolatedPos = blob.getInterpolatedPosition();
    Vec2f rawPos = blob.getPosition();

    if (interpolatedPos != rawPos)
	{
		return interpolatedPos;
	}

    RemoteSmooth@ state;
    blob.get("blob_smooth_positioning", @state);

    if (state is null)
    {
        // first frame init
        @state = RemoteSmooth();

        state.prevPos = state.latestPos = rawPos;
        state.prevTick = state.latestTick = float(getGameTime());

        blob.set("blob_smooth_positioning", @state);

        return rawPos;
    }

    float renderTime  = float(getGameTime()) + getInterpolationFactor();
    float currentTick = float(getGameTime());

    if (rawPos != state.latestPos)
    {
        state.prevPos = state.latestPos;
		state.prevTick = state.latestTick;

        state.latestPos = rawPos;
		state.latestTick = currentTick;
    }

    float playbackTime = renderTime - delay;

    if (playbackTime >= state.latestTick)
	{
		return state.latestPos;
	}

    if (playbackTime <= state.prevTick)
	{
		return state.prevPos;
	}

    float segmentTicks = state.latestTick - state.prevTick;
    if (segmentTicks < 0.001f)
	{
		return state.latestPos;
	}

    float segmentPhase = (playbackTime - state.prevTick) / segmentTicks;
    return state.prevPos + (state.latestPos - state.prevPos) * segmentPhase;
}
