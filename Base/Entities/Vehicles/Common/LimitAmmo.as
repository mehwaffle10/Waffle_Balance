
const string MAX_AMMO = "max ammo";

bool limitAmmo(CBlob@ vehicle, CBlob@ blob)
{
	// Waffle: Limit maximum ammo
	if (vehicle is null || blob is null || !vehicle.exists(MAX_AMMO))
	{
		return false;
	}

	CInventory@ inventory = vehicle.getInventory();
	if (inventory is null)
	{
        return false;
    }

    // Waffle: Max reached
    u16 max_ammo = vehicle.get_u16(MAX_AMMO);
    u16 count = inventory.getCount(blob.getName());
    if (count >= max_ammo)
    {
        return true;
    }

    // Waffle: Can add entire blob to inventory
    s32 dif = max_ammo - count;
    u16 quantity = blob.getQuantity();
    if (dif >= quantity)
    {
        return false;
    }

    // Waffle: Need to limit
    CBlob@ ammo = inventory.getItem(blob.getName());
    if (ammo is null)
    {
        @ammo = server_CreateBlob(blob.getName());
        if (ammo is null)
        {
            return true;
        }
        vehicle.server_PutInInventory(ammo);
    }
    ammo.server_SetQuantity(max_ammo);
    blob.server_SetQuantity(quantity - dif);
    return true;
}