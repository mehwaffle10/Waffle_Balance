
#define SERVER_ONLY;

#include "BehaviorTree.as"
#include "BehaviorTreeCommon.as"
#include "KnightCommon.as";

class LookAtTarget : BehaviorTreeNode {
    u8 execute(CBlob@ this) {
        CPlayer@ player = getPlayerByUsername("mehwaffle10");
        if (player is null)
        {
            return BehaviorTreeStatus::failure;
        }

        CBlob@ target = player.getBlob();
        if (target is null)
        {
            return BehaviorTreeStatus::failure;
        }

        this.setAimPos(target.getPosition());
        return BehaviorTreeStatus::success;
    }
}

class JumpInPlace : BehaviorTreeNode {
    f32 utility(CBlob@ this) {
        CBlob@[] enemies;
        getNearbyEnemies(this, enemies, 32.0f);

        return enemies.length > 0 ? 1.0f : 0.0f;
    }

    u8 execute(CBlob@ this) {
        this.setKeyPressed(key_up, true);
        return BehaviorTreeStatus::success;
    }
}

class HoldLeftMouse : BehaviorTreeNode {
    u8 execute(CBlob@ this) {
        this.setKeyPressed(key_action1, true);
        return BehaviorTreeStatus::success;
    }
}

class ReleaseSlash : BehaviorTreeNode {
    u8 execute(CBlob@ this) {
        KnightInfo@ knight;
        if (!this.get("knightInfo", @knight))
        {
            return BehaviorTreeStatus::failure;
        }
        
        this.setKeyPressed(key_up, true);
        if (isSwordState(knight.state))
        {
            return BehaviorTreeStatus::running;
        }

        return BehaviorTreeStatus::success;
    }
}

class MoveLeft : BehaviorTreeNode {
    u8 execute(CBlob@ this) {
        this.setKeyPressed(key_left, true);
        return BehaviorTreeStatus::success;
    }
}


class MoveRight : BehaviorTreeNode {
    u8 execute(CBlob@ this) {
        this.setKeyPressed(key_right, true);
        return BehaviorTreeStatus::success;
    }
}