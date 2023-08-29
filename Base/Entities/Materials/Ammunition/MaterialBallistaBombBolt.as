
void onInit(CBlob@ this)
{
  if (getNet().isServer())
  {
    this.set_u8("decay step", 2);
  }

  this.maxQuantity = 6;

  this.getCurrentScript().runFlags |= Script::remove_after_this;

  this.set_f32("important-pickup", 18.0f);  // Waffle: Adjust Z values
}
