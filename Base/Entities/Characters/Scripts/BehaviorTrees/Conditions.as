
#include "BehaviorTree.as"
#include "BehaviorTreeCommon.as"
#include "Leaves.as"

class HasSlashCharged : BehaviorTreeNode {
    f32 utility(CBlob@ this) {
        return 1.0f;
    }
    
    u8 execute(CBlob@ this) {
        KnightInfo@ knight;
        if (!this.get("knightInfo", @knight) || knight.swordTimer < KnightVars::slash_charge)
        {
            return BehaviorTreeStatus::failure;
        }
        return BehaviorTreeStatus::success;
    }
}

class IsSlashing : BehaviorTreeNode {
    f32 utility(CBlob@ this) {
        return 1.0f;
    }
    
    u8 execute(CBlob@ this) {
        KnightInfo@ knight;
        if (!this.get("knightInfo", @knight) || !inMiddleOfAttack(knight.state))
        {
            return BehaviorTreeStatus::failure;
        }
        return BehaviorTreeStatus::success;
    }
}

class LeftOfTarget : BehaviorTreeNode {
    f32 utility(CBlob@ this) {
        return 0.5f;
    }

    u8 execute(CBlob@ this) {
        CPlayer@ player = getPlayerByUsername("mehwaffle10");
        if (player is null)
        {
            return BehaviorTreeStatus::failure;
        }

        CBlob@ target = player.getBlob();
        if (target is null || this.getPosition().x > target.getPosition().x)
        {
            return BehaviorTreeStatus::failure;
        }

        return BehaviorTreeStatus::success;
    }
}

class RightOfTarget : BehaviorTreeNode {
    f32 utility(CBlob@ this) {
        return 0.5f;
    }

    u8 execute(CBlob@ this) {
        CPlayer@ player = getPlayerByUsername("mehwaffle10");
        if (player is null)
        {
            return BehaviorTreeStatus::failure;
        }

        CBlob@ target = player.getBlob();
        if (target is null || this.getPosition().x < target.getPosition().x)
        {
            return BehaviorTreeStatus::failure;
        }

        return BehaviorTreeStatus::success;
    }
}