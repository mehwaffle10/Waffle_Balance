
#include "BehaviorTree.as"
#include "BehaviorTreeCommon.as"
#include "Leaves.as"
#include "Conditions.as"

class AttackTarget : Parallel {
    AttackTarget() {
        children.push_back(LookAtTarget());
        children.push_back(SlashTarget());
        children.push_back(MoveToTarget());
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

class MoveToTarget : Parallel {
    MoveToTarget() {
        children.push_back(TryMoveLeft());
        children.push_back(TryMoveRight());
    }
}

class TryMoveLeft : Sequence {
    TryMoveLeft() {
        children.push_back(RightOfTarget());
        children.push_back(MoveLeft());
    }
}

class TryMoveRight : Sequence {
    TryMoveRight() {
        children.push_back(LeftOfTarget());
        children.push_back(MoveRight());
    }
}