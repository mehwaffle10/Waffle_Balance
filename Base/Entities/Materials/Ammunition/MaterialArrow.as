#include "ArrowCommon.as" // Waffle: Increase max arrow quantity

void onInit(CBlob@ this)
{
  if (getNet().isServer())
  {
    this.set_u16("decay time", 45);
  }

  this.maxQuantity = ARROW_MAX_QUANTITY;  // Waffle: Increase max arrow quantity

  this.getCurrentScript().runFlags |= Script::remove_after_this;
}
