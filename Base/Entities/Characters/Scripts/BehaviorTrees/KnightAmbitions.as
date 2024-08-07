
#include "BehaviorTree.as"
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
        children.push_back(SetKeyPressed(key_action1));
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

class CommitToSlash : Sequence
{
    CommitToSlash()
    {
        children.push_back(SetAttackTarget());
    }

    f32 utility(CBlob@ this, Blackboard@ blackboard)
    {
        f32 score = 1.0f;
        if (blackboard.target is null)
        {
            return 0.0f;
        }

        f32 health = this.getHealth();
        Vec2f target_pos = blackboard.target.getPosition();
        Vec2f this_pos = this.getPosition();

        for (u16 i = 0; i < blackboard.nearby_enemies.length; i++)
        {
            CBlob@ enemy = blackboard.nearby_enemies[i];
            Vec2f enemy_pos = enemy.getPosition();
            f32 distance = this.getDistanceTo(enemy);
            string target_type = enemy.getName();
            bool towards_target = target_pos.x < this_pos.x ? enemy_pos.x < this_pos.x : enemy_pos.x > this_pos.x;
            if (target_type == "knight")
            {
                KnightInfo@ knight, enemy_knight;
                if (!this.get("knightInfo", @knight) || !enemy.get("knightInfo", @enemy))
                {
                    return 0.0f;
                }

                if (distance <= 50.0f)
                {
                    if (health <= 0.5f)
                    {
                        score *= towards_target ? 0.25f : 1.2f;
                    }
                    else if (health <= 1.0f)
                    {
                        score *= towards_target ? 0.5f : 1.05f;
                    }
                }
            }
            else if (target_type == "archer")
            {
                if (towards_target) {
                    if (health <= 0.25f)
                    {
                        score *= 0.25f;
                    }
                    else if (health <= 0.5f)
                    {
                        score *= 0.5f;
                    }
                }
            }
            else  // Builder
            {
                if (distance <= 40.0f && towards_target) {
                    if (health <= 0.25f)
                    {
                        score *= 0.25f;
                    }
                    else if (health <= 0.5f)
                    {
                        score *= 0.5f;
                    }
                }
            }
        }

        for (u16 i = 0; i < blackboard.nearby_allies.length; i++)
        {
            score *= 1.2f;
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

class KnightRoot : Fallback
{
    KnightRoot()
    {
        children.push_back(CheckAttackTarget());
        children.push_back(ChargeAttack());
    }
}

class ChargeAttack : Sequence
{
    ChargeAttack()
    {
        children.push_back(SetKeyPressed(key_action1));
        children.push_back(HasSlashCharged());
        children.push_back(SetAttackTarget());
        // children.push_back(CheckSlashJump());
    }
}

class CheckAttackTarget : Sequence
{
    CheckAttackTarget()
    {
        children.push_back(HasAttackTarget());
        children.push_back(HandleAttackTarget());
    }
}

class HandleAttackTarget : Parallel
{
    HandleAttackTarget()
    {
        children.push_back(LookAtTarget());
        children.push_back(MoveToTarget(0));
        // children.push_back(CheckJump());
        children.push_back(CheckSlashJump());
        children.push_back(CheckAttack());
    }
}

class CheckAttack : Sequence
{
    CheckAttack()
    {
        children.push_back(IsAttackFinished());
        children.push_back(ClearAttackTarget());
        // children.push_back(ClearJump());
    }
}

class CheckSlashJump : Sequence
{
    CheckSlashJump()
    {
        children.push_back(BelowTarget(-4));
        children.push_back(SetKeyPressed(key_up));
    }
}
