
#include "BehaviorTree.as"
#include "BehaviorTreeCommon.as"
#include "CommonLeaves.as"
#include "CommonAmbitions.as"
#include "KnightConditions.as"
#include "KnightLeaves.as"

class AttackKnight : Sequence {
    AttackKnight() {
        children.push_back(AttackTarget(16));
    }
}

class AttackArcher : Sequence {
    AttackArcher() {
        children.push_back(AttackTarget(0));
    }
}

class AttackBuilder : Sequence {
    AttackBuilder() {
        children.push_back(AttackTarget(0));
    }
}

class AttackTarget : Parallel {
    AttackTarget(u16 distance) {
        children.push_back(LookAtTarget());
        children.push_back(SlashTarget());
        children.push_back(MoveToTarget(distance));
    }
}

class SlashTarget : Parallel {
    SlashTarget() {
        children.push_back(TryChargeSlash());
        children.push_back(TryReleaseSlash());
    }
}

class TryChargeSlash : Sequence {
    TryChargeSlash() {
        children.push_back(Inverse(HasSlashCharged()));
        children.push_back(Inverse(IsSlashing()));
        children.push_back(HoldLeftMouse());
    }
}

class TryReleaseSlash : Sequence {
    TryReleaseSlash() {
        children.push_back(IsSlashing());
        children.push_back(ReleaseSlash());
    }
}