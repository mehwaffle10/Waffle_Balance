
const u8 radius = 16;
const string tree_limit = "tree limit";
const string tree_limit_delay = "tree limit delay";

void onInit(CBlob@ this)
{
    if (this.hasTag("startbig"))
    {
        // Delay checking since get blobs can't work first tick
        this.set_u8(tree_limit_delay, 1);
    }
    else
    {
        // Check immediately
        initLimit(this);
    }
}

void onTick(CBlob@ this)
{
    u8 delay = this.get_u8(tree_limit_delay);
    if (delay > 0)
    {
        initLimit(this);
    }
    else
    {
        this.set_u8(tree_limit_delay, delay - 1);
    }
}

void initLimit(CBlob@ this)
{
    this.getCurrentScript().tickFrequency = 0;
    CMap@ map = getMap();
    if (map is null)
    {
        return;
    }
    
    CBlob@[] blobs;
    getNearbyBlobs(map, this, blobs);
    for (u16 i = 0; i < blobs.length(); i++)
    {
        if (blobs[i] !is null && blobs[i].hasTag("tree") && blobs[i].getNetworkID() != this.getNetworkID())
        {
            createLimit(map, this);
            createLimit(map, blobs[i]);
        }
    }
}

void onDie(CBlob@ this)
{
    CMap@ map = getMap();
    if (map is null)
    {
        return;
    }

    CBlob@[] blobs;
    getNearbyBlobs(map, this, blobs);
    for (u16 i = 0; i < blobs.length(); i++)
    {
        if (blobs[i] !is null && blobs[i].hasTag("tree"))
        {
            removeLimit(map, blobs[i], this);
        }
    }
}

void getNearbyBlobs(CMap@ map, CBlob@ tree, CBlob@[]@ blobs)
{
    Vec2f offset = Vec2f(1, 1) * map.tilesize;
    map.getBlobsInBox(getUpperLeft(map, tree) + offset, getBottomRight(map, tree) - offset, blobs);
}

Vec2f getUpperLeft(CMap@ map, CBlob@ tree)
{
    return getCenter(map, tree) - getOffset(map);
}

Vec2f getBottomRight(CMap@ map, CBlob@ tree)
{
    return getCenter(map, tree) + getOffset(map) + Vec2f(1, 0) * map.tilesize;
}

Vec2f getCenter(CMap@ map, CBlob@ tree)
{
    return map.getTileSpacePosition(tree.getPosition()) * map.tilesize;
}

Vec2f getOffset(CMap@ map)
{
    return Vec2f(1, 1) * radius * map.tilesize;
}

void createLimit(CMap@ map, CBlob@ tree)
{
    map.server_AddSector(
        getUpperLeft(map, tree),
        getBottomRight(map, tree),
        tree_limit,
        "",
        tree.getNetworkID()
    );
}

void removeLimit(CMap@ map, CBlob@ tree, CBlob@ source_tree)
{
    if (tree.getNetworkID() != source_tree.getNetworkID())
    {
        CBlob@[] blobs;
        getNearbyBlobs(map, tree, blobs);
        for (u16 i = 0; i < blobs.length(); i++)
        {
            if (blobs[i] !is null && blobs[i].hasTag("tree") && blobs[i].getNetworkID() != tree.getNetworkID() && blobs[i].getNetworkID() != source_tree.getNetworkID())
            {
                return;
            }
        }
    }

    map.RemoveSectorsAtPosition(
        getCenter(map, tree),
        tree_limit,
        tree.getNetworkID()
    );
}
