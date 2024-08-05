
void getNearbyEnemies(CBlob@ this, CBlob@[]&out enemies, f32 distance) {
    CBlob@[] players;
	getBlobsByTag("player", @players);
	Vec2f pos = this.getPosition();
	for (uint i = 0; i < players.length; i++)
	{
		CBlob@ player = players[i];
		if (player !is this && this.getTeamNum() != player.getTeamNum() && (pos - player.getPosition()).Length() < distance)
		{
			enemies.push_back(player);
		}
	}
}
