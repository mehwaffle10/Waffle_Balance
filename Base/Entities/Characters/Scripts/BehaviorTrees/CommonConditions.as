
#include "BehaviorTree.as"
#include "BehaviorTreeCommon.as"
#include "CommonLeaves.as"

class LeftOfTarget : BehaviorTreeNode {
    u16 offset;

    LeftOfTarget(u16 _offset) {
        offset = _offset;
    }

    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        if (blackboard.target is null || this.getPosition().x > blackboard.target.getPosition().x - offset)
        {
            return BehaviorTreeStatus::failure;
        }

        return BehaviorTreeStatus::success;
    }
}

class RightOfTarget : BehaviorTreeNode {
    u16 offset;

    RightOfTarget(u16 _offset) {
        offset = _offset;
    }

    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        if (blackboard.target is null || this.getPosition().x < blackboard.target.getPosition().x + offset)
        {
            return BehaviorTreeStatus::failure;
        }

        return BehaviorTreeStatus::success;
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