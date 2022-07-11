
void FireSpread(Vec2f world_pos, bool static)
{
    if (!isServer())
    {
        return;
    }

    CMap@ map = getMap();
    CBitStream params;
    world_pos += Vec2f(1.0f, 1.0f) * map.tilesize / 2;
    
    // Ignite target locations
    if (static)
    {
        for (u8 i = 0; i < 2; i++)
        {
            Vec2f target = map.getAlignedWorldPos(world_pos) + Vec2f(1 - XORRandom(3), 1 - XORRandom(3)) * map.tilesize + Vec2f(map.tilesize, map.tilesize) / 2;
            map.server_setFireWorldspace(target, true);
            params.write_Vec2f(target);
        }
    }
    else
    {
        Vec2f target = map.getAlignedWorldPos(world_pos) + Vec2f(map.tilesize, map.tilesize) / 2;
        map.server_setFireWorldspace(target, true);
        params.write_Vec2f(target);
    }

    // Animate on client
    CRules@ rules = getRules();
    rules.SendCommand(rules.getCommandID("Display Fire"), params);
}
