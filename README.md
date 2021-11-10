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
- (Not enabled by default, need to toggle "hearts do not collide" bool in CRules) Not team based (ignores change above)
- Dont despawn
- Not account age based

Quarries
- Removed

Arrows
- Collide with enemy arrows
- Have 5x the amount of health (will last 5x longer when climbed on)

Fire Arrows
- Always flare even if not on flammable surface

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
- Cost 30 stone instead of 35 so you can use spawn mats to buy them
- Can still convert to your team by picking them up

Crates
- Won't break when exiting
- Cost 100 wood instead of 150 so you can use spawn mats to buy them

Sponges
- Cost 10 instead of 15 coins to punish players less financially (a lost inventory slot is already a lot)

Fall Damage
- TDM fall damage (takes 1.3x longer falls)

Map Ceiling
- Blobs no longer collide with the ceiling on non-cave maps (no blocks at the top of the map)
- Lightened the sky above the top of the map a bit to improve visibility

Coins
- 2 coins for platforms and wood doors instead of 1
- 5 whenever hitting a vehicle instead of 5 * damage done
- 50 coins for breaking a vehicle instead of 20

Bombs
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
