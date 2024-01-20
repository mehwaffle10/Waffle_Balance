
const string PAUSE_MATERIALS = "pause materials";

bool materialsPaused()
{
    CRules@ rules = getRules();
    return (rules.isIntermission() || rules.isWarmup()) && rules.get_bool(PAUSE_MATERIALS);
}
