
const u8 inner_distance = 30;  // Distance from center to inner front wall
const u8 open_offset = 12;     // Distance to add to open side
const u8 top_distance = 24;    // Distance from center to top
const u8 bottom_distance = 8;  // Distance from center to bottom

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
            Vec2f player_pos = local.getPosition();
            Vec2f warboat_pos = warboat.getPosition();
            u8 left_limit = inner_distance, right_limit = inner_distance;
            if (warboat.isFacingLeft())
            {
                right_limit += open_offset;
            }
            else
            {
                left_limit += open_offset;
            }

            if (player_pos.x > warboat_pos.x - left_limit   &&
                player_pos.x < warboat_pos.x + right_limit  &&
                player_pos.y > warboat_pos.y - top_distance &&
                player_pos.y < warboat_pos.y + bottom_distance)
            {
                visible = false;
            }
        }
    }

    front.SetVisible(visible);
    front.animation.setFrameFromRatio(1.0f - (warboat.getHealth() / warboat.getInitialHealth()));
}
