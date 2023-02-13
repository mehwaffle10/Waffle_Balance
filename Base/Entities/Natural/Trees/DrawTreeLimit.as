
#define CLIENT_ONLY

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
            CBlob@ occupied = attachment.getOccupied();
            if (occupied !is null && occupied.getName() == "seed" && 
               (occupied.get_string("seed_grow_blobname") == "tree_pine" || occupied.get_string("seed_grow_blobname") == "tree_bushy"))
            {
                holding_sapling = true;
                break;
            }
        }
    }

    if (!holding_sapling || !player.isKeyPressed(key_action1))
    {
        return;
    }

    Vec2f mouse_pos = player.getAimPos();
    CMap::Sector@[] sectors;
    map.getSectorsAtPosition(mouse_pos, sectors);
    // map.getSectors("tree limit", sectors);  // for debug
    for (u16 i = 0 ; i < sectors.length(); i++)
    {
        CMap::Sector@ sector = sectors[i];
        if (sector !is null && sector.name == "tree limit")
        {
            GUI::DrawRectangle(
                driver.getScreenPosFromWorldPos(sector.upperleft),
                driver.getScreenPosFromWorldPos(sector.lowerright),
			    SColor(0x20ed1202)
		    );
        }
    }
}

void onInit(CRules@ this)
{
    
}

void onRestart(CRules@ this)
{

}