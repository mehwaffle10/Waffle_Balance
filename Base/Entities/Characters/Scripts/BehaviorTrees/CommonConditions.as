
#include "BehaviorTree.as"
#include "CommonLeaves.as"

class LeftOfTarget : BehaviorTreeNode {
    s16 offset;

    LeftOfTarget(s16 _offset) {
        offset = _offset;
    }

    u8 execute(CBlob@ this, Blackboard@ blackboard) {
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
        offset = _offset;
    }

    u8 execute(CBlob@ this, Blackboard@ blackboard) {
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
        offset = _offset;
    }

    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        CBlob@ target = blackboard.attack_target is null ? @blackboard.target : @blackboard.attack_target;
        if (target is null)
        {
            return BehaviorTreeStatus::failure;
        }

        return this.getPosition().y > target.getPosition().y + offset ? BehaviorTreeStatus::success : BehaviorTreeStatus::failure;
    }
}

class HasAttackTarget : BehaviorTreeNode {
    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        return blackboard.attack_target is null ? BehaviorTreeStatus::failure : BehaviorTreeStatus::success;
    }
}

class IsJump : BehaviorTreeNode {
    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        return blackboard.jump ? BehaviorTreeStatus::success : BehaviorTreeStatus::failure;
    }
}

class isOnGround : BehaviorTreeNode {
    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        return this.isOnGround() ? BehaviorTreeStatus::success : BehaviorTreeStatus::failure;
    }
}

// class TooClose : BehaviorTreeNode {
//     u8 execute(CBlob@ this, Blackboard@ blackboard) {
//         if (blackboard.target is null || Maths::Abs(this.getPosition().x - blackboard.target.getPosition().x) < DEFAULT_ATTACK_DISTANCE)
//         {
//             return BehaviorTreeStatus::failure;
//         }

//         return BehaviorTreeStatus::success;
//     }
// }

// class TooFar : BehaviorTreeNode {
//     u8 execute(CBlob@ this, Blackboard@ blackboard) {
//         if (blackboard.target is null || Maths::Abs(this.getPosition().x - blackboard.target.getPosition().x) > MAX_ATTACK_DISTANCE)
//         {
//             return BehaviorTreeStatus::failure;
//         }

//         return BehaviorTreeStatus::success;
//     }
// }