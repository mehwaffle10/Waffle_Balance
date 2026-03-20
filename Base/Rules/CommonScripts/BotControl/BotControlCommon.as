
const string MINIMUM_TEAM_SIZE = "minimum team size";
const string PLAYER_COUNT_SUFFIX = "_player_count";
const string BOT_COUNT_SUFFIX = "_bot_count";
const string TEAM_SIZE_SUFFIX = "_team_size";
const string INGAME_COUNT = "ingame count";
const string TEAM_PROPERTY = "fake team num";  // Dumb but it doesn't update until next tick

void updateTeamStats(CRules@ this)
{
	u8 blue_players = 0, blue_bots = 0, red_players = 0, red_bots = 0;
	for (u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player is null)
		{
			continue;
		}

		s32 team = player.get_s32(TEAM_PROPERTY);
		bool isBot = player.isBot();
		if (team == 0)
		{
			if (isBot)
			{
				blue_bots++;
			}
			else
			{
				blue_players++;
			}
		}
		else if (team == 1)
		{
			if (isBot)
			{
				red_bots++;
			}
			else
			{
				red_players++;
			}
		}
	}
	this.set_u8(0 + PLAYER_COUNT_SUFFIX, blue_players);
	this.set_u8(0 + BOT_COUNT_SUFFIX, blue_bots);
	this.set_u8(0 + TEAM_SIZE_SUFFIX, blue_players + blue_bots);
	this.set_u8(1 + PLAYER_COUNT_SUFFIX, red_players);
	this.set_u8(1 + BOT_COUNT_SUFFIX, red_bots);
	this.set_u8(1 + TEAM_SIZE_SUFFIX, red_players + red_bots);
	this.set_u8(INGAME_COUNT, blue_players + blue_bots + red_players + red_bots);
}