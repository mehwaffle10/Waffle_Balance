//Auto-mining quarry
//converts wood into ores

#include "GenericButtonCommon.as"
#include "TreeLimitCommon.as"

const string fuel = "mat_wood";
const string ore = "mat_stone";
const string rare_ore = "mat_gold";

//balance
const int input = 100;					// input cost in fuel
const int initial_output = 20;			// output amount in ore
const int min_output = 20;				// minimal possible output in ore
const int output_decrease = 0;			// by how much output decreases every time ore is dropped  // Waffle: Quarries never slow down
const bool enable_rare = false;			// enable/disable
const int rare_chance = 10;				// one-in
const int rare_output = 20;				// output for rare ore
const int conversion_frequency = 15;	// how often to convert, in seconds
const u8 producer_check_offset = 6;     // Waffle: Prevent trees from slightly off the quarry

const int min_input = Maths::Ceil(input/initial_output);

//fuel levels for animation
const int max_fuel = 800;
const int mid_fuel = 500;
const int low_fuel = 200;

//property names
const string fuel_prop = "fuel_level";
const string working_prop = "working";
const string unique_prop = "unique";
const string last_working_prop = "last_working";  // Waffle: Add power up and down sounds
const string last_working_time = "last_working_time";
const string last_stopped_time = "last_stopped_time";
const string next_production_time = "next_production_time";  // Waffle: Remove RNG from production time


void onInit(CSprite@ this)
{
	CSpriteLayer@ belt = this.addSpriteLayer("belt", "QuarryBelt.png", 32, 32);
	if (belt !is null)
	{
		//default anim
		{
			Animation@ anim = belt.addAnimation("default", 0, true);
			int[] frames = {
				0, 1, 2, 3,
				4, 5, 6, 7,
				8, 9, 10, 11,
				12, 13
			};
			anim.AddFrames(frames);
		}
		//belt setup
		belt.SetOffset(Vec2f(-7.0f, -4.0f));
		belt.SetRelativeZ(1);
		belt.SetVisible(true);
	}

	CSpriteLayer@ wood = this.addSpriteLayer("wood", "Quarry.png", 16, 16);
	if (wood !is null)
	{
		wood.SetOffset(Vec2f(8.0f, -1.0f));
		wood.SetVisible(false);
		wood.SetRelativeZ(1);
	}

	this.SetEmitSound("/Quarry.ogg");
	this.SetEmitSoundPaused(true);
}

void onInit(CBlob@ this)
{
	//building properties
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getSprite().SetZ(-50);
	this.getShape().getConsts().mapCollisions = false;

	//gold building properties
	this.set_s32("gold building amount", 100);

	//quarry properties
	this.set_s16(fuel_prop, 0);
	this.set_bool(working_prop, false);
	this.set_u8(unique_prop, XORRandom(getTicksASecond() * conversion_frequency));

	//commands
	this.addCommandID("add fuel");
	string current_output = "current_quarry_output_" + this.getTeamNum();
	CRules@ rules = getRules();

	if (!rules.exists(current_output) || rules.get_s32(current_output) == -1)
	{
		rules.set_s32("current_quarry_output_" + this.getTeamNum(), initial_output);
	}
}

void onTick(CBlob@ this)
{
	//only do "real" update logic on server
	if (getNet().isServer())
	{
		// Waffle: Quarries can only produce when overlapping at least 2 trees
		if (!canProduce(this))
		{
			this.set_u32(last_stopped_time, getGameTime());
			if (this.get_bool(working_prop) && this.get_u32(last_working_time) + 10 < getGameTime())  // Waffle: Need to delay since seeds take a couple ticks to spawn and land on the ground
			{
				this.set_bool(working_prop, false);
				this.Sync(working_prop, true);
			}
		}
		else
		{
            this.set_u32(last_working_time, getGameTime());
            if (this.get_u32(last_stopped_time) + 10 < getGameTime())
            {
                int oldBlobCount = this.get_s16(fuel_prop);
                PickupOverlap(this);  // Waffle: Quarries can pick up wood
                int blobCount = this.get_s16(fuel_prop);
                if ((blobCount >= min_input))
                {
                    bool oldWorking = this.get_bool(working_prop);
                    if (!oldWorking)
                    {
                        this.set_bool(working_prop, true);
                        this.set_u32(next_production_time, getGameTime() + conversion_frequency * getTicksASecond());
                    }

                    //only convert every conversion_frequency seconds
                    u32 next_production = this.get_u32(next_production_time);
                    if (next_production <= getGameTime())  // Waffle: Remove RNG from production time
                    {
                        spawnOre(this);
                        this.set_u32(next_production_time, next_production + conversion_frequency * getTicksASecond());  // Waffle: Remove RNG from production time

                        if (blobCount - input < min_input)
                        {
                            this.set_bool(working_prop, false);
                        }
                    }

                    bool newWorking = this.get_bool(working_prop);
                    if (newWorking != oldWorking)
                    {
                        this.Sync(working_prop, true);
                    }
                }

                int newBlobCount = this.get_s16(fuel_prop);
                if (newBlobCount != oldBlobCount)
                {
                    this.Sync(fuel_prop, true);
                }
            }
		}
	}

	// Waffle: Add power up and down sounds
	CSprite@ sprite = this.getSprite();
	bool working = this.get_bool(working_prop);
	bool last_working = this.get_bool(last_working_prop);
	if (sprite.getEmitSoundPaused())
	{
		if (working)
		{
			if (!last_working)
			{
				sprite.PlaySound("PowerUp.ogg");
			}
			sprite.SetEmitSoundPaused(false);
		}
	}
	else if (!working)
	{
		if (last_working)
		{
			sprite.PlaySound("PowerDown.ogg");
		}
		sprite.SetEmitSoundPaused(true);
	}
	this.set_bool(last_working_prop, working);  // Waffle: Fix an issue where change classes reloaded sprites, causing the power up and down sounds to play

	//update sprite based on modified or synced properties
	updateWoodLayer(this.getSprite());
	if (getGameTime() % (getTicksASecond()/2) == 0) animateBelt(this, working);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller) || !this.isOverlapping(caller)) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());

	string text = "Add fuel";
	bool enabled = caller.hasBlob(fuel, 1);
	if (!canProduce(this))
	{
		text = "Must have two overlapping trees that can grow";
		enabled = false;
	}
	else if (this.get_s16(fuel_prop) >= max_fuel)
	{
		text = "Fuel is full";
		enabled = false;
	}
	CButton@ button = caller.CreateGenericButton("$mat_wood$", Vec2f(-4.0f, 0.0f), this, this.getCommandID("add fuel"), getTranslatedString(text), params);
	if (button !is null)
	{
		button.deleteAfterClick = false;
		button.SetEnabled(enabled);
        CShape@ shape = this.getShape();
        button.enableRadius = shape is null ? 16 : Maths::Max(this.getRadius(), (shape.getWidth() + shape.getHeight()) / 2);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("add fuel"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller is null) return;

		//amount we'd _like_ to insert
		int requestedAmount = Maths::Min(250, max_fuel - this.get_s16(fuel_prop));
		//(possible with laggy commands from 2 players, faster to early out here if we can)
		if (requestedAmount <= 0) return;

		CBlob@ carried = caller.getCarriedBlob();
		//how much fuel does the caller have including what's potentially in his hand?
		int callerQuantity = caller.getInventory().getCount(fuel) + (carried !is null && carried.getName() == fuel ? carried.getQuantity() : 0);

		//amount we _can_ insert
		int ammountToStore = Maths::Min(requestedAmount, callerQuantity);
		//can we even insert anything?
		if (ammountToStore > 0)
		{
			caller.TakeBlob(fuel, ammountToStore);
			this.set_s16(fuel_prop, this.get_s16(fuel_prop) + ammountToStore);

			updateWoodLayer(this.getSprite());
		}
	}
}

void spawnOre(CBlob@ this)
{
	int blobCount = this.get_s16(fuel_prop);
	int actual_input = Maths::Min(input, blobCount);

	int r = XORRandom(rare_chance);
	int output = getRules().get_s32("current_quarry_output_" + this.getTeamNum());

	//rare chance, but never rare if not a full batch of wood
	bool rare = (enable_rare && r == 0 && blobCount >= input);

	CBlob@ _ore = server_CreateBlobNoInit(!rare ? ore : rare_ore);

	if (_ore is null) return;

	int amountToSpawn = Maths::Floor(output * actual_input / input);
	//round to 5
	int remainder = amountToSpawn % 5;
	amountToSpawn += (remainder < 3 ? -remainder : (5 - remainder));
	//setup res
	_ore.Tag("custom quantity");
	_ore.Init();
	_ore.setPosition(this.getPosition() + Vec2f(-8.0f, 0.0f));
	_ore.server_SetQuantity(!rare ? amountToSpawn : rare_output);

	this.set_s16(fuel_prop, blobCount - actual_input); //burn wood
	const string current_output = "current_quarry_output_" + this.getTeamNum();
	
	// reduce output if it's higher than minimal output
	if (getRules().hasScript("ResetQuarry.as"))
	{
		getRules().set_s32(current_output, Maths::Max(getRules().get_s32(current_output) - output_decrease, min_output));
	}
}

void updateWoodLayer(CSprite@ this)
{
	int wood = this.getBlob().get_s16(fuel_prop);
	CSpriteLayer@ layer = this.getSpriteLayer("wood");

	if (layer is null) return;

	if (wood < min_input)
	{
		layer.SetVisible(false);
	}
	else
	{
		layer.SetVisible(true);
		int frame = 5;
		if (wood > low_fuel) frame = 6;
		if (wood > mid_fuel) frame = 7;
		layer.SetFrameIndex(frame);
	}
}

void animateBelt(CBlob@ this, bool isActive)
{
	//safely fetch the animation to modify
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;
	CSpriteLayer@ belt = sprite.getSpriteLayer("belt");
	if (belt is null) return;
	Animation@ anim = belt.getAnimation("default");
	if (anim is null) return;

	//modify it based on activity
	if (isActive)
	{
		// slowly start animation
		if (anim.time == 0) anim.time = 6;
		if (anim.time > 3) anim.time--;
	}
	else
	{
		//(not tossing stone)
		if (anim.frame < 2 || anim.frame > 8)
		{
			// slowly stop animation
			if (anim.time == 6) anim.time = 0;
			if (anim.time > 0 && anim.time < 6) anim.time++;
		}
	}
}

void PickupOverlap(CBlob@ this)
{
	Vec2f tl, br;
	this.getShape().getBoundingRect(tl, br);
	CBlob@[] blobs;
	this.getMap().getBlobsInBox(tl, br, @blobs);
	for (uint i = 0; i < blobs.length; i++)
	{
		CBlob@ blob = blobs[i];
		if (blob is null)
		{
			continue;
		}

		if (!blob.isAttached() && blob.isOnGround() && blob.getName() == "mat_wood")
		{
			int quantity = blob.getQuantity();
			int ammountToStore = Maths::Min(max_fuel - this.get_s16(fuel_prop), quantity);
			if (ammountToStore > 0)
			{
				blob.server_SetQuantity(quantity - ammountToStore);
				this.set_s16(fuel_prop, this.get_s16(fuel_prop) + ammountToStore);
			}
		}
	}
}

bool canProduce(CBlob@ this)
{
	Vec2f tl, br;
	this.getShape().getBoundingRect(tl, br);
	tl.x += producer_check_offset;
	br.x -= producer_check_offset;
	CBlob@[] blobs;
	this.getMap().getBlobsInBox(tl, br, @blobs);
	u16 producers = 0;
	for (uint i = 0; i < blobs.length; i++)
	{
		CBlob@ blob = blobs[i];
		if (blob is null || blob is this)
		{
			continue;
		}

		// Waffle: Check if we can produce
		if (blob.hasTag("tree"))  // Trees are blocking
		{
			producers++;
		}
		else if (isLimitingSeed(blob))  // Seeds are only blocking if they can grow and dont already have too many seeds nearby
		{
			producers++;
			CBlob@[] nearby;
			getNearbyBlobs(getMap(), blob, nearby);
			u16 tree_count = 0;
			
			for (u16 i = 0; i < nearby.length(); i++)
			{
				if (nearby[i] !is null && nearby[i] !is blob && (nearby[i].hasTag("tree") || isLimitingSeed(nearby[i])))
				{
					tree_count++;
					if (tree_count >= 2)
					{
						producers--;
						break;
					}
				}
			}
			
		}
	}

	return producers >= 2;
}

