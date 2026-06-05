#include "ChatCommand.as"

class AllMatsCommand : BlobCommand
{
	AllMatsCommand()
	{
		super("allmats", "Spawn all types of materials");
		AddAlias("allmaterials");
		AddAlias("materials");
		AddAlias("mats");
	}

	void SpawnBlobAt(Vec2f pos, string[] args, CPlayer@ player)
	{
		CBlob@ wood = server_CreateBlob("mat_wood", -1, pos);
		wood.server_SetQuantity(500);
		CBlob@ stone = server_CreateBlob("mat_stone", -1, pos);
		stone.server_SetQuantity(500);
		// CBlob@ gold = server_CreateBlob("mat_gold", -1, pos);  // Waffle: Gold gives coins
		// gold.server_SetQuantity(100);                          // Waffle: --
	}
}

class WoodCommand : BlobCommand
{
	WoodCommand()
	{
		super("wood", "Spawn wood");
	}

	void SpawnBlobAt(Vec2f pos, string[] args, CPlayer@ player)
	{
		CBlob@ wood = server_CreateBlob("mat_wood", -1, pos);
		wood.server_SetQuantity(500);
	}
}

class StoneCommand : BlobCommand
{
	StoneCommand()
	{
		super("stone", "Spawn stone");
		AddAlias("stones");
	}

	void SpawnBlobAt(Vec2f pos, string[] args, CPlayer@ player)
	{
		CBlob@ stone = server_CreateBlob("mat_stone", -1, pos);
		stone.server_SetQuantity(500);
	}
}

class GoldCommand : BlobCommand
{
	GoldCommand()
	{
		super("gold", "Gives the player coins");  // Waffle: Gold gives coins
	}

	void Execute(string[] args, CPlayer@ player)
	{
		if (isServer())
		{
			int coins = args.size() > 0 ? parseInt(args[0]) : player.getCoins() + 100;
			player.server_setCoins(coins);
		}

		if (player.isMyPlayer())
		{
			Sound::Play("snes_coin.ogg");
		}
	}
	// Waffle: Gold gives coins
	// void SpawnBlobAt(Vec2f pos, string[] args, CPlayer@ player)
	// {
	// 	CBlob@ gold = server_CreateBlob("mat_gold", -1, pos);
	// 	gold.server_SetQuantity(100);
	// }
}
