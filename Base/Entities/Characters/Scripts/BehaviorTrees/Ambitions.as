
#include "BehaviorTree.as"
#include "BehaviorTreeCommon.as"
#include "Leaves.as"
#include "Conditions.as"

class JumpOrStare : Selector {
    JumpOrStare() {
        children.push_back(LookAtTarget());
        children.push_back(JumpInPlace());
    }

    f32 utility(CBlob@ this) {
        return 1.0f;
    }
}

class AttackTarget : Parallel {
    AttackTarget() {
        children.push_back(LookAtTarget());
        children.push_back(SlashTarget());
    }

    f32 utility(CBlob@ this) {
        return 1.0f;
    }
}

class SlashTarget : Selector {
    SlashTarget() {
        children.push_back(TryChargeSlash());
        children.push_back(TryReleaseSlash());
    }

    f32 utility(CBlob@ this) {
        return 1.0f;
    }
}

class TryChargeSlash : Sequence {
    TryChargeSlash() {
        children.push_back(Inverse(HasSlashCharged()));
        children.push_back(HoldLeftMouse());
    }

    f32 utility(CBlob@ this) {
        return 1.0f;
    }
}

class TryReleaseSlash : Sequence {
    TryReleaseSlash() {
        children.push_back(HasSlashCharged());
        children.push_back(ReleaseSlash());
    }

    f32 utility(CBlob@ this) {
        return 1.0f;
    }
}