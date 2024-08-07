
#include "BehaviorTree.as"
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

        // Do I have a timing advantage
        if (knight.swordTimer > enemy.swordTimer + 2) {
            return BehaviorTreeStatus::success;
        }

        return BehaviorTreeStatus::failure;
    }
}

class IsAttackFinished : BehaviorTreeNode {
    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        if (blackboard.attack_target is null)
        {
            return BehaviorTreeStatus::success;
        }
        
        KnightInfo@ knight;
        if (this.get("knightInfo", @knight))
        {
            if (knight.state >= KnightStates::sword_drawn && knight.state <= KnightStates::sword_power_super)
            {
                return BehaviorTreeStatus::failure;
            }
        }
        
        return BehaviorTreeStatus::success;
    }
}