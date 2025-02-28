
// Waffle: Add bullet stomps courtesy of bunnie

#include "/Entities/Common/Attacks/Hitters.as";
#include "KnockedCommon.as"
#include "CrouchCommon.as"

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
    if (!isServer() || this.hasTag("dead")) {
        return;
    }
    
    if (blob is null && isServer())   // map collision?
	{
		Vec2f old_pos = this.getOldPosition();
		f32 distance = (point1 - old_pos).Length();
		f32 angle = -(point1 - old_pos).getAngle();

		HitInfo@[] hit_infos;
		if (getMap().getHitInfosFromArc(old_pos, angle, 0.0, distance, this, hit_infos))
		{
			for (int i = 0; i < hit_infos.length(); ++i)
			{
				CBlob@ target = @hit_infos[i].blob;
				if (target !is null &&
                    target !is this &&
                    target.hasTag("player") &&
                    old_pos.y < target.getPosition().y - 2 &&
                    target.getTeamNum() != this.getTeamNum() &&
                    !isCrouching(target) &&
                    !target.hasTag("dead") &&
                    !target.isAttached()
                )
				{
                    Stomp(this, target);
                }
			}
		}
		return;
	}

	if (solid && blob.hasTag("player") && this.getPosition().y < blob.getPosition().y - 2)
	{
		Stomp(this, blob);
	}
}

void Stomp(CBlob@ this, CBlob@ blob) {
    // Waffle: No double stomp
    if (getGameTime() - this.get_u32("laststomptime" + blob.getNetworkID()) < 4) {
        return;
    }

    float enemydam = 0.0f;
    f32 vely = this.getOldVelocity().y;

    if (vely > 10.0f)
    {
        enemydam = 2.0f;
    }
    else if (vely > 5.5f)
    {
        enemydam = 1.0f;
    }

    if (enemydam > 0)
    {
        this.set_u32("laststomptime" + blob.getNetworkID(), getGameTime());
        this.set_u32("laststomptime", getGameTime());
        this.Sync("laststomptime", true);
        this.server_Hit(blob, this.getPosition(), Vec2f(0, 1) , enemydam, Hitters::stomp);
    }
}

// effects

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::stomp && damage > 0.0f && velocity.y > 0.0f && worldPoint.y < this.getPosition().y)
	{
		this.getSprite().PlaySound("Entities/Characters/Sounds/Stomp.ogg");
		setKnocked(this, 15, true, hitterBlob.getDamageOwnerPlayer());  // Waffle: Track stuns for assists
	}

    if (isServer() && (customData == Hitters::sword || customData == Hitters::fall || customData == Hitters::crush || customData == Hitters::shield) && damage > 0.0f)
	{
		hitterBlob.set_u32("laststomptime", getGameTime());
		hitterBlob.Sync("laststomptime", true);
	}

	return damage;
}
