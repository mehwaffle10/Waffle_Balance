
#include "BehaviorTree.as"
#include "KnightCommon.as";

class ReleaseSlash : BehaviorTreeNode {
	ReleaseSlash() {
		name = "ReleaseSlash";
	}

    u8 execute(CBlob@ this, Blackboard@ blackboard, u16 depth) {
		PushDebugMessage(this, name, color, depth);
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