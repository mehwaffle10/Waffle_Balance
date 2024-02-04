
class MapFlag
{
    bool[] flags;

    MapFlag(u32 size)
    {
        print("isServer: " + isServer() + ", MapFlag.as constructor size: " + size);
        flags = bool[](size);
    }

    void Sync(CRules@ rules, CPlayer@ player, string command)
    {
        if (!isServer() || rules is null)
        {
            return;
        }

        CBitStream params;
        params.write_u32(flags.length);
        for (u32 i = 0; i < flags.length; i++)
        {
            params.write_bool(flags[i]);
        }

        rules.SendCommand(rules.getCommandID(command), params, player);
    }
}