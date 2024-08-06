
#define SERVER_ONLY;

#include "KnightAmbitions.as"
#include "BehaviorTree.as"

// #include "KnightCommon.as";

const string ROOT_PROP = "root node";
const string BLACKBOARD_PROP = "blackboard";

void onInit(CBlob@ this)
{
    BehaviorTreeNode@ root = AttackTarget(64);
    this.set(ROOT_PROP, @root);

    Blackboard@ blackboard = Blackboard();
    this.set(BLACKBOARD_PROP, @blackboard);
}

void onTick(CBlob@ this)
{
    // KnightInfo@ knight;
    // if (!this.get("knightInfo", @knight)) {
    //     return;
    // }
    // print("isSwordState(knight.state): " + isSwordState(knight.state) + " inMiddleOfAttack(knight.state): " + inMiddleOfAttack(knight.state) + " knight.swordTimer: " + knight.swordTimer);

    BehaviorTreeNode@ root;
    if (!this.get(ROOT_PROP, @root) || root is null)
    {
        return;
    }

    Blackboard@ blackboard;
    if (!this.get(BLACKBOARD_PROP, @blackboard) || blackboard is null)
    {
        return;
    }
    blackboard.nearby_enemies.clear();
    blackboard.nearby_allies.clear();
    // blackboard.nearby_threats.clear();

    CMap@ map = getMap();
    if (map is null)
    {
        return;
    }
    CBlob@[] nearby_blobs;
    f32 target_distance = -1.0f;
    map.getBlobsInRadius(this.getPosition(), 15 * map.tilesize, nearby_blobs);
    for (u16 i = 0; i < nearby_blobs.length; i++)
    {
        CBlob@ blob = nearby_blobs[i];
        if (blob is null)
        {
            continue;
        }

        f32 distance = this.getDistanceTo(blob);
        if (blob !is this && blob.hasTag("player"))
        {
            if (blob.getTeamNum() != this.getTeamNum())
            {
                blackboard.nearby_enemies.push_back(blob);
                if (distance < target_distance || target_distance < 0.0f)
                {
                    @blackboard.target = @blob;
                    target_distance = distance;
                }
            }
            else
            {
                blackboard.nearby_allies.push_back(blob);
            }
        }
    }

    this.setKeyPressed(key_up,      false);
    this.setKeyPressed(key_down,    false);
    this.setKeyPressed(key_left,    false);
    this.setKeyPressed(key_right,   false);
    this.setKeyPressed(key_action1, false);
    this.setKeyPressed(key_action2, false);
    this.setKeyPressed(key_action3, false);
    this.setKeyPressed(key_use,     false);
    this.setKeyPressed(key_pickup,  false);
    this.setKeyPressed(key_eat,     false);
    root.execute(this, blackboard);
}