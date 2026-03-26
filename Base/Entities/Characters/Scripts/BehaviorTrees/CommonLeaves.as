
#define SERVER_ONLY;

#include "BehaviorTree.as"
#include "BehaviorTreeDebugCommon.as"

class LookAtTarget : BehaviorTreeNode {
	LookAtTarget() {
		name = "LookAtTarget";
	}

    u8 execute(CBlob@ this, Blackboard@ blackboard, u16 depth) {
		PushDebugMessage(this, name, color, depth);
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
	LookLeft() {
		name = "LookLeft";
	}

    u8 execute(CBlob@ this, Blackboard@ blackboard, u16 depth) {
		PushDebugMessage(this, name, color, depth);
        this.setAimPos(this.getPosition() + Vec2f(-10, -4));
        return BehaviorTreeStatus::success;
    }
}

class LookRight : BehaviorTreeNode {
	LookRight() {
		name = "LookRight";
	}

    u8 execute(CBlob@ this, Blackboard@ blackboard, u16 depth) {
		PushDebugMessage(this, name, color, depth);
        this.setAimPos(this.getPosition() + Vec2f(10, -4));
        return BehaviorTreeStatus::success;
    }
}

class SetKeyPressed : BehaviorTreeNode {
    keys key;

    SetKeyPressed(keys _key)
    {
		name = "SetKeyPressed " + _key;
        key = _key;
    }

    u8 execute(CBlob@ this, Blackboard@ blackboard, u16 depth) {
		PushDebugMessage(this, name, color, depth);
        this.setKeyPressed(key, true);
        return BehaviorTreeStatus::success;
    }
}

class SetAttackTarget : BehaviorTreeNode {
	SetAttackTarget() {
		name = "SetAttackTarget";
	}

    u8 execute(CBlob@ this, Blackboard@ blackboard, u16 depth) {
		PushDebugMessage(this, name, color, depth);
        if (blackboard.target is null)
        {
            return BehaviorTreeStatus::failure;
        }

        @blackboard.attack_target = @blackboard.target;
        return BehaviorTreeStatus::success;
    }
}

class ClearAttackTarget : BehaviorTreeNode {
	ClearAttackTarget() {
		name = "ClearAttackTarget";
	}

    u8 execute(CBlob@ this, Blackboard@ blackboard, u16 depth) {
		PushDebugMessage(this, name, color, depth);
        @blackboard.attack_target = null;
        return BehaviorTreeStatus::success;
    }
}
