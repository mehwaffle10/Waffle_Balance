# Waffle_Balance
A balance mod for King Arthur's Gold that attempts to make the game faster paced and more enjoyable and adds features/mechanics to less used items

DISCLAIMER: Developed without compatibility with other mods in mind, so there's a decent chance it will conflict with any mod that changes base game scripts. Partly due to how KAG mods things partly due to that I'm lazy and there's no way to fully disconnect things

# Changes

Eggs
- Hatch in 20 seconds instead of 50

Chickens
- Hover no longer decays
- Dies if player holding it takes damage from an enemy
- Max horizontal speed decreased with strong decay of speeds above threshold while in the air
- Can now be burned
- Can have up to 4 simultaneous eggs instead of 2
- Can have up to 10 chickens in close proximity instead of 6

Food
- Team based: only players on the item's team can eat them
- Picking up a food will still change it to that player's team (can catch enemy food but leads to more medic plays)

Hearts
- (Not enabled by default, need to toggle "hearts do not collide" bool in CRules) Not team based (ignores change above)
- Dont despawn
- Not account age based

Drills
- Dig pure dirt 3x slower and properly detected (30 ticks instead of 10)
- Digging pure dirt overheats the drill incredibly fast
	- Will overheat even in water
- Water slowdown is now double instead of a fixed rate
	- Digging pure dirt in water is excruciatingly slow (60 ticks)
	- Digging resources is slightly faster (16 tick delay instead of 20)

Arrows
- Collide with enemy arrows
- Have 5x the amount of health (will last 5x longer when climbed on)

Fire Arrows
- Always flare even if not on flammable surface
- Ignite instantly on contact
- Added animation and sound for instant feedback
- Collide with enemy trampolines
- Fire arrow flares don't do an extra half heart to things they ignite
	- Direct arrow hits still do full damage plus burn damage

Fire
- Can spread diagonally
- Can spread from non-player blobs

Buckets
- Can only splash once before needing a refill

Sponges
- Cost 10 instead of 15 coins to punish players less financially (a lost inventory slot is already a lot)

Mines
- Deploy after timer like they used to 
- Can still be picked up

Trampoline
- Increase bounce velocity from 10 to 11
- Bounce from all angles
- No longer "medium" weight (no slow down while carrying)
- Can use M1 and M2 while holding a trampoline
	- Archers: Shoot arrows and grapple. Arrows always collide with trampoline
	- Knights: Slash, jab, and shield as normal
	- Builders: Can only dig, since selecting a block makes you drop what you are holding
- Can bounce boulders into rock and roll mode if a player is holding the trampoline
- Now cost 100 wood and 80 coins so they can be bought with spawn mats but are less spammable
- Snap to angles
- Are now flammable
- No longer bounce enemy fire arrows

Warboats
- Can't be captured
- Doubled health from 45 to 90
- Doesn't break on land or if flipped
- Doesn't sink on low health

Longboats
- Doesn't break on land or if flipped (or if left alone???)
- Doesn't sink on low health
- Captured much quicker

Mounted Bow
- Health increased from 2 to 20
- Can fire every 15 ticks instead of every 25 ticks (every .75 seconds instead of 1.25 seconds)

Catapults
- Rocks ignore no build zones, allowing them to destroy backwall in the flag room and behind shops
- Captured much quicker
- Can no longer shoot through platforms

Ballista
- Bolts ignore no build zones, allowing them to destroy backwall in the flag room and behind shops
- Captured much quicker
- Can no longer shoot through platforms
- No longer function as spawn points

Boulders (Rock and roll mode is the block destroying mode like when launched from a catapult)
- Team based collisions like TDM (allows friendly archers to shoot through them but not enemy)
- Cost 30 stone instead of 35 so you can use spawn mats to buy them
- Can still convert to your team by picking them up
- Ignore no build zones when in rock and roll mode, allowing them to destroy backwall in the flag room and behind shops
- Can be bounced off a trampoline to activate rock and roll mode
- Tick faster in rock and roll mode (damage happens faster so it will blow holes in walls rather than phase through and break blocks intermittently)
- Can break static blobs (doors, platforms, etc) in rock and roll mode

Crates
- Won't break when exiting
- Heavily reduced air friction
- Cost 100 wood instead of 150 so you can use spawn mats to buy them

Explosives
- Ignore no build zones, allowing them to destroy backwall in the flag room and behind shops
- Changed the threshold for a strong launch from 30% to 50% of the blast radius to make bomb jumps easier especially on laggy servers, damage remains the same

Bombs
- Do full damage to stone structures instead of half (3 shot stone doors and tunnels, 2 shot storage)
- Do 2x damage to wood structures instead of 1.4x (1 shot wood doors, already 1 shot wood buildings)

Wood Structure Damage
- Arrows do full damage to wood structures instead of 1/8 heart for damage <= 1 heart and 1/4 * damage for damage > 1 heart
- Swords do half damage to wood structures instead of 1/8 heart for damage <= 1 heart and 1/4 * damage for damage > 1 heart
- Do the math:
	- wood shops have 4 health
	- storages have 10 health
	- tunnels have 16 health
	- wood doors have 7 health
	- platforms have 5 health

Builder
- Increased swing speed on man-made structures
- Decreased swing speed on dirt

Knight and Builder
- Double damage for digging wood or stone (3 hits for wood block, 4 for stone block)

Fall Damage
- TDM fall damage (takes 1.3x longer falls)

Flag Room
- Increased size from 3x5 to 5x6

Map Ceiling
- Blobs no longer collide with the ceiling on non-cave maps (no blocks at the top of the map)
- Lightened the sky above the top of the map a bit to improve visibility
- Maps tend to have significantly shorter sky boxes

Build Phase
- Can build extremely fast during build phase
