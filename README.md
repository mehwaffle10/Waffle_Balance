# Waffle_Balance
A balance mod for King Arthur's Gold that attempts to make the game faster paced and more enjoyable and adds features/mechanics to less used items

DISCLAIMER: Developed without compatibility with other mods in mind, so there's a decent chance it will conflict with any mod that changes base game scripts. Partly due to how KAG mods things partly due to that I'm lazy and there's no way to fully disconnect things

# Changes

Eggs
- Hatch in 20 seconds instead of 50

Chickens
- Hover no longer decays
- Can have up to 4 simultaneous eggs instead of 2
- Can have up to 10 chickens in close proximity instead of 6

Food
- Team based: only players on the item's team can eat them
- Picking up a food will still change it to that player's team (can catch enemy food but leads to more medic plays)

Hearts
- (Not enabled by default, need to toggle "hearts ignore team" bool in CRules) Not team based (ignores change above)
- Dont despawn
- Not account age based

Boat Shop
- Doesn't cost gold, doesn't drop gold

Quarries
- Removed

Arrows
- Collide with enemy arrows
- Have 5x the amount of health (will last 5x longer when climbed on)

Mines
- Deploy after timer like they used to 
- Can still be picked up

Trampoline
- Increase bounce velocity from 10 to 12
- Bounce from all angles
- No longer "medium" weight (no slow down while carrying)

Warboats
- Can't be captured
- Doubled health from 45 to 90
- Doesn't break on land or if flipped
- Doesn't sink on low health

Longboats
- Doesn't break on land or if flipped (or if left alone???)
- Doesn't sink on low health

Mounted Bow
- Health increased from 2 to 20
- Can fire every 15 ticks instead of every 25 ticks (every .75 seconds instead of 1.25 seconds)

Boulders
- Team based collisions like TDM (allows friendly archers to shoot through them but not enemy)
- 30 stone instead of 35
- Can still convert to your team by picking them up

Fall Damage
- TDM fall damage (takes 1.3x longer falls)

Crates
- Won't break when exiting

Coins
- 2 coins for platforms and wood doors instead of 1
- 5 whenever hitting a vehicle instead of 5 * damage done
- 50 coins for breaking a vehicle instead of 20

Bombs
- (Not enabled by default, post thought it seems too strong with the door buffs) Do the same damage to tiles as bomb arrows
- Do full damage to stone structures instead of half (3 shot stone doors and tunnels, 2 shot storage)
- Do 2x damage to wood structures instead of 1.4x (1 shot wood doors, already 1 shot wood buildings)

Slash/Arrow/Jab
- Do full damage to wood structures instead of 1/8 heart for damage <= 1 heart and 1/4 * damage for damage > 1 heart
- Do the math:
	- wood shops have 4 health
	- storages have 10 health
	- tunnels have 16 health
	- wood doors have 7 health
	- platforms have 5 health

Digging
- Double damage for digging wood or stone (3 hits for wood block, 4 for stone block)

# TODO/Ideas for the future

Trampoline
- Can shield/grapple while holding
- Fix stun when hitting tramp (bigger hitbox so it collides sooner so you dont hit the ground)

Death Messages
- Add em

Tips
- Make em actually useful

Firearrows
- Make flares always occur

----- Potential Ideas -----

Trampoline
- Can't pick up enemy tramps + Arrows collide with tramps to deal damage rather than bouncing (cover while holding, but fragile, allows for archers to counter them)

Food
- Team based colors (for change above)

Arrows
- Slashable

Logs
- Enemy arrows collide in them (mobile cover)
- Break after a hit or two

Drills
- Nerf again prolly

Catapults
- Make aggressive driving more viable

Shield Bash
- Make stronger knock back

Stone Blocks/Doors
- Nerf to a point where maybe quarries can exist

Boulders
- Make launching off a trampoline activate rock and roll (if not just throwing them fast)
- Tick faster and hit more blocks in rock and roll
- Increase health (default is 6 hearts, or 3 against pickaxes)

Spam Decay
- Disable

Siege Blocks
- Armor Ideas
	- Inventory filled with wood
	- Specific Upgrade
	- Builder build wood on top
- Mounted Bow
- Driver Seat
- Wheels
- Door blocks
	- Doesn't collide with team

// TODO
- Fix sound sync
- Depth texture renders behind player
- Inventory icon for other blocks
*/
