
#define SERVER_ONLY;

#include "BehaviorTree.as"
#include "BehaviorTreeCommon.as"

class LookAtTarget : BehaviorTreeNode {
    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        if (blackboard.target is null)
        {
            return BehaviorTreeStatus::failure;
        }

        this.setAimPos(blackboard.target.getPosition());
        return BehaviorTreeStatus::success;
    }
}

class LookLeft : BehaviorTreeNode {
    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        this.setAimPos(this.getPosition() + Vec2f(-10, -4));
        return BehaviorTreeStatus::success;
    }
}

class LookRight : BehaviorTreeNode {
    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        this.setAimPos(this.getPosition() + Vec2f(10, -4));
        return BehaviorTreeStatus::success;
    }
}

class HoldLeftMouse : BehaviorTreeNode {
    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        this.setKeyPressed(key_action1, true);
        return BehaviorTreeStatus::success;
    }
}

class MoveLeft : BehaviorTreeNode {
    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        this.setKeyPressed(key_left, true);
        return BehaviorTreeStatus::success;
    }
}

class MoveRight : BehaviorTreeNode {
    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        this.setKeyPressed(key_right, true);
        return BehaviorTreeStatus::success;
    }
}