/**
// ====================================================================================================
Change Log:
1.0.0 (15-02-2024)
    - Initial release.
// ====================================================================================================
*/

// ====================================================================================================
// Filenames
// ====================================================================================================

// ====================================================================================================
// Plugin Info - define
// ====================================================================================================

#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <colors>
#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_DESCRIPTION "Night Vision for survivors"
#define IMPULS_FLASHLIGHT 100 //Flashlight
#define LIGHTING_STRIKE_CORRECTION "materials/correction/lightningstrike100.pwl.raw"

public Plugin myinfo = 
{
	name 			= "[L4D2] Night Vision",
	author 			= "Tuan",
	description 	= PLUGIN_DESCRIPTION,
	version 		=  PLUGIN_VERSION,
	url 			= "https://steamcommunity.com/id/Strikeraot/"
}

// ====================================================================================================
// Global Varriables
// ====================================================================================================
int g_iEntRef[MAXPLAYERS] = {INVALID_ENT_REFERENCE, ...};
float g_fLastPress[MAXPLAYERS];
bool g_bEnabled[MAXPLAYERS];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if (test != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

public void OnClientDisconnect(int client)
{
	// Clear this player's slot
	if(IsFakeClient(client))
		return;
	DeletePlayerCC(client);
	g_fLastPress[client] = 0.0;
	g_bEnabled[client] = false;
}
// ====================================================================================================
// Main Plugin Code start here...
// ====================================================================================================
public Action OnPlayerRunCmd(int client, int &buttons, int &impuls, float vel[3], float angles[3], int &weapon)
{
	if (impuls == IMPULS_FLASHLIGHT)
	{
		if (0 < client < MaxClients && IsPlayerAlive(client)) {
			float fCurrent = GetEngineTime();
			if (fCurrent - g_fLastPress[client] <= 0.3) {
				// Show menu
				Toggle(client);
			}
			g_fLastPress[client] = fCurrent;
		}
	}
	return Plugin_Continue;
}

public void Toggle(int client)
{
	//PrintToChatAll("In Toggle for id: %i, %N", client, client);
	if(client == 0) return;
	g_bEnabled[client] = !g_bEnabled[client];
	DeletePlayerCC(client);
	// player's correction has been enabled before disabling
	if (!g_bEnabled[client])  {
		//PrintToChatAll("Disabled");
	}
	else
	{
		if(!CreatePlayerCC(client, LIGHTING_STRIKE_CORRECTION)) {
			LogError("Can't create \"color_correction\" entity for %i (%N)", client, client);
			g_bEnabled[client] = false;
		}
		else {
			//PrintToChatAll("Enabled");
		}
	}
}

// ====================================================================================================
// Entity Stuff
// ====================================================================================================
void DeletePlayerCC(int client)
{
	int ent = EntRefToEntIndex(g_iEntRef[client]);
	if(ent != -1 && IsValidEntity(ent)) 
		RemoveEntity(ent);
	g_iEntRef[client] = INVALID_ENT_REFERENCE;
}

bool CreatePlayerCC(int client, const char[] raw_file)
{
	int ent = CreateEntityByName("color_correction");
	DispatchKeyValue(ent, "StartDisabled", "0");
	DispatchKeyValue(ent, "maxweight", "1.0");
	DispatchKeyValue(ent, "maxfalloff", "-1.0");
	DispatchKeyValue(ent, "minfalloff", "0.0");
	DispatchKeyValue(ent, "filename", raw_file);
	
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	SetEntPropFloat(ent, Prop_Send, "m_flCurWeight", 1.0);
	SetEdictFlags(ent, GetEdictFlags(ent) & ~FL_EDICT_ALWAYS);
	if (!CheckIfEntityMax(EntIndexToEntRef(ent))) return false;
	SDKHook(ent, SDKHook_SetTransmit, OnHook_Transmit);
	g_iEntRef[client] = EntIndexToEntRef(ent);
	
	return true;
}

public Action OnHook_Transmit(int entity, int client)
{
	SetEdictFlags(entity, GetEdictFlags(entity) & ~FL_EDICT_ALWAYS);
	
	// only show to client his correction
	if (EntRefToEntIndex(g_iEntRef[client]) != entity)
		return Plugin_Handled;
	else
	{
		SetEdictFlags(entity, GetEdictFlags(entity) | FL_EDICT_DONTSEND);
		SetEntPropFloat(entity, Prop_Send, "m_flCurWeight", 1.0);
		return Plugin_Continue;
	}
}

// ====================================================================================================
// Stocks
// ====================================================================================================
bool CheckIfEntityMax(int entity)
{
	entity = EntRefToEntIndex(entity);
	if(entity == -1) return false;

	if(	entity > 2000)
	{
		AcceptEntityInput(entity, "Kill");
		return false;
	}
	return true;
}