
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