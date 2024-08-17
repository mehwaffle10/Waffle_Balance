

#include "canGrow.as"

const u8 radius = 16;
const string tree_limit = "tree limit";
const string tree_limit_delay = "tree limit delay";

void getNearbyBlobs(CMap@ map, CBlob@ tree, CBlob@[]@ blobs)
{
    Vec2f offset = Vec2f(1, 1) * map.tilesize;
    map.getBlobsInBox(getUpperLeft(map, tree) + offset, getBottomRight(map, tree) - offset, blobs);
}

Vec2f getUpperLeft(CMap@ map, CBlob@ tree)
{
    return getUpperLeft(map, tree.getPosition());
}

Vec2f getUpperLeft(CMap@ map, Vec2f pos)
{
    return getCenter(map, pos) - getOffset(map);
}

Vec2f getBottomRight(CMap@ map, CBlob@ tree)
{
    return getBottomRight(map, tree.getPosition());
}

Vec2f getBottomRight(CMap@ map, Vec2f pos)
{
    return getCenter(map, pos) + getOffset(map) + Vec2f(1, 0) * map.tilesize;
}

Vec2f getCenter(CMap@ map, CBlob@ tree)
{
    return getCenter(map, tree.getPosition());
}

Vec2f getCenter(CMap@ map, Vec2f pos)
{
    return map.getTileSpacePosition(pos) * map.tilesize;
}

Vec2f getTreeUpperLeft(CMap@ map, CBlob@ tree)
{
    return getTreeUpperLeft(map, tree.getPosition());
}

Vec2f getTreeUpperLeft(CMap@ map, Vec2f pos)
{
    return getCenter(map, pos) + Vec2f(0, -12) * map.tilesize;
}

Vec2f getTreeBottomRight(CMap@ map, CBlob@ tree)
{
    return getTreeBottomRight(map, tree.getPosition());
}

Vec2f getTreeBottomRight(CMap@ map, Vec2f pos)
{
    return getCenter(map, pos) + Vec2f(1, 1) * map.tilesize;
}

Vec2f getOffset(CMap@ map)
{
    return Vec2f(1, 1) * radius * map.tilesize;
}

bool isTreeSeed(CBlob@ blob)
{
    return blob !is null && blob.getName() == "seed" && (blob.get_string("seed_grow_blobname") == "tree_pine" || blob.get_string("seed_grow_blobname") == "tree_bushy");
}

bool isLimitingSeed(CBlob@ blob)
{
	return blob !is null && !blob.isAttached() && (blob.isOnGround() || blob.getShape() !is null && blob.getShape().isStatic()) && isTreeSeed(blob) && canGrowAt(blob, blob.getPosition());
}

void DrawTreeHeight(Driver@ driver, CMap@ map, CBlob@ tree)
{
    DrawTreeHeight(driver, map, tree.getPosition());
}

void DrawTreeHeight(Driver@ driver, CMap@ map, Vec2f pos)
{
    GUI::DrawRectangle(
        driver.getScreenPosFromWorldPos(getTreeUpperLeft(map, pos)),
        driver.getScreenPosFromWorldPos(getTreeBottomRight(map, pos)),
        SColor(0x600bfc03)
    );
}