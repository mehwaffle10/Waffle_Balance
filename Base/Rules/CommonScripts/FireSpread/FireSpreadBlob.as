
#define SERVER_ONLY

#include "Hitters.as"
#include "FireSpreadCommon.as"

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
    if (customData == Hitters::burn)
    {
        // Spread fire to adjacent blocks including diagonals
        FireSpread(worldPoint);
    }

    return damage;
}
