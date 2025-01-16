#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#define PLUGIN_VERSION "1.0.1"

StringMap g_smStoredSurvivors;
StringMap g_ModelToName;
StringMap g_smBlocked;
int TEAM_SURVIVOR = 2;
int TEAM_INFECTED = 3;
iSurvivor g_survivors[MAXPLAYERS + 1];
float g_fTimeout[MAXPLAYERS + 1];

enum struct iSurvivor
{
	int weapons[5];
	int headshot;
	int ciKills;
	int siKills;
	int death;
	int incap;
	int client;
	int health;
	int buffer;
	bool created;
	
	//constructor
	void init(int client)
	{
		this.created = true;
		this.weapons = {-1, -1, -1, -1, -1};
		this.headshot = 0;
		this.ciKills = 0;
		this.siKills = 0;
		this.death = 0;
		this.incap = 0;
		this.client = client;
	}
	
	void get_weap_name(int slot, char[] buffer, int size)
	{
		char sModelWeapon[128];
		char sWeaponName[64];
		if (!IsNonClientEntityValid(this.weapons[slot]))
		{
			FormatEx(buffer, size, "Trống");
			return;
		}
		GetEntPropString(this.weapons[slot], Prop_Data, "m_ModelName", sModelWeapon, sizeof sModelWeapon);
		StringToLowerCase(sModelWeapon);
		// PrintToChatAll("%N: weapon[%i]: %s", client, slot, sModelWeapon);
		g_ModelToName.GetString(sModelWeapon, sWeaponName, sizeof sWeaponName);
		FormatEx(buffer, size, sWeaponName);	
	}
	
	void load_status()
	{
		//Update lại thông tin weapon
		if (!IsClientValid(this.client, TEAM_SURVIVOR)) return;
		for (int i = 0; i < 5; i++)
		{
			int iWeap = GetPlayerWeaponSlot(this.client, i);
			if (!IsNonClientEntityValid(iWeap))
			{
				this.weapons[i] = -1;
				continue;
			}
			this.weapons[i] = iWeap;
		}
		
		this.health = GetClientRealHealth(this.client);
		this.buffer = GetClientTempHealth(this.client);
		this.incap = GetClientReviveCount(this.client);
	}
	
	bool is_using_weaponSlot(int slot)
	{
		this.load_status();
		if (!IsClientValid(this.client, TEAM_SURVIVOR)) return false;
		int active = GetEntPropEnt(this.client, Prop_Data, "m_hActiveWeapon");
		return active == this.weapons[slot];
	}
	
	void print_info()
	{
		this.load_status();
		static char buffer[32];
		//thông tin vũ khí
		for (int i = 0; i < 5; i++)
		{
			this.get_weap_name(i, buffer, sizeof buffer);
			PrintToChat(this.client, "%s", buffer);
		}
		//thông tin khác
		PrintToChat(this.client, "created? %b", this.created);
		PrintToChat(this.client, "headshot: %i", this.headshot);
		PrintToChat(this.client, "ciKills: %i", this.ciKills);
		PrintToChat(this.client, "siKills: %i", this.siKills);
		PrintToChat(this.client, "death: %i", this.death);
		PrintToChat(this.client, "incap: %i", this.incap);
		PrintToChat(this.client, "client: %i", this.client);
	}
}

public Plugin myinfo = 
{
	name 			= "[L4D2] View Player Stat",
	author 			= "strikeraot",
	description 	= "Allows survivors to view others stats by shoving them",
	version 		=  PLUGIN_VERSION,
	url 			= ""
}

void createStringMap()
{
	g_ModelToName = new StringMap();
	g_smStoredSurvivors = new StringMap();
	g_smBlocked = new StringMap();
	
	// Case-sensitive
	g_ModelToName.SetString("models/v_models/v_medkit.mdl", "First aid kit");
	g_ModelToName.SetString("models/v_models/v_defibrillator.mdl", "Defibrillator");
	g_ModelToName.SetString("models/v_models/v_painpills.mdl", "Pain pills");
	g_ModelToName.SetString("models/v_models/v_adrenaline.mdl", "Adrenaline");
	g_ModelToName.SetString("models/v_models/v_bile_flask.mdl", "Bile Bomb");
	g_ModelToName.SetString("models/v_models/v_molotov.mdl", "Molotov");
	g_ModelToName.SetString("models/v_models/v_pipebomb.mdl", "Pipe bomb");
	g_ModelToName.SetString("models/v_models/v_laser_sights.mdl", "Laser Sight");
	g_ModelToName.SetString("models/v_models/v_incendiary_ammopack.mdl", "Incendiary UpgradePack");
	g_ModelToName.SetString("models/v_models/v_explosive_ammopack.mdl", "Explosive UpgradePack");
	g_ModelToName.SetString("models/props/terror/ammo_stack.mdl", "Ammo");
	g_ModelToName.SetString("models/props_unique/spawn_apartment/coffeeammo.mdl", "Ammo");
	g_ModelToName.SetString("models/props/de_prodigy/ammo_can_02.mdl", "Ammo");
	g_ModelToName.SetString("models/v_models/v_pistola.mdl", "Pistol");
	g_ModelToName.SetString("models/v_models/v_dual_pistola.mdl", "Dual Pistol");
	g_ModelToName.SetString("models/v_models/v_pistol_a.mdl", "Pistol");
	g_ModelToName.SetString("models/v_models/v_desert_eagle.mdl", "Magnum");
	g_ModelToName.SetString("models/v_models/v_pumpshotgun.mdl", "Shotgun Chrome");
	g_ModelToName.SetString("models/v_models/v_shotgun_chrome.mdl", "Shotgun Chrome");
	g_ModelToName.SetString("models/v_models/v_smg.mdl", "Uzi Smg");
	g_ModelToName.SetString("models/v_models/v_silenced_smg.mdl", "Silenced Smg");
	g_ModelToName.SetString("models/v_models/v_smg_mp5.mdl", "MP5 Smg");
	g_ModelToName.SetString("models/v_models/v_rifle.mdl", "Rifle");
	g_ModelToName.SetString("models/v_models/v_rifle_sg552.mdl", "SG552");
	g_ModelToName.SetString("models/v_models/v_rifle_ak47.mdl", "AK47");
	g_ModelToName.SetString("models/v_models/v_desert_rifle.mdl", "Desert Rifle");
	g_ModelToName.SetString("models/v_models/v_shotgun_spas.mdl", "Shotgun Spas");
	g_ModelToName.SetString("models/v_models/v_autoshotgun.mdl", "Auto Shotgun");
	g_ModelToName.SetString("models/v_models/v_huntingrifle.mdl", "Hunting Rifle");
	g_ModelToName.SetString("models/v_models/v_sniper_military.mdl", "Military Sniper");
	g_ModelToName.SetString("models/v_models/v_snip_scout.mdl", "Scout");
	g_ModelToName.SetString("models/v_models/v_snip_awp.mdl", "AWP");
	g_ModelToName.SetString("models/v_models/v_grenade_launcher.mdl", "Grenade Launcher");
	g_ModelToName.SetString("models/v_models/v_m60.mdl", "M60");
	g_ModelToName.SetString("models/v_models/v_knife_t.mdl", "Knife");
	g_ModelToName.SetString("models/props/terror/exploding_ammo.mdl", "Explosive Ammo");
	g_ModelToName.SetString("models/props/terror/incendiary_ammo.mdl", "Incendiary Ammo");
	
	
	g_ModelToName.SetString("models/weapons/melee/v_chainsaw.mdl", "Chainsaw");
	g_ModelToName.SetString("models/weapons/melee/v_bat.mdl", "Baseball Bat");
	g_ModelToName.SetString("models/weapons/melee/v_cricket_bat.mdl", "Cricket Bat");
	g_ModelToName.SetString("models/weapons/melee/v_crowbar.mdl", "Crowbar");
	g_ModelToName.SetString("models/weapons/melee/v_electric_guitar.mdl", "Electric Guitar");
	g_ModelToName.SetString("models/weapons/melee/v_fireaxe.mdl", "Fireaxe");
	g_ModelToName.SetString("models/weapons/melee/v_frying_pan.mdl", "Frying Pan");
	g_ModelToName.SetString("models/weapons/melee/v_katana.mdl", "Katana");
	g_ModelToName.SetString("models/weapons/melee/v_machete.mdl", "Machete");
	g_ModelToName.SetString("models/weapons/melee/v_tonfa.mdl", "Nightstick");
	g_ModelToName.SetString("models/weapons/melee/v_golfclub.mdl", "Golf Club");
	g_ModelToName.SetString("models/weapons/melee/v_pitchfork.mdl", "Pitckfork");
	g_ModelToName.SetString("models/weapons/melee/v_shovel.mdl", "Shovel");
	g_ModelToName.SetString("models/v_models/v_bile_flask.mdl", "Bile jar");	
	
	g_smBlocked.SetValue("weapon_adrenaline", true);
	g_smBlocked.SetValue("weapon_pain_pills", true);
	g_smBlocked.SetValue("weapon_first_aid_kit", true);
	g_smBlocked.SetValue("weapon_molotov", true);
	g_smBlocked.SetValue("weapon_pipe_bomb", true);
	g_smBlocked.SetValue("weapon_vomitjar", true);
	g_smBlocked.SetValue("weapon_upgradepack_explosive", true);
	g_smBlocked.SetValue("weapon_upgradepack_incendiary", true);
	g_smBlocked.SetValue("weapon_defibrillator", true);
}

public void OnPluginStart()
{
	createStringMap();
	// AddCommandListener(Vocalize_Listener, "vocalize"); //Không dùng nữa
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	HookEvent("witch_killed", Event_WitchKilled, EventHookMode_Post);
	HookEvent("player_shoved", Event_Shoved);
	HookEvent("weapon_drop", Event_WeaponDrop);
	char auth[20];
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsClientValid(i, TEAM_SURVIVOR)) 
		{
			GetClientAuthId(i, AuthId_Steam2, auth, sizeof(auth));
			OnClientAuthorized(i, auth);
		}
	}
}

public void OnClientAuthorized(int client, const char[] auth) 
{
	if (IsFakeClient(client) && IsClientValid(client, TEAM_SURVIVOR))
	{
		g_survivors[client].init(client);
		return;
	}
	iSurvivor sur;
//	Load thông tin survivor đã lưu
	if (g_smStoredSurvivors.GetArray(auth, sur, sizeof(sur))) 
	{
		g_survivors[client] = sur;
	}
	else
	{
		g_survivors[client].init(client);
	}
}

public void OnClientDisconnect(int client)
{
	if (IsFakeClient(client)) return;
	
//	Save lại thông tin survivor khi họ disconnected:
	char auth[32];
	GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));
	g_smStoredSurvivors.SetArray(auth, g_survivors[client], true);
}

/* public void OnClientPutInServer(int client)
{
	int userid = GetClientUserId(client);
	//client với userid này đã tồn tại
	if (g_survivors[userid].created) return; 
	
	//client mới
	g_survivors[userid].init(userid);
} */

public void Event_Shoved (Event event, char[] name, bool bDontBroadcast)
{
	int userid = event.GetInt("userid");
	int attacker = event.GetInt("attacker");
	DataPack hPack = new DataPack();
	hPack.WriteCell(userid);
	hPack.WriteCell(attacker);
	static char sTemp[32];
	int weapon = GetEntPropEnt(GetClientOfUserId(attacker), Prop_Send, "m_hActiveWeapon");
	if( weapon != -1 )
	{
		GetEdictClassname(weapon, sTemp, sizeof(sTemp));
		int aNull;
		if( g_smBlocked.GetValue(sTemp, aNull) )
		{
			return;
		}
	}
	RequestFrame(OnFrameShove, hPack); 
}

void Event_WeaponDrop(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if( client )
	{
		static char sTemp[8];
		event.GetString("item", sTemp, sizeof(sTemp));
		if( strncmp(sTemp, "pain", 4) == 0 || strncmp(sTemp, "adre", 4) == 0 )
		{
			g_fTimeout[client] = GetGameTime() + 0.5;
		}
	}
}

//Ý tưởng ban đầu là dùng 'z' vocalize để xem thông tin tin survivor trước khi đổi sang shove, có thể uncomment block code dưới này để sử dụng
// public Action Vocalize_Listener(int client, const char[] command, int argc)
// {
	// if (IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == 2)
	// {
		// static char sCmdString[32];
		// if (GetCmdArgString(sCmdString, sizeof(sCmdString)) <= 1)return Plugin_Continue;
		// PrintToChatAll("%s", sCmdString);
		// if (strncmp(sCmdString, "smartlook #", 11, false) == 0)
		// {
			// int aimed = GetClientAimTarget(client, false);
			// if (!IsValidEntity(aimed))return Plugin_Continue;
			
			// if (IsValidEntity(aimed) && 1 <= aimed <= MaxClients)
			// {
				// if (IsClientInGame(aimed) && IsPlayerAlive(aimed))
				// Lỗi trước đó: entityID không phải là userid, userid chỉ dành riêng cho player cho nên khi truyền entityID vào hàm GetClientOfUserId sẽ khiến output bị nhầm
				// createPanelPlayer(client, GetClientOfUserId(aimed));
				// createPanelPlayer(client, aimed);
			// }
		// }
	// }
	// return Plugin_Continue;
// }

public Action Event_PlayerDeath(Event event, char[] name, bool bDontBroadcast) {
	bool isHeadshot = event.GetBool("headshot");
	int attacker = event.GetInt("attacker");
	int userid = event.GetInt("userid");
	
	if (IsClientValid(GetClientOfUserId(userid), TEAM_SURVIVOR)) //player death là một client survivor
	{
		if (!g_survivors[GetClientOfUserId(userid)].created) return Plugin_Continue;
		g_survivors[GetClientOfUserId(userid)].death++;
		return Plugin_Continue;
	}
	else if (IsClientValid(GetClientOfUserId(userid), TEAM_INFECTED)) //player death là một client Special Infected
	{
		// PrintToChatAll("victim là một SI!");
		if (!IsClientValid(GetClientOfUserId(attacker), TEAM_SURVIVOR))
		{
			// PrintToChatAll("attacker không phải là survivor");
			return Plugin_Continue; //Không handle case này vì client attacker không tồn tại hoặc không phải là player
		}
		if (!g_survivors[attacker].created)
		{
			// PrintToChatAll("Không thấy attacker với userid này %i", event.GetInt("attacker"));
			return Plugin_Continue;
		}
		g_survivors[attacker].siKills++;
		// PrintToChatAll("update thông tin cho survivor userid %i thành công! Số kill SI: %i", g_survivors[attacker].userid, g_survivors[attacker].siKills);
	}
	else //player death không phải là một client
	{
		static char vName[16];
		//kiểm tra xem entity này có phải là infected hay không? (Witch cũng là một entity chứ ko đc xem là client)
		event.GetString("victimname", vName, sizeof vName);
		StringToLowerCase(vName);
		if (strcmp("infected", vName) == 0)
		{
			// PrintToChatAll("entity là infected");
			if (!IsClientValid(GetClientOfUserId(attacker), TEAM_SURVIVOR)) return Plugin_Continue;
			if (!g_survivors[attacker].created) return Plugin_Continue;
			g_survivors[attacker].ciKills++;
		}
	}
	if (isHeadshot) g_survivors[attacker].headshot++;
	return Plugin_Continue;
}

public Action Event_WitchKilled(Event event, char[] name, bool bDontBroadcast) {
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	if (!IsClientValid(client, TEAM_SURVIVOR)) return Plugin_Continue;
	g_survivors[userid].siKills++;
	
	return Plugin_Continue;
}

void OnFrameShove(DataPack hPack) {
//	reset coord for reading
	hPack.Reset();

	int client = hPack.ReadCell();
	int userid = hPack.ReadCell();
	
	delete hPack;
	
	client = GetClientOfUserId(client);
	int attacker = GetClientOfUserId(userid);
	
		// Timeout
	if( g_fTimeout[attacker] > GetGameTime() )
		return;

	g_fTimeout[attacker] = 0.0;
	
	if (IsFakeClient(attacker)) return;
	if (IsClientValid(client, TEAM_SURVIVOR) && IsClientValid(attacker, TEAM_SURVIVOR))
	{
		createPanelPlayer(attacker, client);
	}
}

void createPanelPlayer(int client, int target)
{
	g_fTimeout[client] = GetGameTime() + 3;
	Panel panel = new Panel();
	char weaponName[64];
	char content[255];
	//client target là bot
/* 	if (IsFakeClient(target))
	{
		//Kiểm tra xem bot có đang idle hay không
		if (HasIdlePlayer(target))
		{
			//Nếu có thì cần replace target hiện tại là survivor đang idle bot này
			for (int i = 1; i < MAXPLAYERS; i++) 
			{
				if (i == GetEntProp(target, Prop_Send, "m_humanSpectatorUserID")) userid = i;
			}
		}
	} */
	if (!g_survivors[target].created) return;
	//update lại thông tin survivor target
	g_survivors[target].load_status();
	Format(content, sizeof content, "Thông tin survivor %N:", target);
	panel.DrawItem(content, ITEMDRAW_RAWLINE);
	panel.DrawItem(" ", ITEMDRAW_RAWLINE);
	panel.DrawItem("Slot 1");
	g_survivors[target].get_weap_name(0, weaponName, sizeof weaponName);
	Format(content, sizeof content, "%s", weaponName);
	panel.DrawItem(content, ITEMDRAW_RAWLINE);

	panel.DrawItem("Slot 2");
	g_survivors[target].get_weap_name(1, weaponName, sizeof weaponName);
	Format(content, sizeof content, "%s", weaponName);
	panel.DrawItem(content, ITEMDRAW_RAWLINE);

	panel.DrawItem("Slot 3");
	g_survivors[target].get_weap_name(2, weaponName, sizeof weaponName);
	Format(content, sizeof content, "%s", weaponName);
	panel.DrawItem(content, ITEMDRAW_RAWLINE);

	panel.DrawItem("Slot 4");
	g_survivors[target].get_weap_name(3, weaponName, sizeof weaponName);
	Format(content, sizeof content, "%s", weaponName);
	panel.DrawItem(content, ITEMDRAW_RAWLINE);

	panel.DrawItem("Slot 5");
	g_survivors[target].get_weap_name(4, weaponName, sizeof weaponName);
	Format(content, sizeof content, "%s", weaponName);
	panel.DrawItem(content, ITEMDRAW_RAWLINE);
	panel.DrawItem(" ", ITEMDRAW_RAWLINE);
	panel.DrawItem("Status");
	int health = g_survivors[target].health;
	int health_buffer = g_survivors[target].buffer;
	int revived = g_survivors[target].incap;
	float hsPercentage = 0.0;
	int roundedHSPct = 0;
	
	if (g_survivors[target].headshot > 0) 
	{
		hsPercentage = (float(g_survivors[target].headshot) / float(g_survivors[target].ciKills)) * 100;
		roundedHSPct = RoundFloat(hsPercentage);
	}
	
	Format(content, sizeof content, "HP: %i[+%i] / Incap: %i lần / Chết: %i lần / CI: %i / SI: %i / HS: %i (Tỉ lệ: %i%%)", health, health_buffer, 
		revived, g_survivors[target].death, g_survivors[target].ciKills, g_survivors[target].siKills, g_survivors[target].headshot, roundedHSPct);
	panel.DrawItem(content, ITEMDRAW_RAWLINE);
	//panel.DrawItem(" ", ITEMDRAW_RAWLINE);
	panel.Send(client, HandleShowTeamsPanel, 3);
}

void StringToLowerCase(char[] input)
{
    for (int i = 0; i < strlen(input); i++)
    {
        input[i] = CharToLower(input[i]);
    }
}

int HandleShowTeamsPanel(Menu menu, MenuAction action, int client, int selectedIndex)
{
	switch (action)
	{
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		case MenuAction_Cancel:
		{
			CloseHandle(menu);
		}
	}
	delete menu;
	return 0;
}

int GetClientReviveCount(int client)
{
	return GetEntProp(client, Prop_Send, "m_currentReviveCount");
}

int GetClientRealHealth(int client)
{
	return IsClientIncapped(client) ? 0 : GetClientHealth(client);
}

int GetClientTempHealth(int client)
{
	static ConVar painPillsDecayCvar;
	if (painPillsDecayCvar == null)
	{
		painPillsDecayCvar = FindConVar("pain_pills_decay_rate");
		if (painPillsDecayCvar == null)
		{
			return -1;
		}
	}
	
	int tempHealth = RoundToCeil(GetEntPropFloat(client, Prop_Send, "m_healthBuffer") - ((GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime")) * painPillsDecayCvar.FloatValue)) - 1;
	return tempHealth < 0 ? 0 : tempHealth;
}

bool HasIdlePlayer(int bot)
{
	if(HasEntProp(bot, Prop_Send, "m_humanSpectatorUserID"))
	{
		if(GetEntProp(bot, Prop_Send, "m_humanSpectatorUserID") > 0)
		{
			return true;
		}
	}
	
	return false;
}

bool IsClientIncapped(int client)
{
	return GetEntProp(client, Prop_Send, "m_isIncapacitated", 1) > 0 && GetEntProp(client, Prop_Send, "m_isHangingFromLedge") != 1;
}

bool IsNonClientEntityValid(int entity)
{
	return IsValidEntity(entity) && entity > MaxClients && !(entity == INVALID_ENT_REFERENCE);
}

bool IsClientValid(int client, int team)
{
	switch (team)
	{
		case 2:
		{
			return 0 < client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == team;
		}
		case 3:
		{
			if (0 < client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == team)
			{
				int zClass = GetEntProp(client, Prop_Send, "m_zombieClass");
				// PrintToChatAll("kiểm tra client có phải SI hay không: %b ", 1 <= zClass <= 8);
				return 1 <= zClass <= 8;
			}
		}
	}
	return false;
}

// ====================================================================================================
//					FORWARDS - From "Gear Transfer" plugin
// ====================================================================================================
public void GearTransfer_OnWeaponGive(int client, int target, int item)
{
	g_fTimeout[client] = GetGameTime() + 0.5;
}

public void GearTransfer_OnWeaponGrab(int client, int target, int item)
{
	g_fTimeout[client] = GetGameTime() + 0.5;
}

public void GearTransfer_OnWeaponSwap(int client, int target, int itemGiven, int itemTaken)
{
	g_fTimeout[client] = GetGameTime() + 0.5;
}

// bool IsClientBlackAndWhite(int client) {
	// return view_as<bool>(GetEntProp(client, Prop_Send, "m_bIsOnThirdStrike"));
// }

// bool IsClientIdle(int client)
// {
	// if(GetClientTeam(client) != 2)
		// return false;
	
	// for(int i = 1; i <= MaxClients; i++)
	// {
		// if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
		// {
			// if(HasEntProp(i, Prop_Send, "m_humanSpectatorUserID"))
			// {
				// if(GetClientOfUserId(GetEntProp(i, Prop_Send, "m_humanSpectatorUserID")) == client)
						// return true;
			// }
		// }
	// }
	// return false;
// }