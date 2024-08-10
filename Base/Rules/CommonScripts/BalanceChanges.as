/* 
	Menu to display balance changes
	Adapted from Update poll popup by Bunnie
*/

#define CLIENT_ONLY

const string github_link = "https://github.com/mehwaffle10/Waffle_Balance";
const string discord_link = "https://discord.gg/3g5jTDF";
bool hide = true;
f32 scale = getScreenWidth() / 1920.0f;
Vec2f guidebook_size = Vec2f(599.0f, 418.0f);
Vec2f bookmark_size = Vec2f(52, 52);
u8 current_page = 1;

class Guidebook
{
	ClickButton@[] buttons;
    Vec2f top_left;

	Guidebook()
	{
        top_left = Vec2f(getScreenWidth(), getScreenHeight()) / 2.0f - guidebook_size * scale;
        for (u8 i = 1; i <= 7; i++)
        {
            u8 y_offset = i >= 6 ? 0 : i >= 4 ? 4 : 8;
            buttons.push_back(ClickButton(
                top_left + Vec2f((20.0f + bookmark_size.x) * i - 12.0f, y_offset) * scale,
                bookmark_size * scale,
                "GuidebookBookmarkHighlight.png",
                "",
                i,
                true)
            );
        }

        buttons.push_back(ClickButton(
            top_left + Vec2f(68.0f, 344.0f) * scale,
            Vec2f(130, 130) * scale,
            "GuidebookDWIHighlight.png",
            discord_link,
            1,
            false)
        );

        buttons.push_back(ClickButton(
            top_left + Vec2f(370.0f, 530.0f) * scale,
            Vec2f(178.0f, 186.0f) * scale,
            "GuidebookGitHubHighlight.png",
            github_link,
            1,
            false)
        );
	}

	void Render()
	{
		GUI::DrawIcon("Guidebook" + current_page + ".png", top_left, scale);
        for (u8 i = 0; i < buttons.length; i++)
        {
            buttons[i].Render();
        }
	}

	void Update(CControls@ controls)
	{
        for (u8 i = 0; i < buttons.length; i++)
        {
            buttons[i].Update(controls);
        }
	}
}

class ClickButton
{
	bool hovered;
    Vec2f top_left;
    Vec2f size;
	string hover_icon;
    string open_link;
    u8 page;
    bool bookmark;

	ClickButton(Vec2f _top_left, Vec2f _size, string _hover_icon, string _open_link, u8 _page, bool _bookmark)
	{
        hovered = false;
        top_left = _top_left;
        size = _size;
	    hover_icon = _hover_icon;
        open_link = _open_link;
        page = _page;
        bookmark = _bookmark;
	}

	bool isHovered(Vec2f mouse_pos)
	{
		Vec2f bottom_right = top_left + size;
		return (mouse_pos.x > top_left.x     && mouse_pos.y > top_left.y &&
		        mouse_pos.x < bottom_right.x && mouse_pos.y < bottom_right.y);
	}

    bool isCorrectPage()
    {
        return bookmark ? page != current_page : page == current_page;
    }

	void Render()
	{
		if (hovered && isCorrectPage())
		{
			GUI::DrawIcon(hover_icon, top_left, scale);
		}
	}

	void Update(CControls@ controls)
	{
        bool correct_page = isCorrectPage();
		Vec2f mouse_pos = controls.getMouseScreenPos();
		const bool mouse_just_released = controls.isKeyJustReleased(KEY_LBUTTON);

        bool now_hovered = this.isHovered(mouse_pos);
		if (!hovered && now_hovered && correct_page)
		{
			Sound::Play("select.ogg");
		}

		hovered = now_hovered;

		if (hovered && mouse_just_released && correct_page)
		{
			if (open_link != "")
            {
                OpenWebsite(open_link);
            }
            else if (bookmark)
            {
                current_page = page;
            }
			Sound::Play("buttonclick.ogg");
		}
	}
}

void onInit(CRules@ this)
{
	hide = false;
	Guidebook@ guidebook = Guidebook();
	this.set("guide book", @guidebook);
}

void onTick(CRules@ this)
{
	if (getLocalPlayer() !is null && !hide)
	{
		CControls@ controls = getControls();
        Guidebook@ guidebook;
        this.get("guide book", @guidebook);
        if (guidebook !is null && controls !is null) 
        {
            guidebook.Update(controls);
        }
	}
}

void onRender(CRules@ this)
{
	Guidebook@ guidebook;
	this.get("guide book", @guidebook);
	if (guidebook is null) 
	{
		Guidebook@ guidebook = Guidebook();
		this.set("guide book", @guidebook);
		return;
	}

	if (!hide)
	{
		guidebook.Render();
	}
}

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
	hide = true;
	Menu::addContextItem(menu, getTranslatedString("Balance Changes"), "BalanceChanges.as", "void OpenMenu()");
}

void OpenMenu()
{
	Menu::CloseAllMenus();
	hide = false;
}