
#define SERVER_ONLY

void onStateChange(CRules@ this, const u8 oldState)
{
    this.set_u8("Synced State", this.getCurrentState());
    this.Sync("Synced State", true);
}
