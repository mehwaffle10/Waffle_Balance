
const u8 inner_distance = 24;  // Distance from center to inner front wall
const u8 open_offset = 16;     // Distance to add to open side
const u8 top_distance = 24;    // Distance from center to top
const u8 bottom_distance = 10;  // Distance from center to bottom

void onInit(CSprite@ this)
{
	this.getCurrentScript().tickFrequency = 10;
}

void onTick(CSprite@ this)
{
	CSpriteLayer@ front = this.getSpriteLayer("front layer");
	if (front is null)
	{
        return;
    }

    bool visible = true;
    int frame = front.getFrameIndex();
    CBlob@ warboat = this.getBlob();
    CPlayer@ p = getLocalPlayer();
    if (p !is null)
    {
        CBlob@ local = p.getBlob();
        if (local !is null)
        {
            // Find center of box
            Vec2f box_center = warboat.getPosition() + Vec2f(open_offset * (warboat.isFacingLeft() ? 1 : -1), bottom_distance - top_distance) / 2;

            // Move box and point to origin
            Vec2f player_pos = local.getPosition() - box_center;

            // Rotate point around center
            player_pos = player_pos.RotateByRadians(-warboat.getAngleRadians());

            // Check if rotated point is in box
            if (Maths::Abs(player_pos.x) < inner_distance + open_offset / 2 &&
                Maths::Abs(player_pos.y) < (top_distance + bottom_distance) / 2)
            {
                visible = false;
            }
        }
    }

    front.SetVisible(visible);
    front.animation.setFrameFromRatio(1.0f - (warboat.getHealth() / warboat.getInitialHealth()));
}
