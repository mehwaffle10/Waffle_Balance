
void onInit(CBlob@ this)
{
  if (getNet().isServer())
  {
    this.set_u8("decay step", 2);
  }

  this.maxQuantity = 6;  // 12  // Waffle: Reduce amount of bolts

  this.getCurrentScript().runFlags |= Script::remove_after_this;
}
