
#define SERVER_ONLY;

#include "Ambitions.as"
#include "BehaviorTree.as"

const string ROOT_PROP = "root node";

void onInit(CBlob@ this)
{
    BehaviorTreeNode@ root = AttackTarget();
    this.set(ROOT_PROP, @root);
}

void onTick(CBlob@ this)
{
    BehaviorTreeNode@ root;
    if (!this.get(ROOT_PROP, @root) || root is null)
    {
        return;
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
    root.execute(this);
}