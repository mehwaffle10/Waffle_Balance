
const string GOLD_LOCATIONS = "gold locations";
const u8 GOLD_REGEN_SECONDS = 60;

class MapLocations
{
    Vec2f[] locations;

    MapLocations(u32 size)
    {
        locations = Vec2f[](size);
    }
}