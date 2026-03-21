
#include "ShieldCommon.as"

uint MAX_BUFFER = 20;

class PastInfo {
    u16[] gametime;
    bool[] state;

    PastInfo() {}

    void push_state(u16 gametime, bool state)
    {
        this.gametime.insertAt(0, gametime);
        this.state.insertAt(0, state);
        
        if (this.gametime.size() > MAX_BUFFER)
        {
            this.gametime.pop_back();
            this.state.pop_back();
        }
    }
}


void onInit(CBlob@ this)
{ 
    this.addCommandID("sync_debug_state");

    PastInfo@ temp = PastInfo();

    this.set("sync_debug_server", @temp);

    PastInfo@ tempo = PastInfo();

    this.set("sync_debug_client", @tempo);
}

void onTick(CBlob@ this)
{
    ShieldVars@ vars = getShieldVars(this);
    if (isServer()) {
        CBitStream p;
        p.write_u16(getGameTime());
        p.write_bool(vars.enabled);

        this.SendCommand(this.getCommandID("sync_debug_state"), p);
    } 
    
    if (isClient()) {
        PastInfo@ info;
        this.get("sync_debug_client", @info);

        info.push_state(getGameTime(), vars.enabled);

        this.set("sync_debug_client", @info);
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("sync_debug_state") && isClient())
    {
        u16 gametime = params.read_u16();
        bool shielding = params.read_bool();

        PastInfo@ info = PastInfo();
        this.get("sync_debug_server", @info);

        info.push_state(gametime, shielding);
    }
}

void onRender(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    ImGui::SetNextWindowPos(getDriver().getScreenPosFromWorldPos(blob.getPosition()) + Vec2f(-75, 30), 1, Vec2f_zero);
    ImGui::SetNextWindowSize(Vec2f(160, 400));
    ImGui::SetNextWindowBgAlpha(0.2);

    if (!ImGui::Begin("Shield Debug - " + blob.getNetworkID())) {
        ImGui::End();
        return;
    }

    ImGui::Text("---- Client");
    ImGui::Separator();

    ShieldVars@ vars = getShieldVars(blob);

    if (vars.enabled) {
        ImGui::TextColored(SColor(255, 50, 250, 100), "Shielding");
    } else {
        ImGui::TextColored(SColor(255, 255, 100, 100), "Exposed");
    }

    if (vars.forcedDown) {
        ImGui::TextColored(SColor(255, 255, 100, 100), "Forced down");
    } else {
        ImGui::TextColored(SColor(255, 50, 250, 100), "Free");
    }

    ImGui::Spacing();
    ImGui::Spacing();
    ImGui::Spacing();

    ImGui::Text("---- Server");
    ImGui::Separator();

    ImGui::TextColored(SColor(100, 255, 255, 255), "Tick:   Server      -  Client");

    PastInfo@ info = PastInfo();
    PastInfo@ infoClient = PastInfo();
    blob.get("sync_debug_server", @info);
    blob.get("sync_debug_client", @infoClient);


    for (int a = 0; a < infoClient.gametime.size(); a++)
    {
        bool notFound = true;
        // Search the server info
        for (int b = 0; b < info.gametime.size(); b++)
        {
            if (infoClient.gametime[a] == info.gametime[b])
            {
                notFound = false;

                SColor col = infoClient.state[a] != info.state[b] ? SColor(255, 255, 0, 0) : SColor(255, 0, 255, 0);

                ImGui::TextColored(col, infoClient.gametime[a] + ": " + (info.state[b] ? "Shielding" : "Exposed  ") + " - " + (infoClient.state[a] ? "Shielding" : "Exposed"));
                
                break;
            }
        }
        

        if (notFound)
            ImGui::Text(infoClient.gametime[a] + ": " + "No synced state from the server");
    }



    ImGui::End();
}