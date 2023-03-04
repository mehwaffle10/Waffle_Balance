// Trampoline animation

namespace Trampoline
{
	enum State
	{
		folded = 0,
		idle,
		bounce,
		unpack
	}
}

void onTick(CSprite@ this)
{
	u8 state = this.getBlob().get_u8("trampolineState");

	//let the current anim finish
	if (this.isAnimationEnded())
	{
		if (state == Trampoline::unpack)
		{
			if (!this.isAnimation("unpack"))
			{
				this.SetAnimation("unpack");
			}
			else
			{
				this.getBlob().set_u8("trampolineState", Trampoline::idle);
			}
		}
		else if (state == Trampoline::folded)
		{
			if (!this.isAnimation("pack"))
			{
				this.SetAnimation("pack");
			}
		}
		else if (state == Trampoline::bounce)
		{
			this.SetAnimation("bounce");
			this.animation.SetFrameIndex(0);
		}
		else if (state == Trampoline::idle)
		{
			if (this.isAnimation("bounce"))
			{
				this.SetAnimation("default");
			}
			else if (!this.isAnimation("default"))
			{
				this.SetAnimation("default");
			}
		}
	}
}
