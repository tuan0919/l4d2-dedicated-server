/**
// ====================================================================================================
Change Log:

1.0.7 (04-March-2022)
    - Fixed compability with other plugins. (thanks "ddd123" for reporting)

1.0.6 (26-February-2021)
    - Added support for explosive oil drum (custom model - can be found on GoldenEye 4 Dead custom map)

1.0.5 (04-January-2021)
    - Added support for gas pump. (found on No Mercy, 3rd map)

1.0.4 (29-November-2020)
    - Added support to physics_prop, prop_physics_override and prop_physics_multiplayer.

1.0.3 (28-November-2020)
    - Changed the detection method of explosion, from OnEntityDestroyed to break_prop/OnKilled.
    - Fixed message being sent when pick up a breakable prop item while on ignition.
    - Fixed message being sent from fuel barrel parts explosion.
    - Added Hungarian (hu) translations. (thanks to "KasperH")

1.0.2 (21-October-2020)
    - Fixed a bug while printing to chat for multiple clients. (thanks to "KRUTIK" for reporting)
    - Added Russian (ru) translations. (thanks to "KRUTIK")
    - Fixed some Russian (ru) lines. (thanks to " Angerfist2188")

1.0.1 (20-October-2020)
    - Added Simplified Chinese (chi) and Traditional Chinese (zho) translations. (thanks to "HarryPotter")
    - Fixed some Simplified Chinese (chi) lines. (thanks to "viaxiamu")

1.0.0 (20-October-2020)
    - Initial release.

// ====================================================================================================
*/

// ====================================================================================================
// Plugin Info - define
// ====================================================================================================
#define PLUGIN_NAME                   "[L4D1 & L4D2] Explosion Announcer"
#define PLUGIN_AUTHOR                 "Mart"
#define PLUGIN_DESCRIPTION            "Outputs to the chat who exploded some props"
#define PLUGIN_VERSION                "1.0.7"
#define PLUGIN_URL                    "https://forums.alliedmods.net/showthread.php?t=328006"

// ====================================================================================================
// Plugin Info
// ====================================================================================================
public Plugin myinfo =
{
    name        = PLUGIN_NAME,
    author      = PLUGIN_AUTHOR,
    description = PLUGIN_DESCRIPTION,
    version     = PLUGIN_VERSION,
    url         = PLUGIN_URL
}

// ====================================================================================================
// Includes
// ====================================================================================================
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <Tuan_custom_forwards>

// ====================================================================================================
// Pragmas
// ====================================================================================================
#pragma semicolon 1
#pragma newdecls required

// ====================================================================================================
// Cvar Flags
// ====================================================================================================
#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

// ====================================================================================================
// Filenames
// ====================================================================================================
#define CONFIG_FILENAME               "l4d_explosion_announcer"

// ====================================================================================================
// Defines
// ====================================================================================================
#define MODEL_GASCAN                  "models/props_junk/gascan001a.mdl"
#define MODEL_FUEL_BARREL             "models/props_industrial/barrel_fuel.mdl"
#define MODEL_PROPANECANISTER         "models/props_junk/propanecanister001a.mdl"
#define MODEL_OXYGENTANK              "models/props_equipment/oxygentank01.mdl"
#define MODEL_BARRICADE_GASCAN        "models/props_unique/wooden_barricade_gascans.mdl"
#define MODEL_GAS_PUMP                "models/props_equipment/gas_pump_nodebris.mdl"
#define MODEL_FIREWORKS_CRATE         "models/props_junk/explosive_box001.mdl"
#define MODEL_OILDRUM_EXPLOSIVE       "models/props_c17/oildrum001_explosive.mdl" // Custom Model - can be found on GoldenEye 4 Dead custom map

#define TEAM_SPECTATOR                1
#define TEAM_SURVIVOR                 2
#define TEAM_INFECTED                 3
#define TEAM_HOLDOUT                  4

#define FLAG_TEAM_NONE                (0 << 0) // 0 | 0000
#define FLAG_TEAM_SURVIVOR            (1 << 0) // 1 | 0001
#define FLAG_TEAM_INFECTED            (1 << 1) // 2 | 0010
#define FLAG_TEAM_SPECTATOR           (1 << 2) // 4 | 0100
#define FLAG_TEAM_HOLDOUT             (1 << 3) // 8 | 1000

#define TYPE_NONE                     0
#define TYPE_GASCAN                   1
#define TYPE_FUEL_BARREL              2
#define TYPE_PROPANECANISTER          3
#define TYPE_OXYGENTANK               4
#define TYPE_BARRICADE_GASCAN         5
#define TYPE_GAS_PUMP                 6
#define TYPE_FIREWORKS_CRATE          7
#define TYPE_OIL_DRUM_EXPLOSIVE       8

#define MAX_TYPES                     8

#define MAXENTITIES                   2048

// ====================================================================================================
// Plugin Cvars
// ====================================================================================================
ConVar g_hCvar_Enabled;
ConVar g_hCvar_SpamProtection;
ConVar g_hCvar_SpamTypeCheck;
ConVar g_hCvar_Team;
ConVar g_hCvar_Self;
ConVar g_hCvar_Gascan;
ConVar g_hCvar_FuelBarrel;
ConVar g_hCvar_PropaneCanister;
ConVar g_hCvar_OxygenTank;
ConVar g_hCvar_BarricadeGascan;
ConVar g_hCvar_GasPump;
ConVar g_hCvar_FireworksCrate;
ConVar g_hCvar_OilDrumExplosive;

// ====================================================================================================
// bool - Plugin Variables
// ====================================================================================================
bool g_bL4D2;
bool g_bEventsHooked;
bool g_bCvar_Enabled;
bool g_bCvar_SpamProtection;
bool g_bCvar_SpamTypeCheck;
bool g_bCvar_Self;
bool g_bCvar_Gascan;
bool g_bCvar_FuelBarrel;
bool g_bCvar_PropaneCanister;
bool g_bCvar_OxygenTank;
bool g_bCvar_BarricadeGascan;
bool g_bCvar_GasPump;
bool g_bCvar_FireworksCrate;
bool g_bCvar_OilDrumExplosive;

// ====================================================================================================
// int - Plugin Variables
// ====================================================================================================
int g_iModel_Gascan = -1;
int g_iModel_FuelBarrel = -1;
int g_iModel_PropaneCanister = -1;
int g_iModel_OxygenTank = -1;
int g_iModel_BarricadeGascan = -1;
int g_iModel_GasPump = -1;
int g_iModel_FireworksCrate = -1;
int g_iModel_OilDrumExplosive = -1;
int g_iCvar_Team;

// ====================================================================================================
// float - Plugin Variables
// ====================================================================================================
float g_fCvar_SpamProtection;

// ====================================================================================================
// client - Plugin Variables
// ====================================================================================================
float gc_fLastChatOccurrence[MAXPLAYERS+1][MAX_TYPES+1];

// ====================================================================================================
// entity - Plugin Variables
// ====================================================================================================
int ge_iType[MAXENTITIES+1];
int ge_iLastAttacker[MAXENTITIES+1];
GlobalForward g_OnClientExplodeObject;

// ====================================================================================================
// Plugin Start
// ====================================================================================================
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion engine = GetEngineVersion();

    if (engine != Engine_Left4Dead && engine != Engine_Left4Dead2)
    {
        strcopy(error, err_max, "This plugin only runs in \"Left 4 Dead\" and \"Left 4 Dead 2\" game");
        return APLRes_SilentFailure;
    }

    g_bL4D2 = (engine == Engine_Left4Dead2);

    return APLRes_Success;
}

/****************************************************************************************************/

public void OnPluginStart()
{

    CreateConVar("l4d_explosion_announcer_version", PLUGIN_VERSION, PLUGIN_DESCRIPTION, CVAR_FLAGS_PLUGIN_VERSION);
    g_hCvar_Enabled            = CreateConVar("l4d_explosion_announcer_enable", "1", "Enable/Disable the plugin.\n0 = Disable, 1 = Enable.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvar_SpamProtection     = CreateConVar("l4d_explosion_announcer_spam_protection", "3.0", "Delay in seconds to output to the chat the message from the same client again.\n0 = OFF.", CVAR_FLAGS, true, 0.0);
    g_hCvar_SpamTypeCheck      = CreateConVar("l4d_explosion_announcer_spam_type_check", "1", "Whether the plugin should apply chat spam protection by entity type.\nExample: \"gascans\" and \"propane canisters\" are of different types.\n0 = OFF, 1 = ON.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvar_Team               = CreateConVar("l4d_explosion_announcer_team", "1", "Which teams should the message be transmitted to.\n0 = NONE, 1 = SURVIVOR, 2 = INFECTED, 4 = SPECTATOR, 8 = HOLDOUT.\nAdd numbers greater than 0 for multiple options.\nExample: \"3\", enables for SURVIVOR and INFECTED.", CVAR_FLAGS, true, 0.0, true, 15.0);
    g_hCvar_Self               = CreateConVar("l4d_explosion_announcer_self", "1", "Should the message be transmitted to those who exploded it.\n0 = OFF, 1 = ON.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvar_Gascan             = CreateConVar("l4d_explosion_announcer_gascan", "1", "Output to the chat every time someone explodes (last hit) a gascan.\n0 = OFF, 1 = ON.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvar_FuelBarrel         = CreateConVar("l4d_explosion_announcer_fuelbarrel", "1", "Output to the chat every time someone explodes (last hit) a fuel barrel.\n0 = OFF, 1 = ON.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvar_PropaneCanister    = CreateConVar("l4d_explosion_announcer_propanecanister", "1", "Output to the chat every time someone explodes (last hit) a propane canister.\n0 = OFF, 1 = ON.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvar_OxygenTank         = CreateConVar("l4d_explosion_announcer_oxygentank", "1", "Output to the chat every time someone explodes (last hit) a oxygen tank.\n0 = OFF, 1 = ON.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvar_BarricadeGascan    = CreateConVar("l4d_explosion_announcer_barricadegascan", "1", "Output to the chat every time someone explodes (last hit) a barricade with gascans.\n0 = OFF, 1 = ON.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvar_GasPump            = CreateConVar("l4d_explosion_announcer_gaspump", "1", "Output to the chat every time someone explodes (last hit) a gas pump.\n0 = OFF, 1 = ON.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvar_OilDrumExplosive   = CreateConVar("l4d_explosion_announcer_oildrumexplosive", "1", "Output to the chat every time someone explodes (last hit) an oil drum explosive (custom).\n0 = OFF, 1 = ON.", CVAR_FLAGS, true, 0.0, true, 1.0);
    if (g_bL4D2)
        g_hCvar_FireworksCrate = CreateConVar("l4d_explosion_announcer_fireworkscrate", "1", "Output to the chat every time someone explodes (last hit) a fireworks crate.\nL4D2 only.\n0 = OFF, 1 = ON.", CVAR_FLAGS, true, 0.0, true, 1.0);

    // Hook plugin ConVars change
    g_hCvar_Enabled.AddChangeHook(Event_ConVarChanged);
    g_hCvar_SpamProtection.AddChangeHook(Event_ConVarChanged);
    g_hCvar_SpamTypeCheck.AddChangeHook(Event_ConVarChanged);
    g_hCvar_Team.AddChangeHook(Event_ConVarChanged);
    g_hCvar_Self.AddChangeHook(Event_ConVarChanged);
    g_hCvar_Gascan.AddChangeHook(Event_ConVarChanged);
    g_hCvar_FuelBarrel.AddChangeHook(Event_ConVarChanged);
    g_hCvar_PropaneCanister.AddChangeHook(Event_ConVarChanged);
    g_hCvar_OxygenTank.AddChangeHook(Event_ConVarChanged);
    g_hCvar_BarricadeGascan.AddChangeHook(Event_ConVarChanged);
    g_hCvar_GasPump.AddChangeHook(Event_ConVarChanged);
    g_hCvar_OilDrumExplosive.AddChangeHook(Event_ConVarChanged);
    if (g_bL4D2)
        g_hCvar_FireworksCrate.AddChangeHook(Event_ConVarChanged);

    // Load plugin configs from .cfg
    AutoExecConfig(true, CONFIG_FILENAME);
	g_OnClientExplodeObject = CreateGlobalForward("Tuan_OnClient_ExplodeObject", ET_Event, Param_Cell, Param_Cell);
    // Admin Commands
    RegAdminCmd("sm_print_cvars_l4d_explosion_announcer", CmdPrintCvars, ADMFLAG_ROOT, "Prints the plugin related cvars and their respective values to the console.");
}

/****************************************************************************************************/

public void OnMapStart()
{
    g_iModel_Gascan = PrecacheModel(MODEL_GASCAN, true);
    g_iModel_FuelBarrel = PrecacheModel(MODEL_FUEL_BARREL, true);
    g_iModel_PropaneCanister = PrecacheModel(MODEL_PROPANECANISTER, true);
    g_iModel_OxygenTank = PrecacheModel(MODEL_OXYGENTANK, true);
    g_iModel_BarricadeGascan = PrecacheModel(MODEL_BARRICADE_GASCAN, true);
    g_iModel_GasPump = PrecacheModel(MODEL_GAS_PUMP, true);
    if (g_bL4D2)
        g_iModel_FireworksCrate = PrecacheModel(MODEL_FIREWORKS_CRATE, true);

    if (IsModelPrecached(MODEL_OILDRUM_EXPLOSIVE))
        g_iModel_OilDrumExplosive = PrecacheModel(MODEL_OILDRUM_EXPLOSIVE, true);
    else
        g_iModel_OilDrumExplosive = -1;
}

void FireClientExplodedObjectEvent(int client, int object_type) {
    Call_StartForward(g_OnClientExplodeObject);
    Call_PushCell(client);
	Call_PushCell(object_type);
    Call_Finish();
}

/****************************************************************************************************/

public void OnConfigsExecuted()
{
    GetCvars();

    LateLoad();

    HookEvents();
}

/****************************************************************************************************/

void Event_ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    GetCvars();

    HookEvents();
}

/****************************************************************************************************/

void GetCvars()
{
    g_bCvar_Enabled = g_hCvar_Enabled.BoolValue;
    g_fCvar_SpamProtection = g_hCvar_SpamProtection.FloatValue;
    g_bCvar_SpamProtection = (g_fCvar_SpamProtection > 0.0);
    g_bCvar_SpamTypeCheck = g_hCvar_SpamTypeCheck.BoolValue;
    g_iCvar_Team = g_hCvar_Team.IntValue;
    g_bCvar_Self = g_hCvar_Self.BoolValue;
    g_bCvar_Gascan = g_hCvar_Gascan.BoolValue;
    g_bCvar_FuelBarrel = g_hCvar_FuelBarrel.BoolValue;
    g_bCvar_PropaneCanister = g_hCvar_PropaneCanister.BoolValue;
    g_bCvar_OxygenTank = g_hCvar_OxygenTank.BoolValue;
    g_bCvar_BarricadeGascan = g_hCvar_BarricadeGascan.BoolValue;
    g_bCvar_GasPump = g_hCvar_GasPump.BoolValue;
    g_bCvar_OilDrumExplosive = g_hCvar_OilDrumExplosive.BoolValue;
    if (g_bL4D2)
        g_bCvar_FireworksCrate = g_hCvar_FireworksCrate.BoolValue;
}

/****************************************************************************************************/

void HookEvents()
{
    if (g_bCvar_Enabled && !g_bEventsHooked)
    {
        g_bEventsHooked = true;

        HookEvent("break_prop", Event_BreakProp);

        return;
    }

    if (!g_bCvar_Enabled && g_bEventsHooked)
    {
        g_bEventsHooked = false;

        UnhookEvent("break_prop", Event_BreakProp);

        return;
    }
}

/****************************************************************************************************/

void Event_BreakProp(Event event, const char[] name, bool dontBroadcast)
{
    int entity = event.GetInt("entindex");
    int client = GetClientOfUserId(event.GetInt("userid"));

    int type = ge_iType[entity];

    if (type == TYPE_NONE)
        return;

    if (client == 0)
        client = GetClientOfUserId(ge_iLastAttacker[entity]);

    if (client == 0)
        return;

    OutputMessage(client, type);
}

/****************************************************************************************************/

public void OnClientDisconnect(int client)
{
    for (int type = TYPE_NONE; type <= MAX_TYPES; type++)
    {
        gc_fLastChatOccurrence[client][type] = 0.0;
    }
}

/****************************************************************************************************/

void LateLoad()
{
    int entity;

    if (g_bL4D2)
    {
        entity = INVALID_ENT_REFERENCE;
        while ((entity = FindEntityByClassname(entity, "weapon_gascan")) != INVALID_ENT_REFERENCE)
        {
            RequestFrame(OnNextFrameWeaponGascan, EntIndexToEntRef(entity));
        }
    }

    entity = INVALID_ENT_REFERENCE;
    while ((entity = FindEntityByClassname(entity, "prop_fuel_barrel")) != INVALID_ENT_REFERENCE)
    {
        RequestFrame(OnNextFrame, EntIndexToEntRef(entity));
    }

    entity = INVALID_ENT_REFERENCE;
    while ((entity = FindEntityByClassname(entity, "prop_physics*")) != INVALID_ENT_REFERENCE)
    {
        if (HasEntProp(entity, Prop_Send, "m_isCarryable")) // CPhysicsProp
            RequestFrame(OnNextFrame, EntIndexToEntRef(entity));
    }

    entity = INVALID_ENT_REFERENCE;
    while ((entity = FindEntityByClassname(entity, "physics_prop")) != INVALID_ENT_REFERENCE)
    {
        RequestFrame(OnNextFrame, EntIndexToEntRef(entity));
    }
}

/****************************************************************************************************/

public void OnEntityCreated(int entity, const char[] classname)
{
    if (entity < 0)
        return;

    switch (classname[0])
    {
        case 'w':
        {
            if (!g_bL4D2)
                return;

            if (classname[1] != 'e') // weapon_*
                return;

            if (StrEqual(classname, "weapon_gascan"))
            {
                RequestFrame(OnNextFrameWeaponGascan, EntIndexToEntRef(entity));
            }
        }
        case 'p':
        {
            if (HasEntProp(entity, Prop_Send, "m_isCarryable")) // CPhysicsProp
                RequestFrame(OnNextFrame, EntIndexToEntRef(entity));
        }
    }
}

/****************************************************************************************************/

public void OnEntityDestroyed(int entity)
{
    if (entity < 0)
        return;

    ge_iType[entity] = TYPE_NONE;
    ge_iLastAttacker[entity] = 0;
}

/****************************************************************************************************/

// Extra frame to get netprops updated
void OnNextFrameWeaponGascan(int entityRef)
{
    int entity = EntRefToEntIndex(entityRef);

    if (entity == INVALID_ENT_REFERENCE)
        return;

    if (ge_iType[entity] != TYPE_NONE)
        return;

    if (GetEntProp(entity, Prop_Data, "m_iHammerID") == -1) // Ignore entities with hammerid -1
        return;

    RenderMode rendermode = GetEntityRenderMode(entity);
    int rgba[4];
    GetEntityRenderColor(entity, rgba[0], rgba[1], rgba[2], rgba[3]);

    if (rendermode == RENDER_NONE || (rendermode == RENDER_TRANSCOLOR && rgba[3] == 0)) // Other plugins support, ignore invisible entities
        return;

    ge_iType[entity] = TYPE_GASCAN;
    SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
    HookSingleEntityOutput(entity, "OnKilled", OnKilled, true);
}

/****************************************************************************************************/

// Extra frame to get netprops updated
void OnNextFrame(int entityRef)
{
    int entity = EntRefToEntIndex(entityRef);

    if (entity == INVALID_ENT_REFERENCE)
        return;

    if (ge_iType[entity] != TYPE_NONE)
        return;

    if (GetEntProp(entity, Prop_Data, "m_iHammerID") == -1) // Ignore entities with hammerid -1
        return;

    RenderMode rendermode = GetEntityRenderMode(entity);
    int rgba[4];
    GetEntityRenderColor(entity, rgba[0], rgba[1], rgba[2], rgba[3]);

    if (rendermode == RENDER_NONE || (rendermode == RENDER_TRANSCOLOR && rgba[3] == 0)) // Other plugins support, ignore invisible entities
        return;

    int modelIndex = GetEntProp(entity, Prop_Send, "m_nModelIndex");

    if (modelIndex == g_iModel_Gascan)
    {
        ge_iType[entity] = TYPE_GASCAN;
        SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
        return;
    }

    if (modelIndex == g_iModel_FuelBarrel)
    {
        ge_iType[entity] = TYPE_FUEL_BARREL;
        SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
        return;
    }

    if (modelIndex == g_iModel_PropaneCanister)
    {
        ge_iType[entity] = TYPE_PROPANECANISTER;
        SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
        return;
    }

    if (modelIndex == g_iModel_OxygenTank)
    {
        ge_iType[entity] = TYPE_OXYGENTANK;
        SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
        return;
    }

    if (modelIndex == g_iModel_BarricadeGascan)
    {
        ge_iType[entity] = TYPE_BARRICADE_GASCAN;
        SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
        return;
    }

    if (modelIndex == g_iModel_GasPump)
    {
        ge_iType[entity] = TYPE_GAS_PUMP;
        SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
        return;
    }

    if (modelIndex == g_iModel_OilDrumExplosive && g_iModel_OilDrumExplosive != -1)
    {
        ge_iType[entity] = TYPE_OIL_DRUM_EXPLOSIVE;
        SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
        return;
    }

    if (!g_bL4D2)
        return;

    if (modelIndex == g_iModel_FireworksCrate)
    {
        ge_iType[entity] = TYPE_FIREWORKS_CRATE;
        SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
        return;
    }
}

/****************************************************************************************************/

Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!g_bCvar_Enabled)
        return Plugin_Continue;

    if (IsValidClient(attacker))
        ge_iLastAttacker[victim] = GetClientUserId(attacker);

    return Plugin_Continue;
}

/****************************************************************************************************/

void OnKilled(const char[] output, int caller, int activator, float delay)
{
    if (!g_bCvar_Enabled)
        return;

    int type = ge_iType[caller];

    if (type == TYPE_NONE)
        return;

    if (IsValidClient(activator))
        ge_iLastAttacker[caller] = GetClientUserId(activator);

    if (ge_iLastAttacker[caller] == 0)
        return;

    int client = GetClientOfUserId(ge_iLastAttacker[caller]);

    if (client == 0)
        return;

    OutputMessage(client, type);
}

/****************************************************************************************************/

void OutputMessage(int client, int type)
{
    if (g_iCvar_Team == FLAG_TEAM_NONE)
        return;

    if (g_bCvar_SpamProtection)
    {
        if (g_bCvar_SpamTypeCheck)
        {
            if (gc_fLastChatOccurrence[client][type] != 0.0 && GetGameTime() - gc_fLastChatOccurrence[client][type] < g_fCvar_SpamProtection)
                return;

            gc_fLastChatOccurrence[client][type] = GetGameTime();
        }
        else
        {
            if (gc_fLastChatOccurrence[client][TYPE_NONE] != 0.0 && GetGameTime() - gc_fLastChatOccurrence[client][TYPE_NONE] < g_fCvar_SpamProtection)
                return;

            gc_fLastChatOccurrence[client][TYPE_NONE] = GetGameTime();
        }
    }

    switch (type)
    {
        case TYPE_GASCAN:
        {
            if (!g_bCvar_Gascan)
                return;

            FireClientExplodedObjectEvent(client, TYPE_GASCAN);
        }

        case TYPE_FUEL_BARREL:
        {
            if (!g_bCvar_FuelBarrel)
                return;

            FireClientExplodedObjectEvent(client, TYPE_FUEL_BARREL);
        }

        case TYPE_PROPANECANISTER:
        {
            if (!g_bCvar_PropaneCanister)
                return;

			FireClientExplodedObjectEvent(client, TYPE_PROPANECANISTER);
        }

        case TYPE_OXYGENTANK:
        {
            if (!g_bCvar_OxygenTank)
                return;

            FireClientExplodedObjectEvent(client, TYPE_OXYGENTANK);
        }

        case TYPE_BARRICADE_GASCAN:
        {
            if (!g_bCvar_BarricadeGascan)
                return;

            FireClientExplodedObjectEvent(client, TYPE_BARRICADE_GASCAN);
        }

        case TYPE_GAS_PUMP:
        {
            if (!g_bCvar_GasPump)
                return;

            FireClientExplodedObjectEvent(client, TYPE_GAS_PUMP);
        }

        case TYPE_FIREWORKS_CRATE:
        {
            if (!g_bCvar_FireworksCrate)
                return;

            FireClientExplodedObjectEvent(client, TYPE_FIREWORKS_CRATE);
        }

        case TYPE_OIL_DRUM_EXPLOSIVE:
        {
            if (!g_bCvar_OilDrumExplosive)
                return;

            FireClientExplodedObjectEvent(client, TYPE_OIL_DRUM_EXPLOSIVE);
        }
    }
}

// ====================================================================================================
// Admin Commands
// ====================================================================================================
Action CmdPrintCvars(int client, int args)
{
    PrintToConsole(client, "");
    PrintToConsole(client, "======================================================================");
    PrintToConsole(client, "");
    PrintToConsole(client, "--------------- Plugin Cvars (l4d_explosion_announcer) ---------------");
    PrintToConsole(client, "");
    PrintToConsole(client, "l4d_explosion_announcer_version : %s", PLUGIN_VERSION);
    PrintToConsole(client, "l4d_explosion_announcer_enable : %b (%s)", g_bCvar_Enabled, g_bCvar_Enabled ? "true" : "false");
    PrintToConsole(client, "l4d_explosion_announcer_spam_protection : %.1f", g_fCvar_SpamProtection);
    PrintToConsole(client, "l4d_explosion_announcer_spam_type_check : %b (%s)", g_bCvar_SpamTypeCheck, g_bCvar_SpamTypeCheck ? "true" : "false");
    PrintToConsole(client, "l4d_explosion_announcer_team : %i (SPECTATOR = %s | SURVIVOR = %s | INFECTED = %s | HOLDOUT = %s)", g_iCvar_Team,
    g_iCvar_Team & FLAG_TEAM_SPECTATOR ? "true" : "false", g_iCvar_Team & FLAG_TEAM_SURVIVOR ? "true" : "false", g_iCvar_Team & FLAG_TEAM_INFECTED ? "true" : "false", g_iCvar_Team & FLAG_TEAM_HOLDOUT ? "true" : "false");
    PrintToConsole(client, "l4d_explosion_announcer_self : %b (%s)", g_bCvar_Self, g_bCvar_Self ? "true" : "false");
    PrintToConsole(client, "l4d_explosion_announcer_gascan : %b (%s)", g_bCvar_Gascan, g_bCvar_Gascan ? "true" : "false");
    PrintToConsole(client, "l4d_explosion_announcer_fuelbarrel : %b (%s)", g_bCvar_FuelBarrel, g_bCvar_FuelBarrel ? "true" : "false");
    PrintToConsole(client, "l4d_explosion_announcer_propanecanister : %b (%s)", g_bCvar_PropaneCanister, g_bCvar_PropaneCanister ? "true" : "false");
    PrintToConsole(client, "l4d_explosion_announcer_oxygentank : %b (%s)", g_bCvar_OxygenTank, g_bCvar_OxygenTank ? "true" : "false");
    PrintToConsole(client, "l4d_explosion_announcer_barricadegascan : %b (%s)", g_bCvar_BarricadeGascan, g_bCvar_BarricadeGascan ? "true" : "false");
    PrintToConsole(client, "l4d_explosion_announcer_gaspump : %b (%s)", g_bCvar_GasPump, g_bCvar_GasPump ? "true" : "false");
    PrintToConsole(client, "l4d_explosion_announcer_oildrumexplosive : %b (%s)", g_bCvar_OilDrumExplosive, g_bCvar_OilDrumExplosive ? "true" : "false");
    if (g_bL4D2) PrintToConsole(client, "l4d_explosion_announcer_fireworkscrate : %b (%s)", g_bCvar_FireworksCrate, g_bCvar_FireworksCrate ? "true" : "false");
    PrintToConsole(client, "");
    PrintToConsole(client, "======================================================================");
    PrintToConsole(client, "");

    return Plugin_Handled;
}

// ====================================================================================================
// Helpers
// ====================================================================================================
/**
 * Validates if is a valid client index.
 *
 * @param client        Client index.
 * @return              True if client index is valid, false otherwise.
 */
bool IsValidClientIndex(int client)
{
    return (1 <= client <= MaxClients);
}

/****************************************************************************************************/

/**
 * Validates if is a valid client.
 *
 * @param client        Client index.
 * @return              True if client index is valid and client is in game, false otherwise.
 */
bool IsValidClient(int client)
{
    return (IsValidClientIndex(client) && IsClientInGame(client));
}