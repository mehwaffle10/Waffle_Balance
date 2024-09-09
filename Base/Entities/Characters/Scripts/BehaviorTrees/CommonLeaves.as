
#define SERVER_ONLY;

#include "BehaviorTree.as"

class LookAtTarget : BehaviorTreeNode {
    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        CBlob@ target = blackboard.attack_target is null ? @blackboard.target : @blackboard.attack_target;
        if (target is null)
        {
            return BehaviorTreeStatus::failure;
        }

        this.setAimPos(target.getPosition());
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

class SetKeyPressed : BehaviorTreeNode {
    keys key;

    SetKeyPressed(keys _key)
    {
        key = _key;
    }

    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        this.setKeyPressed(key, true);
        return BehaviorTreeStatus::success;
    }
}

class SetAttackTarget : BehaviorTreeNode {
    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        if (blackboard.target is null)
        {
            return BehaviorTreeStatus::failure;
        }

        @blackboard.attack_target = @blackboard.target;
        return BehaviorTreeStatus::success;
    }
}

class ClearAttackTarget : BehaviorTreeNode {
    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        @blackboard.attack_target = null;
        return BehaviorTreeStatus::success;
    }
}
