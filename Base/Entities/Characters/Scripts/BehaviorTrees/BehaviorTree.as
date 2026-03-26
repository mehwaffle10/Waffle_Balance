
#define SERVER_ONLY;

#include "BehaviorTreeDebugCommon.as"

namespace BehaviorTreeStatus {
    enum statuses {
        success = 0,
        failure,
        running
    }
}

const string ATTACK_TARGET = "bt attack target";

class Blackboard {
    CBlob@ target;
    CBlob@ attack_target;
    CBlob@[] nearby_enemies;
    CBlob@[] nearby_allies;

    // CBlob@[] nearby_projectiles;
    // CBlob@[] nearby_bombs;
    // CBlob@[] nearby_
}

class BehaviorTreeNode {
	string name;
	SColor color;

	BehaviorTreeNode() {
		color = SColor(200, 255, 0, 0);
	}

    f32 utility(CBlob@ this, Blackboard@ blackboard) {
        return 0.0f;
    };

    u8 execute(CBlob@ this, Blackboard@ blackboard, u16 depth) {
        return BehaviorTreeStatus::failure;
    }
}

class Selector : BehaviorTreeNode {
    BehaviorTreeNode@[] children;

	Selector()
	{
		color = SColor(200, 0, 150, 0);
	}

    u8 execute(CBlob@ this, Blackboard@ blackboard, u16 depth) {
        f32 max_utility = -1.0f;
        string scores = name + ":: ";
        BehaviorTreeNode@ best = null;
        for (u8 i = 0; i < children.length; i++) {
            f32 utility = children[i].utility(this, blackboard);
            scores += children[i].name + ": " + utility + " ";
            if (utility > max_utility)
            {
                max_utility = utility;
                @best = @children[i];
            }
        }
		PushDebugMessage(this, scores, color, depth);
        if (best !is null)
        {
            return best.execute(this, blackboard, depth + 1);
        }
        return BehaviorTreeStatus::failure;
    }
}

class Sequence : BehaviorTreeNode {
    BehaviorTreeNode@[] children;

	Sequence()
	{
		color = SColor(200, 150, 150, 150);
	}

    u8 execute(CBlob@ this, Blackboard@ blackboard, u16 depth) {
		PushDebugMessage(this, name, color, depth);
        for (u8 i = 0; i < children.length; i++) {
            u8 status = children[i].execute(this, blackboard, depth + 1);
            if (status != BehaviorTreeStatus::success)
            {
                return status;
            }
        }
        return BehaviorTreeStatus::success;
    }
}

class Fallback : BehaviorTreeNode {
    BehaviorTreeNode@[] children;

	Fallback()
	{
		color = SColor(200, 240, 0, 240);
	}

    u8 execute(CBlob@ this, Blackboard@ blackboard, u16 depth) {
		PushDebugMessage(this, name, color, depth);
        for (u8 i = 0; i < children.length; i++) {
            u8 status = children[i].execute(this, blackboard, depth + 1);
            if (status != BehaviorTreeStatus::failure)
            {
                return status;
            }
        }
        return BehaviorTreeStatus::failure;
    }
}

class Parallel : BehaviorTreeNode {
    BehaviorTreeNode@[] children;

	Parallel()
	{
		color = SColor(200, 0, 150, 150);
	}

    u8 execute(CBlob@ this, Blackboard@ blackboard, u16 depth) {
		PushDebugMessage(this, name, color, depth);
        u8 node_status = BehaviorTreeStatus::failure;
        for (u8 i = 0; i < children.length; i++) {
            u8 status = children[i].execute(this, blackboard, depth + 1);
            if (status == BehaviorTreeStatus::running)
            {
                node_status = BehaviorTreeStatus::running;
            }
            else if (node_status == BehaviorTreeStatus::failure && status == BehaviorTreeStatus::success)
            {
                node_status = BehaviorTreeStatus::success;
            }
        }
        return node_status;
    }
}

class Inverse : BehaviorTreeNode {
    BehaviorTreeNode@ child;

    Inverse(BehaviorTreeNode@ _child) {
		name = "Inverse " + _child.name;
		color = SColor(200, 150, 0, 0);
        @child = @_child;
    }

    f32 utility(CBlob@ this, Blackboard@ blackboard) {
        return child.utility(this, blackboard);
    }

    u8 execute(CBlob@ this, Blackboard@ blackboard, u16 depth) {
		PushDebugMessage(this, name, color, depth);
        u8 status = child.execute(this, blackboard, depth + 1);
        if (status == BehaviorTreeStatus::success)
        {
            return BehaviorTreeStatus::failure;
        }
        else if (status == BehaviorTreeStatus::failure)
        {
            return BehaviorTreeStatus::success;
        }
        else
        {
            return BehaviorTreeStatus::running;
        }
    }
}