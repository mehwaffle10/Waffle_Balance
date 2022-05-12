
void onInit(CBlob@ this)
{
  if (getNet().isServer())
  {
    this.set_u16('decay time', 180);
  }

  this.maxQuantity = 1;  // Waffle: Water arrows only stack to one

  this.getCurrentScript().runFlags |= Script::remove_after_this;
}
