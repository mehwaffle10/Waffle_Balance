#include "Hitters.as";
#include "FireCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("sawed");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (!isIgniteHitter(customData) && customData != Hitters::burn && !isExplosionHitter(customData) && customData != Hitters::keg)
	{
		return 0.0f;
	}

	if (damage > 0.05f) //sound for all damage
	{
		f32 angle = (this.getPosition() - worldPoint).getAngle();
		if (hitterBlob !is this)
		{
			this.getSprite().PlayRandomSound("/WoodHit", Maths::Min(1.25f, Maths::Max(0.5f, damage)));
		}
		else
		{
			angle = 90.0f; // self-hit. spawn gibs upwards
		}

		makeGibParticle("/GenericGibs", worldPoint, getRandomVelocity(angle, 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f),
		                1, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
	}

	return damage;
}

void onGib(CSprite@ this)
{
	if (this.getBlob().hasTag("heavy weight"))
	{
		this.PlaySound("/WoodDestruct");
	}
	else
	{
		this.PlaySound("/LogDestruct");
	}
}