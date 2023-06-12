
#define CLIENT_ONLY

#include "TreeLimitCommon.as"

void onRender(CRules@ this)
{
    CMap@ map = getMap();
    Driver@ driver = getDriver();
    CBlob@ player = getLocalPlayerBlob();

    if (map is null || driver is null || player is null)
    {
        return;
    }

    AttachmentPoint@[] attachments;
    player.getAttachmentPoints(attachments);
    bool holding_sapling = false;
    for (u8 i = 0; i < attachments.length(); i++)
    {
        AttachmentPoint@ attachment = attachments[i];
        if (attachment !is null && attachment.name == "PICKUP")
        {
            if (isTreeSeed(attachment.getOccupied()))
            {
                holding_sapling = true;
                break;
            }
        }
    }

    if (!holding_sapling)  // !player.isKeyPressed(key_action1))  // Waffle: Always show if holding a sapling
    {
        return;
    }

    // Vec2f mouse_pos = player.getAimPos();
    // CMap::Sector@[] sectors;
    // // map.getSectorsAtPosition(mouse_pos, sectors);
    // map.getSectors("tree limit", sectors);  // for debug
    // for (u16 i = 0 ; i < sectors.length(); i++)
    // {
    //     CMap::Sector@ sector = sectors[i];
    //     if (sector !is null && sector.name == "tree limit")
    //     {
    //         GUI::DrawRectangle(
    //             driver.getScreenPosFromWorldPos(sector.upperleft),
    //             driver.getScreenPosFromWorldPos(sector.lowerright),
	// 		    SColor(0x20ed1202)
	// 	    );
    //     }
    // }

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
            Vec2f upper_left = driver.getScreenPosFromWorldPos(getUpperLeft(map, blob)),
                  bottom_right = driver.getScreenPosFromWorldPos(getBottomRight(map, blob));
            if (upper_left.x < driver.getScreenWidth() && upper_left.y < driver.getScreenHeight() &&
                bottom_right.x > 0 && bottom_right.y > 0)
            {
                SColor color = SColor(0x200bfc03);
                bool yellow = false;
                CBlob@[] nearby;
                getNearbyBlobs(map, blob, nearby);
                
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
                
                GUI::DrawRectangle(
                    upper_left,
                    bottom_right,
                    color
                );
            }
        }
    }
}