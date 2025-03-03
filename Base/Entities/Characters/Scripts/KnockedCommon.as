const string knockedProp = "knocked";
const string knockedTag = "knockable";

// Waffle: Track stuns for assists
class KnockedHistory
{
	CPlayer@[] players;
	u32[] times;

	KnockedHistory()
	{
		CPlayer@[] _players;
		players = _players;
		u32[] _times;
		times = _times;
	}
}

void InitKnockable(CBlob@ this)
{
	this.set_u8(knockedProp, 0);
	this.Tag(knockedTag);

	this.Sync(knockedProp, true);
	this.Sync(knockedTag, true);

	this.addCommandID("knocked");

	this.set_u32("justKnocked", 0);

	// Waffle: Track stuns for assists
	this.set("KnockedHistory", KnockedHistory());
}

// returns true if the new knocked time would be longer than the current.
bool setKnocked(CBlob@ blob, int ticks, bool server_only = false, CPlayer@ stunnedByPlayer = null)  // Waffle: Track stuns for assists
{
	if (blob.hasTag("invincible"))
		return false; //do nothing

	u8 knockedTime = ticks;
	u8 currentKnockedTime = blob.get_u8(knockedProp);
	if (knockedTime > currentKnockedTime)
	{
		if (getNet().isServer())
		{
			blob.set_u8(knockedProp, knockedTime);

			// Waffle: Track stuns for assists
			KnockedHistory@ knockedHistory;
    		blob.get("KnockedHistory", @knockedHistory);
			if (knockedHistory !is null && stunnedByPlayer !is null)
			{
				knockedHistory.players.push_back(stunnedByPlayer);
				knockedHistory.times.push_back(getGameTime());
			}

			CBitStream params;
			params.write_u8(knockedTime);
			params.write_netid(stunnedByPlayer !is null ? stunnedByPlayer.getNetworkID() : 0);  // Waffle: Track stuns for assists
			blob.SendCommand(blob.getCommandID("knocked"), params);
		}

		if(!server_only && blob.isMyPlayer())
		{
			blob.set_u8(knockedProp, knockedTime);
		}

		return true;
	}
	return false;

}

void KnockedCommands(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("knocked") && getNet().isClient())
	{
		u8 knockedTime = 0;
		if (!params.saferead_u8(knockedTime))
		{
			return;
		}

		this.set_u32("justKnocked", getGameTime());
		this.set_u8(knockedProp, knockedTime);

		// Waffle: Track stuns for assists
		u16 stunnedByPlayerNetID = 0;
		if (!params.saferead_netid(stunnedByPlayerNetID) || stunnedByPlayerNetID == 0)
		{
			return;
		}
		CPlayer@ stunnedByPlayer = getPlayerByNetworkId(stunnedByPlayerNetID);
		KnockedHistory@ knockedHistory;
		this.get("KnockedHistory", @knockedHistory);
		if (knockedHistory !is null && stunnedByPlayer !is null)
		{
			knockedHistory.players.push_back(stunnedByPlayer);
			knockedHistory.times.push_back(getGameTime());
		}
	}
}

u8 getKnockedRemaining(CBlob@ this)
{
	u8 currentKnockedTime = this.get_u8(knockedProp);
	return currentKnockedTime;
}

bool isKnocked(CBlob@ this)
{
	if (this.getPlayer() !is null && this.getPlayer().freeze)
	{
		return true;

	}

	u8 knockedRemaining = getKnockedRemaining(this);
	return (knockedRemaining > 0);
}

bool isJustKnocked(CBlob@ this)
{
	return this.get_u32("justKnocked") == getGameTime();
}

void DoKnockedUpdate(CBlob@ this)
{
	if (this.hasTag("invincible"))
	{
		this.DisableKeys(0);
		this.DisableMouse(false);
		return;
	}

	u8 knockedRemaining = getKnockedRemaining(this);
	bool frozen = false;
	if (this.getPlayer() !is null && this.getPlayer().freeze)
	{
		frozen = true;
	}

	if (knockedRemaining > 0 || frozen)
	{
        this.ClearMenus();  // Waffle: No buying things when stunned or frozen
		if (knockedRemaining > 0)
		{
			knockedRemaining--;
			this.set_u8(knockedProp, knockedRemaining);

		}


		u16 takekeys;
		if (knockedRemaining < 2 || (this.hasTag("dazzled") && knockedRemaining < 30))
		{
			takekeys = key_action1 | key_action2 | key_action3;

			if (this.isOnGround())
			{
				this.AddForce(this.getVelocity() * -10.0f);
			}
		}
		else
		{
			takekeys = key_left | key_right | key_up | key_down | key_action1 | key_action2 | key_action3;
		}

		this.DisableKeys(takekeys);
		this.DisableMouse(true);

		// Disable keys takes the keys for tick after it's called
		// so we want to end on time by not calling DisableKeys before knocked finishes
		if (knockedRemaining < 2 && !frozen)
		{
			this.DisableKeys(0);
			this.DisableMouse(false);
		}

		if (knockedRemaining == 0)
		{
			this.Untag("dazzled");
		}

		this.Tag("prevent crouch");
	}
	else
	{
		this.DisableKeys(0);
		this.DisableMouse(false);
	}
}

bool isKnockable(CBlob@ blob)
{
	return blob.hasTag(knockedTag);
}
