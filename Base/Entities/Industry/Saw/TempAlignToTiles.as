
void onInit(CBlob@ this)
{
    if (getGameTime() < 3)
    {
        this.setVelocity(Vec2f_zero);
        this.getCurrentScript().runFlags |= Script::tick_not_attached;
    }
    else
    {
        this.getCurrentScript().runFlags |= Script::remove_after_this;
    }
}

void onTick(CBlob@ this)
{
	CShape@ shape = this.getShape();
    CMap@ map = this.getMap();
    f32 div_maptile = 1.0f / map.tilesize;

    Vec2f p = this.getPosition();

    Vec2f tp = p * div_maptile;
    Vec2f round_tp = tp;
    round_tp.x = Maths::Round(round_tp.x);
    round_tp.y = Maths::Floor(round_tp.y + 1);

    f32 width = shape.getWidth() * div_maptile;
    f32 height = shape.getHeight() * div_maptile;

    f32 modwidth = Maths::FMod(width , 2.0f);
    f32 modheight = Maths::FMod(height , 2.0f);

    bool oddWidth = modwidth > 0.5f && modwidth < 1.5f;
    bool oddHeight = modheight > 0.5f && modheight < 1.5f;

    f32 move_x = (round_tp.x > tp.x ? -1.0f : 1.0f);
    f32 move_y = (round_tp.y > tp.y ? -1.0f : 1.0f);

    p.x = round_tp.x * map.tilesize + (oddWidth ? map.tilesize * 0.5f : 0.0f) * move_x;
    p.y = round_tp.y * map.tilesize + (oddHeight ? map.tilesize * 0.5f : 0.0f) * move_y;
    this.setPosition(p);
    this.setVelocity(Vec2f());
    this.getCurrentScript().runFlags |= Script::remove_after_this;
}
