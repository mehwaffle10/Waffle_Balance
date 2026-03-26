
// const SColor INACTIVE = SColor(255, 150, 150, 150);
// const SColor ACTIVE = SColor(255, 0, 150, 0);
// const SColor FAILED = SColor(255, 150, 0, 0);
const string PAST_STATE = "past_state";
const string SPACES = "                                                                                                    ";

class PastInfo {
    string[] message;
	SColor[] color;

    PastInfo() {}

    void push_state(string message, SColor color)
    {
        this.message.push_back(message);
		this.color.push_back(color);
    }

	void clear()
    {
        this.message.clear();
		this.color.clear();
    }
}

void DebugInit(CBlob@ this)
{ 
    PastInfo@ past_state = PastInfo();
    this.set(PAST_STATE, @past_state);
}

void RenderDebug(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
	PastInfo@ info = PastInfo();
    if(!blob.get(PAST_STATE, @info)) return;

    ImGui::SetNextWindowPos(Vec2f(100, 100), 1, Vec2f_zero);
    ImGui::SetNextWindowSize(Vec2f(1000, 20 * (info.message.size() + 1)));
    // ImGui::SetNextWindowBgAlpha(0.2);

    if (!ImGui::Begin("AI Debug - " + blob.getNetworkID())) {
        ImGui::End();
        return;
    }

	for (int i = 0; i < info.message.size(); i++)
	{
		ImGui::TextColored(info.color[i], info.message[i]);
	}
    ImGui::End();
}

void ClearDebugMessages(CBlob@ this)
{
	PastInfo@ past_state;
	this.get(PAST_STATE, @past_state);
	past_state.clear();
	this.set(PAST_STATE, @past_state);
}

void PushDebugMessage(CBlob@ this, string message, SColor color, u16 depth)
{
	PastInfo@ past_state;
	this.get(PAST_STATE, @past_state);
	past_state.push_state(SPACES.substr(0, depth * 4) + message, color);
	this.set(PAST_STATE, @past_state);
}