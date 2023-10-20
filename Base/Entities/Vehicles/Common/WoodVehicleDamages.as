#include "Hitters.as";
#include "GameplayEvents.as";

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;

	switch (customData)
	{
		case Hitters::builder:
			dmg *= 3.0f;  // Waffle: Increase builder damage to vehicles
			break;

		case Hitters::sword:
			// Waffle: Swords do full damage
			// if (dmg <= 1.0f)
			// {
			// 	dmg = 0.25f;
			// }
			// else
			// {
			// 	dmg = 0.5f;
			// }
			break;

		case Hitters::bomb:
			dmg *= 1.40f;
			break;

		case Hitters::explosion:
		case Hitters::keg:  // Waffle: Kegs do increased damage
			dmg *= 4.5f;
			break;

		case Hitters::bomb_arrow:
			dmg *= this.exists("bomb resistance") ? this.get_f32("bomb resistance") : 5.0f;  // Waffle: Reduce bomb arrow damage
			break;

		case Hitters::arrow:
			// Waffle: Arrows do full damage
			// dmg = this.getMass() > 1000.0f ? 1.0f : 0.5f;
			break;

		case Hitters::ballista:
			dmg *= 2.0f;
			break;

        // Waffle: Adjust catapult damage
        case Hitters::cata_stones:
            dmg /= 4.0f;
            break;
	}

	if (dmg > 0 && hitterBlob !is null && hitterBlob !is this)
	{
		CPlayer@ damageowner = hitterBlob.getDamageOwnerPlayer();
		if (damageowner !is null)
		{
			if (damageowner.getTeamNum() != this.getTeamNum())
			{
				SendGameplayEvent(createVehicleDamageEvent(damageowner, dmg));
			}
		}
	}

	return dmg;
}

void onDie(CBlob@ this)
{
	CPlayer@ p = this.getPlayerOfRecentDamage();
	if (p !is null)
	{
		CBlob@ b = p.getBlob();
		if (b !is null && b.getTeamNum() != this.getTeamNum())
		{
			SendGameplayEvent(createVehicleDestroyEvent(this.getPlayerOfRecentDamage()));
		}
	}
}
