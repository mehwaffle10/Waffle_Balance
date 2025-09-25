
#include "Hitters.as"
#include "FireSpreadCommon.as"

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	CMap@ map = getMap();
    if (customData == Hitters::burn && map !is null)
    {
        // Spread fire to adjacent blocks including diagonals
        // Realign to center of blob
        Vec2f offset = Vec2f(0, 0);
        if (this.hasTag("door") || this.isPlatform() || this.getName() == "ladder" || this.hasTag("tree"))
        {
            offset = Vec2f(this.getWidth(), this.getHeight()) / 2;
        }

        // Ladders need to be moved down a block for some reason
        if (this.getName() == "ladder")
        {
            offset -= Vec2f(0, map.tilesize);
        }

        CShape@ shape = this.getShape();
        FireSpread(worldPoint - offset, shape is null || shape.isStatic() || this.getName() == "saw");

		// Ignite overlapping tree
		CBlob@[] overlapping;
		if (this.getOverlapping(overlapping))
		{
			for (u16 i = 0; i < overlapping.length; i++)
			{
				CBlob@ blob = overlapping[i];
				if (blob !is null && blob !is this && blob.hasTag("tree"))
				{
					FireSpread(map.getAlignedWorldPos(blob.getPosition()), false);
				}
			}
		}
    }

    return damage;
}
