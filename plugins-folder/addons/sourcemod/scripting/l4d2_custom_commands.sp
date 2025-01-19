/*
*		  NAVIGATION (Search For: Do not allow caps)
*
* -EVENTS - Events.
* 
* -COMMANDS - For commands code
*	-Vomit Player
*	-Incap Player
*	-Change Speed Player
*	-Set Health Player
*	-Change Color Player
*	-
* 
* -MENU RELATED - For menus code
*	-Show Categories
*	-Display menus
* 	-Sub Menus Needed
*	-Do Action
* 
* -FUNCTIONS - For functions code (They do every action)
*
*
*
*
*/

//Include data
#include <sourcemod>
#include <sdktools>
//#include <sdktools_functions>
#include <sdkhooks>
#include <adminmenu>

#pragma newdecls required
#pragma semicolon 1

#define PLUGIN_NAME "[L4D2] Custom admin commands"
#define PLUGIN_AUTHOR "honorcode23, Shadowysn (improvements)"
#define PLUGIN_DESC "Allow admins to use new administrative or fun commands"
#define PLUGIN_VERSION "1.3.9e"
#define PLUGIN_URL "https://forums.alliedmods.net/showpost.php?p=2704580&postcount=483"
#define PLUGIN_NAME_SHORT "Custom admin commands"
#define PLUGIN_NAME_TECH "l4d2_custom_commands"

//Definitions needed for plugin functionality
#define DEBUG 0
#define DESIRED_FLAGS ADMFLAG_UNBAN

#define ARRAY_SIZE 5000

//Colors
#define RED "189 9 13 255"
#define BLUE "34 22 173 255"
#define GREEN "34 120 24 255"
#define YELLOW "231 220 24 255"
#define BLACK "0 0 0 255"
#define WHITE "255 255 255 255"
#define TRANSPARENT "255 255 255 0"
#define HALFTRANSPARENT "255 255 255 180"

//Sounds
#define EXPLOSION_SOUND "ambient/explosions/explode_1.wav"
#define EXPLOSION_SOUND2 "ambient/explosions/explode_2.wav"
#define EXPLOSION_SOUND3 "ambient/explosions/explode_3.wav"
//#define EXPLOSION_DEBRIS "animation/van_inside_debris.wav"
#define EXPLOSION_DEBRIS "animation/plantation_exlposion.wav"
//#define EXPLOSION_DEBRIS "weapons/grenade_launcher/grenadefire/grenade_launcher_explode_1.wav"

//Particles
#define FIRE_PARTICLE "gas_explosion_ground_fire"
#define EXPLOSION_PARTICLE "FluidExplosion_fps"
#define EXPLOSION_PARTICLE2 "weapon_grenade_explosion"
#define EXPLOSION_PARTICLE3 "explosion_huge_b"
#define BURN_IGNITE_PARTICLE "fire_small_01"
#define BLEED_PARTICLE "blood_chainsaw_constant_tp"

//Models
#define ZOEY_MODEL "models/survivors/survivor_teenangst.mdl"
#define FRANCIS_MODEL "models/survivors/survivor_biker.mdl"
#define LOUIS_MODEL "models/survivors/survivor_manager.mdl"

//Command Returns
#define CMD_INVALID_CL "[SM] Invalid client!"
#define CMD_DEAD_CL "[SM] Client is not a living player!"
#define CMD_NOT_SURVIVOR_CL "[SM] Client is not a survivor!"
#define CMD_NOT_INFECTED_CL "[SM] Client is not an infected!"
#define CMD_INVALID_ENT "[SM] Invalid entity!"

//SDKCall Stuff
#define GAMEDATA "l4d2customcmds"
static Handle hConf = null;

// Handles for SDKCalls
static Handle sdkCallPushPlayer = null;
#define NAME_CallPushPlayer "CTerrorPlayer_Fling"
#define SIG_CallPushPlayer_LINUX "@_ZN13CTerrorPlayer5FlingERK6Vector17PlayerAnimEvent_tP20CBaseCombatCharacterf"
#define SIG_CallPushPlayer_WINDOWS "\\x53\\x8B\\xDC\\x83\\xEC\\x08\\x83\\xE4\\xF0\\x83\\xC4\\x04\\x55\\x8B\\x6B\\x04\\x89\\x6C\\x24\\x04\\x8B\\xEC\\x81\\xEC\\xA8\\x00\\x00\\x00\\\\x2A\\x2A\\x2A\\x2A\\x2A\\x2A\\x2A\\x2A\\x2A\\x2A\\x8B\\x43\\x10"

// Handles for SDKCalls (unused)
//static Handle sdkDetonateAcid = null;
//#define NAME_DetonateAcid "CSpitterProjectile_Detonate"
//#define SIG_DetonateAcid_LINUX "@_ZN18CSpitterProjectile8DetonateEv"
//#define SIG_DetonateAcid_WINDOWS "\\x55\\x8B\\xEC\\x81\\xEC\\x94\\x00\\x00\\x00\\x2A\\x2A\\x2A\\x2A\\x2A\\x2A\\x2A\\x2A\\x2A\\x2A\\x53\\x8B\\xD9"

//static Handle sdkVomitInfected = null;
//#define NAME_VomitInfected "CTerrorPlayer_OnHitByVomitJar"
//#define SIG_VomitInfected_LINUX "@_ZN13CTerrorPlayer15OnHitByVomitJarEP20CBaseCombatCharacter"
//#define SIG_VomitInfected_WINDOWS "\\x55\\x8B\\xEC\\x83\\xEC\\x2A\\x56\\x8B\\xF1\\xE8\\x2A\\x2A\\x2A\\x2A\\x84\\xC0\\x74\\x2A\\x8B\\x06\\x8B\\x90\\x2A\\x2A\\x2A\\x2A\\x8B\\xCE\\xFF\\xD2\\x84\\xC0\\x0F"

//static Handle sdkVomitSurvivor = null;
//#define NAME_VomitSurvivor "CTerrorPlayer_OnVomitedUpon"
//#define SIG_VomitSurvivor_LINUX "@_ZN13CTerrorPlayer13OnVomitedUponEPS_b"
//#define SIG_VomitSurvivor_WINDOWS "\\x55\\x8B\\xEC\\x83\\xEC\\x2A\\x53\\x56\\x57\\x8B\\xF1\\xE8\\x2A\\x2A\\x2A\\x2A\\x84\\xC0\\x74\\x2A\\x8B\\x06\\x8B"

//static Handle sdkShoveSurv = null;
//#define NAME_ShoveSurv "CTerrorPlayer_OnStaggered"
//#define SIG_ShoveSurv_LINUX "@_ZN13CTerrorPlayer11OnStaggeredEP11CBaseEntityPK6Vector"
//#define SIG_ShoveSurv_WINDOWS "\\x53\\x8B\\xDC\\x83\\xEC\\x2A\\x83\\xE4\\xF0\\x83\\xC4\\x04\\x55\\x8B\\x6B\\x04\\x89\\x6C\\x24\\x04\\x8B\\xEC\\x83\\xEC\\x2A\\x56\\x57\\x8B\\xF1\\xE8\\x2A\\x2A\\x2A\\x2A\\x84\\xC0\\x0F\\x85\\x6E\\x08"

//static Handle sdkShoveInf = null;
//#define NAME_ShoveInf "CTerrorPlayer_OnShovedBySurvivor"
//#define SIG_ShoveInf_LINUX "@_ZN13CTerrorPlayer18OnShovedBySurvivorEPS_RK6Vector"
//#define SIG_ShoveInf_WINDOWS "\\x55\\x8B\\xEC\\x81\\xEC\\x2A\\x2A\\x2A\\x2A\\xA1\\x2A\\x2A\\x2A\\x2A\\x33\\xC5\\x89\\x45\\xFC\\x53\\x8B\\x5D\\x08\\x56\\x57\\x8B\\x7D\\x0C\\x8B\\xF1"

TopMenu hTopMenu;

/*
 *Offsets, Handles, Bools, Floats, Integers, Strings, Vecs and everything needed for the commands
 */
 
//Strings

#define AUTOEXEC_CFG "l4d2_custom_commands"

//Integers
/* Refers to the last selected userid by the admin client index. Doesn't matter if the admins leaves and another using the same index gets in
 * because if this admin uses the same menu item, the last userid will be reset.
 */
int g_iCurrentUserId[MAXPLAYERS+1] = {0}; 
int g_iLastGrabbedEntity[ARRAY_SIZE+1] = {-1};

//Bools
bool g_bVehicleReady = false;
bool g_bStrike = false;
bool g_bGnomeRain = false;
bool g_bGrab[MAXPLAYERS+1] = {false};
bool g_bGrabbed[ARRAY_SIZE+1] = {false};
//Floats

//Handles (old)
//static Handle sdkVomitInfected = null;
//static Handle sdkVomitSurvivor = null;
//static Handle sdkCallPushPlayer = null;
//static Handle sdkDetonateAcid = null;
//static Handle sdkAdrenaline = null;
//static Handle sdkSetBuffer = null;
//static Handle sdkRevive = null;
//static Handle sdkShoveSurv = null;
//static Handle sdkShoveInf = null;

//Vectors

//CVARS
ConVar g_cvarRadius,
g_cvarPower,
g_cvarDuration,
g_cvarRainDur,
g_cvarRainRadius,
g_cvarLog,
g_cvarAddType,
g_cvarIncapacitated,
g_cvarPPDecay;
float g_fRadius, g_fPower, g_fDuration, g_fRainDur, g_fRainRadius, g_fPPDecay;
bool g_bLog, g_bAddType;
int g_iIncaps;

UserMsg g_FadeUserMsgId;

bool g_isSequel = false;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion ev = GetEngineVersion();
	if (ev == Engine_Left4Dead)
	{
		return APLRes_Success;
	}
	else if (ev == Engine_Left4Dead2)
	{
		g_isSequel = true;
		return APLRes_Success;
	}
	strcopy(error, err_max, "Plugin only supports Left 4 Dead and Left 4 Dead 2.");
	return APLRes_SilentFailure;
}

//Plugin Info
public Plugin myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESC,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
}

public void OnPluginStart()
{
	LogDebug("####### Initializing Plugin... #######");
	
	LogDebug("Creating necessary ConVars...");
	//Cvars
	static char desc_str[64];
	Format(desc_str, sizeof(desc_str), "%s version.", PLUGIN_NAME_SHORT);
	static char cmd_str[64];
	Format(cmd_str, sizeof(cmd_str), "%s_version", PLUGIN_NAME_TECH);
	ConVar version_cvar = CreateConVar(cmd_str, PLUGIN_VERSION, desc_str, FCVAR_NOTIFY|FCVAR_REPLICATED|FCVAR_DONTRECORD);
	if (version_cvar != null)
		version_cvar.SetString(PLUGIN_VERSION);
	
	Format(cmd_str, sizeof(cmd_str), "%s_explosion_radius", PLUGIN_NAME_TECH);
	g_cvarRadius = CreateConVar(cmd_str, "350", "Radius for the Create Explosion's command explosion.", FCVAR_NONE, true, 0.0);
	g_cvarRadius.AddChangeHook(CC_CCmd_Radius);
	
	Format(cmd_str, sizeof(cmd_str), "%s_explosion_power", PLUGIN_NAME_TECH);
	g_cvarPower = CreateConVar(cmd_str, "350", "Power of the Create Explosion's command explosion.", FCVAR_NONE, true, 0.0);
	g_cvarPower.AddChangeHook(CC_CCmd_Power);
	
	Format(cmd_str, sizeof(cmd_str), "%s_explosion_duration", PLUGIN_NAME_TECH);
	g_cvarDuration = CreateConVar(cmd_str, "15", "Duration of the Create Explosion's command explosion fire trace.", FCVAR_NONE, true, 0.0);
	g_cvarDuration.AddChangeHook(CC_CCmd_Duration);
	
	Format(cmd_str, sizeof(cmd_str), "%s_rain_duration", PLUGIN_NAME_TECH);
	g_cvarRainDur = CreateConVar(cmd_str, "10", "Time out for the gnome's rain or l4d1 survivors rain.", FCVAR_NONE, true, 0.0);
	g_cvarRainDur.AddChangeHook(CC_CCmd_RainDur);
	
	Format(cmd_str, sizeof(cmd_str), "%s_rain_radius", PLUGIN_NAME_TECH);
	g_cvarRainRadius = CreateConVar(cmd_str, "300", "Maximum radius of the gnome rain or l4d1 rain.\nWill also affect the air strike radius.", FCVAR_NONE, true, 0.0);
	g_cvarRainRadius.AddChangeHook(CC_CCmd_RainRadius);
	
	Format(cmd_str, sizeof(cmd_str), "%s_log", PLUGIN_NAME_TECH);
	g_cvarLog = CreateConVar(cmd_str, "1", "Log admin actions when they use a command?", FCVAR_NONE, true, 0.0, true, 1.0);
	g_cvarLog.AddChangeHook(CC_CCmd_Log);
	
	Format(cmd_str, sizeof(cmd_str), "%s_menutype", PLUGIN_NAME_TECH);
	g_cvarAddType = CreateConVar(cmd_str, "1", "How should the commands be added to the menu?\n0: Create new category.\n1: Add to default categories.", FCVAR_NONE, true, 0.0, true, 1.0);
	g_cvarAddType.AddChangeHook(CC_CCmd_AddType);
	
	g_cvarIncapacitated = FindConVar("survivor_max_incapacitated_count");
	g_cvarIncapacitated.AddChangeHook(CC_Find_Incapacitated);
	g_cvarPPDecay = FindConVar("pain_pills_decay_rate");
	g_cvarPPDecay.AddChangeHook(CC_Find_PPDecay);
	
	AutoExecConfig(true, AUTOEXEC_CFG);
	SetCvarValues();
	
	LogDebug("Registering all admin and console commands...");
	//Commands
	RegAdminCmd("sm_vomitplayer", CmdVomitPlayer, DESIRED_FLAGS, "Vomits the desired player");
	RegAdminCmd("sm_incapplayer", CmdIncapPlayer, DESIRED_FLAGS, "Incapacitates a survivor or tank");
	RegAdminCmd("sm_smackillplayer", CmdSmackillPlayer, DESIRED_FLAGS, "Smacks a player to death, sending their body flying.");
	RegAdminCmd("sm_rock", CmdRock, DESIRED_FLAGS, "Launch a tank rock.");
	RegAdminCmd("sm_speedplayer", CmdSpeedPlayer, DESIRED_FLAGS, "Set a player's speed");
	RegAdminCmd("sm_sethpplayer", CmdSetHpPlayer, DESIRED_FLAGS, "Set a player's health");
	RegAdminCmd("sm_colorplayer", CmdColorPlayer, DESIRED_FLAGS, "Set a player's model color");
	RegAdminCmd("sm_setexplosion", CmdSetExplosion, DESIRED_FLAGS, "Creates an explosion on your feet or where you are looking at");
	RegAdminCmd("sm_pipeexplosion", CmdPipeExplosion, DESIRED_FLAGS, "Creates a pipebomb explosion on your feet or where you are looking at");
	RegAdminCmd("sm_norescue", CmdNoRescue, DESIRED_FLAGS, "Forces the rescue vehicle to leave");
	RegAdminCmd("sm_dontrush", CmdDontRush, DESIRED_FLAGS, "Forces a player to re-appear in the starting safe zone");
	RegAdminCmd("sm_changehp", CmdChangeHp, DESIRED_FLAGS, "Will switch a player's health between temporal or permanent");
	RegAdminCmd("sm_airstrike", CmdAirstrike, DESIRED_FLAGS, "Will set an airstrike attack in the player's face");
	RegAdminCmd("sm_godmode", CmdGodMode, DESIRED_FLAGS, "Will activate or deactivate godmode from player");
	RegAdminCmd("sm_l4drain", CmdL4dRain, DESIRED_FLAGS, "Will rain left 4 dead 1 survivors");
	RegAdminCmd("sm_colortarget", CmdColorTarget, DESIRED_FLAGS, "Will color the aiming target entity");
	RegAdminCmd("sm_shakeplayer", CmdShakePlayer, DESIRED_FLAGS, "Will shake a player screen during the desired amount of time");
	RegAdminCmd("sm_weaponrain", CmdWeaponRain, DESIRED_FLAGS, "Will rain the specified weapon");
	RegAdminCmd("sm_cmdplayer", CmdConsolePlayer, DESIRED_FLAGS, "Will control a player's console");
	RegAdminCmd("sm_bleedplayer", CmdBleedPlayer, DESIRED_FLAGS, "Will force a player to bleed");
	//RegAdminCmd("sm_callrescue", CmdCallRescue, DESIRED_FLAGS, "Will call the rescue vehicle");
	RegAdminCmd("sm_hinttext", CmdHintText, DESIRED_FLAGS, "Prints an instructor hint to all players");
	RegAdminCmd("sm_cheat", CmdCheat, DESIRED_FLAGS, "Bypass any command and executes it. Rule: [command] [argument] EX: z_spawn tank");
	RegAdminCmd("sm_wipeentity", CmdWipeEntity, DESIRED_FLAGS, "Wipe all entities with the given name");
	RegAdminCmd("sm_setmodel", CmdSetModel, DESIRED_FLAGS, "Sets a player's model relavite to the models folder");
	RegAdminCmd("sm_setmodelentity", CmdSetModelEntity, DESIRED_FLAGS, "Sets all entities model that match the given classname");
	RegAdminCmd("sm_createparticle", CmdCreateParticle, DESIRED_FLAGS, "Creates a particle with the option to parent it");
	RegAdminCmd("sm_ignite", CmdIgnite, DESIRED_FLAGS, "Ignites a survivor player");
	RegAdminCmd("sm_teleport", CmdTeleport, DESIRED_FLAGS, "Teleports a player to your cursor position");
	RegAdminCmd("sm_teleportent", CmdTeleportEnt, DESIRED_FLAGS, "Teleports all entities with the given classname to your cursor position");
	RegAdminCmd("sm_rcheat", CmdCheatRcon, DESIRED_FLAGS, "Bypass any command and executes it on the server console");
	RegAdminCmd("sm_scanmodel", CmdScanModel, DESIRED_FLAGS, "Scans the model of an entity, if possible");
	RegAdminCmd("sm_grabentity", CmdGrabEntity, DESIRED_FLAGS, "Grabs any entity, if possible");
	if (g_isSequel)
	{
		RegAdminCmd("sm_sizeplayer", CmdSizePlayer, DESIRED_FLAGS, "Resize a player's model (Most likely, their pants)");
		RegAdminCmd("sm_sizeclass", CmdSizeClass, DESIRED_FLAGS, "Will size all entities of the defined classname");
		RegAdminCmd("sm_sizetarget", CmdSizeTarget, DESIRED_FLAGS, "Will size the aiming target entity");
		RegAdminCmd("sm_charge", CmdCharge, DESIRED_FLAGS, "Will launch a survivor far away");
		RegAdminCmd("sm_acidspill", CmdAcidSpill, DESIRED_FLAGS, "Spawns a spitter's acid spill on your the desired player");
		RegAdminCmd("sm_adren", CmdAdren, DESIRED_FLAGS, "Gives a player the adrenaline effect");
		RegAdminCmd("sm_gnomerain", CmdGnomeRain, DESIRED_FLAGS, "Will rain gnomes within your position");
		RegAdminCmd("sm_gnomewipe", CmdGnomeWipe, DESIRED_FLAGS, "Will delete all the gnomes in the map");
	}
	RegAdminCmd("sm_temphp", CmdTempHp, DESIRED_FLAGS, "Sets a player temporary health into the desired value");
	RegAdminCmd("sm_revive", CmdRevive, DESIRED_FLAGS, "Revives an incapacitated player");
	RegAdminCmd("sm_oldmovie", CmdOldMovie, DESIRED_FLAGS, "Sets a player into black and white");
	RegAdminCmd("sm_panic", CmdPanic, DESIRED_FLAGS, "Forces a panic event");
	RegAdminCmd("sm_shove", CmdShove, DESIRED_FLAGS, "Shoves a player");
	
	//Development
	RegAdminCmd("sm_entityinfo", CmdEntityInfo, DESIRED_FLAGS, "Returns the aiming entity classname");
	RegAdminCmd("sm_ccrefresh", CmdCCRefresh, DESIRED_FLAGS, "Refreshes the menu items");
	RegAdminCmd("sm_cchelp", CmdHelp, DESIRED_FLAGS, "Prints the entire list of commands");
	
	LogDebug("Hooking events...");
	//Events
	HookEvent("round_end", OnRoundEnd);
	HookEvent("finale_vehicle_ready", OnVehicleReady);
	if (g_isSequel) HookEvent("player_hurt", FixSpitDmgEffects);
	
	LogDebug("Loading Translations");
	//Translations
	LoadTranslations("common.phrases");
	
	LogDebug("Preparing necessary calls...");
	//SDKCalls
	GetGamedata();
	
	/*g_hGameConf = LoadGameConfigFile("l4d2customcmds");
	if (g_hGameConf == null)
	{
		SetFailState("Couldn't find the offsets and signatures file. Please, check that it is installed correctly.");
	}*/
	
	LogDebug("Addin commands to the topmenu (Admin Menu)");
	TopMenu topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != null))
	{
		OnAdminMenuReady(topmenu);
	}
	
	g_FadeUserMsgId = GetUserMessageId("Fade");
	
	LogDebug("####### Plugin is ready #######");
}

void CC_CCmd_Radius(ConVar convar, const char[] oldValue, const char[] newValue)		{ g_fRadius =	convar.FloatValue; }
void CC_CCmd_Power(ConVar convar, const char[] oldValue, const char[] newValue)		{ g_fPower =		convar.FloatValue; }
void CC_CCmd_Duration(ConVar convar, const char[] oldValue, const char[] newValue)		{ g_fDuration =	convar.FloatValue; }
void CC_CCmd_RainDur(ConVar convar, const char[] oldValue, const char[] newValue)		{ g_fRainDur =	convar.FloatValue; }
void CC_CCmd_RainRadius(ConVar convar, const char[] oldValue, const char[] newValue)	{ g_fRainRadius =	convar.FloatValue; }
void CC_CCmd_Log(ConVar convar, const char[] oldValue, const char[] newValue)			{ g_bLog =		convar.BoolValue; }
void CC_CCmd_AddType(ConVar convar, const char[] oldValue, const char[] newValue)		{ g_bAddType =	convar.BoolValue; }
void SetCvarValues()
{
	CC_CCmd_Radius(g_cvarRadius, "", "");
	CC_CCmd_Power(g_cvarPower, "", "");
	CC_CCmd_Duration(g_cvarDuration, "", "");
	CC_CCmd_RainDur(g_cvarRainDur, "", "");
	CC_CCmd_RainRadius(g_cvarRainRadius, "", "");
	CC_CCmd_Log(g_cvarLog, "", "");
	CC_CCmd_AddType(g_cvarAddType, "", "");
	CC_Find_Incapacitated(g_cvarIncapacitated, "", "");
	CC_Find_PPDecay(g_cvarPPDecay, "", "");
}
void CC_Find_Incapacitated(ConVar convar, const char[] oldValue, const char[] newValue)	{ g_iIncaps =	convar.IntValue; }
void CC_Find_PPDecay(ConVar convar, const char[] oldValue, const char[] newValue) 		{ g_fPPDecay =	convar.FloatValue; }

public void OnMapStart()
{
	LogDebug("Map started, precaching sounds and particles");
	PrecacheSound(EXPLOSION_SOUND);
	PrecacheSound(EXPLOSION_SOUND2);
	PrecacheSound(EXPLOSION_SOUND3);
	static char sliceSnd[34];
	for (int i = 1; i <= 6; i++)
	{
		Format(sliceSnd, sizeof(sliceSnd), "player/PZ/hit/zombie_slice_%i.wav", i);
		PrecacheSound(sliceSnd);
	}
	
	PrecacheModel(ZOEY_MODEL);
	PrecacheModel(LOUIS_MODEL);
	PrecacheModel(FRANCIS_MODEL);
	PrecacheModel("sprites/muzzleflash4.vmt");
	
	PrefetchSound(EXPLOSION_SOUND);
	PrefetchSound(EXPLOSION_SOUND2);
	PrefetchSound(EXPLOSION_SOUND3);
	
	PrecacheParticle(FIRE_PARTICLE);
	PrecacheParticle(EXPLOSION_PARTICLE);
	PrecacheParticle(EXPLOSION_PARTICLE2);
	PrecacheParticle(EXPLOSION_PARTICLE3);
	PrecacheParticle(BURN_IGNITE_PARTICLE);
	
	LogDebug("Done precaching sounds and particles");
}

public void OnMapEnd()
{
	LogDebug("Map end, resetting variables");
	g_bVehicleReady = false;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		g_bGrab[i] = false;
	}
	
	for (int i = MaxClients+1; i < ARRAY_SIZE; i++)
	{
		g_iLastGrabbedEntity[i] = -1;
		g_bGrabbed[i] = false;
	}
}
//g_bAlterSpit = false;
public void OnEntityCreated(int entity, const char[] classname)
{
	if (classname[0] == 'i' && strcmp(classname, "insect_swarm", false) == 0)
		SDKHook(entity, SDKHook_SpawnPost, AlterSpit);
}
void AlterSpit(int spit)
{
	if (!RealValidEntity(spit)) return;
	
	//PrintToServer("Found spit! %i", spit);
	//PrintToServer("Spit team is %i", GetEntProp(spit, Prop_Send, "m_iTeamNum"));
	int owner = GetEntPropEnt(spit, Prop_Send, "m_hOwnerEntity");
	if (!RealValidEntity(owner))
	{
		SetEntProp(spit, Prop_Send, "m_iTeamNum", 3);
		//SetEntPropEnt(spit, Prop_Send, "m_hOwnerEntity", client);
	}
}

Action CmdCCRefresh(int client, int args)
{
	LogDebug("Refreshing the admin menu");
	PrintToChat(client, "[SM] Refreshing the admin menu...");
	
	TopMenu topmenu = GetAdminTopMenu();
	
	AddMenuItems(topmenu);
	return Plugin_Handled;
}

Action CmdHelp(int client, int args)
{
	PrintToChat(client, "\x03********************** Custom Commands List **********************");
	PrintToChat(client, "- \"sm_vomitplayer\": Vomits the desired player (Usage: sm_vomitplayer <#userid|name>) | Example: !vomitplayer @me");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_incapplayer\": Incapacitates a survivor or tank (Usage: sm_incapplayer <#userid|name> | Example: !incapplayer @me)");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_speedplayer\": Set a player's speed (Usage: sm_speedplayer <#userid|name> <value>) | Example: !speedplayer @me 1.5");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_sethpplayer\": Set a player's health (Usage: sm_sethpplayer <#userid|name> <amount>) | Example: !sethpplayer @me 50");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_colorplayer\": Set a player's model color (Usage: sm_colorplayer <#userid|name> <R G B A>) | Example: !colorplayer @me \"24 34 38 0\"");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_setexplosion\": Creates an explosion on your feet or where you are looking at (Usage: sm_setexplosion <position |cursor>) | Example: !setexplosion position");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_sizeplayer\": Resize a player's model scale (Usage: sm_sizeplayer <#userid|name> <value>) | Example: !sizeplayer @me 0.1");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_norescue\": Forces the rescue vehicle to leave | Example: !norescue");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_dontrush\": Forces a player to re-appear in the starting safe zone (Usage: sm_dontrush <#userid|name>) | Example: !dontrush RusherName");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_changehp\": Will switch a player's health between temporal or permanent (Usage: sm_changehp <#userid|name> <perm|temp>) | Example: !changehp @me perm");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_airstrike\": Will send an airstrike attack to the target (Usage: sm_airstrike <#userid|name>) | Example: !airstrike @me");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_gnomerain\": Will rain gnomes within your position | Example: !gnomerain");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_gnomewipe\": Will delete all the gnomes in the map | Example: !gnomewipe");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_godmode\": Will activate or deactivate godmode from player (Usage: sm_godmode <#userid|name>) | Example: !godmode @me");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_l4drain\": Will rain left 4 dead 1 survivors | Example: !l4drain");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_colortarget\": Will change the color of the aiming target entity (Usage: sm_colortarget <R G B A>) | Example: !colortarget \"43 55 255 179\"");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_sizetarget\": Will re-size the aiming target entity (Usage: sm_sizetarget <value>) | Example: !sizetarget 5.0");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_shakeplayer\": Will shake a player screen during the desired amount of time (Usage: sm_shake <#userid|name> <duration>) | Example: !shakeplayer @me 5");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_charge\": Will launch a survivor far away (Usage: sm_charge <#userid|name>) | Example: !charge Coach");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_weaponrain\": Will rain the specified weapon (Usage: sm_weaponrain <weapon name>) | Example: !weaponrain adrenaline");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_cmdplayer\": Will control a player's console (Usage: sm_cmdplayer <#userid|name> <command>) | Example: !cmdplayer PlayerName \"+forward\"");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_bleedplayer\": Will force a player to bleed (Usage: sm_bleedplayer <#userid|name> <duration>) | Example: !bleedplayer @me 7");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_hinttext\": Prints an instructor hint to all players (Usage: sm_hinttext <hint>) | Example: !hinttext \"This is a hint text message\"");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_cheat\": Bypass any command and executes it (Usage: sm_cheat <command> <arguments>*) | Example: !cheat z_spawn \"tank auto\"");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_wipeentity\": Wipe all entities with the given classname (Usage: !wipeentity <classname>) | Example: !wipeentity infected");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_setmodel\": Sets a player's model relative to the models folder (Usage: sm_setmodel <#userid|name> <model>) | Example: !setmodel @me models/props_interiors/table_bedside.mdl");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_setmodelentity\": Sets all entities model that match the given classname (Usage: sm_setmodelentity <classname> <model>) | Example: !setmodelentity infected models/props_interiors/table_bedside.mdl");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_createparticle\": Creates a particle with the option to parent it (Usage: sm_createparticle <#userid|name> <particle> <parent: yes|no> <duration> Example: !createparticle @me ParticleName no 5");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_ignite\": Ignites a survivor player (Usage: sm_ignite <#userid|name> <duration>) | Example: !ignite @me 4");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_teleport\": Teleports a player to your cursor position (Usage: sm_teleport <#userid|name>) | Example: !teleport Coach");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_teleportent\": Teleports all entities with the given classname to your cursor position (Usage: sm_teleportent <classname>) | Example: !teleportent weapon_adrenaline");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_rcheat\": Bypass any command and executes it on the server console (Usage: sm_rcheat <command>) | Example: !rcheat director_stop");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_scanmodel\": Scans the model of an aiming entity, if possible | Example: !scanmodel");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_grabentity\": Grabs an aiming entity, if possible | Example: !grabentity");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_acidspill\": Spawns a spitter's acid spill on your the desired player (Usage: sm_acidspill <#userid|name>) | Example: !acidspill @me");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_adren\": Gives a player the adrenaline effect (Usage: sm_adren <#userid|name>) | Example: !adren Nick");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_temphp\": Sets a player temporary health into the desired value (Usage: sm_temphp <#userid|name> <amount>) | Example: !temphp Rochelle 50");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_revive\": Revives an incapacitated player (Usage: sm_revive <#userid|name>) | Example: !revive Coach");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_oldmovie\": Sets a player into black and white (Usage: sm_oldmovie <#userid|name>) | Example: !oldmovie @me");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_panic\": Forces a panic event, ignoring the director | Example: !panic");
	PrintToChat(client, " ");
	PrintToChat(client, "- \"sm_shove\": Shoves a player (Usage: sm_shove <#userid|name>) | Example: !shove @all");
	PrintToChat(client, " ");
	PrintToChat(client, " ");
	PrintToChat(client, "\x04*: Optional argument");
	PrintToChat(client, "\x03[SM] Open your console to check the command list");
	return Plugin_Handled;
}

// EVENTS //
void OnVehicleReady(Event event, const char[] event_name, bool dontBroadcast)
{
	g_bVehicleReady = true;
}

void OnRoundEnd(Event event, const char[] event_name, bool dontBroadcast)
{
	g_bVehicleReady = false;
}

// COMMANDS //
Action CmdVomitPlayer(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1)
	{ PrintToChat(client, "[SM] Usage: sm_vomitplayer <#userid|name>"); return Plugin_Handled; }
	
	static char arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	for (int i = 0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'Vomit Player' command on '%N'", client, i);
		VomitPlayer(target_list[i], client);
	}
	return Plugin_Handled;
}

Action CmdIncapPlayer(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1)
	{ PrintToChat(client, "[SM] Usage: sm_incapplayer <#userid|name>"); return Plugin_Handled; }
	
	static char arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	for (int i = 0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'Incap Player' command on '%N'", client, i);
		IncapPlayer(target_list[i], client);
	}
	return Plugin_Handled;
}

Action CmdSmackillPlayer(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1)
	{ PrintToChat(client, "[SM] Usage: sm_smackillplayer <#userid|name>"); return Plugin_Handled; }
	
	static char arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	for (int i = 0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'Smackill Player' command on '%N'", client, i);
		SmackillPlayer(target_list[i], client);
	}
	return Plugin_Handled;
}

Action CmdRock(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	static char arg[65];
	if (args < 1 || args > 1)
	{ strcopy(arg, sizeof(arg), "position"); }
	else
	{ GetCmdArg(1, arg, sizeof(arg)); }
	
	bool isSuccessful = false;
	
	if (StrContains(arg, "position", false) != -1)
	{
		float pos[3], ang[3];
		GetClientAbsOrigin(client, pos);
		GetClientEyeAngles(client, ang);
		
		LaunchRock(pos, ang);
		isSuccessful = true;
	}
	else if (StrContains(arg, "cursor", false) != -1)
	{
		float VecOrigin[3], ang[3];
		DoClientTrace(client, MASK_OPAQUE, true, VecOrigin);
		GetClientEyeAngles(client, ang);
		
		LaunchRock(VecOrigin, ang);
		isSuccessful = true;
	}
	
	if (isSuccessful)
	{ LogCommand("'%N' used the 'Set Explosion' command", client); }
	else
	{ PrintToChat(client, "[SM] Specify the explosion position"); }
	return Plugin_Handled;
}

Action CmdSpeedPlayer(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 2)
	{ PrintToChat(client, "[SM] Usage: sm_speedplayer <#userid|name> [value]"); return Plugin_Handled; }
	
	static char arg[65], arg2[65]; float speed;
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	speed = StringToFloat(arg2);
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	for (int i = 0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'Speed Player' command on '%N' with value <%f>", client, i, speed);
		ChangeSpeed(target_list[i], client, speed);
	}
	return Plugin_Handled;
}

Action CmdSetHpPlayer(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 2)
	{ PrintToChat(client, "[SM] Usage: sm_sethpplayer <#userid|name> [amount]"); return Plugin_Handled; }
	
	static char arg[65], arg2[65];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	int health = StringToInt(arg2);
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	for (int i = 0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'Set Health' command on '%N' with value <%i>", client, i, health);
		SetHealth(target_list[i], client, health);
	}
	return Plugin_Handled;
}

Action CmdColorPlayer(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 2)
	{ PrintToChat(client, "[SM] Usage: sm_colorplayer <#userid|name> [R G B A]"); return Plugin_Handled; }
	
	static char arg[65], arg2[65];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	for (int i = 0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'Color Player' command on '%N' with value <%s>", client, i, arg2);
		ChangeColor(target_list[i], client, arg2);
	}
	return Plugin_Handled;
}

Action CmdColorTarget(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1)
	{ PrintToChat(client, "[SM] Usage: sm_colortarget [R G B A]"); return Plugin_Handled; }
	
	int target = GetClientAimTarget(client, false);
	if (!RealValidEntity(target))
	{ PrintToChat(client, "[SM] Invalid entity or looking to nothing"); return Plugin_Handled; }
	
	static char arg[256];
	GetCmdArg(1, arg, sizeof(arg));
	DispatchKeyValue(target, "rendercolor", arg);
	DispatchKeyValue(target, "color", arg);
	
	static char class[64];
	GetEntityClassname(target, class, sizeof(class));
	
	LogCommand("'%N' used the 'Color Target' command on entity '%i' of classname '%s' with value <%s>", client, target, class, arg);
	return Plugin_Handled;
}

Action CmdSizeTarget(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1)
	{ PrintToChat(client, "[SM] Usage: sm_sizetarget [scale]"); return Plugin_Handled; }
	
	int target = GetClientAimTarget(client, false);
	if (!RealValidEntity(target))
	{ PrintToChat(client, "[SM] Invalid entity or looking to nothing"); return Plugin_Handled; }
	
	static char arg[24];
	GetCmdArg(1, arg, sizeof(arg));
	float scale = StringToFloat(arg);
	SetEntPropFloat(target, Prop_Send, "m_flModelScale", scale);
	
	static char class[64];
	GetEntityClassname(target, class, sizeof(class));
	
	LogCommand("'%N' used the 'Size Target' command on entity '%i' of classname '%s' with value <%s>", client, target, class, arg);
	return Plugin_Handled;
}

Action CmdSizeClass(int client, int args)
{
	if (args < 1)
	{ PrintToChat(client, "[SM] Usage: sm_sizeclass [classname] [scale]"); return Plugin_Handled; }
	
	static char arg[128], arg2[24];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	float scale = StringToFloat(arg2);
	int ent_class = FindEntityByClassname(-1, arg);
	
	if (RealValidEntity(ent_class))
	{
		for (;ent_class < GetMaxEntities(); ent_class++)
		{
			if (!RealValidEntity(ent_class)) continue;
			
			static char class[64];
			GetEntityClassname(ent_class, class, sizeof(class));
			if (strcmp(class, arg, false) != 0) continue;
			
			SetEntPropFloat(ent_class, Prop_Send, "m_flModelScale", scale);
		}
	}
	else
	{ return Plugin_Handled; }
	
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	LogCommand("'%N' used the 'Size Class' command on classname '%s' with value <%f>", client, arg, scale);
	return Plugin_Handled;
}

Action CmdSetExplosion(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1 || args > 1)
	{ PrintToChat(client, "[SM] Usage: sm_setexplosion [position | cursor]"); return Plugin_Handled; }
	
	bool isSuccessful = false;
	
	static char arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	if (StrContains(arg, "position", false) != -1)
	{
		float pos[3];
		GetClientAbsOrigin(client, pos);
		CreateExplosion(pos);
		isSuccessful = true;
	}
	else if (StrContains(arg, "cursor", false) != -1)
	{
		/*float VecOrigin[3], VecAngles[3];
		GetClientEyePosition(client, VecOrigin);
		GetClientEyeAngles(client, VecAngles);
		
		TR_TraceRayFilter(VecOrigin, VecAngles, MASK_OPAQUE, RayType_Infinite, TraceRayDontHitSelf, client);
		if (TR_DidHit(null))
		{ TR_GetEndPosition(VecOrigin); }
		else
		{ PrintToChat(client, "Vector out of world geometry. Exploding on origin instead"); }*/
		
		float VecOrigin[3];
		DoClientTrace(client, MASK_OPAQUE, true, VecOrigin);
		
		CreateExplosion(VecOrigin);
		isSuccessful = true;
	}
	
	if (isSuccessful)
	{ LogCommand("'%N' used the 'Set Explosion' command", client); }
	else
	{ PrintToChat(client, "[SM] Specify the explosion position"); }
	return Plugin_Handled;
}

Action CmdPipeExplosion(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1 || args > 1)
	{ PrintToChat(client, "[SM] Usage: sm_pipeexplosion [position | cursor]"); return Plugin_Handled; }
	
	bool isSuccessful = false;
	
	static char arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	if (StrContains(arg, "position", false) != -1)
	{
		float pos[3];
		GetClientAbsOrigin(client, pos);
		PipeExplosion(client, pos);
		isSuccessful = true;
	}
	else if (StrContains(arg, "cursor", false) != -1)
	{
		/*float VecOrigin[3], VecAngles[3];
		GetClientEyePosition(client, VecOrigin);
		GetClientEyeAngles(client, VecAngles);
		
		TR_TraceRayFilter(VecOrigin, VecAngles, MASK_OPAQUE, RayType_Infinite, TraceRayDontHitSelf, client);
		if (TR_DidHit(null))
		{ TR_GetEndPosition(VecOrigin); }
		else
		{ PrintToChat(client, "Vector out of world geometry. Exploding on origin instead"); }*/
		
		float VecOrigin[3];
		DoClientTrace(client, MASK_OPAQUE, true, VecOrigin);
		
		PipeExplosion(client, VecOrigin);
		isSuccessful = true;
	}
	
	if (isSuccessful)
	{ LogCommand("'%N' used the 'Pipe Explosion' command", client); }
	else
	{ PrintToChat(client, "[SM] Specify the explosion position"); }
	return Plugin_Handled;
}

Action CmdSizePlayer(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 2)
	{ PrintToChat(client, "[SM] Usage: sm_sizeplayer <#userid|name> [value]"); return Plugin_Handled; }
	
	static char arg[65], arg2[65]; float scale;
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	scale = StringToFloat(arg2);
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	for (int i = 0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'Size Player' command on '%N' with value <%f>", client, i, scale);
		ChangeScale(target_list[i], client, scale);
	}
	
	return Plugin_Handled;
}

Action CmdNoRescue(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	NoRescue(client);
	
	return Plugin_Handled;
}

Action CmdDontRush(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1)
	{ PrintToChat(client, "[SM] Usage: sm_dontrush <#userid|name>"); return Plugin_Handled; }
	static char arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	for (int i = 0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'Anti Rush' command on '%N'", client, i);
		TeleportBack(target_list[i], client);
	}
	
	return Plugin_Handled;
}

/*Action CmdBugPlayer(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1)
	{ PrintToChat(client, "[SM] Usage: sm_bugplayer <#userid|name>"); return Plugin_Handled; }
	
	static char arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	for (int i = 0; i < target_count; i++)
	{
		AcceptEntityInput(target_list[i], "becomeragdoll");
	}
	return Plugin_Handled;
}*/

/*Action CmdDestroyPlayer(int client, int args)
{
	if (args < 1)
	{ PrintToChat(client, "[SM] Usage: sm_destroyplayer <#userid|name>"); return Plugin_Handled; }
	
	static char arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	for (int i = 0; i < target_count; i++)
	{
		LaunchMissile(target_list[i], client);
	}
	
	static char name[MAX_NAME_LENGTH];
	int target;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (Cmd_CheckClient(i, -1, false, -1, false))
		{
			GetClientName(i, name, sizeof(name));
			if (strcmp(name, arg, false) == 0)
			{
				target = i;
			}
		}
	}
	LaunchMissile(target, client);
	return Plugin_Handled;
}
*/

Action CmdAirstrike(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1)
	{ PrintToChat(client, "[SM] Usage: sm_airstrike <#userid|name>"); return Plugin_Handled; }
	
	static char arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	for (int i = 0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'Airstrike' command on '%N'", client, i);
		Airstrike(target_list[i]);
	}
	
	return Plugin_Handled;
}

Action CmdOldMovie(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1)
	{
		PrintToChat(client, "[SM] Usage: sm_oldmovie <#userid|name>");
		return Plugin_Handled;
	}
	static char arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	for (int i = 0; i < target_count; i++)
	{
		float health = GetClientHealth(client)+1.0;
		BlackAndWhite(target_list[i], client);
		SetEntityHealth(target_list[i], 1);
		SetTempHealth(target_list[i], health);
	}
	return Plugin_Handled;
}

Action CmdChangeHp(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1)
	{ PrintToChat(client, "[SM] Usage: sm_changehp <#userid|name> [perm | temp]"); return Plugin_Handled; }
	
	static char arg[65], arg2[65];
	int type = 0;
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	if (strncmp(arg2, "perm", 4, false) == 0)
	{ type = 1; }
	else if (strncmp(arg2, "temp", 4, false) == 0)
	{ type = 2; }
	
	if (type <= 0 || type > 2)
	{ PrintToChat(client, "[SM] Specify the health style you want"); return Plugin_Handled; }
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	for (int i = 0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'Change Health Type' command on '%N' with value <%s>", client, i, arg2);
		SwitchHealth(target_list[i], client, type);
	}
	
	return Plugin_Handled;
}

Action CmdGnomeRain(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	LogCommand("'%N' used the 'Gnome Rain' command", client);
	StartGnomeRain(client);
	return Plugin_Handled;
}

Action CmdL4dRain(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	LogCommand("'%N' used the 'L4D1 Rain' command", client);
	StartL4dRain(client);
	return Plugin_Handled;
}

Action CmdGnomeWipe(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	static char classname[14];
	int count = 0;
	for (int i = MaxClients; i <= GetMaxEntities(); i++)
	{
		if (!RealValidEntity(i)) continue;
		
		GetEntityClassname(i, classname, sizeof(classname));
		if (strcmp(classname, "weapon_gnome", false) == 0)
		{
			AcceptEntityInput(i, "Kill");
			count++;
		}
	}
	PrintToChat(client, "[SM] Succesfully wiped %i gnomes", count);
	count = 0;
	
	LogCommand("'%N' used the 'Gnome Wipe' command", client);
	return Plugin_Handled;
}

/*Action CmdWipeBody(int client, int args)
{
	static char classname[32];
	int count = 0;
	for (int i = MaxClients; i <= GetMaxEntities(); i++)
	{
		if (!RealValidEntity(i)) continue;
		
		GetEntityClassname(i, classname, sizeof(classname));
		if (strcmp(classname, "prop_ragdoll", false) == 0)
		{
			AcceptEntityInput(i, "Kill");
			count++;
		}
	}
	PrintToChat(client, "[SM] Succesfully wiped %i bodies", count);
	count = 0;
	
	return Plugin_Handled;
}
*/

Action CmdGodMode(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1)
	{ PrintToChat(client, "[SM] Usage: sm_godmode <#userid|name>"); return Plugin_Handled; }
	
	static char arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	for (int i = 0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'God Mode' command on '%N'", client, i);
		GodMode(target_list[i], client);
	}
	
	return Plugin_Handled;
}

Action CmdCharge(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (sdkCallPushPlayer == null)
	{
		PrintToChat(client, "[SM] Charge command is unusable: gamedata signature for Fling is broken!");
		return Plugin_Handled;
	}
	
	if (args < 1)
	{ PrintToChat(client, "[SM] Usage: sm_charge <#userid|name>"); return Plugin_Handled; }
	
	static char arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	for (int i = 0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'Charge' command on '%N'", client, i);
		Charge(target_list[i], client);
	}
	
	return Plugin_Handled;
}

Action CmdShakePlayer(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 2)
	{
		PrintToChat(client, "[SM] Usage: sm_shake <#userid|name> [duration]");
		return Plugin_Handled;
	}
	static char arg[65], arg2[65];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	float duration = StringToFloat(arg2);
	
	for (int i = 0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'Shake' command on '%N' with value <%f>", client, i, duration);
		Shake(target_list[i], client, duration);
	}
	
	return Plugin_Handled;
}

Action CmdConsolePlayer(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 2)
	{
		PrintToChat(client, "[SM] Usage: sm_cmdplayer <#userid|name> [command]");
		return Plugin_Handled;
	}
	static char arg[65], arg2[65];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list, COMMAND_FILTER_CONNECTED);
	
	for (int i = 0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'Client Console' command on '%N' with value <%s>", client, i, arg2);
		ClientCommand(target_list[i], arg2);
	}
	
	return Plugin_Handled;
}

Action CmdWeaponRain(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1)
	{
		PrintToChat(client, "[SM] Usage: sm_weaponrain [weapon type] [Example: !weaponrain adrenaline]");
		return Plugin_Handled;
	}
	static char arg[65];
	GetCmdArgString(arg, sizeof(arg));
	if (IsValidWeapon(arg))
	{
		WeaponRain(arg, client);
	}
	else
	{
		PrintToChat(client, "[SM] Wrong weapon type");
	}
	
	LogCommand("'%N' used the 'Weapon Rain' command with value <%s>", client, arg);
	
	return Plugin_Handled;
}

Action CmdBleedPlayer(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 2)
	{
		PrintToChat(client, "[SM] Usage: sm_bleedplayer <#userid|name> [duration]");
		return Plugin_Handled;
	}
	
	static char arg[65], arg2[65];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	float duration = StringToFloat(arg2);
	
	for (int i = 0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'Bleed' command on '%N' with value <%f>", client, i, duration);
		Bleed(target_list[i], client, duration);
	}
	
	return Plugin_Handled;
}

Action CmdHintText(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	static char arg2[65];
	GetCmdArgString(arg2, sizeof(arg2));
	InstructorHint(arg2);
	
	LogCommand("'%N' used the 'Hint Text' command with value <%s>", client, arg2);
	return Plugin_Handled;
}

Action CmdCheat(int client, int args)
{
	static char command[256], buffer2[256];
	GetCmdArg(1, command, sizeof(command));
	GetCmdArg(2, buffer2, sizeof(buffer2));
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_cheat <command>");
		return Plugin_Handled;
	}
	
	if (!Cmd_CheckClient(client, client, false, -1, true))
	{
		int cmdflags = GetCommandFlags(command);
		SetCommandFlags(command, cmdflags & ~FCVAR_CHEAT);
		ServerCommand("%s", buffer2);
		SetCommandFlags(command, cmdflags);
		
		LogCommand("Console used the 'Cheat' command with value <%s>", buffer2);
	}
	else
	{
		CheatCommand(client, command, buffer2);
		LogCommand("'%N' used the 'Cheat' command with value <%s>", client, buffer2);
	}
	return Plugin_Handled;
}

Action CmdWipeEntity(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	static char arg[128], class[64];
	GetCmdArgString(arg, sizeof(arg));
	int count = 0;
	for (int i = MaxClients+1; i <= GetMaxEntities(); i++)
	{
		if (!RealValidEntity(i)) continue;
		GetEntityClassname(i, class, sizeof(class));
		if (strcmp(class, arg, false) == 0)
		{
			AcceptEntityInput(i, "Kill");
			count++;
		}
	}
	PrintToChat(client, "[SM] Succesfully deleted %i <%s> entities", count, arg);
	count = 0;
	
	LogCommand("'%N' used the 'Wipe Entity' command on classname <%s>", client, arg);
	return Plugin_Handled;
}

Action CmdSetModel(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 2)
	{
		PrintToChat(client, "[SM] Usage: sm_setmodel <#userid|name> [model]");
		PrintToChat(client, "Example: !setmodel @me models/props_interiors/table_bedside.mdl ");
		return Plugin_Handled;
	}
	static char arg[256], arg2[256];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	PrecacheModel(arg2);
	for (int i = 0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'Set Model' command on '%N' with value <%s>", client, i, arg2);
		SetEntityModel(target_list[i], arg2);
	}
	
	return Plugin_Handled;
}

Action CmdSetModelEntity(int client, int args)
{
	if (args < 2)
	{
		PrintToChat(client, "[SM] Usage: sm_setmodelentity <classname> [model]");
		PrintToChat(client, "Example: !setmodelentity infected models/props_interiors/table_bedside.mdl");
		return Plugin_Handled;
	}
	static char arg[128], arg2[128], class[64];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	PrecacheModel(arg2);
	int count = 0;
	for (int i = MaxClients+1; i <= GetMaxEntities(); i++)
	{
		if (RealValidEntity(i))
		{
			GetEntityClassname(i, class, sizeof(class));
			if (strcmp(class, arg, false) == 0)
			{
				SetEntityModel(i, arg2);
				count++;
			}
		}
	}
	PrintToChat(client, "[SM] Succesfully set the %s model to %i <%s> entities", arg2, count, arg);
	count = 0;
	
	LogCommand("'%N' used the 'Set Model Entity' command on classname '%s' with value <%s>", client, arg, arg2);
	return Plugin_Handled;
}

Action CmdCreateParticle(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 4)
	{
		PrintToChat(client, "[SM] Usage: sm_createparticle <#userid|name> [particle] [parent: yes|no] [duration]");
		PrintToChat(client, "Example: !createparticle @me no 5 (Teleports the particle to my position, but don't parent it and stop the effect in 5 seconds)");
		return Plugin_Handled;
	}
	static char arg[64], arg2[32], arg3[8], arg4[24];
	
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	GetCmdArg(3, arg3, sizeof(arg3));
	GetCmdArg(4, arg4, sizeof(arg4));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list, COMMAND_FILTER_CONNECTED);
	
	bool parent = false;
	if (strncmp(arg3, "yes", 3, false) == 0)
	{
		parent = false;
	}
	else if (strncmp(arg3, "no", 2, false) == 0)
	{
		parent = true;
	}
	else
	{
		PrintToChat(client, "[SM] No parent option given. As default it won't be parented");
	}
	float duration = StringToFloat(arg4);
	for (int i = 0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'Create Particle' command on '%N' with value <%s> <%s> <%f>", client, i, arg2, arg3, duration);
		CreateParticle(target_list[i], arg2, parent, duration);
	}
	
	return Plugin_Handled;
}

Action CmdIgnite(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 2)
	{
		PrintToChat(client, "[SM] Usage: sm_ignite <#userid|name> [duration]");
		return Plugin_Handled;
	}
	static char arg[64], arg2[8];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	float duration = StringToFloat(arg2);
	for (int i=0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'Ignite Player' command on '%N' with value <%f>", client, i, duration);
		IgnitePlayer(target_list[i], duration);
	}
	
	return Plugin_Handled;
}

Action CmdTeleport(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1)
	{
		PrintToChat(client, "[SM] Usage: sm_teleport <#userid|name>");
		return Plugin_Handled;
	}
	static char arg[64];
	GetCmdArg(1, arg, sizeof(arg));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	/*float VecOrigin[3], VecAngles[3];
	GetClientEyePosition(client, VecOrigin);
	GetClientEyeAngles(client, VecAngles);
	TR_TraceRayFilter(VecOrigin, VecAngles, MASK_OPAQUE, RayType_Infinite, TraceRayDontHitSelf, client);
	if (TR_DidHit(null))
	{
		TR_GetEndPosition(VecOrigin);
	}
	else
	{
		PrintToChat(client, "Vector out of world geometry. Teleporting on origin instead");
	}*/
	float VecOrigin[3];
	DoClientTrace(client, MASK_OPAQUE, true, VecOrigin);
	
	for (int i=0; i < target_count; i++)
	{
		LogCommand("'%N' used the 'Teleport' command on '%N'", client, i);
		TeleportEntity(target_list[i], VecOrigin, NULL_VECTOR, NULL_VECTOR);
	}
	
	return Plugin_Handled;
}

Action CmdTeleportEnt(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1)
	{
		PrintToChat(client, "[SM] Usage: sm_teleportent <classname>");
		return Plugin_Handled;
	}
	static char arg[64], class[64];
	GetCmdArg(1, arg, sizeof(arg));
	int count = 0;
	
	/*float VecOrigin[3], VecAngles[3];
	GetClientEyePosition(client, VecOrigin);
	GetClientEyeAngles(client, VecAngles);
	TR_TraceRayFilter(VecOrigin, VecAngles, MASK_OPAQUE, RayType_Infinite, TraceRayDontHitSelf, client);
	if (TR_DidHit(null))
	{
		TR_GetEndPosition(VecOrigin);
	}
	else
	{
		PrintToChat(client, "Vector out of world geometry. Teleporting on origin instead");
	}*/
	float VecOrigin[3];
	DoClientTrace(client, MASK_OPAQUE, true, VecOrigin);
	
	for (int i = 1; i < (GetMaxEntities()*2); i++)
	{
		if (RealValidEntity(i))
		{
			GetEntityClassname(i, class, sizeof(class));
			if (strcmp(class, arg, false) == 0)
			{
				TeleportEntity(i, VecOrigin, NULL_VECTOR, NULL_VECTOR);
				count++;
			}
		}
	}
	PrintToChat(client, "[SM] Successfully teleported '%i' entities with <%s> classname", count, arg);
	
	LogCommand("'%N' used the 'Teleport Entity' command on '%i' entities with classname <%s>", client, count, arg);
	
	return Plugin_Handled;
}

Action CmdCheatRcon(int client, int args)
{
	static char buffer[256], buffer2[256];
	GetCmdArg(1, buffer, sizeof(buffer));
	GetCmdArgString(buffer2, sizeof(buffer2));
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_rcheat <command>");
		return Plugin_Handled;
	}
	
	if (!Cmd_CheckClient(client, client, false, -1, true))
	{
		int cmdflags = GetCommandFlags(buffer);
		SetCommandFlags(buffer, cmdflags & ~FCVAR_CHEAT);
		ServerCommand("%s", buffer2);
		SetCommandFlags(buffer, cmdflags);
		LogCommand("Console used the 'RCON Cheat' command with value <%s> <%s>", buffer, buffer2);
	}
	else
	{
		int cmdflags = GetCommandFlags(buffer);
		SetCommandFlags(buffer, cmdflags & ~FCVAR_CHEAT);
		ServerCommand("%s", buffer2);
		SetCommandFlags(buffer, cmdflags);
		LogCommand("'%N' used the 'RCON Cheat' command with value <%s> <%s>", client, buffer, buffer2);
	}	
	return Plugin_Handled;
}

Action CmdScanModel(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	static char classname[64];
	
	int entity = GetLookingEntity(client);
	if (!RealValidEntity(entity))
	{
		PrintToChat(client, "[SM] Unable to find a valid target!");
		return Plugin_Handled;
	}
	else
	{
		static char model[PLATFORM_MAX_PATH];
		GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
		GetEntityClassname(entity, classname, sizeof(classname));
		PrintToChat(client, "\x04[SM] The model of the entity <%s>(%d) is \"%s\"", classname, entity, model);
	}
	LogCommand("'%N' used the 'Scan Model' command on entity '%i' of classname '%s'", client, entity, classname);
	return Plugin_Handled;
}

Action CmdGrabEntity(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (!g_bGrab[client])
	{
		GrabLookingEntity(client);
	}
	else
	{
		ReleaseLookingEntity(client);
	}
	LogCommand("'%N' used the 'Grab' command", client);
	return Plugin_Handled;
}

Action CmdAcidSpill(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1)
	{
		PrintToChat(client, "[SM] Usage: sm_acidspill <#userid|name>");
		return Plugin_Handled;
	}
	static char arg[64];
	GetCmdArg(1, arg, sizeof(arg));
	
	//PrintToChatAll("Before: count %i list %i", target_count, target_list);
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	//PrintToChatAll("After: count %i list %i", target_count, target_list);
	
	for (int i = 0; i < target_count; i++)
	{
		CreateAcidSpill(target_list[i], client);
	}
	return Plugin_Handled;
}

Action CmdAdren(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1)
	{
		PrintToChat(client, "[SM] Usage: sm_adren <#userid|name> <seconds|15.0>");
		return Plugin_Handled;
	}
	static char arg[64], arg2[64];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	for (int i=0; i < target_count; i++)
	{
		SetAdrenalineEffect(target_list[i], client, StringToFloat(arg2));
	}
	return Plugin_Handled;
}

Action CmdTempHp(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 2)
	{
		PrintToChat(client, "[SM] Usage: sm_temphp <#userid|name> <amount>");
		return Plugin_Handled;
	}
	static char arg[64], arg2[12];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	GetCmdArg(2, arg2, sizeof(arg2));
	float amount = StringToFloat(arg2);
	if (amount > 65000.0)
	{
		PrintToChat(client, "[SM] The amount <%f> is too high (MAX: 65000)", amount);
		return Plugin_Handled;
	}
	else if (amount < 0.0)
	{
		PrintToChat(client, "[SM] The amount <%f> is too low (MIN: 0)", amount);
		return Plugin_Handled;
	}
	for (int i=0; i < target_count; i++)
	{
		SetTempHealth(target_list[i], amount);
	}
	return Plugin_Handled;
}

Action CmdRevive(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1)
	{
		PrintToChat(client, "[SM] Usage: sm_revive <#userid|name>");
		return Plugin_Handled;
	}
	static char arg[64];
	GetCmdArg(1, arg, sizeof(arg));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	for (int i=0; i < target_count; i++)
	{
		RevivePlayer_Cmd(target_list[i], client);
	}
	return Plugin_Handled;
}

Action CmdPanic(int client, int args)
{
	if (!Cmd_CheckClient(client, -1, false, -1, false))
	{ PrintToServer("[SM] Creating a panic event..."); }
	else
	{ PrintToChat(client, "[SM] Creating a panic event..."); }
	PanicEvent();
	return Plugin_Handled;
}

Action CmdShove(int client, int args)
{
	if (!Cmd_CheckClient(client, client, false, -1, true)) return Plugin_Handled;
	
	if (args < 1)
	{
		PrintToChat(client, "[SM] Usage: sm_shove <#userid|name>");
		return Plugin_Handled;
	}
	static char arg[64];
	GetCmdArg(1, arg, sizeof(arg));
	
	int target_list[MAXPLAYERS];
	int target_count = Cmd_GetTargets(client, arg, target_list);
	
	for (int i=0; i < target_count; i++)
	{
		ShovePlayer_Cmd(target_list[i], client);
	}
	return Plugin_Handled;
}

// MENU RELATED //

public void OnAdminMenuReady(Handle aTopMenu)
{
	TopMenu topmenu = TopMenu.FromHandle(aTopMenu);

	if (topmenu == hTopMenu)
	{
		return;
	}
	
	hTopMenu = topmenu;

	if (topmenu == null) 
	{
		LogDebug("[WARNING!] The topmenu handle was invalid! Unable to add items to the menu");
		LogError("[WARNING!] The topmenu handle was invalid! Unable to add items to the menu");
		return;
	}
	
	AddMenuItems(topmenu);
}

void AddMenuItems(TopMenu topmenu)
{
	//Add to default sourcemod categories
	if (g_bAddType)
	{
		TopMenuObject players_commands = FindTopMenuCategory(topmenu, ADMINMENU_PLAYERCOMMANDS);
		TopMenuObject server_commands = FindTopMenuCategory(topmenu, ADMINMENU_SERVERCOMMANDS);
		
		// now we add the function ...
		if (players_commands != INVALID_TOPMENUOBJECT)
		{
			AddToTopMenu(topmenu, "l4d2vomitplayer", TopMenuObject_Item, MenuItem_VomitPlayer, players_commands, "l4d2vomitplayer", DESIRED_FLAGS);
			AddToTopMenu(topmenu, "l4d2incapplayer", TopMenuObject_Item, MenuItem_IncapPlayer, players_commands, "l4d2incapplayer", DESIRED_FLAGS);
			AddToTopMenu(topmenu, "l4d2smackillplayer", TopMenuObject_Item, MenuItem_SmackillPlayer, players_commands, "l4d2smackillplayer", DESIRED_FLAGS);
			AddToTopMenu(topmenu, "l4d2rock", TopMenuObject_Item, MenuItem_Rock, players_commands, "l4d2rock", DESIRED_FLAGS);
			AddToTopMenu(topmenu, "l4d2speedplayer", TopMenuObject_Item, MenuItem_SpeedPlayer, players_commands, "l4d2speedplayer", DESIRED_FLAGS);
			AddToTopMenu(topmenu, "l4d2sethpplayer", TopMenuObject_Item, MenuItem_SetHpPlayer, players_commands, "l4d2sethpplayer", DESIRED_FLAGS);
			AddToTopMenu(topmenu, "l4d2colorplayer", TopMenuObject_Item, MenuItem_ColorPlayer, players_commands, "l4d2colorplayer", DESIRED_FLAGS);
			if (g_isSequel) AddToTopMenu(topmenu, "l4d2sizeplayer", TopMenuObject_Item, MenuItem_ScalePlayer, players_commands, "l4d2sizeplayer", DESIRED_FLAGS);
			AddToTopMenu(topmenu, "l4d2shakeplayer", TopMenuObject_Item, MenuItem_ShakePlayer, players_commands, "l4d2shakeplayer", DESIRED_FLAGS);
			if (g_isSequel) AddToTopMenu(topmenu, "l4d2chargeplayer", TopMenuObject_Item, MenuItem_Charge, players_commands, "l4d2chargeplayer", DESIRED_FLAGS);
			AddToTopMenu(topmenu, "l4d2teleplayer", TopMenuObject_Item, MenuItem_TeleportPlayer, players_commands, "l4d2teleplayer", DESIRED_FLAGS);
			
			AddToTopMenu(topmenu, "l4d2dontrush", TopMenuObject_Item, MenuItem_DontRush, players_commands, "l4d2dontrush", DESIRED_FLAGS);
			AddToTopMenu(topmenu, "l4d2airstrike", TopMenuObject_Item, MenuItem_Airstrike, players_commands, "l4d2airstrike", DESIRED_FLAGS);
			AddToTopMenu(topmenu, "l4d2changehp", TopMenuObject_Item, MenuItem_ChangeHp, players_commands, "l4d2changehp", DESIRED_FLAGS);
			AddToTopMenu(topmenu, "l4d2godmode", TopMenuObject_Item, MenuItem_GodMode, players_commands, "l4d2godmode", DESIRED_FLAGS);
		}
		else
		{
			LogError("Player commands category is invalid!");
		}
		
		if (server_commands != INVALID_TOPMENUOBJECT)
		{
			AddToTopMenu(topmenu, "l4d2createexplosion", TopMenuObject_Item, MenuItem_CreateExplosion, server_commands, "l4d2createexplosion", DESIRED_FLAGS);
			AddToTopMenu(topmenu, "l4d2norescue", TopMenuObject_Item, MenuItem_NoRescue, server_commands, "l4d2norescue", DESIRED_FLAGS);
			if (g_isSequel) AddToTopMenu(topmenu, "l4d2gnomerain", TopMenuObject_Item, MenuItem_GnomeRain, server_commands, "l4d2gnomerain", DESIRED_FLAGS);
			AddToTopMenu(topmenu, "l4d2survrain", TopMenuObject_Item, MenuItem_SurvRain, server_commands, "l4d2survrain", DESIRED_FLAGS);
			if (g_isSequel) AddToTopMenu(topmenu, "l4d2gnomewipe", TopMenuObject_Item, MenuItem_GnomeWipe, server_commands, "l4d2gnomewipe", DESIRED_FLAGS);
		}
		else
		{
			LogError("Server commands category is invalid!");
		}
	}
	
	//Create Custom category
	else
	{
		TopMenuObject menu_category_customcmds = AddToTopMenu(topmenu, "sm_cccategory", TopMenuObject_Category, Category_Handler, INVALID_TOPMENUOBJECT);
		AddToTopMenu(topmenu, "sm_ccplayer", TopMenuObject_Item, AdminMenu_Player, menu_category_customcmds, "sm_ccplayer", DESIRED_FLAGS);
		AddToTopMenu(topmenu, "sm_ccgeneral", TopMenuObject_Item, AdminMenu_General, menu_category_customcmds, "sm_ccgeneral", DESIRED_FLAGS);
		AddToTopMenu(topmenu, "sm_ccserver", TopMenuObject_Item, AdminMenu_Server, menu_category_customcmds, "sm_ccserver", DESIRED_FLAGS);
	}
}

//Admin Category Name
void Category_Handler(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayTitle)
	{
		Format(buffer, maxlength, "Custom Commands");
	}
	else if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Custom Commands");
	}
}

void AdminMenu_Player(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Player Commands");
	}
	else if (action == TopMenuAction_SelectOption)
	{
		BuildPlayerMenu(param);
	}
}

void AdminMenu_General(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "General Commands");
	}
	else if (action == TopMenuAction_SelectOption)
	{
		BuildGeneralMenu(param);
	}
}

void AdminMenu_Server(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Server Commands");
	}
	else if (action == TopMenuAction_SelectOption)
	{
		BuildServerMenu(param);
	}
}

void BuildPlayerMenu(int client)
{
	Menu menu = CreateMenu(MenuHandler_PlayerMenu);
	SetMenuTitle(menu, "Player Commands");
	SetMenuExitBackButton(menu, true);
	if (g_isSequel) AddMenuItem(menu, "l4d2chargeplayer", "Charge Player");
	AddMenuItem(menu, "l4d2incapplayer", "Incap Player");
	AddMenuItem(menu, "l4d2smackillplayer", "Smackill Player");
	AddMenuItem(menu, "l4d2speedplayer", "Set Player Speed");
	AddMenuItem(menu, "l4d2sethpplayer", "Set Player Health");
	AddMenuItem(menu, "l4d2colorplayer", "Set Player Color");
	AddMenuItem(menu, "l4d2sizeplayer", "Set Player Scale");
	AddMenuItem(menu, "l4d2shakeplayer", "Shake Player");
	AddMenuItem(menu, "l4d2teleplayer", "Teleport Player");
	AddMenuItem(menu, "l4d2dontrush", "Dont Rush Player");
	AddMenuItem(menu, "l4d2airstrike", "Send Airstrike");
	AddMenuItem(menu, "l4d2changehp", "Change Health Style");
	AddMenuItem(menu, "l4d2godmode", "God mode");
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

void BuildGeneralMenu(int client)
{
	Menu menu = CreateMenu(MenuHandler_GeneralMenu);
	SetMenuTitle(menu, "Player Commands");
	SetMenuExitBackButton(menu, true);
	AddMenuItem(menu, "l4d2createexplosion", "Set Explosion");
	AddMenuItem(menu, "l4d2norescue", "Force rescue vehicle to leave");
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

void BuildServerMenu(int client)
{
	Menu menu = CreateMenu(MenuHandler_ServerMenu);
	SetMenuTitle(menu, "Player Commands");
	SetMenuExitBackButton(menu, true);
	AddMenuItem(menu, "l4d2gnomerain", "Gnome Rain");
	AddMenuItem(menu, "l4d2survrain", "Survivors Rain");
	AddMenuItem(menu, "l4d2gnomewipe", "Wipe all gnomes");
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

int MenuHandler_PlayerMenu(Handle menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		if (g_isSequel)
		{
			switch (param2)
			{
				
				case 0: DisplayChargePlayerMenu(client);
				case 1: DisplayIncapPlayerMenu(client);
				case 2: DisplaySmackillPlayerMenu(client);
				case 3: DisplaySpeedPlayerMenu(client);
				case 4: DisplaySetHpPlayerMenu(client);
				case 5: DisplayColorPlayerMenu(client);
				case 6: DisplayScalePlayerMenu(client);
				case 7: DisplayShakePlayerMenu(client);
				case 8: DisplayTeleportPlayerMenu(client);
				case 9: DisplayDontRushMenu(client);
				case 10: DisplayAirstrikeMenu(client);
				case 11: DisplayChangeHpMenu(client);
				case 12: DisplayGodModeMenu(client);
			}
		}
		else
		{
			switch (param2)
			{
				case 0: DisplayIncapPlayerMenu(client);
				case 1: DisplaySmackillPlayerMenu(client);
				case 2: DisplaySpeedPlayerMenu(client);
				case 3: DisplaySetHpPlayerMenu(client);
				case 4: DisplayColorPlayerMenu(client);
				case 5: DisplayScalePlayerMenu(client);
				case 6: DisplayShakePlayerMenu(client);
				case 7: DisplayTeleportPlayerMenu(client);
				case 8: DisplayDontRushMenu(client);
				case 9: DisplayAirstrikeMenu(client);
				case 10: DisplayChangeHpMenu(client);
				case 11: DisplayGodModeMenu(client);
			}
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	return 0;
}

int MenuHandler_GeneralMenu(Handle menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:
			{
				DisplayCreateExplosionMenu(client);
			}
			case 1:
			{
				NoRescue(client);
			}
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	return 0;
}

int MenuHandler_ServerMenu(Handle menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:
			{
				StartGnomeRain(client);
				PrintHintTextToAll("It's raining gnomes!");
			}
			case 1:
			{
				StartL4dRain(client);
				PrintHintTextToAll("It's raining... survivors?!");
			}
			case 2:
			{
				CmdGnomeWipe(client, 0);
			}
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	return 0;
}

//---------------------------------Show Categories--------------------------------------------
void MenuItem_Charge(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Charge Player", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		DisplayChargePlayerMenu(param);
	}
}

void MenuItem_VomitPlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Vomit Player", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		DisplayVomitPlayerMenu(param);
	}
}

void MenuItem_TeleportPlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Teleport Player", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		DisplayTeleportPlayerMenu(param);
	}
}

void MenuItem_GodMode(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "God Mode", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		DisplayGodModeMenu(param);
	}
}

void MenuItem_IncapPlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Incapacitate Player", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		DisplayIncapPlayerMenu(param);
	}
}

void MenuItem_SmackillPlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Smackill Player", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		DisplaySmackillPlayerMenu(param);
	}
}

void MenuItem_Rock(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Launch Rock", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		CmdRock(param, 0);
	}
}

void MenuItem_SpeedPlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Set player speed", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		DisplaySpeedPlayerMenu(param);
	}
}

void MenuItem_SetHpPlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Set player health", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		DisplaySetHpPlayerMenu(param);
	}
}

void MenuItem_ColorPlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Set player color", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		DisplayColorPlayerMenu(param);
	}
}

void MenuItem_CreateExplosion(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Create explosion", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		DisplayCreateExplosionMenu(param);
	}
}

void MenuItem_ScalePlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Set player scale", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		DisplayScalePlayerMenu(param);
	}
}

void MenuItem_ShakePlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Shake player", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		DisplayShakePlayerMenu(param);
	}
}

void MenuItem_NoRescue(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Force Vehicle Leaving", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		NoRescue(param);
	}
}

void NoRescue(int client)
{
	if (g_bVehicleReady)
	{
		static char map[32];
		GetCurrentMap(map, sizeof(map));
		if (strcmp(map, "c1m4_atrium", false) == 0)
		{
			CheatCommand(client, "ent_fire", "relay_car_escape trigger");
			CheatCommand(client, "ent_fire", "car_camera enable");
			EndGame();
		}
		else if (strcmp(map, "c2m5_concert", false) == 0)
		{
			CheatCommand(client, "ent_fire", "stadium_exit_left_chopper_prop setanimation exit2");
			CheatCommand(client, "ent_fire", "stadium_exit_left_outro_camera enable");
			EndGame();
		}
		else if (strcmp(map, "c3m4_plantation", false) == 0)
		{
			CheatCommand(client, "ent_fire", "camera_outro setparentattachment attachment_cam");
			CheatCommand(client, "ent_fire", "escape_boat_prop setanimation c3m4_outro_boat");
			CheatCommand(client, "ent_fire", "camera_outro enable");
			EndGame();
		}
		else if (strcmp(map, "c4m5_milltown_escape", false) == 0)
		{
			CheatCommand(client, "ent_fire", "model_boat setanimation c4m5_outro_boat");
			CheatCommand(client, "ent_fire", "camera_outro setparent model_boat");
			CheatCommand(client, "ent_fire", "camera_outro setparentattachment attachment_cam");
			EndGame();
		}
		else if (strcmp(map, "c5m5_bridge", false) == 0)
		{
			CheatCommand(client, "ent_fire", "heli_rescue setanimation 4lift");
			CheatCommand(client, "ent_fire", "camera_outro enable");
			EndGame();
		}
		else if (strcmp(map, "c6m3_port", false) == 0)
		{
			CheatCommand(client, "ent_fire", "outro_camera_1 setparentattachment Attachment_1");
			CheatCommand(client, "ent_fire", "car_dynamic Disable");
			CheatCommand(client, "ent_fire", "car_outro_dynamic enable");
			CheatCommand(client, "ent_fire", "ghostanim_outro enable");
			CheatCommand(client, "ent_fire", "ghostanim_outro setanimation c6m3_outro");
			CheatCommand(client, "ent_fire", "car_outro_dynamic setanimation c6m3_outro_charger");
			CheatCommand(client, "ent_fire", "outro_camera_1 enable");
			CheatCommand(client, "ent_fire", "c6m3_escape_music playsound");
			EndGame();
		}
		else
		{
			PrintToChat(client, "[SM] This map doesn't have a rescue vehicle or is not supported!");
		}
	}
	else
	{ PrintToChat(client, "[SM] Wait for the rescue vehicle to be ready first!"); }
	
	LogCommand("'%N' used the 'No Rescue' command", client);
}

/*void MenuItem_BugPlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Bug Player(Caution)", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		DisplayBugPlayerMenu(param);
	}
}*/

void MenuItem_DontRush(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Anti Rush Player", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		DisplayDontRushMenu(param);
	}
}

void MenuItem_Airstrike(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Send Airstrike", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		DisplayAirstrikeMenu(param);
	}
}

void MenuItem_GnomeRain(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Gnome Rain", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		StartGnomeRain(param);
		PrintHintTextToAll("It's raining gnomes!");
	}
}

void MenuItem_SurvRain(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "L4D1 Survivor Rain", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		StartL4dRain(param);
		PrintHintTextToAll("It's raining... survivors?!");
	}
}

void MenuItem_GnomeWipe(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Wipe gnomes", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		CmdGnomeWipe(param, 0);
	}
}

void MenuItem_ChangeHp(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Switch Health Style", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		DisplayChangeHpMenu(param);
	}
}

/*void MenuItem_WipeBody(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Wipe bodies", "", param);
	}
	if (action == TopMenuAction_SelectOption)
	{
		static char classname[256];
		int count = 0;
		for (int i = MaxClients; i <= GetMaxEntities(); i++)
		{
			if (!RealValidEntity(i))
			{
				continue;
			}
			GetEntityClassname(i, classname, sizeof(classname));
			if (strcmp(classname, "prop_ragdoll", false) == 0)
			{
				AcceptEntityInput(i, "Kill");
				count++;
			}
		}
		PrintToChat(param, "[SM] Succesfully wiped %i bodies", count);
		count = 0;
	}
}
*/
//---------------------------------Display menus---------------------------------------
void DisplayVomitPlayerMenu(int client)
{
	Handle menu2 = CreateMenu(MenuHandler_VomitPlayer);
	SetMenuTitle(menu2, "Select Player:");
	SetMenuExitBackButton(menu2, true);
	AddTargetsToMenu2(menu2, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu2, client, MENU_TIME_FOREVER);
}

void DisplayTeleportPlayerMenu(int client)
{
	Handle menu2 = CreateMenu(MenuHandler_TeleportPlayer);
	SetMenuTitle(menu2, "Select Player:");
	SetMenuExitBackButton(menu2, true);
	AddTargetsToMenu2(menu2, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu2, client, MENU_TIME_FOREVER);
}

void DisplayChargePlayerMenu(int client)
{
	Handle menu2 = CreateMenu(MenuHandler_ChargePlayer);
	SetMenuTitle(menu2, "Select Player:");
	SetMenuExitBackButton(menu2, true);
	AddTargetsToMenu2(menu2, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu2, client, MENU_TIME_FOREVER);
}

void DisplayGodModeMenu(int client)
{
	Handle menu2 = CreateMenu(MenuHandler_GodMode);
	SetMenuTitle(menu2, "Select Player:");
	SetMenuExitBackButton(menu2, true);
	AddTargetsToMenu2(menu2, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu2, client, MENU_TIME_FOREVER);
}

void DisplayIncapPlayerMenu(int client)
{
	Handle menu3 = CreateMenu(MenuHandler_IncapPlayer);
	SetMenuTitle(menu3, "Select Player:");
	SetMenuExitBackButton(menu3, true);
	AddTargetsToMenu2(menu3, client, COMMAND_FILTER_ALIVE);
	DisplayMenu(menu3, client, MENU_TIME_FOREVER);
}

void DisplaySmackillPlayerMenu(int client)
{
	Handle menu3 = CreateMenu(MenuHandler_SmackillPlayer);
	SetMenuTitle(menu3, "Smackill Player:");
	SetMenuExitBackButton(menu3, true);
	AddTargetsToMenu2(menu3, client, COMMAND_FILTER_ALIVE);
	DisplayMenu(menu3, client, MENU_TIME_FOREVER);
}

void DisplaySpeedPlayerMenu(int client)
{
	Handle menu4 = CreateMenu(MenuSubHandler_SpeedPlayer);
	SetMenuTitle(menu4, "Select Player:");
	SetMenuExitBackButton(menu4, true);
	AddTargetsToMenu2(menu4, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu4, client, MENU_TIME_FOREVER);
}

void DisplaySetHpPlayerMenu(int client)
{
	Handle menu5 = CreateMenu(MenuSubHandler_SetHpPlayer);
	SetMenuTitle(menu5, "Select Player:");
	SetMenuExitBackButton(menu5, true);
	AddTargetsToMenu2(menu5, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu5, client, MENU_TIME_FOREVER);
}

void DisplayChangeHpMenu(int client)
{
	Handle menu5 = CreateMenu(MenuSubHandler_ChangeHp);
	SetMenuTitle(menu5, "Select Player:");
	SetMenuExitBackButton(menu5, true);
	AddTargetsToMenu2(menu5, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu5, client, MENU_TIME_FOREVER);
}

void DisplayColorPlayerMenu(int client)
{
	Handle menu6 = CreateMenu(MenuSubHandler_ColorPlayer);
	SetMenuTitle(menu6, "Select Player:");
	SetMenuExitBackButton(menu6, true);
	AddTargetsToMenu2(menu6, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu6, client, MENU_TIME_FOREVER);
}

void DisplayCreateExplosionMenu(int client)
{
	Handle menu7 = CreateMenu(MenuHandler_CreateExplosion);
	SetMenuTitle(menu7, "Select Position:");
	SetMenuExitBackButton(menu7, true);
	AddMenuItem(menu7, "onpos", "On Current Position");
	AddMenuItem(menu7, "onang", "On Cursor Position");
	DisplayMenu(menu7, client, MENU_TIME_FOREVER);
}

void DisplayScalePlayerMenu(int client)
{
	Handle menu8 = CreateMenu(MenuSubHandler_ScalePlayer);
	SetMenuTitle(menu8, "Select Player:");
	SetMenuExitBackButton(menu8, true);
	AddTargetsToMenu2(menu8, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu8, client, MENU_TIME_FOREVER);
}

void DisplayShakePlayerMenu(int client)
{
	Handle menu8 = CreateMenu(MenuSubHandler_ShakePlayer);
	SetMenuTitle(menu8, "Select Player:");
	SetMenuExitBackButton(menu8, true);
	AddTargetsToMenu2(menu8, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu8, client, MENU_TIME_FOREVER);
}

/*void DisplayBugPlayerMenu(int client)
{
	Handle menu9 = CreateMenu(MenuHandler_BugPlayer);
	SetMenuTitle(menu9, "Select Player:");
	SetMenuExitBackButton(menu9, true);
	AddTargetsToMenu2(menu9, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu9, client, MENU_TIME_FOREVER);
}*/

void DisplayDontRushMenu(int client)
{
	Handle menu10 = CreateMenu(MenuHandler_DontRush);
	SetMenuTitle(menu10, "Select Player:");
	SetMenuExitBackButton(menu10, true);
	AddTargetsToMenu2(menu10, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu10, client, MENU_TIME_FOREVER);
}

void DisplayAirstrikeMenu(int client)
{
	Handle menu11 = CreateMenu(MenuHandler_Airstrike);
	SetMenuTitle(menu11, "Select Player:");
	SetMenuExitBackButton(menu11, true);
	AddTargetsToMenu2(menu11, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu11, client, MENU_TIME_FOREVER);
}

//-------------------------------Sub Menus Needed-----------------------------
int MenuSubHandler_SpeedPlayer(Handle menu4, MenuAction action, int client, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu4);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		static char info[32];
		GetMenuItem(menu4, param2, info, sizeof(info));
		g_iCurrentUserId[client] = StringToInt(info);
		DisplaySpeedValueMenu(client);
	}
	return 0;
}

int MenuSubHandler_SetHpPlayer(Handle menu5, MenuAction action, int client, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu5);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		static char info[32];
		GetMenuItem(menu5, param2, info, sizeof(info));
		g_iCurrentUserId[client] = StringToInt(info);
		DisplaySetHpValueMenu(client);
	}
	return 0;
}

int MenuSubHandler_ChangeHp(Handle menu5, MenuAction action, int client, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu5);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		static char info[32];
		GetMenuItem(menu5, param2, info, sizeof(info));
		g_iCurrentUserId[client] = StringToInt(info);
		DisplayChangeHpStyleMenu(client);
	}
	return 0;
}

int MenuSubHandler_ColorPlayer(Handle menu6, MenuAction action, int client, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu6);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		static char info[32];
		GetMenuItem(menu6, param2, info, sizeof(info));
		g_iCurrentUserId[client] = StringToInt(info);
		DisplayColorValueMenu(client);
	}
	return 0;
}

int MenuSubHandler_ScalePlayer(Handle menu8, MenuAction action, int client, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu8);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		static char info[32];
		GetMenuItem(menu8, param2, info, sizeof(info));
		g_iCurrentUserId[client] = StringToInt(info);
		DisplayScaleValueMenu(client);
	}
	return 0;
}

int MenuSubHandler_ShakePlayer(Handle menu8, MenuAction action, int client, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu8);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		static char info[32];
		GetMenuItem(menu8, param2, info, sizeof(info));
		g_iCurrentUserId[client] = StringToInt(info);
		DisplayShakeValueMenu(client);
	}
	return 0;
}

void DisplaySpeedValueMenu(int client)
{
	Handle menu2a = CreateMenu(MenuHandler_SpeedPlayer);
	SetMenuTitle(menu2a, "New Speed:");
	SetMenuExitBackButton(menu2a, true);
	AddMenuItem(menu2a, "l4d2speeddouble", "x2 Speed");
	AddMenuItem(menu2a, "l4d2speedtriple", "x3 Speed");
	AddMenuItem(menu2a, "l4d2speedhalf", "1/2 Speed");
	AddMenuItem(menu2a, "l4d2speed3", "1/3 Speed");
	AddMenuItem(menu2a, "l4d2speed4", "1/4 Speed");
	AddMenuItem(menu2a, "l4d2speedquarter", "x4 Speed");
	AddMenuItem(menu2a, "l4d2speedfreeze", "0 Speed");
	AddMenuItem(menu2a, "l4d2speednormal", "Normal Speed");
	DisplayMenu(menu2a, client, MENU_TIME_FOREVER);
}

void DisplaySetHpValueMenu(int client)
{
	Handle menu2b = CreateMenu(MenuHandler_SetHpPlayer);
	SetMenuTitle(menu2b, "New Health:");
	SetMenuExitBackButton(menu2b, true);
	AddMenuItem(menu2b, "l4d2hpdouble", "x2 Health");
	AddMenuItem(menu2b, "l4d2hptriple", "x3 Health");
	AddMenuItem(menu2b, "l4d2hphalf", "1/2 Health");
	AddMenuItem(menu2b, "l4d2hp3", "1/3 Health");
	AddMenuItem(menu2b, "l4d2hp4", "1/4 Health");
	AddMenuItem(menu2b, "l4d2hpquarter", "x4 Health");
	AddMenuItem(menu2b, "l4d2hppls100", "+100 Health");
	AddMenuItem(menu2b, "l4d2hppls50", "+50 Health");
	DisplayMenu(menu2b, client, MENU_TIME_FOREVER);
}

void DisplayColorValueMenu(int client)
{
	Handle menu2c = CreateMenu(MenuHandler_ColorPlayer);
	SetMenuTitle(menu2c, "Select Color:");
	SetMenuExitBackButton(menu2c, true);
	AddMenuItem(menu2c, "l4d2colorred", "Red");
	AddMenuItem(menu2c, "l4d2colorblue", "Blue");
	AddMenuItem(menu2c, "l4d2colorgreen", "Green");
	AddMenuItem(menu2c, "l4d2coloryellow", "Yellow");
	AddMenuItem(menu2c, "l4d2colorblack", "Black");
	AddMenuItem(menu2c, "l4d2colorwhite", "White - Normal");
	AddMenuItem(menu2c, "l4d2colortrans", "Transparent");
	AddMenuItem(menu2c, "l4d2colorhtrans", "Semi Transparent");
	DisplayMenu(menu2c, client, MENU_TIME_FOREVER);
}

void DisplayScaleValueMenu(int client)
{
	Handle menu2a = CreateMenu(MenuHandler_ScalePlayer);
	SetMenuTitle(menu2a, "New Scale:");
	SetMenuExitBackButton(menu2a, true);
	AddMenuItem(menu2a, "l4d2scaledouble", "x2 Scale");
	AddMenuItem(menu2a, "l4d2scaletriple", "x3 Scale");
	AddMenuItem(menu2a, "l4d2scalehalf", "1/2 Scale");
	AddMenuItem(menu2a, "l4d2scale3", "1/3 Scale");
	AddMenuItem(menu2a, "l4d2scale4", "1/4 Scale");
	AddMenuItem(menu2a, "l4d2scalequarter", "x4 Scale");
	AddMenuItem(menu2a, "l4d2scalefreeze", "0 Scale");
	AddMenuItem(menu2a, "l4d2scalenormal", "Normal scale");
	DisplayMenu(menu2a, client, MENU_TIME_FOREVER);
}

void DisplayShakeValueMenu(int client)
{
	Handle menu2a = CreateMenu(MenuHandler_ShakePlayer);
	SetMenuTitle(menu2a, "Shake duration:");
	AddMenuItem(menu2a, "shake60", "1 Minute");
	AddMenuItem(menu2a, "shake45", "45 Seconds");
	AddMenuItem(menu2a, "shake30", "30 Seconds");
	AddMenuItem(menu2a, "shake15", "15 Seconds");
	AddMenuItem(menu2a, "shake10", "10 Seconds");
	AddMenuItem(menu2a, "shake5", "5 Seconds");
	AddMenuItem(menu2a, "shake1", "1 Second");
	SetMenuExitBackButton(menu2a, true);
	DisplayMenu(menu2a, client, MENU_TIME_FOREVER);
}

void DisplayChangeHpStyleMenu(int client)
{
	Handle menu2a = CreateMenu(MenuHandler_ChangeHpPlayer);
	SetMenuTitle(menu2a, "Select Style:");
	SetMenuExitBackButton(menu2a, true);
	AddMenuItem(menu2a, "l4d2perm", "Permanent Health");
	AddMenuItem(menu2a, "l4d2temp", "Temporal Health");
	DisplayMenu(menu2a, client, MENU_TIME_FOREVER);
}
	
//-------------------------------Do action------------------------------------
int MenuHandler_VomitPlayer(Handle menu2, MenuAction action, int client, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu2);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		static char info[32];
		int userid, target;
		GetMenuItem(menu2, param2, info, sizeof(info));
		userid = StringToInt(info);
		target = GetClientOfUserId(userid);
		
		LogCommand("'%N' used the 'Vomit Player' command on '%N'", client, target);
		
		VomitPlayer(target, client);
		DisplayVomitPlayerMenu(client);
	}
	return 0;
}

int MenuHandler_TeleportPlayer(Handle menu2, MenuAction action, int client, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu2);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		static char info[32];
		int userid, target;
		GetMenuItem(menu2, param2, info, sizeof(info));
		userid = StringToInt(info);
		target = GetClientOfUserId(userid);
		
		float VecOrigin[3];
		DoClientTrace(client, MASK_OPAQUE, true, VecOrigin);
		
		LogCommand("'%N' used the 'Teleport' command on '%N'", client, target);
		TeleportEntity(target, VecOrigin, NULL_VECTOR, NULL_VECTOR);
		
		DisplayTeleportPlayerMenu(client);
	}
	return 0;
}

int MenuHandler_ChargePlayer(Handle menu2, MenuAction action, int client, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu2);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		static char info[32];
		int userid, target;
		GetMenuItem(menu2, param2, info, sizeof(info));
		userid = StringToInt(info);
		target = GetClientOfUserId(userid);
		
		LogCommand("'%N' used the 'Charge' command on '%N'", client, target);
		Charge(target, client);
		
		DisplayChargePlayerMenu(client);
	}
	return 0;
}

int MenuHandler_GodMode(Handle menu2, MenuAction action, int client, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu2);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		static char info[32];
		int userid, target;
		GetMenuItem(menu2, param2, info, sizeof(info));
		userid = StringToInt(info);
		target = GetClientOfUserId(userid);
		
		LogCommand("'%N' used the 'God Mode' command on '%N'", client, target);
		GodMode(target, client);

		DisplayGodModeMenu(client);
	}
	return 0;
}

int MenuHandler_IncapPlayer(Handle menu3, MenuAction action, int client, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu3);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		static char info[32];
		int userid, target;
		GetMenuItem(menu3, param2, info, sizeof(info));
		userid = StringToInt(info);
		target = GetClientOfUserId(userid);
		
		LogCommand("'%N' used the 'Incap Player' command on '%N'", client, target);
		IncapPlayer(target, client);
		
		DisplayIncapPlayerMenu(client);
	}
	return 0;
}

int MenuHandler_SmackillPlayer(Handle menu3, MenuAction action, int client, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu3);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		static char info[32];
		int userid, target;
		GetMenuItem(menu3, param2, info, sizeof(info));
		userid = StringToInt(info);
		target = GetClientOfUserId(userid);
		
		LogCommand("'%N' used the 'Smackill Player' command on '%N'", client, target);
		SmackillPlayer(target, client);
		
		DisplaySmackillPlayerMenu(client);
	}
	return 0;
}

int MenuHandler_SpeedPlayer(Handle menu2a, MenuAction action, int client, int param2)
{	
	if (action == MenuAction_End)
	{
		CloseHandle(menu2a);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		int target = GetClientOfUserId(g_iCurrentUserId[client]);
		
		if (!Cmd_CheckClient(target, client, true, -1, true)) return 0;
		
		float speed = GetEntPropFloat(target, Prop_Send, "m_flLaggedMovementValue");
		
		switch (param2)
		{
			case 0: speed *= 2;
			case 1: speed *= 3;
			case 2: speed /= 2;
			case 3: speed /= 3;
			case 4: speed /= 4;
			case 5: speed *= 4;
			case 6: speed = 0.0;
			case 7: speed = 1.0;
		}
		LogCommand("'%N' used the 'Speed Player' command on '%N' with value <%f>", client, target, speed);
		
		ChangeSpeed(target, client, speed);
		DisplaySpeedPlayerMenu(client);
	}
	return 0;
}

int MenuHandler_SetHpPlayer(Handle menu2b, MenuAction action, int client, int param2)
{	
	if (action == MenuAction_End)
	{
		CloseHandle(menu2b);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		int health;
		int target = GetClientOfUserId(g_iCurrentUserId[client]);
		
		if (!Cmd_CheckClient(target, client, true, -1, true)) return 0;
		
		switch (param2)
		{
			case 0: health = GetClientHealth(target) * 2;
			case 1: health = GetClientHealth(target) * 3;
			case 2: health = GetClientHealth(target) / 2;
			case 3: health = GetClientHealth(target) / 3;
			case 4: health = GetClientHealth(target) / 4;
			case 5: health = GetClientHealth(target) * 4;
			case 6: health = GetClientHealth(target) + 100;
			case 7: health = GetClientHealth(target) + 50;
		}
		LogCommand("'%N' used the 'Set Health' command on '%N' with value <%i>", client, target, health);
		
		SetHealth(target, client, health);
		DisplaySetHpPlayerMenu(client);
	}
	return 0;
}

int MenuHandler_ColorPlayer(Handle menu2c, MenuAction action, int client, int param2)
{	
	if (action == MenuAction_End)
	{
		CloseHandle(menu2c);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		int target = GetClientOfUserId(g_iCurrentUserId[client]);
		
		if (!Cmd_CheckClient(target, client, false, -1, true)) return 0;
		
		static char colorSelect[24];
		switch (param2)
		{
			case 0: strcopy(colorSelect, sizeof(colorSelect), RED);
			case 1: strcopy(colorSelect, sizeof(colorSelect), BLUE);
			case 2: strcopy(colorSelect, sizeof(colorSelect), GREEN);
			case 3: strcopy(colorSelect, sizeof(colorSelect), YELLOW);
			case 4: strcopy(colorSelect, sizeof(colorSelect), BLACK);
			case 5: strcopy(colorSelect, sizeof(colorSelect), WHITE);
			case 6: strcopy(colorSelect, sizeof(colorSelect), TRANSPARENT);
			case 7: strcopy(colorSelect, sizeof(colorSelect), HALFTRANSPARENT);
		}
		LogCommand("'%N' used the 'Color Player' command on '%N' with value <%s>", client, target, colorSelect);
		
		ChangeColor(target, client, colorSelect);
		DisplayColorPlayerMenu(client);
	}
	return 0;
}

int MenuHandler_CreateExplosion(Handle menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:
			{
				float pos[3];
				GetClientAbsOrigin(client, pos);
				CreateExplosion(pos);
			}
			case 1:
			{
				float VecOrigin[3];
				DoClientTrace(client, MASK_OPAQUE, true, VecOrigin);
				CreateExplosion(VecOrigin);
			}
		}
		LogCommand("'%N' used the 'Set Explosion' command", client);
		DisplayCreateExplosionMenu(client);
	}
	return 0;
}

int MenuHandler_ScalePlayer(Handle menu2a, MenuAction action, int client, int param2)
{	
	if (action == MenuAction_End)
	{
		CloseHandle(menu2a);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		float scale;
		int target = GetClientOfUserId(g_iCurrentUserId[client]);
		
		if (!Cmd_CheckClient(target, client, false, -1, true)) return 0;
		
		switch (param2)
		{
			case 0: scale = GetEntPropFloat(target, Prop_Send, "m_flModelScale") * 2;
			case 1: scale = GetEntPropFloat(target, Prop_Send, "m_flModelScale") * 3;
			case 2: scale = GetEntPropFloat(target, Prop_Send, "m_flModelScale") / 2;
			case 3: scale = GetEntPropFloat(target, Prop_Send, "m_flModelScale") / 3;
			case 4: scale = GetEntPropFloat(target, Prop_Send, "m_flModelScale") / 4;
			case 5: scale = GetEntPropFloat(target, Prop_Send, "m_flModelScale") * 4;
			case 6: scale = 0.0;
			case 7: scale = 1.0;
		}
		LogCommand("'%N' used the 'Size Player' command on '%N' with value <%f>", client, target, scale);
		
		ChangeScale(target, client, scale);
		DisplayScalePlayerMenu(client);
	}
	return 0;
}

int MenuHandler_ShakePlayer(Handle menu2a, MenuAction action, int client, int param2)
{	
	if (action == MenuAction_End)
	{
		CloseHandle(menu2a);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		int target = GetClientOfUserId(g_iCurrentUserId[client]);
		
		if (!Cmd_CheckClient(target, client, false, -1, true)) return 0;
		
		float duration = 0.0;
		switch (param2)
		{
			case 0: duration = 60.0;
			case 1: duration = 45.0;
			case 2: duration = 30.0;
			case 3: duration = 15.0;
			case 4: duration = 10.0;
			case 5: duration = 5.0;
			case 6: duration = 1.0;
		}
		LogCommand("'%N' used the 'Shake' command on '%N' with value <%f>", client, target, duration);
		
		Shake(target, client, duration);
		DisplayShakePlayerMenu(client);
	}
	return 0;
}

/*int MenuHandler_BugPlayer(Handle menu9, MenuAction action, int client, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu9);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		static char info[32];
		int userid, target;
		GetMenuItem(menu9, param2, info, sizeof(info));
		userid = StringToInt(info);
		target = GetClientOfUserId(userid);
		
		if (!Cmd_CheckClient(target, client, false, -1, true)) return;
		
		AcceptEntityInput(target, "becomeragdoll");
		DisplayBugPlayerMenu(client);
	}
	return 0;
}*/
	
int MenuHandler_DontRush(Handle menu10, MenuAction action, int client, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu10);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		static char info[32];
		int userid, target;
		GetMenuItem(menu10, param2, info, sizeof(info));
		userid = StringToInt(info);
		target = GetClientOfUserId(userid);
		
		LogCommand("'%N' used the 'Anti Rush' command on '%N'", client, target);
		TeleportBack(target, client);
		
		DisplayDontRushMenu(client);
	}
	return 0;
}

int MenuHandler_Airstrike(Handle menu2, MenuAction action, int client, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu2);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		static char info[32];
		int userid, target;
		GetMenuItem(menu2, param2, info, sizeof(info));
		userid = StringToInt(info);
		target = GetClientOfUserId(userid);
		
		if (!Cmd_CheckClient(target, client, true, -1, true)) return 0;
		
		LogCommand("'%N' used the 'Airstrike' command on '%N'", client, target);
		Airstrike(target);
		
		DisplayAirstrikeMenu(client);
	}
	return 0;
}

int MenuHandler_ChangeHpPlayer(Handle menu2, MenuAction action, int client, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu2);
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		int target = GetClientOfUserId(g_iCurrentUserId[client]);
		
		if (!Cmd_CheckClient(target, client, true, 1, true)) return 0;
		
		int type = 0;
		static char temp_str[5];
		switch (param2)
		{
			case 0:
			{
				type = 1;
				strcopy(temp_str, sizeof(temp_str), "perm");
			}
			case 1:
			{
				type = 2;
				strcopy(temp_str, sizeof(temp_str), "temp");
			}
		}
		LogCommand("'%N' used the 'Change Health Type' command on '%N' with value <%s>", client, target, temp_str);
		
		SwitchHealth(target, client, type);
		DisplayChangeHpMenu(client);
	}
	return 0;
}
// FUNCTIONS //
void VomitPlayer(int client, int sender)
{
	if (!IsValidClient(client))
	{ PrintToChat(sender, "[SM] Client is invalid"); return; }
	
	if (!IsSurvivor(client) && !IsInfected(client))
	{ PrintToChat(sender, "[SM] Spectators cannot be vomited!"); return; }
	
	if (g_isSequel)
	{ Logic_RunScript("GetPlayerFromUserID(%d).HitWithVomit()", GetClientUserId(client)); }
	else
	{ SetDTCountdownTimer(client, "CTerrorPlayer", "m_itTimer", 15.0); }
}

void DoDamage(int client, int sender, int damage, int damageType = 0)
{
	//float tpos[3], spos[3];
	//GetClientAbsOrigin(client, tpos);
	float spos[3];
	if (IsValidClient(sender))
	{ GetClientAbsOrigin(sender, spos); }
	
	static char temp_str[32];
	
	int iDmgEntity = CreateEntityByName("point_hurt");
	if (IsValidClient(sender) && client != sender)
	{ TeleportEntity(iDmgEntity, spos, NULL_VECTOR, NULL_VECTOR); }
	//else
	//{ TeleportEntity(iDmgEntity, tpos, NULL_VECTOR, NULL_VECTOR); }
	
	DispatchKeyValue(iDmgEntity, "DamageTarget", "!activator");
	
	IntToString(damage, temp_str, sizeof(temp_str));
	DispatchKeyValue(iDmgEntity, "Damage", temp_str);
	IntToString(damageType, temp_str, sizeof(temp_str));
	DispatchKeyValue(iDmgEntity, "DamageType", temp_str);
	
	DispatchSpawn(iDmgEntity);
	ActivateEntity(iDmgEntity);
	AcceptEntityInput(iDmgEntity, "Hurt", client);
	AcceptEntityInput(iDmgEntity, "Kill");
}

void IncapPlayer(int client, int sender)
{
	if (!Cmd_CheckClient(client, sender, true, -1, true)) return;
	
	if (IsInfected(client) && GetEntProp(client, Prop_Send, "m_zombieClass") != 8)
	{
		PrintToChat(sender, "[SM] Only survivors and tanks can be incapacitated!");
		return;
	}
	else if ((IsSurvivor(client) || IsInfected(client)) && GetEntProp(client, Prop_Send, "m_isIncapacitated"))
	{
		PrintToChat(sender, "[SM] Cannot incap already incapacitated players!");
		return;
	}
	
	SetEntityHealth(client, 1);
	DoDamage(client, sender, 100);
}

void SmackillPlayer(int client, int sender)
{
	if (!Cmd_CheckClient(client, sender, true, -1, true)) return;
	
	if (IsSurvivor(client))
	{
		AcceptEntityInput(client, "ClearContext");
		AcceptEntityInput(client, "CancelCurrentScene");
		
		SetVariantString("PainLevel:Incapacitated:0.1");
		AcceptEntityInput(client, "AddContext");
		
		SetVariantString("Pain");
		AcceptEntityInput(client, "SpeakResponseConcept");
	}
	
	/*float tpos[3], spos[3];
	GetClientAbsOrigin(client, tpos);
	GetClientAbsOrigin(sender, spos);
	
	int iDmgEntity = CreateEntityByName("point_hurt");
	if (client != sender)
	{ TeleportEntity(iDmgEntity, spos, NULL_VECTOR, NULL_VECTOR); }
	SetEntityHealth(client, 1);
	SetTempHealth(client, 0.0);
	DispatchKeyValue(client, "targetname", "bm_target");
	DispatchKeyValue(iDmgEntity, "DamageTarget", "bm_target");
	DispatchKeyValue(iDmgEntity, "Damage", "1000000.0");
	DispatchKeyValue(iDmgEntity, "DamageType", "32");
	DispatchSpawn(iDmgEntity);
	AcceptEntityInput(iDmgEntity, "Hurt", client);
	DispatchKeyValue(client, "targetname", "bm_targetoff");
	AcceptEntityInput(iDmgEntity, "Kill");*/
	
	if (IsSurvivor(client))
	{ BlackAndWhite(client, sender); }
	SetEntityHealth(client, 1);
	SetTempHealth(client, 0.0);
	DoDamage(client, sender, 1000000, 32);
	//SDKHooks_TakeDamage(client, sender, sender, 1000000.0, 32, sender, view_as<float>({ 100.0, 100.0, 100.0 }));
	
	if (!IsPlayerAlive(client) && IsSurvivor(client))
	{
		float fPos[3];
		GetClientAbsOrigin(client, fPos);
		
		if (g_isSequel) CreateRagdoll(client);
		int body = FindEntityByClassname(-1, "survivor_death_model");
		if (RealValidEntity(body))
		{
			for (int i = MaxClients; i < GetMaxEntities(); i++) {
				if (!RealValidEntity(i)) continue;
				
				static char classname[22];
				GetEntityClassname(i, classname, sizeof(classname));
				if (strcmp(classname, "survivor_death_model", false) != 0) continue;
				
				float bodyPos[3];
				GetEntPropVector(i, Prop_Data, "m_vecOrigin", bodyPos);
				
				if (bodyPos[0] == fPos[0] && bodyPos[1] == fPos[1] && bodyPos[2] == fPos[2])
				{ SetEntityRenderMode(i, RENDER_NONE); }
			}
		}
	}
}

void LaunchRock(const float origin[3], const float angles[3])
{
	int launcher = CreateEntityByName("env_rock_launcher");
	if (!RealValidEntity(launcher)) return;
	
	DispatchKeyValueVector(launcher, "origin", origin);
	DispatchKeyValueVector(launcher, "angles", angles);
	//DispatchKeyValue(launcher, "RockDamageOverride", "1");
	
	DispatchSpawn(launcher);
	ActivateEntity(launcher);
	
	AcceptEntityInput(launcher, "LaunchRock");
	AcceptEntityInput(launcher, "Kill");
}

void CreateRagdoll(int client)
{
	if (!IsValidClient(client) || (!IsSurvivor(client) && !IsInfected(client)))
	return;
	
	int prev_ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (RealValidEntity(prev_ragdoll))
	return;
	
	int Ragdoll = CreateEntityByName("cs_ragdoll");
	float fPos[3];
	float fAng[3];
	//GetEntPropVector(client, Prop_Data, "m_vecOrigin", fPos);
	//GetEntPropVector(client, Prop_Data, "m_angRotation", fAng);
	GetClientAbsOrigin(client, fPos);
	GetClientAbsAngles(client, fAng);
	
	TeleportEntity(Ragdoll, fPos, fAng, NULL_VECTOR);
	
	SetEntPropVector(Ragdoll, Prop_Send, "m_vecRagdollOrigin", fPos);
	SetEntProp(Ragdoll, Prop_Send, "m_nModelIndex", GetEntProp(client, Prop_Send, "m_nModelIndex"));
	SetEntProp(Ragdoll, Prop_Send, "m_iTeamNum", GetClientTeam(client));
	SetEntPropEnt(Ragdoll, Prop_Send, "m_hPlayer", client);
	SetEntProp(Ragdoll, Prop_Send, "m_iDeathPose", GetEntProp(client, Prop_Send, "m_nSequence"));
	SetEntProp(Ragdoll, Prop_Send, "m_iDeathFrame", GetEntProp(client, Prop_Send, "m_flAnimTime"));
	SetEntProp(Ragdoll, Prop_Send, "m_nForceBone", GetEntProp(client, Prop_Send, "m_nForceBone"));
	float velfloat[3];
	velfloat[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]")*30;
	velfloat[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]")*30;
	velfloat[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]")*30;
	SetEntPropVector(Ragdoll, Prop_Send, "m_vecForce", velfloat);
	
	if (IsSurvivor(client))
	{
		SetEntProp(Ragdoll, Prop_Send, "m_ragdollType", 1);
		SetEntProp(Ragdoll, Prop_Send, "m_survivorCharacter", GetEntProp(client, Prop_Send, "m_survivorCharacter", 1), 1);
	}
	else if (IsInfected(client))
	{
		int infclass = GetEntProp(client, Prop_Send, "m_zombieClass", 1);
		if (infclass == 8)
		{ SetEntProp(Ragdoll, Prop_Send, "m_ragdollType", 3); }
		else
		{ SetEntProp(Ragdoll, Prop_Send, "m_ragdollType", 2); }
		SetEntProp(Ragdoll, Prop_Send, "m_zombieClass", infclass, 1);
		
		int effect = GetEntPropEnt(client, Prop_Send, "m_hEffectEntity");
		if (RealValidEntity(effect))
		{
			static char effectclass[13]; 
			GetEntityClassname(effect, effectclass, sizeof(effectclass));
			if (strcmp(effectclass, "entityflame", false) == 0)
			{ SetEntProp(Ragdoll, Prop_Send, "m_bOnFire", 1, 1); }
		}
	}
	else
	{ SetEntProp(Ragdoll, Prop_Send, "m_ragdollType", 1); }
	
	//SetEntProp(client, Prop_Send, "m_bClientSideRagdoll", 1);
	SetEntPropEnt(client, Prop_Send, "m_hRagdoll", Ragdoll);
	
	DispatchSpawn(Ragdoll);
	ActivateEntity(Ragdoll);
}

void ChangeSpeed(int client, int sender, float newspeed)
{
	if (!Cmd_CheckClient(client, sender, false, -1, true)) return;
	
	SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", newspeed);
}

void SetHealth(int client, int sender, int amount)
{
	if (!Cmd_CheckClient(client, sender, true, -1, true)) return;
	
	SetEntityHealth(client, amount);
}

void ChangeColor(int client, int sender, const char[] color)
{
	if (!Cmd_CheckClient(client, sender, false, -1, true)) return;
	
	DispatchKeyValue(client, "rendercolor", color);
}

void CreateExplosion(float carPos[3])
{
	static char sRadius[64];
	static char sPower[64];
	float flMxDistance = g_fRadius;
	float power = g_fPower;
	IntToString(RoundToNearest(flMxDistance), sRadius, sizeof(sRadius));
	IntToString(RoundToNearest(power), sPower, sizeof(sPower));
	int exParticle2 = CreateEntityByName("info_particle_system");
	int exParticle3 = CreateEntityByName("info_particle_system");
	int exTrace = CreateEntityByName("info_particle_system");
	int exPhys = CreateEntityByName("env_physexplosion");
	int exHurt = CreateEntityByName("point_hurt");
	int exParticle = CreateEntityByName("info_particle_system");
	int exEntity = CreateEntityByName("env_explosion");
	
	//Set up the particle explosion
	DispatchKeyValue(exParticle, "effect_name", EXPLOSION_PARTICLE);
	DispatchSpawn(exParticle);
	ActivateEntity(exParticle);
	TeleportEntity(exParticle, carPos, NULL_VECTOR, NULL_VECTOR);
	
	DispatchKeyValue(exParticle2, "effect_name", EXPLOSION_PARTICLE2);
	DispatchSpawn(exParticle2);
	ActivateEntity(exParticle2);
	TeleportEntity(exParticle2, carPos, NULL_VECTOR, NULL_VECTOR);
	
	DispatchKeyValue(exParticle3, "effect_name", EXPLOSION_PARTICLE3);
	DispatchSpawn(exParticle3);
	ActivateEntity(exParticle3);
	TeleportEntity(exParticle3, carPos, NULL_VECTOR, NULL_VECTOR);
	
	DispatchKeyValue(exTrace, "effect_name", FIRE_PARTICLE);
	DispatchSpawn(exTrace);
	ActivateEntity(exTrace);
	TeleportEntity(exTrace, carPos, NULL_VECTOR, NULL_VECTOR);
	
	
	//Set up explosion entity
	DispatchKeyValue(exEntity, "fireballsprite", "sprites/muzzleflash4.vmt");
	DispatchKeyValue(exEntity, "iMagnitude", sPower);
	DispatchKeyValue(exEntity, "iRadiusOverride", sRadius);
	DispatchKeyValue(exEntity, "spawnflags", "828");
	DispatchSpawn(exEntity);
	TeleportEntity(exEntity, carPos, NULL_VECTOR, NULL_VECTOR);
	
	//Set up physics movement explosion
	DispatchKeyValue(exPhys, "radius", sRadius);
	DispatchKeyValue(exPhys, "magnitude", sPower);
	DispatchSpawn(exPhys);
	TeleportEntity(exPhys, carPos, NULL_VECTOR, NULL_VECTOR);
	
	
	//Set up hurt point
	DispatchKeyValue(exHurt, "DamageRadius", sRadius);
	DispatchKeyValue(exHurt, "DamageDelay", "0.5");
	DispatchKeyValue(exHurt, "Damage", "5");
	DispatchKeyValue(exHurt, "DamageType", "8");
	DispatchSpawn(exHurt);
	TeleportEntity(exHurt, carPos, NULL_VECTOR, NULL_VECTOR);
	
	switch (GetRandomInt(1,3))
	{
		case 1:
		{
			PrecacheSound(EXPLOSION_SOUND);
			EmitAmbientGenericSound(carPos, EXPLOSION_SOUND);
		}
		case 2:
		{
			PrecacheSound(EXPLOSION_SOUND2);
			EmitAmbientGenericSound(carPos, EXPLOSION_SOUND2);
		}
		case 3:
		{
			PrecacheSound(EXPLOSION_SOUND3);
			EmitAmbientGenericSound(carPos, EXPLOSION_SOUND3);
		}
	}
	
	PrecacheSound(EXPLOSION_DEBRIS);
	EmitAmbientGenericSound(carPos, EXPLOSION_DEBRIS);
	
	//BOOM!
	AcceptEntityInput(exParticle, "Start");
	AcceptEntityInput(exParticle2, "Start");
	AcceptEntityInput(exParticle3, "Start");
	AcceptEntityInput(exTrace, "Start");
	AcceptEntityInput(exEntity, "Explode");
	AcceptEntityInput(exPhys, "Explode");
	AcceptEntityInput(exHurt, "TurnOn");
	
	static char temp_str[64];
	Format(temp_str, sizeof(temp_str), "OnUser1 !self:Kill::%f:1", g_fDuration+1.5);
	
	SetVariantString(temp_str);
	AcceptEntityInput(exParticle, "AddOutput");
	AcceptEntityInput(exParticle, "FireUser1");
	SetVariantString(temp_str);
	AcceptEntityInput(exParticle2, "AddOutput");
	AcceptEntityInput(exParticle2, "FireUser1");
	SetVariantString(temp_str);
	AcceptEntityInput(exParticle3, "AddOutput");
	AcceptEntityInput(exParticle3, "FireUser1");
	SetVariantString(temp_str);
	AcceptEntityInput(exEntity, "AddOutput");
	AcceptEntityInput(exEntity, "FireUser1");
	SetVariantString(temp_str);
	AcceptEntityInput(exPhys, "AddOutput");
	AcceptEntityInput(exPhys, "FireUser1");
	SetVariantString(temp_str);
	AcceptEntityInput(exTrace, "AddOutput");
	SetVariantString(temp_str);
	AcceptEntityInput(exHurt, "AddOutput");
	
	Format(temp_str, sizeof(temp_str), "OnUser1 !self:Stop::%f:1", g_fDuration);
	SetVariantString(temp_str);
	AcceptEntityInput(exTrace, "AddOutput");
	AcceptEntityInput(exTrace, "FireUser1");
	
	Format(temp_str, sizeof(temp_str), "OnUser1 !self:TurnOff::%f:1", g_fDuration);
	SetVariantString(temp_str);
	AcceptEntityInput(exHurt, "AddOutput");
	AcceptEntityInput(exHurt, "FireUser1");
	
	float survivorPos[3], traceVec[3], resultingFling[3], currentVelVec[3];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i) || !IsSurvivor(i))
		{
			continue;
		}

		GetEntPropVector(i, Prop_Data, "m_vecOrigin", survivorPos);
		
		//Vector and radius distance calcs by AtomicStryker!
		if (GetVectorDistance(carPos, survivorPos) <= flMxDistance)
		{
			MakeVectorFromPoints(carPos, survivorPos, traceVec);				// draw a line from car to Survivor
			GetVectorAngles(traceVec, resultingFling);							// get the angles of that line
			
			resultingFling[0] = Cosine(DegToRad(resultingFling[1])) * power;	// use trigonometric magic
			resultingFling[1] = Sine(DegToRad(resultingFling[1])) * power;
			resultingFling[2] = power;
			
			GetEntPropVector(i, Prop_Data, "m_vecVelocity", currentVelVec);		// add whatever the Survivor had before
			resultingFling[0] += currentVelVec[0];
			resultingFling[1] += currentVelVec[1];
			resultingFling[2] += currentVelVec[2];
			
			FlingPlayer(i, resultingFling, i);
		}
	}
}

void PipeExplosion(int client, float carPos[3])
{
	int explosion = CreateEntityByName("prop_physics");
	if (!RealValidEntity(explosion)) return;
	
	DispatchKeyValue(explosion, "physdamagescale", "0.0");
	DispatchKeyValue(explosion, "model", "models/props_junk/propanecanister001a.mdl");
	DispatchSpawn(explosion);
	ActivateEntity(explosion);
	SetEntityRenderMode(explosion, RENDER_NONE);
	TeleportEntity(explosion, carPos, NULL_VECTOR, NULL_VECTOR);
	SetEntityMoveType(explosion, MOVETYPE_VPHYSICS);
	
	SetEntPropEnt(explosion, Prop_Send, "m_hOwnerEntity", client);
	
	AcceptEntityInput(explosion, "Break");
}

void FlingPlayer(int client, float vector[3], int attacker, float stunTime = 3.0)
{
	if (sdkCallPushPlayer == null)
	{
		PrintToServer("[%s] Fling signature is broken!", PLUGIN_NAME_SHORT);
		return;
	}
	SDKCall(sdkCallPushPlayer, client, vector, 76, attacker, stunTime);
}

void Charge(int client, int sender)
{
	float tpos[3], spos[3];
	float distance[3], ratio[3], addVel[3], tvec[3];
	GetClientAbsOrigin(client, tpos);
	GetClientAbsOrigin(sender, spos);
	distance[0] = (spos[0] - tpos[0]);
	distance[1] = (spos[1] - tpos[1]);
	distance[2] = (spos[2] - tpos[2]);
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", tvec);
	ratio[0] = distance[0] / SquareRoot(distance[1]*distance[1] + distance[0]*distance[0]);//Ratio x/hypo
	ratio[1] = distance[1] / SquareRoot(distance[1]*distance[1] + distance[0]*distance[0]);//Ratio y/hypo
	
	addVel[0] = ratio[0]*-1 * 500.0;
	addVel[1] = ratio[1]*-1 * 500.0;
	addVel[2] = 500.0;
	FlingPlayer(client, addVel, sender, 7.0);
}

void Bleed(int client, int sender, float duration)
{
	if (!Cmd_CheckClient(client, sender, true, -1, true)) return;
	
	//Userid for targetting
	int userid = GetClientUserId(client);
	float pos[3]; char sName[64], sTargetName[64];
	int Particle = CreateEntityByName("info_particle_system");
	
	GetClientAbsOrigin(client, pos);
	TeleportEntity(Particle, pos, NULL_VECTOR, NULL_VECTOR);
	
	Format(sName, sizeof(sName), "%d", userid+25);
	DispatchKeyValue(client, "targetname", sName);
	GetEntPropString(client, Prop_Data, "m_iName", sName, sizeof(sName));
	
	Format(sTargetName, sizeof(sTargetName), "%d", userid+1000);
	
	DispatchKeyValue(Particle, "targetname", sTargetName);
	DispatchKeyValue(Particle, "parentname", sName);
	DispatchKeyValue(Particle, "effect_name", BLEED_PARTICLE);
	
	DispatchSpawn(Particle);
	
	DispatchSpawn(Particle);
	
	//Parent:		
	SetVariantString(sName);
	AcceptEntityInput(Particle, "SetParent", Particle, Particle);
	ActivateEntity(Particle);
	AcceptEntityInput(Particle, "start");
	
	static char temp_str[64];
	Format(temp_str, sizeof(temp_str), "OnUser1 !self:Kill::%f:1", duration);
	
	SetVariantString(temp_str);
	AcceptEntityInput(Particle, "AddOutput");
	AcceptEntityInput(Particle, "FireUser1");
}

void ChangeScale(int client, int sender, float scale)
{
	if (!Cmd_CheckClient(client, sender, true, -1, true)) return;
	
	SetEntPropFloat(client, Prop_Send, "m_flModelScale", scale);
}

void TeleportBack(int client, int sender)
{
	static char map[32]; float pos[3];
	GetCurrentMap(map, sizeof(map));
	if (!Cmd_CheckClient(client, sender, true, -1, true)) return;
	
	if (strcmp(map, "c1m1_hotel", false) == 0)
	{
		pos[0] = 568.0;
		pos[1] = 5707.0;
		pos[2] = 2848.0;
	}
	else if (strcmp(map, "c1m2_streets", false) == 0)
	{
		pos[0] = 2049.0;
		pos[1] = 4460.0;
		pos[2] = 1235.0;
	}
	else if (strcmp(map, "c1m3_mall", false) == 0)
	{
		pos[0] = 6697.0;
		pos[1] = -1424.0;
		pos[2] = 86.0;
	}
	else if (strcmp(map, "c1m4_atrium", false) == 0)
	{	
		pos[0] = -2046.0;
		pos[1] = -4641.0;
		pos[2] = 598.0;
	}
	else if (strcmp(map, "c2m1_highway", false) == 0)
	{
		pos[0] = 10855.0;
		pos[1] = 7864.0;
		pos[2] = -488.0;
	}
	else if (strcmp(map, "c2m2_fairgrounds", false) == 0)
	{
		pos[0] = 1653.0;
		pos[1] = 2796.0;
		pos[2] = 32.0;
	}
	else if (strcmp(map, "c2m3_coaster", false) == 0)
	{
		pos[0] = 4336.0;
		pos[1] = 2048.0;
		pos[2] = -1.0;
	}
	else if (strcmp(map, "c2m4_barns", false) == 0)
	{
		pos[0] = 3057.0;
		pos[1] = 3632.0;
		pos[2] = -152.0;
	}
	else if (strcmp(map, "c2m5_concert", false) == 0)
	{
		pos[0] = -938.0;
		pos[1] = 2194.0;
		pos[2] = -193.0;
	}
	else if (strcmp(map, "c3m1_plankcountry", false) == 0)
	{
		pos[0] = -12549.0;
		pos[1] = 10488.0;
		pos[2] = 270.0;
	}
	else if (strcmp(map, "c3m2_swamp", false) == 0)
	{
		pos[0] = -8158.0;
		pos[1] = 7531.0;
		pos[2] = 32.0;
	}
	else if (strcmp(map, "c3m3_shantytown", false) == 0)
	{
		pos[0] = -5718.0;
		pos[1] = 2137.0;
		pos[2] = 170.0;
	}
	else if (strcmp(map, "c3m4_plantation", false) == 0)
	{
		pos[0] = -5027.0;
		pos[1] = -1662.0;
		pos[2] = -34.0;
	}
	else if (strcmp(map, "c4m1_milltown_a", false) == 0)
	{
		pos[0] = -7097.0;
		pos[1] = 7706.0;
		pos[2] = 175.0;
	}
	else if (strcmp(map, "c4m2_sugarmill_a", false) == 0)
	{
		pos[0] = 3617.0;
		pos[1] = -1659.0;
		pos[2] = 270.0;
	}
	else if (strcmp(map, "c4m3_sugarmill_b", false) == 0)
	{
		pos[0] = -1788.0;
		pos[1] = -13701.0;
		pos[2] = 170.0;
	}
	else if (strcmp(map, "c4m4_milltown_b", false) == 0)
	{
		pos[0] = 3883.0;
		pos[1] = -1484.0;
		pos[2] = 270.0;
	}
	else if (strcmp(map, "c4m5_milltown_escape", false) == 0)
	{
		pos[0] = -3146.0;
		pos[1] = 7818.0;
		pos[2] = 182.0;
	}
	else if (strcmp(map, "c5m1_waterfront", false) == 0)
	{
		pos[0] = 790.0;
		pos[1] = 686.0;
		pos[2] = -419.0;
	}
	else if (strcmp(map, "c5m2_park", false) == 0)
	{
		pos[0] = -4119.0;
		pos[1] = -1263.0;
		pos[2] = -281.0;
	}
	else if (strcmp(map, "c5m3_cemetery", false) == 0)
	{
		pos[0] = 6361.0;
		pos[1] = 8372.0;
		pos[2] = 62.0;
	}
	else if (strcmp(map, "c5m4_quarter", false) == 0)
	{
		pos[0] = -3235.0;
		pos[1] = 4849.0;
		pos[2] = 130.0;
	}
	else if (strcmp(map, "c5m5_bridge", false) == 0)
	{
		pos[0] = -12062.0;
		pos[1] = 5913.0;
		pos[2] = 574.0;
	}
	else if (strcmp(map, "c6m1_riverbank", false) == 0)
	{
		pos[0] = 913.0;
		pos[1] = 3750.0;
		pos[2] = 156.0;
	}
	else if (strcmp(map, "c6m2_bedlam", false) == 0)
	{
		pos[0] = 3014.0;
		pos[1] = -1216.0;
		pos[2] = -233.0;
	}
	else if (strcmp(map, "c6m3_port", false) == 0)
	{
		pos[0] = -2364.0;
		pos[1] = -471.0;
		pos[2] = -193.0;
	}
	else
	{
		PrintToChat(sender, "[SM] This commands doesn't support the current map!");
	}
	TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
	PrintHintText(client, "You were teleported to the beginning of the map for rushing!");
}

void EndGame()
{
	for (int i=1; i<=MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i) && !IsClientObserver(i) && GetClientTeam(i) == 2) // Dont need to as team 4 doesn't count to living survivors
		{
			ForcePlayerSuicide(i);
		}
	}
}

/*LaunchMissile(int client, int sender)
{
	//Missile: Doesn't exist
	float flCpos[3], flTpos[3], flDistance, power, distance[3], flCang[3];
	power = 350.0;
	if (!Cmd_CheckClient(client, sender, true, -1, true)) return;
	
	GetClientEyePosition(sender, flCpos);
	GetClientEyeAngles(sender, flCang);
	static char angles[32];
	Format(angles, sizeof(angles), "%f %f %f", flCang[0], flCang[1], flCang[2]);
	
	//Missile is being created
	int iMissile = CreateEntityByName("prop_dynamic");
	DispatchKeyValue(iMissile, "model", MISSILE_MODEL);
	DispatchKeyValue(iMissile, "angles", angles);
	DispatchSpawn(iMissile);
	
	//Missile created but not visible. Teleporting
	TeleportEntity(iMissile, flCpos, NULL_VECTOR, NULL_VECTOR);
	
	float addVel[3], final[3], tvec[3], ratio[3];
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", flTpos);
	distance[0] = (flCpos[0] - flTpos[0]);
	distance[1] = (flCpos[1] - flTpos[1]);
	distance[2] = (flCpos[2] - flTpos[2]);
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", tvec);
	ratio[0] =  distance[0] / SquareRoot(distance[1]*distance[1] + distance[0]*distance[0]);//Ratio x/hypo
	ratio[1] =  distance[1] / SquareRoot(distance[1]*distance[1] + distance[0]*distance[0]);//Ratio y/hypo
	
	addVel[0] = ratio[0]*-1 * power;
	addVel[1] = ratio[1]*-1 * power;
	addVel[2] = power;
	final[0] = FloatAdd(addVel[0], tvec[0]);
	final[1] = FloatAdd(addVel[1], tvec[1]);
	final[2] = power;
	FlingPlayer(client, addVel, client);
	TeleportEntity(iMissile, NULL_VECTOR, NULL_VECTOR, final);
}
*/

void Airstrike(int client)
{
	g_bStrike = true;
	CreateTimer(6.0, timerStrikeTimeout, _, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.0, timerStrike, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

Action timerStrikeTimeout(Handle timer)
{
	g_bStrike = false;
	return Plugin_Continue;
}

Action timerStrike(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if (!g_bStrike)
	{
		return Plugin_Stop;
	}
	float pos[3];
	GetClientAbsOrigin(client, pos);
	float radius = g_fRainRadius;
	pos[0] += GetRandomFloat(radius*-1, radius);
	pos[1] += GetRandomFloat(radius*-1, radius);
	CreateExplosion(pos);		
	return Plugin_Continue;
}

void BlackAndWhite(int client, int sender)
{
	if (!Cmd_CheckClient(client, sender, true, -1, true)) return;
	
	if (GetEntProp(client, Prop_Send, "m_isIncapacitated")) RevivePlayer(client);
	
	if (g_isSequel)
	{ Logic_RunScript("GetPlayerFromUserID(%d).SetReviveCount(%i)", GetClientUserId(client), g_iIncaps); }
	else
	{
		SetEntProp(client, Prop_Send, "m_currentReviveCount", g_iIncaps);
		// side note: m_bIsOnThirdStrike doesn't exist for L4D1
	}
}

void SwitchHealth(int client, int sender, int type)
{
	if (!Cmd_CheckClient(client, sender, true, -1, true)) return;
	
	if (type == 1)
	{
		int iTempHealth = GetClientTempHealth(client);
		int iPermHealth = GetClientHealth(client);
		RemoveTempHealth(client);
		SetEntityHealth(client, iTempHealth+iPermHealth);
	}
	else if (type == 2)
	{
		int iTempHealth = GetClientTempHealth(client);
		int iPermHealth = GetClientHealth(client);
		int iTotal = iTempHealth+iPermHealth;
		SetEntityHealth(client, 1);
		RemoveTempHealth(client);
		SetTempHealth(client, iTotal+0.0);
	}
}

void WeaponRain(const char[] weapon, int sender)
{
	static char item[64];
	Format(item, sizeof(item), "weapon_%s", weapon);
	
	g_bGnomeRain = true;
	
	CreateTimer(g_fRainDur, timerRainTimeout, TIMER_FLAG_NO_MAPCHANGE);
	DataPack dpack = CreateDataPack();
	WritePackCell(dpack, GetClientUserId(sender));
	WritePackString(dpack, item);
	CreateTimer(0.1, timerSpawnWeapon, dpack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

Action timerSpawnWeapon(Handle timer, Handle dpack)
{
	static char item[96];
	ResetPack(dpack);
	int client = GetClientOfUserId(ReadPackCell(dpack));
	ReadPackString(dpack, item, sizeof(item));
	
	int weap = CreateEntityByName(item);
	DispatchSpawn(weap);
	
	if (!g_bGnomeRain)
	{ return Plugin_Stop; }
	
	float pos[3];
	GetClientAbsOrigin(client, pos);
	pos[2] += 350.0;
	float radius = g_fRainRadius;
	pos[0] += GetRandomFloat(radius*-1, radius);
	pos[1] += GetRandomFloat(radius*-1, radius);
	TeleportEntity(weap, pos, NULL_VECTOR, NULL_VECTOR);	
	return Plugin_Continue;
}

void StartGnomeRain(int client)
{
	g_bGnomeRain = true;
	CreateTimer(g_fRainDur, timerRainTimeout, _, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.1, timerSpawnGnome, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

void StartL4dRain(int client)
{
	g_bGnomeRain = true;
	CreateTimer(g_fRainDur, timerRainTimeout, _, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.7, timerSpawnL4d, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

void GodMode(int client, int sender)
{
	if (!Cmd_CheckClient(client, sender, false, -1, true)) return;
	
	if (GetEntProp(client, Prop_Data, "m_takedamage") <= 0)
	{
		SetEntProp(client, Prop_Data, "m_takedamage", 2);
		PrintToChat(sender, "[SM] The selected player now has god mode [Deactivated]");
	}
	else
	{
		SetEntProp(client, Prop_Data, "m_takedamage", 0);
		PrintToChat(sender, "[SM] The selected player now has god mode [Activated]");
	}
}

Action timerRainTimeout(Handle timer)
{
	g_bGnomeRain = false;
	return Plugin_Continue;
}

Action timerSpawnGnome(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	float pos[3];
	int gnome = CreateEntityByName("weapon_gnome");
	DispatchSpawn(gnome);
	
	if (!g_bGnomeRain)
	{ return Plugin_Stop; }
	
	GetClientAbsOrigin(client, pos);
	pos[2] += 350.0;
	float radius = g_fRainRadius;
	pos[0] += GetRandomFloat(radius*-1, radius);
	pos[1] += GetRandomFloat(radius*-1, radius);
	TeleportEntity(gnome, pos, NULL_VECTOR, NULL_VECTOR);	
	return Plugin_Continue;
}

Action timerSpawnL4d(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	float pos[3];
	int body = CreateEntityByName("prop_ragdoll");
	switch (GetRandomInt(1,3))
	{
		case 1: DispatchKeyValue(body, "model", ZOEY_MODEL);
		case 2: DispatchKeyValue(body, "model", FRANCIS_MODEL);
		case 3: DispatchKeyValue(body, "model", LOUIS_MODEL);
	}
	DispatchSpawn(body);
	
	if (!g_bGnomeRain)
	{ return Plugin_Stop; }
	
	GetClientAbsOrigin(client, pos);
	pos[2] += 350.0;
	float radius = g_fRainRadius;
	pos[0] += GetRandomFloat(radius*-1, radius);
	pos[1] += GetRandomFloat(radius*-1, radius);
	TeleportEntity(body, pos, NULL_VECTOR, NULL_VECTOR);	
	return Plugin_Continue;
}

void CheatCommand(int client, const char[] command, const char[] arguments)
{
	if (!IsValidClient(client)) return;
	
	int admindata = GetUserFlagBits(client);
	SetUserFlagBits(client, DESIRED_FLAGS);
	
	int flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, flags);
	SetUserFlagBits(client, admindata);
}

void Shake(int client, int sender, float duration)
{
	if (!Cmd_CheckClient(client, sender, false, -1, true)) return;
	
	Handle hBf = StartMessageOne("Shake", client);
	if (hBf != null)
	{
		BfWriteByte(hBf, 0);				
		BfWriteFloat(hBf, 16.0);			// shake magnitude/amplitude
		BfWriteFloat(hBf, 0.5);				// shake noise frequency
		BfWriteFloat(hBf, duration);				// shake lasts this long
		EndMessage();
	}
}

void InstructorHint(const char[] content)
{	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{ ClientCommand(i, "gameinstructor_enable 1"); }
	}
	
	int entity = CreateEntityByName("env_instructor_hint");
	if (RealValidEntity(entity))
	{
		DispatchKeyValue(entity, "hint_auto_start", "0");
		DispatchKeyValue(entity, "hint_alphaoption", "1");
		DispatchKeyValue(entity, "hint_timeout", "10");
		DispatchKeyValue(entity, "hint_forcecaption", "Yes");
		DispatchKeyValue(entity, "hint_static", "1");
		DispatchKeyValue(entity, "hint_icon_offscreen", "icon_alert");
		DispatchKeyValue(entity, "hint_icon_onscreen", "icon_alert");
		DispatchKeyValue(entity, "hint_caption", content);
		DispatchKeyValue(entity, "hint_range", "1");
		DispatchKeyValue(entity, "hint_color", "255 255 255");
		
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "ShowHint");
		
		SetVariantString("OnUser1 !self:Kill::15.0:1");
		AcceptEntityInput(entity, "AddOutput");
		
		SetVariantString("OnUser1 !self:FireUser2::14.9:1");
		AcceptEntityInput(entity, "AddOutput");
		
		AcceptEntityInput(entity, "FireUser1");
		HookSingleEntityOutput(entity, "OnUser2", OnTrigger_DisableInstructor, true);
	}
	else
	{ LogError("Failed to create the instructor hint entity."); }
}

void OnTrigger_DisableInstructor(const char[] output, int caller, int activator, float delay)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) return;
		ClientCommand(i, "gameinstructor_enable 0");
	}
}

bool IsValidWeapon(const char[] weapon)
{
	if (strcmp(weapon, "rifle") == 0
	|| strcmp(weapon, "smg") == 0
	|| strcmp(weapon, "pumpshotgun") == 0
	|| strcmp(weapon, "first_aid_kit") == 0
	|| strcmp(weapon, "autoshotgun") == 0
	|| strcmp(weapon, "molotov") == 0
	|| strcmp(weapon, "pain_pills") == 0
	|| strcmp(weapon, "pipe_bomb") == 0
	|| strcmp(weapon, "hunting_rifle") == 0
	|| strcmp(weapon, "pistol") == 0
	|| strcmp(weapon, "gascan") == 0
	|| strcmp(weapon, "propanetank") == 0)
	{ return true; }
	
	if (!g_isSequel) return false;
	
	// L4D2 only weapons
	if (strcmp(weapon, "rifle_desert") == 0
	|| strcmp(weapon, "rifle_ak47") == 0
	|| strcmp(weapon, "sniper_military") == 0
	|| strcmp(weapon, "shotgun_spas") == 0
	|| strcmp(weapon, "shotgun_chrome") == 0
	|| strcmp(weapon, "chainsaw") == 0
	|| strcmp(weapon, "adrenaline") == 0
	|| strcmp(weapon, "sniper_scout") == 0
	|| strcmp(weapon, "upgradepack_incendiary") == 0
	|| strcmp(weapon, "upgradepack_explosive") == 0
	|| strcmp(weapon, "vomitjar") == 0
	|| strcmp(weapon, "smg_silenced") == 0
	|| strcmp(weapon, "smg_mp5") == 0
	|| strcmp(weapon, "sniper_awp") == 0
	|| strcmp(weapon, "sniper_scout") == 0
	|| strcmp(weapon, "rifle_sg552") == 0
	|| strcmp(weapon, "gnome") == 0
	|| strcmp(weapon, "pistol_magnum") == 0
	|| strcmp(weapon, "grenade_launcher") == 0
	|| strcmp(weapon, "rifle_m60") == 0
	|| strcmp(weapon, "defibrillator") == 0)
	{ return true; }
	
	return false;
}

void CreateParticle(int client, const char[] Particle_Name, bool parent, float duration)
{
	float pos[3]; char sName[64], sTargetName[64];
	int Particle = CreateEntityByName("info_particle_system");
	GetClientAbsOrigin(client, pos);
	TeleportEntity(Particle, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchKeyValue(Particle, "effect_name", Particle_Name);
	
	if (parent)
	{
		int userid = GetClientUserId(client);
		Format(sName, sizeof(sName), "%d", userid+25);
		DispatchKeyValue(client, "targetname", sName);
		GetEntPropString(client, Prop_Data, "m_iName", sName, sizeof(sName));
		
		Format(sTargetName, sizeof(sTargetName), "%d", userid+1000);
		DispatchKeyValue(Particle, "targetname", sTargetName);
		DispatchKeyValue(Particle, "parentname", sName);
	}
	
	DispatchSpawn(Particle);
	
	if (parent)
	{
		SetVariantString(sName);
		AcceptEntityInput(Particle, "SetParent", Particle, Particle);
	}
	ActivateEntity(Particle);
	AcceptEntityInput(Particle, "start");
	
	static char variant_str[128];
	Format(variant_str, sizeof(variant_str), "OnUser1 !self:Hurt::%f:1", duration);
	SetVariantString(variant_str);
	AcceptEntityInput(Particle, "AddOutput");
	AcceptEntityInput(Particle, "FireUser1");
}

void IgnitePlayer(int client, float duration)
{
	if (Cmd_CheckClient(client, -1, false, -1, false))
	{
		float pos[3];
		GetClientAbsOrigin(client, pos);
		
		static char sUser[256];
		IntToString(GetClientUserId(client)+25, sUser, sizeof(sUser));
		
		CreateParticle(client, BURN_IGNITE_PARTICLE, true, duration);
		
		int Damage = CreateEntityByName("point_hurt");
		DispatchKeyValue(Damage, "Damage", "1");
		DispatchKeyValue(Damage, "DamageType", "8");
		DispatchKeyValue(client, "targetname", sUser);
		DispatchKeyValue(Damage, "DamageTarget", sUser);
		DispatchSpawn(Damage);
		TeleportEntity(Damage, pos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(Damage, "Hurt");
		
		SetVariantString("OnUser1 !self:Hurt::0.1:1");
		AcceptEntityInput(Damage, "AddOutput");
		
		static char variant_str[64];
		Format(variant_str, sizeof(variant_str), "OnUser1 !self:Kill::%f:1", duration);
		SetVariantString(variant_str);
		AcceptEntityInput(Damage, "AddOutput");
		AcceptEntityInput(Damage, "FireUser1");
	}
	else if (RealValidEntity(client))
	{ IgniteEntity(client, duration); }
}

bool TraceRayDontHitSelf(int entity, int mask, any data)
{
	if (entity == data) // Check if the TraceRay hit the itself.
	{
		return false; // Don't let the entity be hit
	}
	return true; // It didn't hit itself
}
// DEVELOPMENT //

Action CmdEntityInfo(int client, int args)
{
	static char classname[64];
	int entity = GetClientAimTarget(client, false);

	if (!RealValidEntity(entity))
	{ ReplyToCommand(client, CMD_INVALID_ENT); return Plugin_Handled; }
	
	GetEntityClassname(entity, classname, sizeof(classname));
	PrintToChat(client, "classname: %s", classname);
	return Plugin_Handled;
}

void PrecacheParticle(const char[] ParticleName)
{
	int Particle = CreateEntityByName("info_particle_system");
	if (!RealValidEntity(Particle)) return;
	
	DispatchKeyValue(Particle, "effect_name", ParticleName);
	DispatchSpawn(Particle);
	ActivateEntity(Particle);
	AcceptEntityInput(Particle, "start");
	
	SetVariantString("OnUser1 !self:Kill::0.3:1");
	AcceptEntityInput(Particle, "AddOutput");
	AcceptEntityInput(Particle, "FireUser1");
}

void LogCommand(const char[] format, any ...)
{
	if (!g_bLog) return;
	
	static char buffer[512];
	VFormat(buffer, sizeof(buffer), format, 2);
	Handle file;
	
	static char FileName[256], sTime[256];
	FormatTime(sTime, sizeof(sTime), "%Y%m%d");
	BuildPath(Path_SM, FileName, sizeof(FileName), "logs/customcmds_%s.log", sTime);
	file = OpenFile(FileName, "a+");
	FormatTime(sTime, sizeof(sTime), "%b %d |%H:%M:%S| %Y");
	WriteFileLine(file, "%s: %s", sTime, buffer);
	FlushFile(file);
	CloseHandle(file);
}

void LogDebug(const char[] format, any ...)
{
	#if DEBUG
	static char buffer[512];
	VFormat(buffer, sizeof(buffer), format, 2);
	Handle file;
	
	static char FileName[256], sTime[256];
	FormatTime(sTime, sizeof(sTime), "%Y%m%d");
	BuildPath(Path_SM, FileName, sizeof(FileName), "logs/customcmds_%s.log", sTime);
	file = OpenFile(FileName, "a+");
	FormatTime(sTime, sizeof(sTime), "%b %d |%H:%M:%S| %Y");
	WriteFileLine(file, "%s: [--DEBUG--]:%s", sTime, buffer);
	FlushFile(file);
	CloseHandle(file);
	#endif
}

void GrabLookingEntity(int client)
{
	int entity = GetLookingEntity(client);
	if (g_bGrab[client])
	{ PrintToChat(client, "[SM] You are already grabbing an entity"); return; }
	else if (g_bGrabbed[entity])
	{ PrintToChat(client, "[SM] The entity is already moving"); return; }
	
	if (Cmd_CheckClient(client, -1, false, -1, false))
	{
		g_bGrab[client] = true;
		g_bGrabbed[entity] = true;
		g_iLastGrabbedEntity[client] = entity;
		PrintToChat(client, "[SM] You are now grabbing an entity");
		
		static char sName[64], sObjectName[64];
		Format(sName, sizeof(sName), "%d", GetClientUserId(client)+25);
		Format(sObjectName, sizeof(sObjectName), "%d", entity+100);
		
		DispatchKeyValue(entity, "targetname", sObjectName);
		DispatchKeyValue(client, "targetname", sName);
		GetEntPropString(client, Prop_Data, "m_iName", sName, sizeof(sName));
		DispatchKeyValue(entity, "parentname", sName);
		SetVariantString(sName);
		AcceptEntityInput(entity, "SetParent", entity, entity);
	}
	else
	{ PrintToChat(client, CMD_INVALID_CL); }
}

void ReleaseLookingEntity(int client)
{
	int entity = g_iLastGrabbedEntity[client];
	if (RealValidEntity(entity))
	{
		g_bGrab[client] = false;
		g_bGrabbed[entity] = false;
		PrintToChat(client, "[SM] You are no longer grabbing an object");
		DispatchKeyValue(entity, "targetname", "");
		DispatchKeyValue(entity, "parentname", "");
		SetEntityRenderColor(entity, 255, 255 ,255, 255);
		AcceptEntityInput(entity, "SetParent");
	}
	else
	{ PrintToChat(client, "[SM] The grabbed entity is not valid"); }
}

void CreateAcidSpill(int client, int sender)
{
	if (!Cmd_CheckClient(client, sender, false, -1, true)) return;
	
	float vecPos[3];
	GetClientAbsOrigin(client, vecPos);
	vecPos[2]+=16.0;
	
	/*int iAcid = CreateEntityByName("spitter_projectile");
	if (RealValidEntity(iAcid))
	{
		DispatchSpawn(iAcid);
		SetEntPropFloat(iAcid, Prop_Send, "m_DmgRadius", 1024.0); // Radius of the acid.
		SetEntProp(iAcid, Prop_Send, "m_bIsLive", 1 ); // Without this set to 1, the acid won't make any sound.
		SetEntPropEnt(iAcid, Prop_Send, "m_hThrower", sender); // A player who caused the acid to appear.
		TeleportEntity(iAcid, vecPos, NULL_VECTOR, NULL_VECTOR);
		SDKCall(sdkDetonateAcid, iAcid);
	}*/
	Logic_RunScript("DropSpit(Vector(%f, %f, %f))", vecPos[0], vecPos[1], vecPos[2]);
	
	// The spit dropped by DropSpit is initially a spitter_projectile
	// it oddly doesn't transfer team over to insect_swarm, so do it on timer
	//CreateTimer(0.5, AlterSpit, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	//g_bAlterSpit = true;
	//CreateTimer(1.0, DoAlterSpit, _, TIMER_FLAG_NO_MAPCHANGE);
}
/*Action SetAlterSpitFalse(Handle timer)
{ g_bAlterSpit = false; return Plugin_Continue; }*/
/*Action AlterSpit(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	for (int i = MaxClients; i < GetMaxEntities(); i++)
	{
		if (!RealValidEntity(i)) continue;
		static char classname[14];
		GetEntityClassname(i, classname, sizeof(classname));
		if (classname[0] != 'i' || (strcmp(classname, "insect_swarm", false) != 0)) continue;
		
		//PrintToServer("Found spit! %i", i);
		//PrintToServer("Spit team is %i", GetEntProp(i, Prop_Send, "m_iTeamNum"));
		int owner = GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity");
		if (!RealValidEntity(owner))
		{
			SetEntProp(i, Prop_Send, "m_iTeamNum", 3);
			//SetEntPropEnt(i, Prop_Send, "m_hOwnerEntity", client);
		}
		//return i;
		//break;
	}
	return Plugin_Continue;
}*/
void FixSpitDmgEffects(Event event, const char[] event_name, bool dontBroadcast)
{
	int entity = event.GetInt("attackerentid", 0);
	
	static char classname[14];
	GetEntityClassname(entity, classname, sizeof(classname));
	if (classname[0] != 'i' || strcmp(classname, "insect_swarm", false) != 0) return;
	
	int client = GetClientOfUserId(event.GetInt("userid", 0));
	if (!IsValidClient(client)) return;
	int team = GetClientTeam(client);
	if (team != 2 && team != 4) return;
	
	//RequestFrame(PlaySpitDmgSound, GetClientUserId(client));
	static char sliceSnd[34];
	Format(sliceSnd, sizeof(sliceSnd), "player/PZ/hit/zombie_slice_%i.wav", GetRandomInt(1, 6));
	EmitSoundToAll(sliceSnd, client, SNDCHAN_AUTO, 85, SND_NOFLAGS, 0.7, GetRandomInt(95, 105));
	// PlayerZombie.AttackHit just crashes the game
	/*SetVariantString("PainLevel:Minor:0.1");
	AcceptEntityInput(client, "AddContext");
	SetVariantString("Pain");
	AcceptEntityInput(client, "SpeakResponseConcept");*/
	
	//PrintToServer("spit team: %i", GetEntProp(entity, Prop_Send, "m_iTeamNum"));
	
	int duration = 360;
	int holdtime = 0;
	int flags = 1;
	int color[4] = { 255, 0, 0, 32 };
	
	int clients[2];
	clients[0] = client;
	Handle message = StartMessageEx(g_FadeUserMsgId, clients, 1);
	if (GetUserMessageType() == UM_Protobuf)
	{
		Protobuf pb = UserMessageToProtobuf(message);
		pb.SetInt("duration", duration);
		pb.SetInt("hold_time", holdtime);
		pb.SetInt("flags", flags);
		pb.SetColor("clr", color);
	}
	else
	{
		BfWriteShort(message, duration);
		BfWriteShort(message, holdtime);
		BfWriteShort(message, flags);
		BfWriteByte(message, color[0]);
		BfWriteByte(message, color[1]);
		BfWriteByte(message, color[2]);
		BfWriteByte(message, color[3]);
	}
	EndMessage();
}

void SetAdrenalineEffect(int client, int sender, float timelimit = -1.0)
{
	if (!Cmd_CheckClient(client, sender, false, -1, true)) return;
	
	float final_time = timelimit;
	if (!timelimit || timelimit <= 0.0)
	{ final_time = 15.0; }
	Logic_RunScript("GetPlayerFromUserID(%d).UseAdrenaline(%f)", GetClientUserId(client), final_time);
	//SDKCall(sdkAdrenaline, client, 15.0);
}

void SetTempHealth(int client, float flAmount)
{
	if (g_isSequel)
	{ Logic_RunScript("GetPlayerFromUserID(%d).SetHealthBuffer(%f)", GetClientUserId(client), flAmount); }
	else
	{ SetEntPropFloat(client, Prop_Send, "m_healthBuffer", flAmount); }
	//SDKCall(sdkSetBuffer, client, flAmount);
}

void RevivePlayer_Cmd(int client, int sender)
{
	if (!Cmd_CheckClient(client, sender, true, 1, true)) return;
	
	if (!GetEntProp(client, Prop_Send, "m_isIncapacitated") && !GetEntProp(client, Prop_Send, "m_isHangingFromLedge"))
	{ PrintToChat(sender, "[SM] The player is not incapacitated"); }
	
	//SDKCall(sdkRevive, client);
	RevivePlayer(client);
}

void RevivePlayer(int client)
{
	if (!GetEntProp(client, Prop_Send, "m_isIncapacitated") && !GetEntProp(client, Prop_Send, "m_isHangingFromLedge")) return;
	if (g_isSequel)
	{ Logic_RunScript("GetPlayerFromUserID(%d).ReviveFromIncap()", GetClientUserId(client)); }
	else
	{
		// TODOL4D1
		/*int ReviveHealth = 30;
		if (GetEntProp(client, Prop_Send, "m_isIncapacitated") == 1)
		{ ReviveHealth[client] = GetConVarFloat(selfrevive_health_incap); }
		if (view_as<bool>(GetEntProp(client, Prop_Send, "m_isHangingFromLedge")))
		{ ReviveHealth[client] = GetConVarFloat(selfrevive_health_ledge); }*/
		int revOwner = GetEntPropEnt(client, Prop_Send, "m_reviveOwner");
		SetEntPropEnt(client, Prop_Send, "m_reviveTarget", client);
		SetEntPropEnt(client, Prop_Send, "m_reviveOwner", client);
		if (RealValidEntity(revOwner))
		{
			// No choice but to set the revive owner to themselves
			// Their animation for picking up still plays but eh, deal with it
			SetEntProp(revOwner, Prop_Send, "m_reviveTarget", 0);
			SetEntProp(revOwner, Prop_Send, "m_iProgressBarDuration", 0);
			SetEntPropFloat(revOwner, Prop_Send, "m_flProgressBarStartTime", 0.0);
		}
		SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0);
		SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", 0.0);
	}
}

void ShovePlayer_Cmd(int client, int sender)
{
	if (!Cmd_CheckClient(client, sender, true, -1, true)) return;
	
	float vecOrigin[3];
	GetClientAbsOrigin(sender, vecOrigin);
	
	if (g_isSequel)
	{ Logic_RunScript("GetPlayerFromUserID(%d).Stagger(Vector(%f, %f, %f))", GetClientUserId(client), vecOrigin[0], vecOrigin[1], vecOrigin[2]); }
	else
	{
		// TODOL4D1 UNFINISHED
		SetDTCountdownTimer(client, "CTerrorPlayer", "m_staggerTimer", 1.0);
		SetEntPropVector(client, Prop_Send, "m_staggerDir", {0.0, 90.0, 90.0});
		float startOrigin[3];
		GetClientAbsOrigin(client, startOrigin);
		SetEntPropVector(client, Prop_Send, "m_staggerStart", startOrigin);
		SetEntPropFloat(client, Prop_Send, "m_staggerDist", 250.0);
		/*
		Table: m_staggerTimer (offset 8048) (type DT_CountdownTimer)
			Member: m_duration (offset 4) (type float) (bits 0) (NoScale)
			Member: m_timestamp (offset 8) (type float) (bits 0) (NoScale)
		Member: m_staggerStart (offset 8060) (type vector) (bits 0) (CoordMP)
		Member: m_staggerDir (offset 8072) (type vector) (bits 0) (CoordMP)
		Member: m_staggerDist (offset 8084) (type float) (bits 0) (NoScale|CoordMP)
		*/
	}
}

int GetClientTempHealth(int client)
{
	//First filter -> Must be a valid client and not a spectator (They dont have health).
	if (!Cmd_CheckClient(client, -1, true, -1, false)) return -1;
	
	//First, we get the amount of temporal health the client has
	float buffer = GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
	
	//We declare the permanent and temporal health variables
	float TempHealth;
	
	//In case the buffer is 0 or less, we set the temporal health as 0, because the client has not used any pills or adrenaline yet
	if (buffer <= 0.0)
	{
		TempHealth = 0.0;
	}
	
	//In case it is higher than 0, we proceed to calculate the temporl health
	else
	{
		//This is the difference between the time we used the temporal item, and the current time
		float difference = GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime");
		
		//We get the decay rate from this convar (Note: Adrenaline uses this value)
		//This is a constant we create to determine the amount of health. This is the amount of time it has to pass
		//before 1 Temporal HP is consumed.
		float constant = 1.0/g_fPPDecay;
		
		//Then we do the calcs
		TempHealth = buffer - (difference / constant);
	}
	
	//If the temporal health resulted less than 0, then it is just 0.
	if (TempHealth < 0.0)
	{
		TempHealth = 0.0;
	}
	
	//Return the value
	return RoundToFloor(TempHealth);
}

void RemoveTempHealth(int client)
{
	if (!Cmd_CheckClient(client, -1, true, -1, false)) return;
	SetTempHealth(client, 0.0);
}

void PanicEvent()
{
	int Director = CreateEntityByName("info_director");
	DispatchSpawn(Director);
	switch (g_isSequel)
	{
		case true: AcceptEntityInput(Director, "ForcePanicEvent");
		case false: AcceptEntityInput(Director, "PanicEvent");
	}
	AcceptEntityInput(Director, "Kill");
}

int GetLookingEntity(int client)
{
	if (!IsValidClient(client)) return -1;
	
	float VecOrigin[3], VecAngles[3];
	GetClientEyePosition(client, VecOrigin);
	GetClientEyeAngles(client, VecAngles);
	TR_TraceRayFilter(VecOrigin, VecAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);
	if (TR_DidHit(null))
	{
		int entity = TR_GetEntityIndex(null);
		if (RealValidEntity(entity))
		{
			return entity;
		}
	}
	return -1;
}

#define PLUGIN_SCRIPTLOGIC "plugin_scripting_logic_entity"

void Logic_RunScript(const char[] sCode, any ...) 
{
	if (!g_isSequel) return;
	
	int iScriptLogic = FindEntityByTargetname(-1, PLUGIN_SCRIPTLOGIC);
	if (!RealValidEntity(iScriptLogic))
	{
		iScriptLogic = CreateEntityByName("logic_script");
		DispatchKeyValue(iScriptLogic, "targetname", PLUGIN_SCRIPTLOGIC);
		DispatchSpawn(iScriptLogic);
	}
	
	static char sBuffer[512]; 
	VFormat(sBuffer, sizeof(sBuffer), sCode, 2); 
	
	SetVariantString(sBuffer); 
	AcceptEntityInput(iScriptLogic, "RunScriptCode");
}

void SetDTCountdownTimer(int entity, const char[] classname, const char[] timer_str, float duration)
{
	int info = FindSendPropInfo(classname, timer_str);
	SetEntDataFloat(entity, (info+4), duration, true);
	SetEntDataFloat(entity, (info+8), GetGameTime()+duration, true);
}

stock int FindEntityByTargetname(int index, const char[] findname, bool onlyNetworked = false)
{
	for (int i = index; i < (onlyNetworked ? GetMaxEntities() : (GetMaxEntities()*2)); i++) {
		if (!RealValidEntity(i)) continue;
		static char name[128];
		GetEntPropString(i, Prop_Data, "m_iName", name, sizeof(name));
		if (strcmp(name, findname, false) == 0) continue;
		return i;
	}
	return -1;
}

stock bool IsSurvivor(int client)
{ return (GetClientTeam(client) == 2 || GetClientTeam(client) == 4); }
stock bool IsInfected(int client)
{ return (GetClientTeam(client) == 3); }

void EmitAmbientGenericSound(float pos[3], const char[] snd_str)
{
	int snd_ent = CreateEntityByName("ambient_generic");
	
	TeleportEntity(snd_ent, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchKeyValue(snd_ent, "message", snd_str);
	DispatchKeyValue(snd_ent, "health", "10");
	DispatchKeyValue(snd_ent, "spawnflags", "48");
	DispatchSpawn(snd_ent);
	ActivateEntity(snd_ent);
	
	AcceptEntityInput(snd_ent, "PlaySound");
	
	AcceptEntityInput(snd_ent, "Kill");
}

stock bool IsValidClient(int client, bool replaycheck = true, bool isLoop = false)
{
	if ((isLoop || client > 0 && client <= MaxClients) && IsClientInGame(client))
	{
		if (HasEntProp(client, Prop_Send, "m_bIsCoaching")) // TF2, CSGO?
			if (view_as<bool>(GetEntProp(client, Prop_Send, "m_bIsCoaching"))) return false;
		if (replaycheck)
		{
			if (IsClientSourceTV(client) || IsClientReplay(client)) return false;
		}
		return true;
	}
	return false;
}

stock bool RealValidEntity(int entity)
{ return (entity > 0 && IsValidEntity(entity)); }

stock bool Cmd_CheckClient(int client, int sender = -1, bool must_be_alive = false, int must_be_survivor = -1, bool print = true)
{
	if (!IsValidClient(client))
	{ if (print && IsValidClient(sender)) PrintToChat(sender, CMD_INVALID_CL); return false; }
	
	if (must_be_alive && (!IsPlayerAlive(client) || IsClientObserver(client)))
	{ if (print && IsValidClient(sender)) PrintToChat(sender, CMD_DEAD_CL); return false; }
	
	if (must_be_survivor > 0)
	{
		if (!IsSurvivor(client))
		{ if (print && IsValidClient(sender)) PrintToChat(sender, CMD_NOT_SURVIVOR_CL); return false; }
	}
	else if (must_be_survivor == 0)
	{
		if (!IsInfected(client))
		{ if (print && IsValidClient(sender)) PrintToChat(sender, CMD_NOT_INFECTED_CL); return false; }
	}
	
	return true;
}

/*stock bool Cmd_GetTargets(int client, const char[] arg, int[] target_list, int target_count, int filter = COMMAND_FILTER_ALIVE)
{
	static char target_name[MAX_TARGET_LENGTH]; target_name[0] = '\0';
	bool tn_is_ml;
	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			filter,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{ ReplyToTargetError(client, target_count); return false; }
	return true;
}*/

stock int Cmd_GetTargets(int client, const char[] arg, int[] target_list, int filter = COMMAND_FILTER_ALIVE)
{
	static char target_name[MAX_TARGET_LENGTH]; target_name[0] = '\0';
	int target_count;
	bool tn_is_ml;
	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			filter,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{ ReplyToTargetError(client, target_count); return -1; }
	return target_count;
}

/*int[2] Cmd_GetTargets(int client, const char[] arg, int filter = COMMAND_FILTER_ALIVE)
{
	int cmd_result[2]; cmd_result[0] = -1; cmd_result[1] = -1;
	
	static char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			filter,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{ ReplyToTargetError(client, target_count); }
	else
	{ cmd_result[0] = target_list; cmd_result[1] = target_count; }
	return cmd_result;
}*/

void DoClientTrace(int client, int mask = MASK_OPAQUE, bool print_to_cl = false, float targ_vec[3])
{
	if (!IsValidClient(client)) return;
	
	float VecAngles[3];
	GetClientEyePosition(client, targ_vec);
	GetClientEyeAngles(client, VecAngles);
	TR_TraceRayFilter(targ_vec, VecAngles, mask, RayType_Infinite, TraceRayDontHitSelf, client);
	if (TR_DidHit(null))
	{
		TR_GetEndPosition(targ_vec);
	}
	else if (print_to_cl)
	{
		PrintToChat(client, "[SM] Vector out of world geometry. Getting origin instead.");
	}
}

void GetGamedata()
{
	static char filePath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, filePath, sizeof(filePath), "gamedata/%s.txt", GAMEDATA);
	if ( FileExists(filePath) )
	{
		hConf = LoadGameConfigFile(GAMEDATA); // For some reason this doesn't return null even for invalid files, so check they exist first.
	}
	else
	{
		PrintToServer("[SM] %s unable to get %s.txt gamedata file. Generating...", PLUGIN_NAME, GAMEDATA);
		
		Handle fileHandle = OpenFile(filePath, "w");
		if (fileHandle == null)
		{ PrintToServer("[SM] Couldn't generate gamedata file!"); return; }
		
		WriteFileLine(fileHandle, "\"Games\"");
		WriteFileLine(fileHandle, "{");
		WriteFileLine(fileHandle, "	\"left4dead2\"");
		WriteFileLine(fileHandle, "	{");
		WriteFileLine(fileHandle, "		\"Signatures\"");
		WriteFileLine(fileHandle, "		{");
		WriteFileLine(fileHandle, "			\"%s\"", NAME_CallPushPlayer);
		WriteFileLine(fileHandle, "			{");
		WriteFileLine(fileHandle, "				\"library\"	\"server\"");
		WriteFileLine(fileHandle, "				\"linux\"	\"%s\"", SIG_CallPushPlayer_LINUX);
		WriteFileLine(fileHandle, "				\"windows\"	\"%s\"", SIG_CallPushPlayer_WINDOWS);
		WriteFileLine(fileHandle, "				\"mac\"	\"%s\"", SIG_CallPushPlayer_LINUX);
		WriteFileLine(fileHandle, "			}");
		/*WriteFileLine(fileHandle, "			\"%s\"", NAME_DetonateAcid);
		WriteFileLine(fileHandle, "			{");
		WriteFileLine(fileHandle, "				\"library\"	\"server\"");
		WriteFileLine(fileHandle, "				\"linux\"	\"%s\"", SIG_DetonateAcid_LINUX);
		WriteFileLine(fileHandle, "				\"windows\"	\"%s\"", SIG_DetonateAcid_WINDOWS);
		WriteFileLine(fileHandle, "				\"mac\"	\"%s\"", SIG_DetonateAcid_LINUX);
		WriteFileLine(fileHandle, "			}");
		WriteFileLine(fileHandle, "			\"%s\"", NAME_ShoveSurv);
		WriteFileLine(fileHandle, "			{");
		WriteFileLine(fileHandle, "				\"library\"	\"server\"");
		WriteFileLine(fileHandle, "				\"linux\"	\"%s\"", SIG_ShoveSurv_LINUX);
		WriteFileLine(fileHandle, "				\"windows\"	\"%s\"", SIG_ShoveSurv_WINDOWS);
		WriteFileLine(fileHandle, "				\"mac\"	\"%s\"", SIG_ShoveSurv_LINUX);
		WriteFileLine(fileHandle, "			}");
		WriteFileLine(fileHandle, "			\"%s\"", NAME_ShoveInf);
		WriteFileLine(fileHandle, "			{");
		WriteFileLine(fileHandle, "				\"library\"	\"server\"");
		WriteFileLine(fileHandle, "				\"linux\"	\"%s\"", SIG_ShoveInf_LINUX);
		WriteFileLine(fileHandle, "				\"windows\"	\"%s\"", SIG_ShoveInf_WINDOWS);
		WriteFileLine(fileHandle, "				\"mac\"	\"%s\"", SIG_ShoveInf_LINUX);
		WriteFileLine(fileHandle, "			}");*/
		WriteFileLine(fileHandle, "		}");
		WriteFileLine(fileHandle, "	}");
		WriteFileLine(fileHandle, "}");
		
		CloseHandle(fileHandle);
		hConf = LoadGameConfigFile(GAMEDATA);
		if (hConf == null)
		{ PrintToServer("[SM] Failed to load auto-generated gamedata file!"); return; }
		
		PrintToServer("[SM] %s successfully generated %s.txt gamedata file!", PLUGIN_NAME, GAMEDATA);
	}
	PrepSDKCall();
}

void PrepSDKCall()
{
	if (hConf == null)
	{ PrintToServer("Unable to find %s.txt gamedata.", GAMEDATA); return; }
	
	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, NAME_CallPushPlayer))
	{ PrintToServer("[%s] Failed to set %s from config!", PLUGIN_NAME_SHORT, NAME_CallPushPlayer); return; }
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	sdkCallPushPlayer = EndPrepSDKCall();
	if (sdkCallPushPlayer == null)
	{ PrintToServer("[%s] Cannot initialize %s SDKCall, signature is broken.", PLUGIN_NAME_SHORT, NAME_CallPushPlayer); return; }
	
	/*StartPrepSDKCall(SDKCall_Entity);
	if (!PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, NAME_DetonateAcid))
	{ SetFailState("[SM] Failed to set %s %s from config!", PLUGIN_NAME_SHORT, NAME_DetonateAcid); }
	sdkDetonateAcid = EndPrepSDKCall();
	if (sdkDetonateAcid == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_DetonateAcid); return; }*/
	
	// Signature end
	
	delete hConf;
}

// OLD STUFF

	/*StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer_OnHitByVomitJar");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	sdkVomitInfected = EndPrepSDKCall();
	if (sdkVomitInfected == null)
	{
		SetFailState("Unable to find the \"CTerrorPlayer_OnHitByVomitJar\" signature, check the file version!");
	}
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer_Fling");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	sdkCallPushPlayer = EndPrepSDKCall();
	if (sdkCallPushPlayer == null)
	{
		SetFailState("Unable to find the \"CTerrorPlayer_Fling\" signature, check the file version!");
	}
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer_OnVomitedUpon");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	sdkVomitSurvivor = EndPrepSDKCall();
	if (sdkVomitSurvivor == null)
	{
		SetFailState("Unable to find the \"CTerrorPlayer_OnVomitedUpon\" signature, check the file version!");
	}
	
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CSpitterProjectile_Detonate");
	sdkDetonateAcid = EndPrepSDKCall();
	if (sdkDetonateAcid == null)
	{
		SetFailState("Unable to find the \"CSpitterProjectile::Detonate(void)\" signature, check the file version!");
	}
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer_OnAdrenalineUsed");
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	sdkAdrenaline = EndPrepSDKCall();
	if (sdkAdrenaline == null)
	{
		SetFailState("Unable to find the \"CTerrorPlayer::OnAdrenalineUsed(float)\" signature, check the file version!");
	}
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer_SetHealthBuffer");
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	sdkSetBuffer = EndPrepSDKCall();
	if (sdkSetBuffer == null)
	{
		SetFailState("Unable to find the \"CTerrorPlayer::SetHealthBuffer(float)\" signature, check the file version!");
	}
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer_OnRevived");
	sdkRevive = EndPrepSDKCall();
	if (sdkRevive == null)
	{
		SetFailState("Unable to find the \"CTerrorPlayer::OnRevived(void)\" signature, check the file version!");
	}
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer_OnStaggered");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	sdkShoveSurv = EndPrepSDKCall();
	if (sdkShoveSurv == null)
	{
		SetFailState("Unable to find the \"CTerrorPlayer::OnStaggered(CBaseEntity *, Vector  const*)\" signature, check the file version!");
	}
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer_OnStaggered");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	sdkShoveInf = EndPrepSDKCall();
	if (sdkShoveInf == null)
	{
		SetFailState("Unable to find the \"CTerrorPlayer::OnShovedBySurvivor(CTerrorPlayer*, Vector  const&)\" signature, check the file version!");
	}*/