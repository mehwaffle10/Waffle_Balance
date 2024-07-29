
#include "BehaviorTree.as"
#include "BehaviorTreeCommon.as"
#include "CommonLeaves.as"

class LeftOfTarget : BehaviorTreeNode {
    u16 offset;

    LeftOfTarget(u16 _offset) {
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
    u16 offset;

    RightOfTarget(u16 _offset) {
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

class TargetIsName : BehaviorTreeNode {
    string name;

    TargetIsName(string _name) {
        name = _name;
    }

    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        return blackboard.target is null || blackboard.target.getName() != name ? BehaviorTreeStatus::failure : BehaviorTreeStatus::success;
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