// For crate autopickups

bool crateTake(CBlob@ this, CBlob@ blob)
{
    if (this.exists("packed"))
    {
        return false;
    }

    const string blobName = blob.getName();

    if (
        // blobName == "mat_gold"  // Waffle: Gold shouldn't exist anymore
        blobName == "mat_stone"
        || blobName == "mat_wood"
        || blobName == "mat_bombs"
        || blobName == "mat_waterbombs"
        // || blobName == "mat_arrows"  // Waffle: Tends to be clutter
        || blobName == "mat_firearrows"
        || blobName == "mat_bombarrows"
        || blobName == "mat_waterarrows"
        || blobName == "mat_bolts"       // Waffle: Add ballista bolts
        || blobName == "mat_bomb_bolts"  // Waffle: --
        || blobName == "log"
        || blobName == "fishy"
        || blobName == "grain"
        || blobName == "food"
        || blobName == "egg"
        )
    {
        return this.server_PutInInventory(blob);
    }
    return false;
}
