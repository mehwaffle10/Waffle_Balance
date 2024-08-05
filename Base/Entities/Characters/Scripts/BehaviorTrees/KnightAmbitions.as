
#include "BehaviorTree.as"
#include "BehaviorTreeCommon.as"
#include "CommonLeaves.as"
#include "CommonAmbitions.as"
#include "KnightConditions.as"
#include "KnightLeaves.as"

class AttackKnight : Sequence
{
    AttackKnight()
    {
        children.push_back(AttackTarget(16));
    }
}

class AttackArcher : Sequence
{
    AttackArcher()
    {
        children.push_back(AttackTarget(0));
    }
}

class AttackBuilder : Sequence
{
    AttackBuilder()
    {
        children.push_back(AttackTarget(0));
    }
}

class AttackTarget : Parallel
{
    AttackTarget(u16 distance)
    {
        // children.push_back(LookAtTarget());
        children.push_back(SlashTarget());
        // children.push_back(MoveToTarget(distance));
    }
}

class SlashTarget : Parallel
{
    SlashTarget()
    {
        children.push_back(TryChargeSlash());
        children.push_back(TryReleaseSlash());
    }
}

class TryChargeSlash : Sequence
{
    TryChargeSlash()
    {
        children.push_back(Inverse(HasSlashCharged()));
        children.push_back(Inverse(IsSlashing()));
        children.push_back(HoldLeftMouse());
    }
}

class TryReleaseSlash : Sequence
{
    TryReleaseSlash()
    {
        children.push_back(IsSlashing());
        children.push_back(DecideSlash());
    }
}

class DecideSlash : Selector
{
    DecideSlash()
    {
        children.push_back(CommitToSlash());
        children.push_back(SlashAway());
    } 
}

class CommitToSlash : Parallel
{
    CommitToSlash()
    {
        children.push_back(LookAtTarget());
        children.push_back(MoveToTarget(0));
        children.push_back(ReleaseSlash());
    }

    f32 utility(CBlob@ this, Blackboard@ blackboard)
    {
        f32 score = 1.0f;
        if (blackboard.target is null)
        {
            return 0.0f;
        }

        f32 distance = this.getDistanceTo(blackboard.target);
        f32 health = this.getHealth();
        string target_type = blackboard.target.getName();
        
        if (target_type == "knight")
        {

        }
        else if (target_type == "archer")
        {

        }
        else if (target_type == "builder")
        {
            if (health <= 0.25f)
            {
                score *= 0.5f;
            }
            else if (health <= 0.5f)
            {
                score *= 0.75f;
            }
        }
        else
        {
            print("UNHANDLED TARGET TYPE");
        }

        KnightInfo@ knight, enemy;
        if (!this.get("knightInfo", @knight) || blackboard.target is null || !blackboard.target.get("knightInfo", @enemy))
        {
            return BehaviorTreeStatus::failure;
        }
        return 0.0f;
    };
}

class SlashAway : Parallel
{
    SlashAway()
    {
        children.push_back(LookAwayFromTarget());
        children.push_back(MoveToTarget(80));
        children.push_back(ReleaseSlash());
    }

    f32 utility(CBlob@ this) {
        // Disadvantaged
        // Slashing away provides enough distance
        // About to stun self

        return 1.0f;
    };
}

class KnightDance : Parallel
{
    KnightDance()
    {
        children.push_back(LookAtTarget());
        children.push_back(MoveToTarget(40));
        children.push_back(ReleaseSlash());
    }

    f32 utility(CBlob@ this)
    {
        // 
        return 0.0f;
    };
}