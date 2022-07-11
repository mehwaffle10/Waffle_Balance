
#include "Hitters.as"
#include "FireSpreadCommon.as"

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
    if (customData == Hitters::burn)
    {
        // Spread fire to adjacent blocks including diagonals
        // Realign to center of blob
        Vec2f offset = Vec2f(0, 0);
        if (this.hasTag("door") || this.isPlatform() || this.getName() == "ladder")
        {
            offset = Vec2f(this.getWidth(), this.getHeight()) / 2;
        }

        // Ladders need to be moved down a block for some reason
        if (this.getName() == "ladder")
        {
            offset -= Vec2f(0, getMap().tilesize);
        }

        print("worldPoint: " + worldPoint + " Position: " + this.getPosition() + " Angle: " + this.getAngleDegrees() + " Width: " + this.getWidth() + " Height: " + this.getHeight() + " offset: " + offset);
        CShape@ shape = this.getShape();
        FireSpread(worldPoint - offset, shape is null || shape.isStatic());
    }

    return damage;
}
