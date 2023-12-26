-# Waffle_Balance
A balance mod for King Arthur's Gold that attempts to make the game faster paced and more enjoyable and adds features/mechanics to less used items

DISCLAIMER: Developed without compatibility with other mods in mind, so there's a decent chance it will conflict with any mod that changes base game scripts. Partly due to how KAG mods things partly due to that I'm lazy and there's no way to fully disconnect things

# Changes

## GENERAL

### Respawn
- Reduced from 10 to 5 seconds

### Resupplies
- Removed for builders
- Crates with 500 wood and 150 stone air drop every 10 minutes above team tents
- All classes can see time until next resupply air drop where builder resupply info would be

### Materials
- No longer decay

### Build Phase
- 150 seconds
- Can build extremely fast during build phase
- Single crate at the start of build phase per team with 4000 wood and 2000 stone

### Fall Damage
- TDM fall damage (takes 1.3x longer falls)

### Flag Room
- Increased size from 3x5 to 5x6

### Flag
- Can no longer go through tunnels
- Returns in 10 seconds
- Can not speed up return by standing on it

### Tent
- Fixed sprite not being centered

### Map Ceiling
- Blobs no longer collide with the ceiling on non-cave maps (no blocks at the top of the map)
- Lightened the sky above the top of the map a bit to improve visibility
- Maps tend to have significantly shorter sky boxes

### Builder
- Increased swing speed on man-made structures and wood
- Decreased swing speed on dirt and gold
- Increased backwall building speed
- Moss backwall is now treated like stone backwall
- Repairing blobs will no longer replace healthy stone backwall behind

### Knight and Builder
- Double damage for digging wood or stone (3 hits for wood block, 4 for stone block)

### Archer
- Grapple is no longer cancelled when pressing use key

### Wood Structure Damage
- Arrows do full damage to wood structures instead of 1/8 heart for damage <= 1 heart and 1/4 * damage for damage > 1 heart
	- wood doors = 7 hearts
	- platforms  = 5 hearts
- Swords do 43.75% damage to wood structures instead of 1/8 heart for damage <= 1 heart and 1/4 * damage for damage > 1 heart
    - wood doors = 11 jabs
    - platforms  = 12 jabs
    - ladders    = 5  jabs
	- wood shops = 10 jabs
    - quarry     = 19 jabs
	- tunnels    = 37 jabs


### Explosives
- Ignore no build zones, allowing them to destroy backwall in the flag room and behind shops
- Changed the threshold for a strong launch from 30% to 50% of the blast radius to make bomb jumps easier especially on laggy servers, damage remains the same
- Do full damage to stone structures instead of half (3 shot stone doors and tunnels, 2 shot storage)
- Do 2x damage to wood structures instead of 1.4x (1 shot wood doors, already 1 shot wood buildings)
- No longer damage gold

### Fire
- Can spread diagonally
- Can spread from non-player and non-vehicle blobs

### Gold
- Gives 10 coins per hit instead of gold
- Gold is only present in middle of map
- No longer damaged by explosives
- Can no longer be drilled
- Builders dig gold at the speed that they dig dirt

### Trees
- Can only grow if there is no more than 1 other tree within 16 blocks
	- Added visible bounding box around saplings and trees when holding a sapling
- Purchaseable at the quarters for 100 coins
- Saplings can no longer be placed on each other
- Can build buildings behind trees
- Can be placed on non-static blobs
- Can no longer grow inside of static blobs

### Holidays
- Force default texture pack

### Nature Spawning
- Fish, grain, flowers, and chickens no longer spawn randomly

### Z Indices
- Adjusted Z index for the following items. A higher Z will render in front. Most things including players are at 0.
- bucket              - 1
- keg                 - 15
- bomb bolts          - 18
- water arrows        - 19
- fire arrows         - 20
- bomb arrows         - 21
- mine                - 25
- log                 - 30
- crate               - 35
- bush, grain, flower - 40

### Bison
- Hit vehicles instead of their drivers

# ITEMS

## BUILDINGS

### Buildings
- Can no longer be built on top of crates or boats
- Shops close and can not be opened when stunned

### Siege Shop
- Costs 400 wood total

### Tunnel
- Costs 500 wood total and 250 stone
- Can no longer travel with flags

### Storage
- Removed (Makes room for quarry and redundant with crates)

### Quarry
- Costs 250 wood total and 50 stone
- Produces 50 stone for 150 wood every 45 seconds
- Can only produce with two trees or saplings that can grow overlapping
- Added sounds, button hints, and description for feedback

### Ladders
- Increased health from 1.5 to 2.5

## VEHICLES

### Vehicles
- Drivers are protected from damage besides drowning
- Drivers take burn damage if their vehicle is on fire
- Take full damage from arrows
- Take 1.5x damage from swords
- Can collide when attached (can be shot)
- Take 3x damage from builders instead of 2x
- Take 5x damage from bomb arrows instead of 8x
- Take 4.5x damage from kegs
- Take .25x damage from catapult rocks
- Deploy instantly
- Can't be captured
- Don't break while flipped
- No spawn points
- Can deploy at the top of the map
- Can not deploy on enemy players
- All seats render floating arrows that no longer flicker
- Removed priority for seats for vehicles that are attached to other vehicles
- Only attach to other vehicles on collision

### Boats
- Don't break on land (or if left alone???)
- Doesn't sink on low health
- No longer have wood cost
- No longer have an inventory
- No longer can detach attached siege weapons
- Automatically deploy when packed crates are in water
- Can not deploy on top of other boats
- Always deploy facing right if blue and left if red to avoid a bug with CShape
- Collide with friendly boats
- Removed FakeBoatCollision.as, fixes issues with boats warping and makes boat collisions better
- Removed RunOverPeople.as, Nerfs crushing people and other boats, makes boat collisions better

### Dinghies
- Cost 40 coins
- Damage taken is consistent with other vehicles
- Spawn in crates like other vehicles
- Need a 6 x 3 area to deploy
- No longer can be picked up

### Longboats
- Cost 100 coins
- Need a 10 x 4 area to deploy
- Removed front 3 seats, adjusted back 3 seats
- Fixed bug where sail seat could drive on land
- All rower seats also activate the sail
- Slightly moved vehicle attachment point forward

### Warboats
- Cost 200 coins
- Need a 12 x 6 area to deploy
- Health decreased from 45 to 30
- Removed front 3 seats
- Moved vehicle attachment point to front

### Siege Weapons
- Don't break in water
- Can no longer shoot through platforms
- Can no longer crush players
- No longer drop ammo on death
- Projectiles ignore no build zones, allowing them to destroy backwall in the flag room and behind shops
- 50% Faster and can turn around easier
- No longer turn around while firing or on cooldown
- Can readd wheels after immobilizing
- Driver is also gunner, gunner seat is removed
- Drivers render in front of arms but behind front layers
- Vehicle driving changes to be able to drive over terrain better
    - Lowered center of mass
    - Removed shape elasticity
    - Adjusted shape to ramp over blocks better
    - Clamped max rotation to 45 degrees
    - Removed terrain damage to allow for better bridging

### Catapults
- Rocks reworked
	- Deal half a heart of damage to players
	- Deal 2 hearts to all other blocks
	- Hit backwall 3 times
	- Hit blocks 2 times
	- Break instantly when hitting something
		- No piercing
		- No ricochets
		- Makes for more consistency in gameplay and visuals
- Now shoots 25 rocks instead of 7
- Each rock costs 2 stone instead of 3 (max of 50 stone per shot)
- Doubled the amount of vertical spread on catapult shots
- Can hold 200 stone in reserve
- Cost 180 coins
- Fixed arm angle not being correct when deployed from a crate

### Ballistas
- Can aim up to 60° lower
- Bomb bolt linear explosion damaged increase
	- width from 1 to 2 blocks
	- max depth from 2 to 4 blocks
	- explosion damage (vs blobs) limited from 8 to 4 blocks
- Cost 200 coins instead of 150
- Bomb bolts cost 150 coins instead of 100
- Need a 5 x 5 area to deploy

### Mounted Bow
- Health increased from 2 to 10
- Can fire every 15 ticks instead of every 25 ticks (every .75 seconds instead of 1.25 seconds)
- Arrows no longer decay
- Arrows no longer have random inaccuracy
- Arrows no longer have 2x drag
- Launch speed reduced from 25 to 21
- Can be hit by enemy projectiles

## BUILDER SHOP

### Saws
- Automatically cut fully grown trees down that are behind them
- Are now flammable
- Take increased damage in alignment with `Wood Structure Damage` section above
- Can destroy enemy mines from all sides instead of just the top

### Trampoline
- Increase bounce velocity from 10 to 11
- Bounce from all angles
- No longer "medium" weight (no slow down while carrying)
- Can use M1 and M2 while holding a trampoline
	- Archers: Shoot arrows and grapple. Arrows always collide with trampoline
	- Knights: Slash, jab, and shield as normal
	- Builders: Can only dig, since selecting a block makes you drop what you are holding
- Can bounce boulders into rock and roll mode if a player is holding the trampoline
- Cost 120 coins so they can be bought with by all classes but are less spammable
- Snap to angles by default
	- Can hold down to get exact angles
- Are now flammable
	- Burn until destroyed
	- Take 2x fire damage
	- Takes 1 heart of damage immediately from fire arrow
	- Ignite things that they bounce while on fire
		- Ignite any held objects as well
- No longer bounce enemy fire arrows
- Can use action3 key (default space) to lock the angle the trampoline is facing
	- Has small sound to indicate when the trampoline is locked
- Can be folded using interact (e by default)

### Boulders (Rock and roll mode is the block destroying mode like when launched from a catapult)
- Team based collisions
    - added team colors to sprite
    - does not collide with allied players
    - allows friendly archers to shoot through them but not enemy
- Cost 40 coins so they can be bought by all classes but are less spammable
- Can still convert to your team by picking them up
- Ignore no build zones when in rock and roll mode, allowing them to destroy backwall in the flag room and behind shops
- Can be bounced off a trampoline to activate rock and roll mode
- Tick faster in rock and roll mode (damage happens faster so it will blow holes in walls rather than phase through and break blocks intermittently)
- Can break static blobs (doors, platforms, etc) in rock and roll mode
- Breaks up to 16 blocks in rock and roll mode
- No longer slowed down when breaking blocks in rock and roll mode
- Improved rock and roll tile damage code
	- Fixed radius and full 360 degree arc for block and blob detection
	- Breaks backwall underneath in a plus constantly
	- Leads to much more consistency and wider holes

### Crates
- Won't break when exiting
- Exiting a crate no longer gives the player a jump
- Fixed players getting in crates while not holding them
- Opening a crate with an enemy player only stun for half a second instead of a full second
- Inventory increased from 3x3 to 4x3
- Displays label if anything is in inventory
- Heavily reduced air friction
- Cost 100 wood instead of 150
- Take 50% more damage from builders (takes 6 hits to break instead of 8)
- No longer decay in water
- No longer decay if spammed
- Can be picked up by enemy players without having to overlap the crate
- Changes team when picked up
- Can automatically pick up materials again
	- No longer automatically picks up normal arrows
    - Automatically pickup ballista bolts and bomb bolts
- Fixed vehicle deployments
	- Appropriately sized area checks for each vehicle
	- Fixed map alignment for area check
	- Can not deploy on enemy players
	- Area check is now checked from crate upwards instead of centered on the crate

### Drills
- Can no longer dig gold
- Deals half a heart base damage instead of a full heart
- No longer deals overheat damage
- Blocked completely by shield
- Give 100% of tile resources dug
- Only hits dirt and stone/thickstone once per hit instead of twice
- Digging stone heats up the drill at the same rate as constructed block
- Dig pure dirt 3x slower and properly detected (30 ticks instead of 10)
- Digging pure dirt overheats the drill incredibly fast
	- Will overheat even in water
- Water slowdown is now double instead of a fixed rate
	- Digging pure dirt in water is excruciatingly slow (60 ticks)
	- Digging resources is slightly faster (16 tick delay instead of 20)

### Buckets
- Can only splash once before needing a refill
- Slightly bigger splash area
- Cost 15 coins

### Sponges
- Cost 10 instead of 15 coins to punish players less financially (a lost inventory slot is already a lot)

## ARCHER SHOP

### Arrows
- Collide with enemy arrows
- Have 5x the amount of health (will last 5x longer when climbed on)

### Water Arrows
- Cost 25 coins for 1 instead of 15

### Fire Arrows
- Cost 50 coins for 2 instead of 30
- Always flare even if not on flammable surface
- Ignite instantly on contact
- Added animation and sound for instant feedback
- Collide with enemy trampolines
	- Does an immediate heart of damage to the trampoline
- Fire arrow flares don't do an extra half heart to things they ignite
	- Direct arrow hits still do full damage plus burn damage

### Bomb Arrows
- Cost 75 coins for 1 instead of 50

## KNIGHT SHOP

### Keg
- Explode in a circular 6 block radius instead of doing bomberman plus shape
- Deal double damage to structures
- Deal full damage in the inner 80% of their explosion instead of 70%
    - Can 1-shot a tunnel from a 1-wide wall on the side or 2-tall wall vertically
- Improved explosion visuals
- Ignite from any fire damage
- Fixed fuse sound not resetting when extinguished
- Fixed screen shake happening when the keg wasn't exploding
- Cost 160 coins

### Mines
- Deploy after timer like they used to 
- Can still be picked up

## QUARTERS

### Food
- Team based: only players on the item's team can eat them
- Added team colors to all food sprites
- Picking up a food will still change it to that player's team (can catch enemy food but leads to more medic plays)

### Hearts
- Not team based (ignores change above)
- Dont despawn
- Not account age based

### Eggs
- Are no longer buyable from the quarters
- Hatch in 20 seconds instead of 50
- Spawn chickens on the same team as the chicken that laid them

### Chickens
- Are bought directly from the quarters for 50 coins
- Hover no longer decays
- Dies if player holding it takes damage from an enemy
- Max horizontal speed decreased with strong decay of speeds above threshold while in the air
- Can now be burned
- Can have up to 4 simultaneous eggs instead of 2
- Can have up to 10 chickens in close proximity instead of 6
- Only have 0.1 health
- Converted to your team when picked up (no friendly fire)
- Added team colors to sprite
- Spawn on your team during build phase

### Saplings
- Can now be bought for 100 coins
- Can no longer be placed on top of each other
- Now show tree limit around existing trees and saplings while held
