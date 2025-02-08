//fall damage for all characters and fall damaged items
// apply Rules "fall vel modifier" property to change the damage velocity base

#include "Hitters.as";
#include "KnockedCommon.as";
#include "FallDamageCommon.as";

const u8 knockdown_time = 12;

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickIfTag = "dead";
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (!solid || this.isInInventory() || this.hasTag("invincible"))
	{
		return;
	}

	if (blob !is null && (blob.hasTag("player") || blob.hasTag("no falldamage")))
	{
		return; //no falldamage when stomping
	}

	f32 vely = this.getOldVelocity().y;

	if (vely < 0 || Maths::Abs(normal.x) > Maths::Abs(normal.y) * 2) { return; }

	f32 damage = FallDamageAmount(vely);
	if (damage != 0.0f) //interesting value
	{
		bool doknockdown = true;

        // check if we aren't touching a trampoline  // Waffle: Always check for trampolines
        CMap@ map = getMap();
        if (map !is null) {
			// Waffle: Fall damage testing
			// TileType marker = CMap::tile_empty;
			// if (damage == -1.0f) {marker = CMap::tile_ground_back;}
			// if (damage == 0.5f)  {marker = CMap::tile_wood_back;}
			// if (damage == 1.0f)  {marker = CMap::tile_castle_back;}
			// if (damage == 4.0f)  {marker = CMap::tile_ground_back;}
			// if (damage == 50.0f) {marker = CMap::tile_wood_back;}
			// for (u8 i = 0; i < 10; i++)
			// {
			// 	map.server_SetTile(this.getPosition() + Vec2f(0, (4 - i) * map.tilesize), marker);
			// }
			// /rcon /loadmap waffle_falldmg
			// /rcon for(u8 i=0;i<64-8;i++){Vec2f p=(Vec2f(31,104)+Vec2f(6,-1)*i)*8;CBlob@ k=server_CreateBlob('knight',-1,p);k.setAimPos(p-Vec2f(0, 1));}
            // /rcon for(u8 i=0;i<64-8;i++){Vec2f p=(Vec2f(31,104)+Vec2f(6,-1)*i)*8;CBlob@ k=server_CreateBlob('knight',-1,p);k.setAimPos(p-Vec2f(0, 1));k.setKeyPressed(key_action2,true);}
			// Fall Damage Heights
			// Ramp 1.2
			// ------------------------------------------------------
			// fall vel modifier | stun |  0.5 |  1.0 |  4.0 | 50.0 
			// ------------------------------------------------------
			// TDM (1.2)         |  16  |  22  |  32  |  47  |  ?
			// TDM (1.2) Glide   |  30  |  35  |  47  |  61  |  ?
			// CTF (1.0)         |  12  |  15  |  22  |  33  |  47
			// CTF (1.0) Glide   |  23  |  29  |  35  |  47  |  61

			// Ramp  1.1
			// ------------------------------------------------------
			// fall vel modifier | stun |  0.5 |  1.0 |  4.0 | 50.0
			// ------------------------------------------------------
			// TDM (1.2)         |  16  |  19  |  23  |  28  |  35
			// TDM (1.2) Glide   |  30  |  33  |  37  |  42  |  47
			// CTF (1.0)         |  12  |  14  |  18  |  20  |  25
			// CTF (1.0) Glide   |  23  |  26  |  30  |  33  |  37

            u8 width = this.getWidth() / 2 + 1;
            u8 height = this.getHeight();

            CBlob@[] overlapping;
            for (s8 x = -width; x <= width; x += width) {
                for (s8 y = 0; y <= height; y += height / 2) {
                    map.getBlobsAtPosition(point1 - Vec2f(x, y), @overlapping);
                }
            }

            for (uint i = 0; i < overlapping.length; i++)
            {
                CBlob@ overlapping_blob = overlapping[i];

                if (overlapping_blob is null || overlapping_blob is this)
                {
                    continue;
                }

                if (overlapping_blob.hasTag("no falldamage"))
                {
                    return;
                }

                CBlob@ carried_blob = overlapping_blob.getCarriedBlob();
                if (carried_blob !is null && carried_blob.hasTag("no falldamage"))
                {
                    return;
                }
            }
        }

        // Waffle: Stomp prevents fall damage briefly. Courtesy of bunnie
        if (getGameTime() - this.get_u32("laststomptime") < 4)
        {
            return;
        }

		if (damage > 0.0f)
		{
			if (damage > 0.1f)
			{
				this.server_Hit(this, point1, normal, damage, Hitters::fall);
			}
			else
			{
				doknockdown = false;
			}
		}

		if (doknockdown)
			setKnocked(this, knockdown_time);

		if (!this.hasTag("should be silent"))
		{				
			if (this.getHealth() > damage) //not dead
				Sound::Play("/BreakBone", this.getPosition());
			else
			{
				Sound::Play("/FallDeath.ogg", this.getPosition());
			}
		}
	}
}

void onTick(CBlob@ this)
{
	this.Tag("should be silent");
	this.getCurrentScript().tickFrequency = 0;
}
