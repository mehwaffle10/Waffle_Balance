/* 
	Menu to display balance changes
	Adapted from Update poll popup by Bunnie
*/

#define CLIENT_ONLY

const string link = "https://github.com/mehwaffle10/Waffle_Balance"; 
const Vec2f text_offset = Vec2f(10, 10);
bool hide = true;

class PopupGUI
{
	string text = "Welcome to Waffle Balance!\n\nThis menu can be reopened from the main menu\n\nCheck out the GitHub repo for a full list of balance changes";
	ClickButton@ website_button;
	string website_text = "GitHub Repo";
	Vec2f website_text_dim;
	ClickButton@ close_button;
	string close_text = "x"; // nobody will give a fuck
	Vec2f text_dim;
	Vec2f button_dim;

	Vec2f center;
	Vec2f tl;
	Vec2f tr;
	Vec2f bl;
	Vec2f br;

	PopupGUI()
	{
		GUI::SetFont("menu");
		GUI::GetTextDimensions(text, text_dim);
		text_dim += Vec2f(text_offset.x * 2, text_offset.y);

		GUI::SetFont("slightly bigger text 2");
		GUI::GetTextDimensions(website_text, website_text_dim);

		this.Update(null);
		@website_button = ClickButton(0, SColor(255, 0, 170, 0), website_text, "slightly bigger text 2");
		@close_button = ClickButton(1, SColor(255, 200, 0, 0), "X");
	}

	void RenderGUI()
	{
		GUI::SetFont("menu");
		GUI::DrawPane(tl, br, SColor(255, 200, 200, 200));

		GUI::DrawText(text, tl + text_offset, color_white);

		Vec2f button_tl = bl;

		website_button.RenderGUI(button_tl, Vec2f(text_dim.x, website_text_dim.y * 2));
		close_button.RenderGUI(tr - Vec2f(24, 0), Vec2f(24, 24));
	}

	void Update(CControls@ controls)
	{
		center = Vec2f(getScreenWidth() / 2, getScreenHeight() / 2);
		tl = center - Vec2f(text_dim.x / 2, text_dim.y / 2);
		tr = center + Vec2f(text_dim.x / 2, -text_dim.y / 2);
		bl = center - Vec2f(text_dim.x / 2, -text_dim.y / 2 - 20);
		br = center + Vec2f(text_dim.x / 2, text_dim.y / 2 + 20);

		Vec2f button_tl = bl;

		if (controls is null) return;

		website_button.Update(button_tl, Vec2f(text_dim.x, website_text_dim.y * 2), controls);
		close_button.Update(tr - Vec2f(24, 0), Vec2f(24, 24), controls);
	}
}

class ClickButton
{
	u8 id;
	bool hovered;
	SColor color;
	string text;
	string font;

	ClickButton(int _id, SColor _color, string _text, string _font="menu")
	{
		id = _id;
		color = _color;
		text = _text;
		font = _font;
		hovered = false;
	}

	bool isHovered(Vec2f origin, Vec2f size, Vec2f mousepos)
	{
		Vec2f tl = origin;
		Vec2f br = origin + size;

		return (mousepos.x > tl.x && mousepos.y > tl.y &&
		        mousepos.x < br.x && mousepos.y < br.y);
	}

	void RenderGUI(Vec2f origin, Vec2f size)
	{
		SColor new_color = color;

		if (hovered)
		{
			f32 tint_factor = 0.80;
			new_color = color.getInterpolated(color_white, tint_factor);
		}

		GUI::DrawPane(origin, origin+size, new_color);

		Vec2f text_pos = Vec2f(origin.x + size.x / 2, origin.y + size.y / 2);

		if (id == 1) text_pos -= Vec2f(2, 0); // as i said, nobody will give a fuck

		GUI::SetFont(font);
		GUI::DrawTextCentered(text, text_pos, color_white);
	}

	void Update(Vec2f origin, Vec2f size, CControls@ controls)
	{
		if (controls is null) return;

		Vec2f mousepos = controls.getMouseScreenPos();
		const bool mousePressed = controls.isKeyPressed(KEY_LBUTTON);
		const bool mouseJustReleased = controls.isKeyJustReleased(KEY_LBUTTON);

		if (hovered == false && this.isHovered(origin, size, mousepos) == true)
		{
			Sound::Play("select.ogg");
		}

		hovered = this.isHovered(origin, size, mousepos);

		if (hovered && mouseJustReleased)
		{
			hide = true;
			if (id == 0) OpenWebsite(link);
			Sound::Play("buttonclick.ogg");
		}
	}
}

void onInit(CRules@ this)
{
	hide = false;
	if (!GUI::isFontLoaded("slightly bigger text 2"))
	{
		string font = CFileMatcher("AveriaSerif-Bold.ttf").getFirst();
		GUI::LoadFont("slightly bigger text 2", font, 36, true);
	}

	PopupGUI@ GUI = PopupGUI();
	this.set("popupgui", @GUI);
}

void onTick(CRules@ this)
{
	if (getLocalPlayer() !is null)
	{
		CControls@ controls = getControls();

		if (!hide)
		{
			PopupGUI@ GUI;
			this.get("popupgui", @GUI);
			if (GUI is null) 
			{
				return;
			}

			GUI.Update(controls);
		}
	}
}

void onRender(CRules@ this)
{
	PopupGUI@ GUI;
	this.get("popupgui", @GUI);
	if (GUI is null) 
	{
		PopupGUI@ GUI = PopupGUI();
		this.set("popupgui", @GUI);
		return;
	}

	if (!hide)
	{
		GUI.RenderGUI();
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