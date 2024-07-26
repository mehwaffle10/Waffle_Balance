
#include "BehaviorTree.as"
#include "BehaviorTreeCommon.as"
#include "KnightCommon.as";

class ReleaseSlash : BehaviorTreeNode {
    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        KnightInfo@ knight;
        if (!this.get("knightInfo", @knight))
        {
            return BehaviorTreeStatus::failure;
        }
        
        this.setKeyPressed(key_up, true);
        if (isSwordState(knight.state))
        {
            return BehaviorTreeStatus::running;
        }

        return BehaviorTreeStatus::success;
    }
}