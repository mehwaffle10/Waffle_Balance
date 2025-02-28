
#include "KnockedCommon"  // Waffle: Track stuns for assists

//TODO: powerful items that insta-kill shouldnt have an assist (keg, mine)

CPlayer@ getAssistPlayer(CPlayer@ victim, CPlayer@ killer)
{
	//no assist if teamkill
	if (victim is null || killer is null)  // || victim.getTeamNum() == killer.getTeamNum())  // Waffle: Allow teamkill assist in kill feed
	{
		return null;
	}

	//get victim blob
	CBlob@ victimBlob = victim.getBlob();
	if (victimBlob is null)
	{
		return null;
	}

	// Waffle: Track stuns for assists
	KnockedHistory@ knockedHistory;
	victimBlob.get("KnockedHistory", @knockedHistory);
	if (knockedHistory !is null)
	{
		for (int i = knockedHistory.players.length - 1; i >= 0; i--)
		{
			if (knockedHistory.times[i] + 3 * getTicksASecond() <= getGameTime())
			{
				break;
			}

			if (knockedHistory.players[i] !is killer)
			{
				return knockedHistory.players[i];
			}
		}
	}

	//damage criteria for assist
	f32 assistDamage = victimBlob.getInitialHealth() / 2.0f;

	//get info used to determine assist
	CPlayer@[] hitters;
	f32[] damages;
	// int[] times;
	victimBlob.getPlayersOfDamage(@hitters);
	victimBlob.getAmountsOfDamage(damages);
	// victimBlob.getTimesOfDamage(times);

	// print("assist lengths: " + hitters.length + " " + damages.length + " " + times.length);

	// for (u8 i = 0; i < hitters.length; i++)
	// {
	// 	if (hitters[i] !is null)
	// 	{
	// 		print("hitters: " + i + " " + hitters[i].getUsername() + " damage: " + damages[i] + " time: " + times[i]);
	// 	}
	// }

	//why does the server only have the final hit?
	if (isServer())
	{
		hitters.removeLast();
		damages.removeLast();
		// times.removeLast();
	}

	//at this point, the arrays have all hits except the final hit

	//no hitters if victim is killed in one hit
	if (hitters.length == 0)
	{
		return null;
	}

	//subtract amount healed from damage
	f32 healed = victimBlob.get_f32("heal amount");
	// print("healed: " + healed);
	uint limit;
	for (limit = 0; limit < damages.length; limit++)
	{
		f32 sub = Maths::Min(healed, damages[limit]);
		damages[limit] -= sub;
		healed -= sub;

		//no more healing left
		if (healed == 0.0f)
		{
			break;
		}
	}

	//reverse arrays to loop from newest to oldest
	hitters.reverse();
	damages.reverse();
	limit = hitters.length - limit;

	for (uint i = 0; i < limit; i++)
	{
		CPlayer@ origHitter = hitters[i];
		if(origHitter is null)
		{
			continue;
		}
		f32 totalDamage = 0;

		for (uint j = 0; j < hitters.length; j++)
		{
			CPlayer@ hitter = hitters[j];
			f32 damage = damages[j];

			//get sum of damage from hitter
			if (hitter is origHitter)
			{
				totalDamage += damage;
			}
		}

		//check if damage is enough for assist
		if (totalDamage >= assistDamage)
		{
			//killer cannot assist their own kill
			//helper needs to be from a different team
			if (origHitter is killer || victim.getTeamNum() == origHitter.getTeamNum())
			{
				return null;
			}

			//so close, yet so far. give this player some recognition!
			return origHitter;
		}
	}

	return null;
}
