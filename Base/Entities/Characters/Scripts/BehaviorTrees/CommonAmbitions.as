
#include "BehaviorTree.as"
#include "BehaviorTreeCommon.as"
#include "CommonLeaves.as"
#include "CommonConditions.as"

class MoveToTarget : Parallel {
    MoveToTarget(u16 offset) {
        children.push_back(TryMoveLeft(offset));
        children.push_back(TryMoveRight(offset));
    }
}

class TryMoveLeft : Sequence {
    TryMoveLeft(u16 offset) {
        children.push_back(RightOfTarget(offset));
        children.push_back(MoveLeft());
    }
}

class TryMoveRight : Sequence {
    TryMoveRight(u16 offset) {
        children.push_back(LeftOfTarget(offset));
        children.push_back(MoveRight());
    }
}

/*
To add:
- Collect items
- Heal
- Heal ally
- Give ally item
*/