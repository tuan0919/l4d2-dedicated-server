#define PLUGIN_VERSION	"1.2.1"
#define PLUGIN_NAME		"l4d_announce_healer"
#define PLUGIN_PHRASES	"l4d_announce_healer.phrases"

/**
 *	v1.0 just releases; 21-2-22
 *	v1.0.1 remove unused code, fix isDying not works; 22-2-22
 *	v1.0.2 
 *		fix issue 'wrong to use GameTime cause cooldown not work on next round'
 *		use OnClientPutInServer to solve client bind multiple listener; 23-2-22
 *	v1.1 add feature: announce adrenaline duration; 28-2-22;
 *	v1.1.1 fix some format error cause multiple announce; 28-2-22
 *	v1.1.2 make announce delay show compatible for thirdparty plugin health changes; 25-April-22
 *	v1.1.3 fix wrong adrenaline duration, thanks to Silvers; 17-October-2022
 *	v1.1.4 add support for Late Load, add support for plugin '[L4D & L4D2] Heartbeat'; 14-November-2022
 *	v1.2 (8-February-2023)
 *		- add support for L4D1
 *		- change dying text to actually third striked
 *		- add ConVar *_aim to control show message when aim to survivor
 *		- allow show survivor health for special infected when aim
 *		- allow special infected health when aim
 *	v1.2.1 (4-June-2023)
 *		- fix andrenaline feature not working by previous change
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define ANNOUNCE_CENTER	(1 << 0)
#define ANNOUNCE_CHAT	(1 << 1)
#define ANNOUNCE_HINT	(1 << 2)

#define SOUND_READY		"buttons/bell1.wav"
#define SOUND_REJECT	"buttons/button11.wav"


int g_iChapterCIKills[MAXPLAYERS + 1] =  { 0, ... };
int g_iChapterSIKills[MAXPLAYERS + 1] =  { 0, ... };
int g_iChapterHSKills[MAXPLAYERS + 1] =  { 0, ... };

static const char medicine_classes[][] =  {
	"pain_pills", 
	"adrenaline", 
	"defibrillator", 
	"first_aid_kit"
};

enum {
	PILLS = (1 << 0), 
	ADRENALINE = (1 << 1)
}

enum {
	WEAPONID_PILLS = 15, 
	WEAPONID_ADRENALINE = 23
}

enum {
	PLAY_READY = (1 << 0), 
	PLAY_FULLED = (1 << 1)
}

enum {
	PICKUP = (1 << 0), 
	TRANSFERRING = (1 << 1), 
	HEALING = (1 << 2), 
	DEFIBRILLATING = (1 << 3), 
	REVIVED = (1 << 4), 
	PILLS_USED = (1 << 5), 
	ADRENALINE_USED = (1 << 6), 
	MEDIC_SWITCHED = (1 << 7)
}

enum {
	ALLOW_SI_RECEIVE = (1 << 0), 
	ALLOW_GOT_SI = (1 << 1), 
}

/**
 * @brief Gets the revive count of a client.
 * @remarks Because this plugin overwrites "m_currentReviveCount" netprop in L4D1, this native allows you to get the actual revive count for clients.
 *
 * @param client          Client index to affect.
 *
 * @return                Number or revives
 */
native int Heartbeat_GetRevives(int client);

bool bIsHeartbeatExists, bLateLoad, hasTranslations, bIsLeft4Dead2;

public void OnAllPluginsLoaded() {
	
	if (LibraryExists("l4d_heartbeat") == true) {
		bIsHeartbeatExists = true;
	}
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	
	if (late)
		bLateLoad = true;
	bIsLeft4Dead2 = GetEngineVersion() == Engine_Left4Dead2;
	
	MarkNativeAsOptional("Heartbeat_GetRevives");
	return APLRes_Success;
}


public void OnLibraryAdded(const char[] name) {
	if (strcmp(name, "l4d_heartbeat") == 0) {
		bIsHeartbeatExists = true;
	}
}

public void OnLibraryRemoved(const char[] name) {
	if (strcmp(name, "l4d_heartbeat") == 0) {
		bIsHeartbeatExists = false;
	}
}


ConVar Enabled;
ConVar Announce_types; int announce_types;
ConVar Announce_events; int announce_events;
ConVar Announce_also; int announce_also;
ConVar Announce_sounds; int announce_sounds;
ConVar Announce_cooldown; float announce_cooldown;
ConVar Announce_medicines; int announce_medicines;
ConVar Announce_aim; int announce_aim;
ConVar Announce_SI; int announce_SI;
StringMap g_mapWeap;

public Plugin myinfo =  {
	name = "[L4D & L4D2] Announce Health", 
	author = "NoroHime", 
	description = "Info Announce to healer & defiber & reviver & AIMer", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/NoroHime/"
}

public void createStringMap()
{
	g_mapWeap = new StringMap();
	g_mapWeap.SetString("weapon_pistol", "Pistol");
	g_mapWeap.SetString("weapon_smg", "SMG");
	g_mapWeap.SetString("weapon_shotgun_chrome", "Chrome Shotgun");
	g_mapWeap.SetString("weapon_sniper_military", "Military Sniper");
	g_mapWeap.SetString("weapon_shotgun_spas", "SPAS Shotgun");
	g_mapWeap.SetString("weapon_grenade_launcher", "Grenade Launcher");
	g_mapWeap.SetString("weapon_rifle_ak47", "Súng trường AK47");
	g_mapWeap.SetString("weapon_smg_mp5", "SMG MP5");
	g_mapWeap.SetString("weapon_rifle_sg552", "Súng trường SG552");
	g_mapWeap.SetString("weapon_sniper_awp", "AWP Sniper");
	g_mapWeap.SetString("weapon_sniper_scout", "Súng ngắm Scout");
	g_mapWeap.SetString("weapon_rifle_m60", "Rifle M60");
	g_mapWeap.SetString("weapon_machinegun", "Machine Gun");
	g_mapWeap.SetString("weapon_pistol_magnum", "Súng lục Magnum");
	g_mapWeap.SetString("weapon_hunting_rifle", "Súng săn");
	g_mapWeap.SetString("weapon_rifle", "Súng trường M16");
	g_mapWeap.SetString("weapon_autoshotgun", "Auto Shotgun");
	g_mapWeap.SetString("weapon_pumpshotgun", "Pump Shotgun");
	g_mapWeap.SetString("weapon_smg_silenced", "Silenced SMG");
	g_mapWeap.SetString("weapon_rifle_desert", "Súng trường ScarL");
	g_mapWeap.SetString("weapon_pipe_bomb", "Pipe bomb");
	g_mapWeap.SetString("weapon_dual_pistols", "Dual Pistol");
	g_mapWeap.SetString("weapon_chainsaw", "Máy cưa");
	
	g_mapWeap.SetString("weapon_pipe_bomb", "Pipe Bomb");
	g_mapWeap.SetString("weapon_molotov", "Molotov");
	g_mapWeap.SetString("weapon_vomitjar", "Bile jar");
	
	g_mapWeap.SetString("weapon_first_aid_kit", "First Aid Kit");
	g_mapWeap.SetString("weapon_weapon_defibrillator", "Defibrillator");
	g_mapWeap.SetString("weapon_adrenaline", "Adrenaline");
	g_mapWeap.SetString("weapon_pain_pills", "Pain Pills");
	g_mapWeap.SetString("weapon_upgradepack_incendiary", "Hộp đạn lửa");
	g_mapWeap.SetString("weapon_upgradepack_explosive", "Hộp đạn nổ");
	
	g_mapWeap.SetString("fireaxe", "Rìu");
	g_mapWeap.SetString("baseball_bat", "Gậy bóng chày");
	g_mapWeap.SetString("cricket_bat", "Cricket Bat");
	g_mapWeap.SetString("crowbar", "Xà beng");
	g_mapWeap.SetString("frying_pan", "Chảo");
	g_mapWeap.SetString("golfclub", "Gậy golf");
	g_mapWeap.SetString("electric_guitar", "Đàn Guitar");
	g_mapWeap.SetString("katana", "Kiếm nhật");
	g_mapWeap.SetString("machete", "Dao rựa");
	g_mapWeap.SetString("tonfa", "Tonfa");
	g_mapWeap.SetString("knife", "Dao");
	g_mapWeap.SetString("pitchfork", "Chĩa ba");
	g_mapWeap.SetString("shovel", "Xẻng");
}

public void OnPluginStart() {
	
	CreateConVar("announce_healer_version", PLUGIN_VERSION, "Version of 'Announce Health for Healer'", FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_REPLICATED | FCVAR_NOTIFY);
	Enabled = CreateConVar("announce_healer_enabled", "1", "Enabled 'Announce Health for Healer'", FCVAR_NOTIFY);
	Announce_types = CreateConVar("announce_healer_types", "4", "announce positions 1=center 2=chat 4=hint 7=all. add together you want", FCVAR_NOTIFY);
	Announce_events = CreateConVar("announce_healer_events", "0", "which event about medicines wanna anounce 1=pickup medicines 2=transfer\n4=healing 8=defib 16=revive 32=used pill 64=use adrenaline 128=switch to medicines 255=all. add together you want", FCVAR_NOTIFY);
	Announce_also = CreateConVar("announce_healer_also", "0", "which event also announce to be-heal player 2=transfer 4=healing 8=defib 16=revive. 28=all listed. add together you want", FCVAR_NOTIFY);
	Announce_sounds = CreateConVar("announce_healer_sounds", "2", "which sound wanna play 1=allowed 2=reject 3=all", FCVAR_NOTIFY);
	Announce_cooldown = CreateConVar("announce_healer_cooldown", "0", "cooldown time for announce player info 0:disable", FCVAR_NOTIFY);
	Announce_medicines = CreateConVar("announce_healer_medicines", "11", "which medicine be switched/received/pickup you want to announce 1=pill 2=adrenaline 4=defib 8=first aid 15=all", FCVAR_NOTIFY);
	Announce_aim = CreateConVar("announce_healer_aim", "1", "when aim to survivor then show the message to AIMer, 30=detect frames, 0=disabled", FCVAR_NOTIFY);
	Announce_SI = CreateConVar("announce_healer_si", "1", "1=special infected can received health message 2=can got SI health message 3=both", FCVAR_NOTIFY);
	
	AutoExecConfig(true, PLUGIN_NAME);
	AddCommandListener(Vocalize_Listener, "vocalize");
	
	Enabled.AddChangeHook(OnConVarChanged);
	Announce_types.AddChangeHook(OnConVarChanged);
	Announce_events.AddChangeHook(OnConVarChanged);
	Announce_also.AddChangeHook(OnConVarChanged);
	Announce_sounds.AddChangeHook(OnConVarChanged);
	Announce_cooldown.AddChangeHook(OnConVarChanged);
	Announce_medicines.AddChangeHook(OnConVarChanged);
	Announce_aim.AddChangeHook(OnConVarChanged);
	Announce_SI.AddChangeHook(OnConVarChanged);
	
	PrecacheSound(SOUND_REJECT, false);
	
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, PLATFORM_MAX_PATH, "translations/%s.txt", PLUGIN_PHRASES);
	hasTranslations = FileExists(path);
	
	if (hasTranslations)
		LoadTranslations(PLUGIN_PHRASES);
	
	ApplyCvars();
	createStringMap();
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	HookEvent("round_start", Event_RoundStart, EventHookMode_Post);
	HookEvent("witch_killed", Event_WitchKilled, EventHookMode_Post);
	
	// Late Load
	if (bLateLoad)
		for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i))
		OnClientPutInServer(i);
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	ApplyCvars();
}

public void OnConfigsExecuted() {
	ApplyCvars();
}

public void ApplyCvars() {
	
	static bool hooked = false;
	bool enabled = Enabled.BoolValue;
	
	if (enabled && !hooked) {
		
		if (bIsLeft4Dead2) {
			
			HookEvent("defibrillator_used_fail", OnDefibFail, EventHookMode_Post);
			HookEvent("adrenaline_used", OnArenalineUsed, EventHookMode_Post);
		}
		
		HookEvent("heal_begin", OnHealBegin, EventHookMode_Post);
		HookEvent("weapon_given", OnWeaponGiven, EventHookMode_Post);
		HookEvent("pills_used", OnPillsUsed, EventHookMode_Post);
		HookEvent("pills_used_fail", OnPillsUsedFail, EventHookMode_Post);
		HookEvent("revive_success", OnReviveSuccess, EventHookMode_Post);
		HookEvent("item_pickup", OnItemPickup, EventHookMode_Post);
		
		hooked = true;
		
	} else if (!enabled && hooked) {
		
		if (bIsLeft4Dead2) {
			UnhookEvent("adrenaline_used", OnArenalineUsed, EventHookMode_Post);
			UnhookEvent("defibrillator_used_fail", OnDefibFail, EventHookMode_Post);
		}
		
		UnhookEvent("pills_used_fail", OnPillsUsedFail, EventHookMode_Post);
		UnhookEvent("heal_begin", OnHealBegin, EventHookMode_Post);
		UnhookEvent("weapon_given", OnWeaponGiven, EventHookMode_Post);
		UnhookEvent("pills_used", OnPillsUsed, EventHookMode_Post);
		UnhookEvent("revive_success", OnReviveSuccess, EventHookMode_Post);
		UnhookEvent("item_pickup", OnItemPickup, EventHookMode_Post);
		
		hooked = false;
	}
	
	announce_types = Announce_types.IntValue;
	announce_events = Announce_events.IntValue;
	announce_also = Announce_also.IntValue;
	announce_sounds = Announce_sounds.IntValue;
	announce_cooldown = Announce_cooldown.FloatValue;
	announce_medicines = Announce_medicines.IntValue;
	announce_aim = Announce_aim.IntValue;
	announce_SI = Announce_SI.IntValue;
}

public Action Vocalize_Listener(int client, const char[] command, int argc)
{
	if (IsHumanSurvivor(client))
	{
		static int aim_last[MAXPLAYERS + 1];
		static char sCmdString[32];
		if (GetCmdArgString(sCmdString, sizeof(sCmdString)) <= 1)return Plugin_Continue;
		//PrintToChatAll("%s", sCmdString);
		if (strncmp(sCmdString, "smartlook #", 11, false) == 0)
		{
			int aimed = GetClientAimTarget(client, false);
			if (!IsValidEntity(aimed))return Plugin_Continue;
			//PrintToChatAll("target is: %i", aimed); 
			if (aimed != INVALID_ENT_REFERENCE && 1 <= aimed <= MaxClients && IsClientInGame(aimed) && IsPlayerAlive(aimed))
			{
				if (IsClientHanging(aimed) || IsClientIncapped(aimed))return Plugin_Continue;
				createPanelPlayer(client, aimed);
				//AnnounceHealth(aimed, client);
				//PrintToChatAll("OK");
				//getPlayerSlot(client);
			}
			//aim_last[client] = aimed;
		}
	}
	return Plugin_Continue;
}

void getPlayerSlot(int slot, int client, char[] buffer)
{
	if (client == INVALID_ENT_REFERENCE || !IsPlayerAlive(client))return;
	char szClassname[36];
	int entity = -1;
	if ((entity = GetPlayerWeaponSlot(client, slot)) <= MaxClients || !IsValidEntity(entity))
	{
		Format(buffer, 64, "Trống");
		return;
	}
	GetEntityClassname(entity, szClassname, sizeof szClassname);
	if (strcmp(szClassname, "weapon_melee") == 0)
	{
		GetEntPropString(entity, Prop_Data, "m_strMapSetScriptName", szClassname, sizeof szClassname);
	}
	g_mapWeap.GetString(szClassname, szClassname, sizeof szClassname);
	//PrintToChatAll("slot[%i] = %s", i, szClassname);
	
	Format(buffer, 64, szClassname);
}

public Action Event_PlayerDeath(Event event, char[] name, bool bDontBroadcast) {
	int victim = event.GetInt("entityid");
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	bool isHeadshot = event.GetBool("headshot");
	
	char infectedName[32];
	char clsName[32];
	
	event.GetString("victimname", infectedName, sizeof(infectedName));
	GetEntityClassname(victim, clsName, sizeof(clsName));
	
	if (IsAliveSurvivor(attacker) && isHeadshot)g_iChapterHSKills[attacker]++;
	
	if (StrEqual(infectedName, "infected") || StrEqual(clsName, "infected")) {
		if (IsAliveSurvivor(attacker))g_iChapterCIKills[attacker]++;
	} else {
		victim = event.GetInt("userid");
		if (victim == 0)return Plugin_Handled;
		int zClass = GetEntProp(GetClientOfUserId(victim), Prop_Send, "m_zombieClass");
		
		if (zClass >= 1 && zClass <= 8) {
			if (IsAliveSurvivor(attacker))g_iChapterSIKills[attacker]++;
		}
	}
	
	return Plugin_Continue;
}

public Action Event_WitchKilled(Event event, char[] name, bool bDontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (IsAliveSurvivor(client))g_iChapterSIKills[client]++;
	
	return Plugin_Continue;
}

public Action Event_RoundStart(Event event, char[] name, bool bDontBroadcast) {
	ResetCampaignStats();
	
	return Plugin_Continue;
}

void createPanelPlayer(int client, int target)
{
	Panel panel = new Panel();
	char weaponName[64];
	char content[255];
	if (!IsClientInGame(target)) return;
	Format(content, sizeof content, "Thông tin survivor %N:", target);
	panel.DrawItem(content, ITEMDRAW_RAWLINE);
	panel.DrawItem(" ", ITEMDRAW_RAWLINE);
	panel.DrawItem("Slot 1");
	getPlayerSlot(0, target, weaponName);
	Format(content, sizeof content, "%s", weaponName);
	panel.DrawItem(content, ITEMDRAW_RAWLINE);
	//panel.DrawItem(" ", ITEMDRAW_RAWLINE);
	panel.DrawItem("Slot 2");
	getPlayerSlot(1, target, weaponName);
	Format(content, sizeof content, "%s", weaponName);
	panel.DrawItem(content, ITEMDRAW_RAWLINE);
	//panel.DrawItem(" ", ITEMDRAW_RAWLINE);
	panel.DrawItem("Slot 3");
	getPlayerSlot(2, target, weaponName);
	Format(content, sizeof content, "%s", weaponName);
	panel.DrawItem(content, ITEMDRAW_RAWLINE);
	//panel.DrawItem(" ", ITEMDRAW_RAWLINE);
	panel.DrawItem("Slot 4");
	getPlayerSlot(3, target, weaponName);
	Format(content, sizeof content, "%s", weaponName);
	panel.DrawItem(content, ITEMDRAW_RAWLINE);
	//panel.DrawItem(" ", ITEMDRAW_RAWLINE);
	panel.DrawItem("Slot 5");
	getPlayerSlot(4, target, weaponName);
	Format(content, sizeof content, "%s", weaponName);
	panel.DrawItem(content, ITEMDRAW_RAWLINE);
	panel.DrawItem(" ", ITEMDRAW_RAWLINE);
	panel.DrawItem("Status");
	
	int health = GetClientHealth(target);
	int health_buffer = L4D_GetPlayerTempHealth(target);
	int revived = bIsHeartbeatExists ? Heartbeat_GetRevives(target) : L4D_GetPlayerReviveCount(target);
	float hsPercentage = 0.0;
	int roundedHSPct = 0;
	
	if (g_iChapterHSKills[client] > 0) {
		hsPercentage = (float(g_iChapterHSKills[client]) / float(g_iChapterCIKills[target])) * 100;
		roundedHSPct = RoundFloat(hsPercentage);
	}
	
	Format(content, sizeof content, "HP: %i[+%i] / Incap: %i / CI: %i / SI: %i / HS: %i (Tỉ lệ: %i%%)", health, health_buffer, 
		revived, g_iChapterCIKills[target], g_iChapterSIKills[target], g_iChapterHSKills[target], roundedHSPct);
	panel.DrawItem(content, ITEMDRAW_RAWLINE);
	//panel.DrawItem(" ", ITEMDRAW_RAWLINE);
	panel.Send(client, HandleShowTeamsPanel, 3);
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

public void OnItemPickup(Event event, const char[] name, bool dontBroadcast) {
	
	static char name_item[32];
	
	event.GetString("item", name_item, sizeof(name_item));
	
	int subject = GetClientOfUserId(event.GetInt("userid"));
	
	if (announce_events & PICKUP && IsAliveSurvivor(subject) && isAllowedMedicine(name_item)) {
		AnnounceHealth(subject, subject);
	}
	
}

bool isAllowedMedicine(const char[] name) {
	
	for (int i = 0; i < sizeof(medicine_classes); i++)
	if (StrContains(name, medicine_classes[i]) >= 0 && announce_medicines & (1 << i))
		return true;
	
	return false;
}

public void OnClientPutInServer(int client) {
	
	SDKHook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);
}

public void OnWeaponSwitchPost(int client, int weapon) {
	
	static char name_weapon[32];
	
	if (IsAliveSurvivor(client) && weapon != INVALID_ENT_REFERENCE) {
		GetEntityClassname(weapon, name_weapon, sizeof(name_weapon));
		
		if (announce_events & MEDIC_SWITCHED && IsHumanSurvivor(client) && isAllowedMedicine(name_weapon))
			AnnounceHealth(client, client);
	}
}

public void OnArenalineUsed(Event event, const char[] name, bool dontBroadcast) {
	
	int healer = GetClientOfUserId(event.GetInt("userid"));
	
	if (announce_events & ADRENALINE_USED && IsHumanSurvivor(healer))
		AnnounceHealth(healer, healer);
}

public void OnDefibFail(Event event, const char[] name, bool dontBroadcast) {
	
	int healer = GetClientOfUserId(event.GetInt("userid")), 
	subject = GetClientOfUserId(event.GetInt("subject"));
	
	if (announce_events & DEFIBRILLATING && IsAliveSurvivor(healer)) {
		
		AnnounceHealth(subject, healer);
		
		if (announce_also & DEFIBRILLATING)
			AnnounceHealth(subject, subject);
	}
}

public void OnHealBegin(Event event, const char[] name, bool dontBroadcast) {
	
	int healer = GetClientOfUserId(event.GetInt("userid")), 
	subject = GetClientOfUserId(event.GetInt("subject"));
	
	if (announce_events & HEALING && IsAliveSurvivor(healer)) {
		
		AnnounceHealth(subject, healer);
		
		if (announce_also & HEALING)
			AnnounceHealth(subject, subject);
	}
}


public void OnWeaponGiven(Event event, const char[] name, bool dontBroadcast) {
	
	int giver = GetClientOfUserId(event.GetInt("giver")), 
	subject = GetClientOfUserId(event.GetInt("userid")), 
	weaponclass = event.GetInt("weapon");
	
	if (announce_events & TRANSFERRING && IsAliveSurvivor(subject))
		
	switch (weaponclass) {
		
		case WEAPONID_PILLS :  {
			
			if (announce_medicines & PILLS) {
				AnnounceHealth(subject, giver);
				
				if (announce_also & TRANSFERRING)
					AnnounceHealth(subject, subject);
			}
		}
		case WEAPONID_ADRENALINE :  {
			
			if (announce_medicines & ADRENALINE) {
				AnnounceHealth(subject, giver);
				
				if (announce_also & TRANSFERRING)
					AnnounceHealth(subject, subject);
			}
		}
	}
}

public void OnPillsUsed(Event event, const char[] name, bool dontBroadcast) {
	
	int healer = GetClientOfUserId(event.GetInt("userid"));
	
	if (announce_events & PILLS_USED && IsHumanSurvivor(healer))
		AnnounceHealth(healer, healer);
}

public void OnPillsUsedFail(Event event, const char[] name, bool dontBroadcast) {
	
	int healer = GetClientOfUserId(event.GetInt("userid"));
	
	if (announce_events & PILLS_USED && IsHumanSurvivor(healer))
		AnnounceHealth(healer, healer);
}

public void OnReviveSuccess(Event event, const char[] name, bool dontBroadcast) {
	
	int healer = GetClientOfUserId(event.GetInt("userid")), 
	subject = GetClientOfUserId(event.GetInt("subject"));
	
	if (announce_events & REVIVED && IsAliveSurvivor(subject)) {
		
		AnnounceHealth(subject, healer);
		
		if (announce_also & REVIVED)
			AnnounceHealth(subject, subject);
	}
}

void AnnounceHealth(int client, int receiver) {
	
	DataPack data = new DataPack();
	data.WriteCell(GetClientUserId(client));
	data.WriteCell(GetClientUserId(receiver));
	data.Reset();
	
	RequestFrame(AnnounceHealthPost, data);
}

public void AnnounceHealthPost(DataPack data) {
	
	int client, receiver;
	
	client = GetClientOfUserId(data.ReadCell());
	receiver = GetClientOfUserId(data.ReadCell());
	
	delete data;
	
	static ConVar HealthMax;
	static char buffer[254];
	static float time_announced_last[MAXPLAYERS];
	
	if (!HealthMax)
		HealthMax = FindConVar("first_aid_kit_max_heal");
	
	if (IsClientInGame(client) && IsPlayerAlive(client) && IsClientInGame(receiver)) {
		
		if (announce_SI & ALLOW_GOT_SI == 0 && GetClientTeam(client) == 3)
			return;
		
		if (announce_SI & ALLOW_SI_RECEIVE == 0 && GetClientTeam(receiver) == 3)
			return;
		
		int health = GetClientHealth(client), 
		health_buffer = L4D_GetPlayerTempHealth(client), 
		revived = bIsHeartbeatExists ? Heartbeat_GetRevives(client) : L4D_GetPlayerReviveCount(client);
		
		bool isDying = bIsLeft4Dead2 && IsOnBlackNWhiteScreen(client);
		
		float time = GetEngineTime();
		
		float adrenaline_duration = bIsLeft4Dead2 ? Terror_GetAdrenalineTime(client) : 0.0;
		
		if (!hasTranslations) {
			PrintToServer("translation file %s not loaded.", PLUGIN_PHRASES);
			return;
		}
		
		SetGlobalTransTarget(receiver);
		
		Format(buffer, sizeof(buffer), "%t%t", "Name", client, "Health", health);
		
		if (health_buffer > 0)
			Format(buffer, sizeof(buffer), "%s%t", buffer, "Buffer", health_buffer);
		
		if (revived > 0)
			Format(buffer, sizeof(buffer), "%s%t", buffer, "Revived", revived);
		
		if (isDying)
			Format(buffer, sizeof(buffer), "%s%t", buffer, "Dying");
		
		// if (bIsLeft4Dead2 && adrenaline_duration > 0)
		// 	Format(buffer, sizeof(buffer), "%s%t", buffer, "Adrenaline Left", adrenaline_duration);
		
		if (!announce_cooldown || (time - time_announced_last[receiver]) > announce_cooldown) {
			
			Announce(receiver, "%s", buffer);
			time_announced_last[receiver] = time;
			
			if (announce_sounds & PLAY_FULLED && HealthMax && (health + health_buffer) >= (HealthMax.IntValue - 1))
				
			EmitSoundToClient(receiver, SOUND_REJECT, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
			
			else if (announce_sounds & PLAY_READY && revived)
				
			EmitSoundToClient(receiver, SOUND_READY, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
		}
		
	}
}


void Announce(int client, const char[] format, any...) {
	
	static char buffer[254];
	SetGlobalTransTarget(client);
	VFormat(buffer, sizeof(buffer), format, 3);
	//ReplaceColor(buffer, sizeof(buffer));
	
	if (IsClient(client)) {
		
		if (announce_types & ANNOUNCE_CHAT)
			PrintToChat(client, "%s", buffer);
		
		if (announce_types & ANNOUNCE_HINT)
			PrintHintText(client, "%s", buffer);
		
		if (announce_types & ANNOUNCE_CENTER)
			PrintCenterText(client, "%s", buffer);
	}
}

public void ResetCampaignStats() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsClientConnected(i)) {
			g_iChapterCIKills[i] = 0;
			g_iChapterSIKills[i] = 0;
			g_iChapterHSKills[i] = 0;
		}
	}
}

bool IsHumanSurvivor(int client) {
	return IsClient(client) && GetClientTeam(client) == 2 && !IsFakeClient(client);
}

bool IsAliveSurvivor(int client) {
	return IsClient(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client);
}

bool IsClient(int client) {
	return (1 <= client <= MaxClients) && IsClientInGame(client);
}

bool IsOnBlackNWhiteScreen(int client) {
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_bIsOnThirdStrike"));
}

// ==================================================
// STOCKS (left4dhooks_stocks.inc)
// ==================================================


/**
 * Return player current revive count.
 *
 * @param client		Client index.
 * @return				Survivor's current revive count.
 * @error				Invalid client index.
 */
int L4D_GetPlayerReviveCount(int client)
{
	return GetEntProp(client, Prop_Send, "m_currentReviveCount");
}


/**
 * Returns player temporarily health.
 *
 * Note: This will not work with mutations or campaigns that alters the decay
 * rate through vscript'ing. If you want to be sure that it works no matter
 * the mutation, you will have to detour the OnGetScriptValueFloat function.
 * Doing so you are able to capture the altered decay rate and calculate the
 * temp health the same way as this function does.
 *
 * @param client		Client index.
 * @return				Player's temporarily health, -1 if unable to get.
 * @error				Invalid client index or unable to find pain_pills_decay_rate cvar.
 */
int L4D_GetPlayerTempHealth(int client)
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

bool IsClientHanging(int client)
{
	return GetEntProp(client, Prop_Send, "m_isHangingFromLedge") != 0 || GetEntProp(client, Prop_Send, "m_isFallingFromLedge") != 0;
}

bool IsClientIncapped(int client)
{
	return GetEntProp(client, Prop_Send, "m_isIncapacitated", 1) > 0 && GetEntProp(client, Prop_Send, "m_isHangingFromLedge") != 1;
}

/**
 * Returns the remaining duration of a survivor's adrenaline effect.
 *
 * @param iClient		Client index of the survivor.
 *
 * @return 			Remaining duration or -1.0 if there's no effect.
 * @error			Invalid client index.
 **/
// L4D2 only.
float Terror_GetAdrenalineTime(int iClient)
{
	// Get CountdownTimer address
	static int timerAddress = -1;
	if (timerAddress == -1)
	{
		timerAddress = FindSendPropInfo("CTerrorPlayer", "m_bAdrenalineActive") - 12;
	}
	
	//timerAddress + 8 = TimeStamp
	float flGameTime = GetGameTime();
	float flTime = GetEntDataFloat(iClient, timerAddress + 8);
	if (flTime <= flGameTime)
		return -1.0;
	
	if (!GetEntProp(iClient, Prop_Send, "m_bAdrenalineActive"))
		return -1.0;
	
	return flTime - flGameTime;
}
