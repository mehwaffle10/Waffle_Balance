
#define SERVER_ONLY;

namespace BehaviorTreeStatus {
    enum statuses {
        success = 0,
        failure,
        running
    }
}

class Blackboard {
    CBlob@ target;
}

class BehaviorTreeNode {
    f32 utility(CBlob@ this) {
        return 0.0f;
    };

    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        return BehaviorTreeStatus::failure;
    }
}

class Selector : BehaviorTreeNode {
    BehaviorTreeNode@[] children;

    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        f32 max_utility = -1.0f;
        BehaviorTreeNode@ best = null;
        for (u8 i = 0; i < children.length; i++) {
            f32 utility = children[i].utility(this);
            if (utility > max_utility)
            {
                max_utility = utility;
                @best = @children[i];
            }
        }
        if (best !is null)
        {
            return best.execute(this, blackboard);
        }
        return BehaviorTreeStatus::failure;
    }
}

class Sequence : BehaviorTreeNode {
    BehaviorTreeNode@[] children;

    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        for (u8 i = 0; i < children.length; i++) {
            u8 status = children[i].execute(this, blackboard);
            if (status != BehaviorTreeStatus::success)
            {
                return status;
            }
        }
        return BehaviorTreeStatus::success;
    }
}

class Parallel : BehaviorTreeNode {
    BehaviorTreeNode@[] children;

    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        u8 node_status = BehaviorTreeStatus::failure;
        for (u8 i = 0; i < children.length; i++) {
            u8 status = children[i].execute(this, blackboard);
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
        @child = @_child;
    }

    f32 utility(CBlob@ this) {
        return child.utility(this);
    }

    u8 execute(CBlob@ this, Blackboard@ blackboard) {
        u8 status = child.execute(this, blackboard);
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