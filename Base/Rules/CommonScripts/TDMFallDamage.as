
string cost_config_file = "tdm_vars.cfg";

void Reset(CRules@ this)
{
	if (this.exists("tdm_costs_config"))
		cost_config_file = this.get_string("tdm_costs_config");

	ConfigFile cfg = ConfigFile();
	cfg.loadFile(cost_config_file);

	this.set_f32("fall vel modifier", cfg.read_f32("fall_dmg_nerf", 1.3f));
}

void onInit(CRules@ this)
{
	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}