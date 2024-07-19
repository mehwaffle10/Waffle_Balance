
#define SERVER_ONLY;

#include "BehaviorTree.as"
#include "BehaviorTreeCommon.as"

shared class LookAtPlayer : BehaviorTreeNode {
    f32 utility(CBlob@ this) {
        return 0.5f;
    }

    void execute(CBlob@ this) {
        CPlayer@ player = getPlayerByUsername("mehwaffle10");
        if (player is null)
        {
            return;
        }

        CBlob@ target = player.getBlob();
        if (target is null)
        {
            return;
        }

        this.setAimPos(target.getPosition());
    }
}

shared class JumpInPlace : BehaviorTreeNode {
    f32 utility(CBlob@ this) {
        CBlob@[] enemies;
        getNearbyEnemies(this, enemies, 32.0f);

        return enemies.length > 0 ? 1.0f : 0.0f;
    }

    void execute(CBlob@ this) {
        this.setKeyPressed(key_up, true);
    }
}
