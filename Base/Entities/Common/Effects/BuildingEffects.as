#include "MakeDustParticle.as";

void onDie(CBlob@ this)
{
	if (!this.getSprite().getVars().gibbed)
	{
		this.getSprite().PlaySound("/BuildingExplosion");
	}

	// gib no matter what
	this.getSprite().Gib();
	// effects
	MakeDustParticle(this.getPosition(), "Smoke.png");

}

// Waffle: Set behind trees
void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-150);	
}