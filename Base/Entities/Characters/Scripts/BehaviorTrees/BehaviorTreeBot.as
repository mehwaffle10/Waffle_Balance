
#define SERVER_ONLY;

#include "KnightAmbitions.as"
#include "BehaviorTree.as"

// #include "KnightCommon.as";

const string ROOT_PROP = "root node";
const string BLACKBOARD_PROP = "blackboard";

void onInit(CBlob@ this)
{
    BehaviorTreeNode@ root = AttackTarget(16);
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

    CPlayer@ player = getPlayerByUsername('mehwaffle10');
    if (player !is null)
    {
        @blackboard.target = @player.getBlob();
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