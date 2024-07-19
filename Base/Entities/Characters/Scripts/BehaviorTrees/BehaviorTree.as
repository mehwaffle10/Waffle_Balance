
#define SERVER_ONLY;

shared interface BehaviorTreeNode {
    f32 utility(CBlob@ this);
    void execute(CBlob@ this);
}

shared class Selector : BehaviorTreeNode {
    BehaviorTreeNode@[] children;

    f32 utility(CBlob@ this) {
        return 1.0f;
    }

    void execute(CBlob@ this) {
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
            best.execute(this);
        }
    }
}

shared class Sequence : BehaviorTreeNode {
    BehaviorTreeNode@[] children;

    f32 utility(CBlob@ this) {
        return 0.0f;
    }

    void execute(CBlob@ this) {
        for (u8 i = 0; i < children.length; i++) {
            children[i].execute(this);
        }
    }
}