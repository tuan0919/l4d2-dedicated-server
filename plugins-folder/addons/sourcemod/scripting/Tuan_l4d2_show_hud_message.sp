#define PLUGIN_VERSION		"1.0"
#define PLUGIN_PREFIX		"l4d2_"
#define PLUGIN_NAME			"show_hud_messages"
#define PLUGIN_NAME_FULL		"[L4D2] Show Message On HUD"
#define PLUGIN_DESCRIPTION	"show extra death messages those not included by game"
#define PLUGIN_AUTHOR		"nqat0919"
#define PLUGIN_LINK			""

#pragma newdecls required
#pragma semicolon 1

#include <sdktools>
#include <sourcemod>
#include <left4dhooks>
#include <Tuan_custom_forwards>

public Plugin myinfo = {
	name			= PLUGIN_NAME_FULL,
	author			= PLUGIN_AUTHOR,
	description		= PLUGIN_DESCRIPTION,
	version			= PLUGIN_VERSION,
	url				= PLUGIN_LINK
};

static const char ENTITY_KEYs[][] = {
	"Infected",
	"Witch",
	"CInferno",
	"CPipeBombProjectile",
	"CWorld",
	"CEntityFlame",
	"CInsectSwarm",
	"CBaseTrigger",
};

static const char ENTITY_VALUEs[][] = {
	"Zombie",
	"Witch",
	"Fire",
	"Blast",
	"World",
	"Fire",
	"Spitter",
	"Map",
};

// noro.inc start
#define HUD_FLAG_NONE                 0     // no flag
#define HUD_FLAG_PRESTR               1     // do you want a string/value pair to start(pre) with the string (default is PRE)
#define HUD_FLAG_POSTSTR              2     // do you want a string/value pair to end(post) with the string
#define HUD_FLAG_BEEP                 4     // Makes a countdown timer blink
#define HUD_FLAG_BLINK                8     // do you want this field to be blinking
#define HUD_FLAG_AS_TIME              16    // ?
#define HUD_FLAG_COUNTDOWN_WARN       32    // auto blink when the timer gets under 10 seconds
#define HUD_FLAG_NOBG                 64    // dont draw the background box for this UI element
#define HUD_FLAG_ALLOWNEGTIMER        128   // by default Timers stop on 0:00 to avoid briefly going negative over network, this keeps that from happening
#define HUD_FLAG_ALIGN_LEFT           256   // Left justify this text
#define HUD_FLAG_ALIGN_CENTER         512   // Center justify this text
#define HUD_FLAG_ALIGN_RIGHT          768   // Right justify this text
#define HUD_FLAG_TEAM_SURVIVORS       1024  // only show to the survivor team
#define HUD_FLAG_TEAM_INFECTED        2048  // only show to the special infected team
#define HUD_FLAG_TEAM_MASK            3072  // ?
#define HUD_FLAG_UNKNOWN1             4096  // ?
#define HUD_FLAG_TEXT                 8192  // ?
#define HUD_FLAG_NOTVISIBLE           16384 // if you want to keep the slot data but keep it from displaying
#define KILL_HUD_BASE 9
#define KILL_INFO_MAX 6
#define IsClient(%1) ((1 <= %1 <= MaxClients) && IsClientInGame(%1))
#define L4D2_ZOMBIECLASS_TANK		8
#define MAX_HUD_NUMBER	4
#define HUD_TIMEOUT	5.0
#define HUD_WIDTH	0.3
#define HUD_SLOT	4
#define CLASSNAME_INFECTED            "infected"
#define CLASSNAME_WITCH               "witch"
#define TEAM_SURVIVOR		2
#define TEAM_INFECTED		3

static float g_HUDpos[][] = {
    {0.00,0.00,0.00,0.00}, // 0
    {0.00,0.00,0.00,0.00},
    {0.00,0.00,0.00,0.00},
    {0.00,0.00,0.00,0.00},
    {0.00,0.00,0.00,0.00},
    {0.00,0.00,0.00,0.00},
    {0.00,0.00,0.00,0.00},
    {0.00,0.00,0.00,0.00},
	{0.00,0.00,0.00,0.00},

    // kill list
	// {x, y, width, height}
    {0.0,0.04,HUD_WIDTH,0.04}, // 9
    {0.0,0.08,HUD_WIDTH,0.04}, // 10
    {0.0,0.12,HUD_WIDTH,0.04},
    {0.0,0.16,HUD_WIDTH,0.04},
    {0.0,0.20,HUD_WIDTH,0.04},
    {0.0,0.24,HUD_WIDTH,0.04}, // 14
};
static int g_iHUDFlags_Normal = HUD_FLAG_TEXT | HUD_FLAG_ALIGN_LEFT | HUD_FLAG_NOBG | HUD_FLAG_TEAM_SURVIVORS;
static int g_iHUDFlags_Newest = HUD_FLAG_TEXT | HUD_FLAG_ALIGN_LEFT | HUD_FLAG_NOBG | HUD_FLAG_TEAM_SURVIVORS | HUD_FLAG_BLINK;

enum struct HUD
{
	int slot;
	float pos[4];
	char info[128];
	void Place(int flag)
	{
		HUDSetLayout(this.slot, flag, this.info);
		HUDPlace(this.slot, this.pos[0], this.pos[1], this.pos[2], this.pos[3]);
	}
}

StringMap mapNetClassToName;
ArrayList g_hud_info;
Handle g_hHudDecreaseTimer;
char output[128];
public void OnPluginStart() {

	CreateConVar(PLUGIN_NAME ... "_version", PLUGIN_VERSION, "Plugin Version of " ... PLUGIN_NAME_FULL, FCVAR_SPONLY|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);

	mapNetClassToName = new StringMap();
	g_hud_info = new ArrayList(ByteCountToCells(128));

	for (int i = 0; i < sizeof(ENTITY_KEYs); i++)
		mapNetClassToName.SetString(ENTITY_KEYs[i], ENTITY_VALUEs[i]);

	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_incapacitated", OnPlayerIncapacitated);
	HookEvent("player_death", Event_PlayerDeathInfo_Post);
	HookEvent("witch_killed", OnWitchKilled);

}

char[] GetEntityTranslatedName(int entity) {

	static char result[32];

	if (IsClient(entity)) {

		if (GetEntProp(entity, Prop_Send, "m_zombieClass") == L4D2_ZOMBIECLASS_TANK && IsFakeClient(entity))
			result = "Tank";
		else
			FormatEx(result, sizeof(result), "%N", entity);

	} else {

		GetEntityNetClass(entity, result, sizeof(result));
		mapNetClassToName.GetString(result, result, sizeof(result));
	}

	return result;
}

public void OnMapStart() {
	GameRules_SetProp("m_bChallengeModeActive", true, _, _, true);
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	for (int slot = KILL_HUD_BASE; slot < MAX_HUD_NUMBER; slot++)
		RemoveHUD(slot);

	delete g_hud_info;
	g_hud_info = new ArrayList(ByteCountToCells(128));

	delete g_hHudDecreaseTimer;
}

public void OnMapEnd()
{
	delete g_hud_info;
	g_hud_info = new ArrayList(ByteCountToCells(128));

	delete g_hHudDecreaseTimer;
}

void OnWitchKilled(Event event, const char[] name, bool dontBroadcast) {

	int attacker = GetClientOfUserId(event.GetInt("userid"));

	if (IsClient(attacker)) {

		FormatEx(output, sizeof(output), " %s Killed Witch", GetEntityTranslatedName(attacker));
		DisplayHUD(output);
	}
}

void Event_PlayerDeathInfo_Post(Event event, const char[] name, bool dontBroadcast) {
	PrintToChatAll("Event_PlayerDeathInfo_Post");
	int victim = GetClientOfUserId(event.GetInt("userid")),
		attacker = GetClientOfUserId(event.GetInt("attacker"));
	int entityid = event.GetInt("entityid");
	bool headshot = event.GetBool("headshot");
	bool bDetectedVictim = false;
	bool bDetectedAttacker = false;
	int damagetype = event.GetInt("type");
	static char victim_name[128];
	static char attacker_name[128];
	if (attacker == 0) {
		attacker = event.GetInt("attackerentid");
	}
	if (IsClient(victim)) {
		if ( GetClientTeam(victim) == TEAM_SURVIVOR) {
			FormatEx(victim_name,sizeof(victim_name),"%N",victim);
			bDetectedVictim = true;
		}
		else if (GetClientTeam(victim) == TEAM_INFECTED) {
			event.GetString("victimname", victim_name, sizeof(victim_name));
			bDetectedVictim = true;
		}
	}
	else if ( IsWitch(entityid) ) {
		FormatEx(victim_name,sizeof(victim_name),"Witch");
		bDetectedVictim = true;
	}
	if (IsClient(attacker)) {
		FormatEx(attacker_name, sizeof(attacker_name), "%N", attacker);
		bDetectedAttacker = true;
	}
	if (bDetectedAttacker && bDetectedVictim) {
		FormatEx(output, sizeof(output), " %s Killed %s", GetEntityTranslatedName(attacker), GetEntityTranslatedName(victim));
		DisplayHUD(output);
	}
	else if (attacker == victim && GetClientTeam(victim) == 2) {
		FormatEx(output, sizeof(output), " %s Died by Bleeding", GetEntityTranslatedName(victim));
	}
	PrintToChatAll("bDetectedVictim: %s", bDetectedVictim ? "true" : "false");
    PrintToChatAll("bDetectedAttacker: %s", bDetectedAttacker ? "true" : "false");
}

void OnPlayerIncapacitated(Event event, const char[] name, bool dontBroadcast) {

	int victim = GetClientOfUserId(event.GetInt("userid"));

	if (IsClient(victim)) {

		int attacker = GetClientOfUserId(event.GetInt("attacker"));

		if (attacker == 0)
			attacker = event.GetInt("attackerentid");

		if (attacker == victim && GetClientTeam(attacker) == 2) {
			
			FormatEx(output, sizeof(output), " %s Incapped Self", GetEntityTranslatedName(victim));

		// player => tank
		} else if (GetEntProp(victim, Prop_Send, "m_zombieClass") == L4D2_ZOMBIECLASS_TANK) {

			FormatEx(output, sizeof(output), " %s Killed %s", GetEntityTranslatedName(attacker), GetEntityTranslatedName(victim));

		// entity => player
		} else if (!IsClient(attacker))
			FormatEx(output, sizeof(output), " %s Incapped %s", GetEntityTranslatedName(attacker), GetEntityTranslatedName(victim));
		else
			return;

		DisplayHUD(output);
	}
}


// HUD-------------------------------

void HUDSetLayout(int slot, int flags, const char[] dataval, any ...) {
	static char str[128];
	VFormat(str, sizeof str, dataval, 4);

	GameRules_SetProp("m_iScriptedHUDFlags", flags, _, slot, true);
	GameRules_SetPropString("m_szScriptedHUDStringSet", str, true, slot);
}

//Function-------------------------------

void DisplayHUD(const char[] info)
{
	HUD kill_list;
	FormatEx(kill_list.info, sizeof(kill_list.info), "%s", info);
	g_hud_info.PushString(info);
	if( g_hud_info.Length > MAX_HUD_NUMBER ) {
		g_hud_info.Erase(0);
	}
	kill_list.slot = g_hud_info.Length - 1 + KILL_HUD_BASE;
	kill_list.pos  = g_HUDpos[kill_list.slot];
	for(int index = 0; index < KILL_INFO_MAX && index < g_hud_info.Length; index++)
	{
		g_hud_info.GetString(index, kill_list.info, sizeof(kill_list.info));
		kill_list.slot = index+KILL_HUD_BASE;
		kill_list.pos  = g_HUDpos[kill_list.slot];
		kill_list.Place(index == g_hud_info.Length - 1 ? g_iHUDFlags_Newest : g_iHUDFlags_Normal);
	}

	delete g_hHudDecreaseTimer;
	g_hHudDecreaseTimer = CreateTimer(HUD_TIMEOUT, Timer_KillHUDDecrease, _, TIMER_REPEAT);
}


//Timer-------------------------------

Action Timer_KillHUDDecrease(Handle timer)
{
	if( g_hud_info.Length == 0 )
	{
		g_hHudDecreaseTimer = null;
		return Plugin_Stop;
	}

	g_hud_info.Erase(0);

	HUD kill_list;
	int index;
	for(index = 0; index < KILL_INFO_MAX && index < g_hud_info.Length; index++)
	{
		g_hud_info.GetString(index, kill_list.info, sizeof(kill_list.info));
		kill_list.slot = index + KILL_HUD_BASE;
		kill_list.pos  = g_HUDpos[kill_list.slot];
		kill_list.Place(g_iHUDFlags_Normal);
	}

	while(index < KILL_INFO_MAX)
	{
		RemoveHUD(index + KILL_HUD_BASE);
		index++;
	}

	return Plugin_Continue;
}

void HUDPlace(int slot, float x, float y, float width, float height) {
	GameRules_SetPropFloat("m_fScriptedHUDPosX", x, slot, true);
	GameRules_SetPropFloat("m_fScriptedHUDPosY", y, slot, true);
	GameRules_SetPropFloat("m_fScriptedHUDWidth", width, slot, true);
	GameRules_SetPropFloat("m_fScriptedHUDHeight", height, slot, true);
}

void RemoveHUD(int slot) {
	GameRules_SetProp("m_iScriptedHUDInts", 0, _, slot, true);
	GameRules_SetPropFloat("m_fScriptedHUDFloats", 0.0, slot, true);
	GameRules_SetProp("m_iScriptedHUDFlags", HUD_FLAG_NOTVISIBLE, _, slot, true);
	GameRules_SetPropFloat("m_fScriptedHUDPosX", 0.0, slot, true);
	GameRules_SetPropFloat("m_fScriptedHUDPosY", 0.0, slot, true);
	GameRules_SetPropFloat("m_fScriptedHUDWidth", 0.0, slot, true);
	GameRules_SetPropFloat("m_fScriptedHUDHeight", 0.0, slot, true);
	GameRules_SetPropString("m_szScriptedHUDStringSet", "", true, slot);
}

bool IsWitch(int entity)
{
    if (entity > 0 && IsValidEntity(entity))
    {
        char strClassName[64];
        GetEntityClassname(entity, strClassName, sizeof(strClassName));
        return strcmp(strClassName, CLASSNAME_WITCH, false) == 0;
    }
    return false;
}