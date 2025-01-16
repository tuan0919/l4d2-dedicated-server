#define PLUGIN_NAME                   "[L4D1 & L4D2] Announce death & incapped & defib info to players"
#define PLUGIN_AUTHOR                 "Tuan"
#define PLUGIN_DESCRIPTION            "Announce death & incapped & defib info to players"
#define PLUGIN_VERSION                "1.0"
#define HUD_WIDTH	0.4
#define HUD_SLOT	4

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <colors>
#include <tuan_custom>

native bool L4D2_ExecVScriptCode(char[] code);
float fTime;
#define HUD_FLAG_NONE			0		// no flag
#define HUD_FLAG_PRESTR			1		// do you want a string/value pair to start(pre) with the string (default is PRE)
#define HUD_FLAG_POSTSTR		2		// do you want a string/value pair to end(post) with the string
#define HUD_FLAG_BEEP			4		// Makes a countdown timer blink
#define HUD_FLAG_BLINK			8		// do you want this field to be blinking
#define HUD_FLAG_AS_TIME		16		// ?
#define HUD_FLAG_COUNTDOWN_WARN	32		// auto blink when the timer gets under 10 seconds
#define HUD_FLAG_NOBG			64		// dont draw the background box for this UI element
#define HUD_FLAG_ALLOWNEGTIMER	128		// by default Timers stop on 0:00 to avoid briefly going negative over network, this keeps that from happening
#define HUD_FLAG_ALIGN_LEFT		256		// Left justify this text
#define HUD_FLAG_ALIGN_CENTER	512		// Center justify this text
#define HUD_FLAG_ALIGN_RIGHT	768		// Right justify this text
#define HUD_FLAG_TEAM_SURVIVORS	1024	// only show to the survivor team
#define HUD_FLAG_TEAM_INFECTED	2048	// only show to the special infected team
#define HUD_FLAG_TEAM_MASK		3072	// ?
#define HUD_FLAG_UNKNOWN1		4096	// ?
#define HUD_FLAG_TEXT			8192	// ?
#define HUD_FLAG_NOTVISIBLE		16384	// if you want to keep the slot data but keep it from displaying

public Plugin myinfo = 
{
	name = "Announce death & incapped & defib info to players", 
	author = "Strikeraot", 
	description = "Simple plugin", 
	version = "1.0", 
	url = "http://forums.alliedmods.net"
};

#define MAXENTITIES 			2048
#define TRANSLATION_FILENAME 	"Tuan_l4d2_death_incap_announcer.phrases"

enum {
	ZOMBIECLASS_SMOKER = 1, 
	ZOMBIECLASS_BOOMER = 2, 
	ZOMBIECLASS_HUNTER = 3, 
	ZOMBIECLASS_SPITTER = 4, 
	ZOMBIECLASS_JOCKEY = 5, 
	ZOMBIECLASS_CHARGER = 6, 
	ZOMBIECLASS_TANK = 8, 
};

enum {
	ATTACKER_AS_VICTIM = 1, 
	ATTACKER_AS_SURVIVOR = 2, 
	ATTACKER_AS_INFECTED = 3, 
	ATTACKER_AS_INVALID = 4
}

char g_ZomNames[9][24] =  {
	"Unknown", 
	"Smoker", 
	"Boomer", 
	"Hunter", 
	"Spitter", 
	"Jockey", 
	"Charger", 
	"Unknown", 
	"Tank"
};
StringMap g_mapWeap;
int g_WitchBurners[MAXENTITIES + 1];
int g_TankBurners[MAXENTITIES + 1];
ArrayList g_hud_killinfo;
static const float g_HUDpos[][] = {
	{0.00,0.04,1.00,0.04},
    {0.00,0.08,1.00,0.04},
    {0.00,0.12,1.00,0.04},
    {0.00,0.16,1.00,0.04},
};

stock void ScriptedHUDSetParams(int element = 0, const char[] text = "", int flags = 0, float posX = 0.0, float posY = 0.0, float width = 1.0, float height = 0.026) {
	fTime = GetEngineTime();

	GameRules_SetPropFloat("m_fScriptedHUDPosX", posX, element);
	GameRules_SetPropFloat("m_fScriptedHUDPosY", posY, element);

	GameRules_SetPropFloat("m_fScriptedHUDWidth", width, element);
	GameRules_SetPropFloat("m_fScriptedHUDHeight", height, element);

	GameRules_SetPropString("m_szScriptedHUDStringSet", text, _, element);

	ScriptedHUDSetFlags(flags, element);
}

stock void ScriptedHUDSetFlags(int flags, int element) {
	GameRules_SetProp("m_iScriptedHUDFlags", flags, _, element);
}

stock void ScriptedHUDSetEnabled(bool enable) {
	GameRules_SetProp("m_bChallengeModeActive", view_as<int>(enable));
}

public OnPluginStart()
{
	LoadTrans();
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("player_incapacitated_start", Event_PlayerIncapacitated, EventHookMode_Pre);
	HookEvent("tank_spawn", Event_Tank_Spawn, EventHookMode_Pre);
	HookEvent("witch_spawn", Event_Witch_Spawn, EventHookMode_Pre);
	HookEvent("revive_success", Event_Revive_Success, EventHookMode_Pre);
	HookEvent("heal_success", Event_Heal_Success, EventHookMode_Pre);
	HookEvent("defibrillator_used", Event_Defib_Used, EventHookMode_Pre);
	createStringMap();
	g_hud_killinfo = new ArrayList(128);
}

void LoadTrans()
{
	char path[256];
	BuildPath(Path_SM, path, sizeof(path), "translations/edited-plugins/%s.txt", TRANSLATION_FILENAME);
	if (FileExists(path)) {
		LoadTranslations(TRANSLATION_FILENAME);
	}
}

void Event_Revive_Success(Event event, const char[] name, bool dontBroadCast)
{
	int client = event.GetInt("userid");
	int subject = event.GetInt("subject");
	char message[64];
	client = GetClientOfUserId(client);
	subject = GetClientOfUserId(subject);
	if (client > 0 && subject > 0) {
		Format(message, sizeof(message), "%N helped %N.", client, subject);
		ScriptedHUDSetParams(HUD_SLOT, message, HUD_FLAG_TEXT|HUD_FLAG_BLINK|HUD_FLAG_ALIGN_CENTER, 0.01, 0.03, HUD_WIDTH);
	}
}

void Event_Defib_Used(Event event, const char[] name, bool dontBroadCast)
{
	int client = event.GetInt("userid");
	int subject = event.GetInt("subject");
	char message[64];
	client = GetClientOfUserId(client);
	subject = GetClientOfUserId(subject);
	if (client > 0 && subject > 0) {
		Format(message, sizeof(message), "%N revived %N.", client, subject);
		ScriptedHUDSetParams(HUD_SLOT, message, HUD_FLAG_TEXT|HUD_FLAG_BLINK|HUD_FLAG_ALIGN_CENTER, 0.01, 0.03, HUD_WIDTH);
	}
}

void Event_Heal_Success(Event event, const char[] name, bool dontBroadCast)
{
	int client = event.GetInt("userid");
	int subject = event.GetInt("subject");
	char message[64];
	client = GetClientOfUserId(client);
	subject = GetClientOfUserId(subject);
	if (client > 0 && subject > 0) {
		Format(message, sizeof(message), "%N healed %N.", client, subject);
		ScriptedHUDSetParams(HUD_SLOT, message, HUD_FLAG_TEXT|HUD_FLAG_BLINK|HUD_FLAG_ALIGN_CENTER, 0.01, 0.03, HUD_WIDTH);
	}
}

public void GearTransfer_OnWeaponGive_TuanCustom(int client, int target, char[] item) {
	char message[64];
	Format(message, sizeof(message), "%N gave %s to %N", client, item, target);
	ScriptedHUDSetParams(HUD_SLOT, message, HUD_FLAG_TEXT|HUD_FLAG_BLINK|HUD_FLAG_ALIGN_CENTER, 0.01, 0.03, HUD_WIDTH);
}
public void GearTransfer_OnWeaponSwap_TuanCustom(int client, int target, char[] prevItem, char[] curItem) {
	char message[64];
	Format(message, sizeof(message), "%N swapped %s with %N", client, prevItem, target);
	ScriptedHUDSetParams(HUD_SLOT, message, HUD_FLAG_TEXT|HUD_FLAG_BLINK|HUD_FLAG_ALIGN_CENTER, 0.01, 0.03, HUD_WIDTH);
}

void Event_Tank_Spawn(Event event, const char[] name, bool dontBroadCast)
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client))
	{
		SDKHook(client, SDKHook_OnTakeDamage, CheckTankIgnited);
	}
}

void Event_Witch_Spawn(Event event, const char[] name, bool dontBroadCast)
{
	int witchid = event.GetInt("witchid");
	if (IsValidEntity(witchid))
	{
		SDKHook(witchid, SDKHook_OnTakeDamage, CheckWitchIgnited);
	}
}

public int OnClientSelfRevived(int client) {
	char message[64];
	if (IsClientConnected(client)) {
		Format(message, sizeof(message), "%N self-revived.", client);
		ScriptedHUDSetParams(HUD_SLOT, message, HUD_FLAG_TEXT|HUD_FLAG_BLINK|HUD_FLAG_ALIGN_CENTER, 0.01, 0.03, HUD_WIDTH);
	}
}

Action MapGlobalTimer(Handle timer) {

	if (GetEngineTime() - fTime > 5) {
		g_hud_killinfo.Clear();
		ScriptedHUDSetFlags(HUD_FLAG_NOTVISIBLE, HUD_SLOT);
		ScriptedHUDSetFlags(HUD_FLAG_NOTVISIBLE, 9);
		ScriptedHUDSetFlags(HUD_FLAG_NOTVISIBLE, 10);
		ScriptedHUDSetFlags(HUD_FLAG_NOTVISIBLE, 11);
		ScriptedHUDSetFlags(HUD_FLAG_NOTVISIBLE, 12);
		ScriptedHUDSetFlags(HUD_FLAG_NOTVISIBLE, 13);
	}
	return Plugin_Continue;
}

public void OnMapStart() {
	L4D2_ExecVScriptCode("g_ModeScript");
	ScriptedHUDSetEnabled(true);
	CreateTimer(1.0, MapGlobalTimer, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}


Action CheckTankIgnited(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	// LogMessage("g_TankBurners[%d] = %d", GetClientUserId(victim), attacker)
	if (!IsValidEntity(victim) || !(damagetype & DMG_BURN) || !isSurvivors(attacker))return Plugin_Continue;
	bool isSamePlayer = GetClientUserId(attacker) == g_TankBurners[GetClientUserId(victim)];
	if (isSamePlayer)return Plugin_Continue;
	g_TankBurners[GetClientUserId(victim)] = GetClientUserId(attacker);
	return Plugin_Continue;
}

Action CheckWitchIgnited(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if (!(damagetype & DMG_BURN) || !isSurvivors(attacker))return Plugin_Continue;
	bool isSamePlayer = GetClientUserId(attacker) == g_WitchBurners[victim];
	if (isSamePlayer)return Plugin_Continue;
	g_WitchBurners[victim] = GetClientUserId(attacker);
	// LogMessage("[Line 64] g_WitchBurners[%d] = %d", victim, GetClientUserId(attacker))
	return Plugin_Continue;
}

public void createStringMap()
{
	g_mapWeap = new StringMap();
	g_mapWeap.SetString("pistol", "Pistol");
	g_mapWeap.SetString("smg", "SMG");
	g_mapWeap.SetString("shotgun_chrome", "Chrome Shotgun");
	g_mapWeap.SetString("sniper_military", "Military Sniper");
	g_mapWeap.SetString("shotgun_spas", "SPAS Shotgun");
	g_mapWeap.SetString("grenade_launcher_projectile", "Grenade Launcher");
	g_mapWeap.SetString("rifle_ak47", "Rifle AK47");
	g_mapWeap.SetString("smg_mp5", "SMG MP5");
	g_mapWeap.SetString("rifle_sg552", "Rifle SG552");
	g_mapWeap.SetString("sniper_awp", "AWP Sniper");
	g_mapWeap.SetString("sniper_scout", "Scout Sniper");
	g_mapWeap.SetString("rifle_m60", "Rifle M60");
	g_mapWeap.SetString("machinegun", "Machine Gun");
	g_mapWeap.SetString("pistol_magnum", "Pistol Magnum");
	g_mapWeap.SetString("hunting_rifle", "Hunting Rifle");
	g_mapWeap.SetString("rifle", "Rifle M16");
	g_mapWeap.SetString("autoshotgun", "Auto Shotgun");
	g_mapWeap.SetString("pumpshotgun", "Pump Shotgun");
	g_mapWeap.SetString("smg_silenced", "Silenced SMG");
	g_mapWeap.SetString("rifle_desert", "Rifle Desert");
	g_mapWeap.SetString("pipe_bomb", "Pipe bomb");
	g_mapWeap.SetString("dual_pistols", "Dual Pistol");
	g_mapWeap.SetString("prop_minigun", "Prop Minigun L4D2");
	g_mapWeap.SetString("prop_minigun_l4d1", "Prop Minigun L4D1");
	g_mapWeap.SetString("chainsaw", "Chainsaw");
	g_mapWeap.SetString("melee", "melee");
	
	g_mapWeap.SetString("inferno", "Lửa chùa");
	g_mapWeap.SetString("entityflame", "Lửa chùa");
	g_mapWeap.SetString("fireaxe", "FireAxe");
	g_mapWeap.SetString("baseball_bat", "Baseball Bat");
	g_mapWeap.SetString("cricket_bat", "Cricket Bat");
	g_mapWeap.SetString("crowbar", "Crowbar");
	g_mapWeap.SetString("frying_pan", "Frying Pan");
	g_mapWeap.SetString("golfclub", "Golf Club");
	g_mapWeap.SetString("electric_guitar", "Electric Guitar");
	g_mapWeap.SetString("katana", "Katana");
	g_mapWeap.SetString("machete", "Machete");
	g_mapWeap.SetString("tonfa", "Tonfa");
	g_mapWeap.SetString("knife", "Knife");
	g_mapWeap.SetString("pitchfork", "Pitchfork");
	g_mapWeap.SetString("shovel", "Shovel");
	
	g_mapWeap.SetString("smoker_claw", "smoker claw");
	g_mapWeap.SetString("spitter_claw", "spitter claw");
	g_mapWeap.SetString("jockey_claw", "jockey claw");
	g_mapWeap.SetString("boomer_claw", "boomer claw");
	g_mapWeap.SetString("charger claw", "charger claw");
	g_mapWeap.SetString("hunter_claw", "hunter claw");
	g_mapWeap.SetString("tank_claw", "tank claw");
	g_mapWeap.SetString("tank_rock", "đá tank");
	g_mapWeap.SetString("worldspawn", "Bleeding");
	g_mapWeap.SetString("world", "map");
	g_mapWeap.SetString("infected", "hit");
	g_mapWeap.SetString("witch", "witch claw");
}

stock bool isSurvivors(client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2);
}

stock bool isInfected(client)
{
	return (client && IsClientInGame(client) && GetClientTeam(client) == 3);
}

void Event_PlayerIncapacitated(Event event, const char[] name, bool donBroadCast)
{
	int victim;
	int attacker;
	char attacker_name[128];
	char victim_name[128];
	int dmg_type;
	char message[255];
	char weapon_name[64];
	int case_attacker;
	
	victim = GetClientOfUserId(event.GetInt("userid"));
	attacker = GetClientOfUserId(event.GetInt("attacker"));
	dmg_type = event.GetInt("type"); //damage type
	event.GetString("weapon", weapon_name, sizeof(weapon_name));
	case_attacker = ATTACKER_AS_INVALID;
	//PrintToConsoleAll("weapon name: %s, damage type: %d", weapon_name, dmg_type);
	if (isSurvivors(attacker))
	{
		case_attacker = ATTACKER_AS_SURVIVOR;
		GetClientName(attacker, attacker_name, sizeof(attacker_name));
		// victim là survivor
		if (isSurvivors(victim))
		{
			GetClientName(victim, victim_name, sizeof(victim_name));
			if (attacker == victim)case_attacker = ATTACKER_AS_VICTIM;
		}
	}
	else if (isSurvivors(victim))
	{
		GetClientName(victim, victim_name, sizeof(victim_name));
		event.GetString("attackername", attacker_name, sizeof(attacker_name));
		case_attacker = ATTACKER_AS_INVALID;
		if (!isInfected(attacker))
		{
			// Trường hợp attacker có thể là Witch hoặc Common Infected
			int iEntity = event.GetInt("attackerentid");
			char className[64];
			if (iEntity > 0 && IsValidEntity(iEntity) && IsValidEdict(iEntity))
			{
				GetEdictClassname(iEntity, className, sizeof(className));
				if (StrEqual(className, "Witch", false)) {
					case_attacker = ATTACKER_AS_INFECTED;
					Format(attacker_name, sizeof(attacker_name), "Witch");
				}
				else if (StrEqual(className, "Infected", false)) {
					case_attacker = ATTACKER_AS_INFECTED;
					Format(attacker_name, sizeof(attacker_name), "Infected");
				}
			}
		}
		else if (isInfected(attacker))
		{
			case_attacker = ATTACKER_AS_INFECTED;
			int zom_type = GetEntProp(attacker, Prop_Send, "m_zombieClass");
			Format(attacker_name, sizeof(attacker_name), g_ZomNames[zom_type]);
		}
	}
	//Lấy tên weapon
	if (StrEqual(weapon_name, "melee"))
	{
		GetEntPropString(GetPlayerWeaponSlot(attacker, 1), Prop_Data, "m_strMapSetScriptName", weapon_name, sizeof(weapon_name));
		//PrintToConsoleAll("melee name: %s, damage type: %d", weapon_name, dmg_type);
		g_mapWeap.GetString(weapon_name, weapon_name, sizeof(weapon_name));
	}
	else
	{
		weapon_name = GetWeapon_Name(dmg_type, weapon_name);
	}
	switch (case_attacker)
	{
		case ATTACKER_AS_VICTIM:
		{
			Format(message, sizeof(message), "%t %t", "DANGER_TAG", "Self_Incap", attacker_name, weapon_name);
		}
		case ATTACKER_AS_INVALID:
		{
			Format(message, sizeof(message), "%t %t", "DANGER_TAG", "Invalid_Entity_Incap_Survivor", victim_name, weapon_name);
		}
		case ATTACKER_AS_SURVIVOR:
		{
			Format(message, sizeof(message), "%t %t", "DANGER_TAG", "Survivor_Incap_Survivor", attacker_name, victim_name, weapon_name);
		}
		case ATTACKER_AS_INFECTED:
		{
			Format(message, sizeof(message), "%t %t", "DANGER_TAG", "Infected_Incap_Survivor", attacker_name, victim_name, weapon_name);
		}
		
	}
	PrintToConsoleAll("[PlayerIncap]case_attacker = %d", case_attacker);
	CPrintToChatAll(message);
}

void Event_PlayerDeath(Event event, const char[] name, bool donBroadCast)
{
	int victim;
	int attacker;
	char attacker_name[128];
	char victim_name[128];
	int dmg_type;
	char message[255];
	char weapon_name[64];
	int case_attacker;
	bool bInfected;
	
	victim = GetClientOfUserId(event.GetInt("userid"));
	attacker = GetClientOfUserId(event.GetInt("attacker"));
	dmg_type = event.GetInt("type"); //damage type
	event.GetString("weapon", weapon_name, sizeof(weapon_name));
	// LogMessage("weapon name: %s", weapon_name);
	case_attacker = ATTACKER_AS_INVALID;
	if (isSurvivors(attacker))
	{
		case_attacker = ATTACKER_AS_SURVIVOR;
		GetClientName(attacker, attacker_name, sizeof(attacker_name));
		// victim là survivor
		if (isSurvivors(victim))
		{
			GetClientName(victim, victim_name, sizeof(victim_name));
			if (attacker == victim)case_attacker = ATTACKER_AS_VICTIM;
		}
		else
		{
			event.GetString("victimname", victim_name, sizeof(victim_name));
			bInfected = true;
			if (StrEqual(victim_name, "Infected", false))return;
		}
	}
	else if (isSurvivors(victim))
	{
		case_attacker = ATTACKER_AS_INFECTED;
		GetClientName(victim, victim_name, sizeof(victim_name));
		event.GetString("attackername", attacker_name, sizeof(attacker_name));
		if (!isInfected(attacker))
		{
			// Trường hợp attacker có thể là Witch hoặc Common Infected
			// LogMessage("%s is victim, attacker is %s", victim_name, attacker_name)
			// if (!StrEqual(weapon_name, "Witch", false) && !StrEqual(weapon_name, "Infected", false)) return;
			if (StrEqual(weapon_name, "Witch", false))Format(attacker_name, sizeof(attacker_name), "Witch");
			else if (StrEqual(weapon_name, "Infected", false))Format(attacker_name, sizeof(attacker_name), "Infected");
			else
				case_attacker = ATTACKER_AS_INVALID;
		}
	}
	else
	{
		int client = 0;
		event.GetString("victimname", victim_name, sizeof(victim_name));
		if (!StrEqual(victim_name, "Tank", false) && !StrEqual(victim_name, "Witch", false))return;
		if (dmg_type & DMG_BURN)
		{
			if (StrEqual(victim_name, "Tank", false))
			{
				case_attacker = ATTACKER_AS_SURVIVOR;
				victim = event.GetInt("userid");
				client = GetClientOfUserId(g_TankBurners[victim]);
				// LogMessage("Extract: g_TankBurners[%d] = %d", victim, g_TankBurners[victim])
			}
			else if (StrEqual(victim_name, "Witch", false))
			{
				case_attacker = ATTACKER_AS_SURVIVOR;
				victim = event.GetInt("entityid");
				client = GetClientOfUserId(g_WitchBurners[victim]);
				// LogMessage("g_WitchBurners[%d] = %d", victim, g_WitchBurners[victim])
			}
			if (!client || !IsClientInGame(client))return;
			GetClientName(client, attacker_name, sizeof(attacker_name));
		}
	}
	//Lấy tên weapon
	// LogMessage("weapon name: %s, damage type: %d", weapon_name, dmg_type);
	if (StrEqual(weapon_name, "melee"))
	{
		GetEntPropString(GetPlayerWeaponSlot(attacker, 1), Prop_Data, "m_strMapSetScriptName", weapon_name, sizeof(weapon_name));
		g_mapWeap.GetString(weapon_name, weapon_name, sizeof(weapon_name));
	}
	else
	{
		weapon_name = GetWeapon_Name(dmg_type, weapon_name);
	}
	switch (case_attacker)
	{
		case ATTACKER_AS_VICTIM:
		{
			Format(message, sizeof(message), "%t %t", "DANGER_TAG", "Self_Kill", attacker_name, weapon_name);
		}
		case ATTACKER_AS_INVALID:
		{
			Format(message, sizeof(message), "%t %t", "DANGER_TAG", "Invalid_Entity_Kill_Client", victim_name, weapon_name);
		}
		case ATTACKER_AS_SURVIVOR:
		{
			if (bInfected) {
				//fire: ♨
				
				Format(message, sizeof(message), "%s killed %s (%s)", attacker_name, victim_name, weapon_name);
				g_hud_killinfo.PushString(message);
			}
			Format(message, sizeof(message), "%t %t", "DANGER_TAG", "Survivor_Kill_Survivor", attacker_name, victim_name, weapon_name);
		}
		case ATTACKER_AS_INFECTED:
		{
			Format(message, sizeof(message), "%t %t", "DANGER_TAG", "Infected_Kill_Survivor", attacker_name, victim_name, weapon_name);
		}
	}
	//PrintToConsoleAll("[PlayerDeath]case_attacker = %d", case_attacker);
	if (!bInfected) CPrintToChatAll(message);
	if (g_hud_killinfo.Length > 4) g_hud_killinfo.Erase(0);
	for(int i = 0; i < g_hud_killinfo.Length; i++) {
		g_hud_killinfo.GetString(i,message, sizeof(message));
		if (i == g_hud_killinfo.Length - 1) {
			ScriptedHUDSetParams(i + 9, message, HUD_FLAG_TEXT|HUD_FLAG_BLINK|HUD_FLAG_NOBG|HUD_FLAG_ALIGN_RIGHT, g_HUDpos[i][0], g_HUDpos[i][1], g_HUDpos[i][2], g_HUDpos[i][3]);
			continue;
		}
		ScriptedHUDSetParams(i + 9, message, HUD_FLAG_TEXT|HUD_FLAG_NOBG|HUD_FLAG_ALIGN_RIGHT, g_HUDpos[i][0], g_HUDpos[i][1], g_HUDpos[i][2], g_HUDpos[i][3]);
	}
}

char[] GetWeapon_Name(int dmgType, const char[] wp_str)
{
	char wpName[64] = "unknown";
	if (dmgType & (DMG_BLAST | DMG_BLAST_SURFACE))
	{
		Format(wpName, sizeof(wpName), "explosion");
	}
	else if (dmgType & (DMG_BURN | DMG_DIRECT))
	{
		Format(wpName, sizeof(wpName), "flame");
	}
	else if (dmgType & DMG_FALL)
	{
		Format(wpName, sizeof(wpName), "fall");
	}
	else if (dmgType == 263168 || dmgType == 265216)
	{
		Format(wpName, sizeof(wpName), "acid");
	}
	else if (dmgType & DMG_POISON)
	{
		Format(wpName, sizeof(wpName), "bleeding");
	}
	else if (dmgType & DMG_CLUB)
	{
		Format(wpName, sizeof(wpName), "hit");
	}
	else if (dmgType & (DMG_BULLET | DMG_SLASH | DMG_CLUB | DMG_GENERIC | DMG_DISSOLVE))
	{
		g_mapWeap.GetString(wp_str, wpName, sizeof(wpName));
	}
	return wpName;
} 