
#include "BehaviorTree.as"
#include "CommonLeaves.as"
#include "CommonAmbitions.as"
#include "KnightConditions.as"
#include "KnightLeaves.as"
#include "ShieldCommon.as"

class KnightRoot : Fallback
{
    KnightRoot()
    {
        children.push_back(CheckAttackTarget());
        children.push_back(ChargeAttack());
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
        children.push_back(CheckSlashJump());
        children.push_back(CheckAttack());
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

class CheckAttack : Sequence
{
    CheckAttack()
    {
        children.push_back(IsAttackFinished());
        children.push_back(ClearAttackTarget());
    }
}

class ChargeAttack : Sequence
{
    ChargeAttack()
    {
        children.push_back(SetKeyPressed(key_action1));
        children.push_back(DecideSlash());
    }
}

class DecideSlash : Selector
{
    DecideSlash()
    {
        children.push_back(CommitToAttack());
        children.push_back(SlashForDistance());
        children.push_back(KnightDance());
    }
}

class CommitToAttack : Sequence
{
    CommitToAttack()
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

        KnightInfo@ knight;
        if (!this.get("knightInfo", @knight))
        {
            return 0.0f;
        }

        f32 health = this.getHealth();
        Vec2f target_pos = blackboard.target.getPosition();
        Vec2f this_pos = this.getPosition();

        f32 attack_damage = 0.5f;
        f32 attack_range = 40.0f;
        if (knight.swordTimer >= KnightVars::slash_charge)
        {
            if (knight.swordTimer < KnightVars::slash_charge_level2)
            {
                attack_damage = 1.0f;
                attack_range = 48.0f;
            }
            else if(knight.swordTimer < KnightVars::slash_charge_limit)
            {
                attack_damage = 2.0f;
                attack_range = 56.0f;
            }
        }

        CMap@ map = getMap();
        f32 total_damage = 0.0f;
        if (map !is null)
        {
            HitInfo@[] hitInfos;
            Vec2f aim_direction;
            this.getAimDirection(aim_direction);
	        if (map.getHitInfosFromArc(this.getPosition(), -(aim_direction.Angle()), 40.0f, attack_range, this, @hitInfos))
            {
                for (u16 i = 0; i < hitInfos.length; i++)
                {
                    HitInfo@ hit_info = hitInfos[i];
			        CBlob@ hit_blob = hit_info.blob;
                    if (hit_blob is null || !hit_blob.hasTag("player") || hit_blob.hasTag("dead"))
                    {
                        continue;
                    }

                    f32 hit_blob_health = hit_blob.getHealth();
                    total_damage += hit_blob_health > attack_damage ? attack_damage : 4.0f;
                }
            }
        }

        f32 incoming_damage = 0.1f;
        for (u16 i = 0; i < blackboard.nearby_enemies.length; i++)
        {
            CBlob@ enemy = blackboard.nearby_enemies[i];
            Vec2f enemy_pos = enemy.getPosition();
            f32 distance = this.getDistanceTo(enemy);
            string target_type = enemy.getName();
            bool towards_target = target_pos.x < this_pos.x ? enemy_pos.x < this_pos.x : enemy_pos.x > this_pos.x;
            if (target_type == "knight")
            {
                KnightInfo@ enemy_knight;
                if (!enemy.get("knightInfo", @enemy_knight))
                {
                    continue;
                }

                f32 enemy_attack_damage = 0.0f;
                f32 enemy_attack_range = 0.0f;
                if (isShieldState(enemy_knight.state))
                {
                    if (attack_damage <= 0.5f && blockAttack(enemy, enemy_pos - this_pos, attack_damage))
                    {
                        enemy_attack_damage = 4.0f;
                        enemy_attack_range = 40.0f;
                    }
                }
                else if (enemy_knight.state == KnightStates::sword_drawn)
                {
                    enemy_attack_damage = 0.5f;
                    enemy_attack_range = 40.0f;
                    if (enemy_knight.swordTimer < KnightVars::slash_charge_level2)
                    {
                        enemy_attack_damage = 1.0f;
                        enemy_attack_range = 48.0f;
                    }
                    else if(enemy_knight.swordTimer < KnightVars::slash_charge_limit)
                    {
                        enemy_attack_damage = 2.0f;
                        enemy_attack_range = 56.0f;
                    }
                }
                else if (enemy_knight.state >= KnightStates::sword_cut_mid && enemy_knight.state <= KnightStates::sword_cut_down)
                {
                    enemy_attack_damage = 0.5f;
                    enemy_attack_range = 40.0f;
                }
                else if (enemy_knight.state == KnightStates::sword_power)
                {
                    enemy_attack_damage = 1.0f;
                    enemy_attack_range = 48.0f;
                }
                else if (enemy_knight.state == KnightStates::sword_power_super)
                {
                    enemy_attack_damage = 2.0f;
                    enemy_attack_range = 56.0f;
                }

                if (distance <= enemy_attack_range)
                {
                    incoming_damage += enemy_attack_damage;
                    if (health <= enemy_attack_damage)
                    {
                        score *= towards_target ? 0.25f : 1.2f;
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

        score *= total_damage / incoming_damage;

        for (u16 i = 0; i < blackboard.nearby_allies.length; i++)
        {
            score *= 1.2f;
        }

        return score;
    };
}

class SlashForDistance : Parallel
{
    SlashForDistance()
    {
        children.push_back(LookAwayFromTarget());
        children.push_back(MoveToTarget(80));
        children.push_back(ReleaseSlash());
    }

    f32 utility(CBlob@ this) {
        f32 score = 1.0f;
        KnightInfo@ knight;
        if (!this.get("knightInfo", @knight))
        {
            return 0.0f;
        }

        if (knight.swordTimer < KnightVars::slash_charge)
        {
            return 0.0f;
        }
        else if (knight.swordTimer < KnightVars::slash_charge_level2)
        {
            knight.state = KnightStates::sword_power;
        }
        else if(knight.swordTimer < KnightVars::slash_charge_limit)
        {
            knight.state = KnightStates::sword_power_super;
        }
        // Disadvantaged
        // Slashing away provides enough distance
        // About to stun self

        return score;
    };
}

class KnightDance : Parallel
{
    KnightDance()
    {
        children.push_back(LookAtTarget());
        children.push_back(MoveToTarget(40));
    }

    f32 utility(CBlob@ this)
    {
        
        return 0.0f;
    };
}

