
#include "BehaviorTree.as"
#include "BehaviorTreeCommon.as"
#include "KnightCommon.as"

class HasSlashCharged : BehaviorTreeNode {
    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        KnightInfo@ knight;
        if (!this.get("knightInfo", @knight) || knight.swordTimer < KnightVars::slash_charge)
        {
            return BehaviorTreeStatus::failure;
        }
        return BehaviorTreeStatus::success;
    }
}

class IsSlashing : BehaviorTreeNode {
    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        KnightInfo@ knight;
        if (!this.get("knightInfo", @knight) || !inMiddleOfAttack(knight.state))
        {
            return BehaviorTreeStatus::failure;
        }
        return BehaviorTreeStatus::success;
    }
}