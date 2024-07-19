
#include "BehaviorTree.as"
#include "BehaviorTreeCommon.as"
#include "Leaves.as"

shared class JumpOrStare : Selector {
    JumpOrStare() {
        children.push_back(LookAtPlayer());
        children.push_back(JumpInPlace());
    }

    f32 utility(CBlob@ this) {
        return 1.0f;
    }
}