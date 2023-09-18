#include "ArrowCommon.as"

void onInit(CBlob@ this)
{
  if (getNet().isServer())
  {
    this.set_u16("decay time", 180);
  }

  this.maxQuantity = 1;

  this.getCurrentScript().runFlags |= Script::remove_after_this;

  setArrowHoverRect(this);

  this.set_f32("important-pickup", 19.0f);  // Waffle: Adjust Z values
}
