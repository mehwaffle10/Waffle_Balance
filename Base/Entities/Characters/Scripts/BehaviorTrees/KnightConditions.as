
#include "BehaviorTree.as"
#include "BehaviorTreeCommon.as"
#include "CommonConditions.as"
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

class KnightHasAdvantageOnTarget : Parallel {
    KnightHasAdvantageOnTarget() {
        children.push_back(KnightHasAdvantageOnKnight());
    }
}

class KnightHasAdvantageOnKnight : Sequence {
    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        KnightInfo@ knight, enemy;
        if (!this.get("knightInfo", @knight) || blackboard.target is null || !blackboard.target.get("knightInfo", @enemy))
        {
            return BehaviorTreeStatus::failure;
        }

        // Do I have a slash available
        if (knight.swordTimer >= KnightVars::slash_charge)
        {
            return BehaviorTreeStatus::success;
        }

        return BehaviorTreeStatus::failure;
    }
}
