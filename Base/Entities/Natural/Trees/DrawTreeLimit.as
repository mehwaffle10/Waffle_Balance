
#define CLIENT_ONLY

#include "TreeLimitCommon.as"

void onRender(CRules@ this)
{
    CMap@ map = getMap();
    Driver@ driver = getDriver();
    CBlob@ player = getLocalPlayerBlob();
    if (map is null || driver is null || player is null) return;
    CBlob@ carried = player.getCarriedBlob();
    if (carried is null) return;

    CBlob@[] blobs, seeds;
    getBlobsByTag("tree", blobs);
    getBlobsByName("seed", seeds);
    for (u16 i = 0; i < seeds.length(); i++)
    {
        CBlob@ seed = seeds[i];
        if (isTreeSeed(seed) && !seed.isInInventory())
        {
            blobs.push_back(seed);
        }
    }

    // Draw boxes that are on screen
    for (u16 i = 0; i < blobs.length(); i++)
    {
        CBlob@ blob = blobs[i];
        if (blob !is null)
        {
            Vec2f blob_pos = blob is carried ? player.getAimPos() : blob.getPosition();
            Vec2f upper_left = driver.getScreenPosFromWorldPos(getUpperLeft(map, blob_pos)),
                  bottom_right = driver.getScreenPosFromWorldPos(getBottomRight(map, blob_pos));
            if (upper_left.x < driver.getScreenWidth() && upper_left.y < driver.getScreenHeight() &&
                bottom_right.x > 0 && bottom_right.y > 0)
            {
                SColor color = SColor(0x200bfc03);
                bool yellow = false;
                CBlob@[] nearby;
                getNearbyBlobs(map, blob_pos, nearby);
                
                for (u16 i = 0; i < nearby.length(); i++)
                {
                    if (nearby[i] !is null && nearby[i] !is blob && (nearby[i].hasTag("tree") || isTreeSeed(nearby[i])))
                    {
                        if (!yellow)
                        {
                            color = SColor(0x20fcf803);
                            yellow = true;
                        }
                        else
                        {
                            color = SColor(0x20ed1202);
                            break;
                        }
                    }
                }
                
                // Draw Limit
                GUI::DrawRectangle(
                    upper_left,
                    bottom_right,
                    color
                );

                DrawTreeHeight(driver, map, blob_pos);
            }
        }
    }
}