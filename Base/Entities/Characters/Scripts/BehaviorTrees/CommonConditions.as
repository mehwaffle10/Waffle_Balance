
#include "BehaviorTree.as"
#include "CommonLeaves.as"

class LeftOfTarget : BehaviorTreeNode {
    s16 offset;

    LeftOfTarget(s16 _offset) {
		name = "LeftOfTarget " + _offset;
        offset = _offset;
    }

    u8 execute(CBlob@ this, Blackboard@ blackboard, u16 depth) {
		PushDebugMessage(this, name, color, depth);
        if (blackboard.target is null)
        {
            return BehaviorTreeStatus::failure;
        }
        bool left_of_target = this.getPosition().x < blackboard.target.getPosition().x;
        if (offset > 0)
        {
            left_of_target = this.getPosition().x < blackboard.target.getPosition().x + offset * (left_of_target ? -1 : 1);
        }

        return left_of_target ? BehaviorTreeStatus::success : BehaviorTreeStatus::failure;
    }
}

class RightOfTarget : BehaviorTreeNode {
    s16 offset;

    RightOfTarget(s16 _offset) {
		name = "RightOfTarget " + _offset;
        offset = _offset;
    }

    u8 execute(CBlob@ this, Blackboard@ blackboard, u16 depth) {
		PushDebugMessage(this, name, color, depth);
        if (blackboard.target is null)
        {
            return BehaviorTreeStatus::failure;
        }
        bool right_of_target = this.getPosition().x > blackboard.target.getPosition().x;
        if (offset > 0)
        {
            right_of_target = this.getPosition().x > blackboard.target.getPosition().x + offset * (right_of_target ? 1 : -1);
        }

        return right_of_target ? BehaviorTreeStatus::success : BehaviorTreeStatus::failure;
    }
}

class BelowTarget : BehaviorTreeNode {
    s16 offset;

    BelowTarget(s16 _offset) {
		name = "BelowTarget " + _offset;
        offset = _offset;
    }

    u8 execute(CBlob@ this, Blackboard@ blackboard, u16 depth) {
		PushDebugMessage(this, name, color, depth);
        CBlob@ target = blackboard.attack_target is null ? @blackboard.target : @blackboard.attack_target;
        if (target is null)
        {
            return BehaviorTreeStatus::failure;
        }

        return this.getPosition().y > target.getPosition().y + offset ? BehaviorTreeStatus::success : BehaviorTreeStatus::failure;
    }
}

class HasAttackTarget : BehaviorTreeNode {
	HasAttackTarget() {
		name = "HasAttackTarget";
	}

    u8 execute(CBlob@ this, Blackboard@ blackboard, u16 depth) {
		PushDebugMessage(this, name, color, depth);
        return blackboard.attack_target is null ? BehaviorTreeStatus::failure : BehaviorTreeStatus::success;
    }
}

class isOnGround : BehaviorTreeNode {
	isOnGround() {
		name = "isOnGround";
	}

    u8 execute(CBlob@ this, Blackboard@ blackboard, u16 depth) {
		PushDebugMessage(this, name, color, depth);
        return this.isOnGround() ? BehaviorTreeStatus::success : BehaviorTreeStatus::failure;
    }
}
