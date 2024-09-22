// Runner Common

// Waffle: Add chicken jump/hover
const u8 MAX_CHICKEN_HOVER_COUNTER = 3 * getTicksASecond();
const u8 CHICKEN_JUMP_RESET_TIME = 2 * getTicksASecond();

shared class RunnerMoveVars
{
	//walking vars
	f32 walkSpeed;  //target vel
	f32 walkSpeedInAir;
	f32 walkFactor;

	//ladder
	Vec2f walkLadderSpeed;

	//jumping vars
	f32 jumpMaxVel;
	f32 jumpStart;
	f32 jumpMid;
	f32 jumpEnd;
	f32 jumpFactor;
	s32 jumpCount; //internal counter
	s32 fallCount; //internal counter only moving down

	//swimming vars
	f32 swimspeed;
	f32 swimforce;
	f32 swimEdgeScale;

	//vaulting vars
	bool canVault;

	//scale the entire movement
	f32 overallScale;

	//force applied while... stopping
	f32 stoppingForce;
	f32 stoppingForceAir;
	f32 stoppingFactor;

	// moved from tags...
	bool walljumped;
	s32 walljumped_side;
	int wallrun_count;
	bool wallclimbing;
	bool wallsliding;

	// Waffle: Add chicken jump/hover
	u8 chicken_jump_timer;
	u8 chicken_hover_counter;
};

namespace Walljump
{
	enum WalljumpSide
	{
		NONE,
		LEFT,
		JUMPED_LEFT,
		RIGHT,
		JUMPED_RIGHT,
		BOTH
	};
}

void ResetChickenJump(CBlob@ this, RunnerMoveVars@ moveVars)
{
	if (moveVars.chicken_jump_timer > 0) {
		moveVars.chicken_jump_timer--;
		if (moveVars.chicken_jump_timer == 0)
		{
			this.getSprite().PlaySound("/ScaredChicken0" + (XORRandom(3) + 1));
		}
	}
	moveVars.chicken_hover_counter = MAX_CHICKEN_HOVER_COUNTER;
}