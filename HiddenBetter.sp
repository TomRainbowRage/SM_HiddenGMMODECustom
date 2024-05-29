#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "TomRainbowRage"
#define PLUGIN_VERSION "0.00"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <string>
#include <sdkhooks>
#include <entity>
#include <adt_array>

#pragma newdecls required
#pragma semicolon 1

EngineVersion g_Game;

public Plugin myinfo = 
{
	name = "HiddenBetter",
	author = PLUGIN_AUTHOR,
	description = "Hidden GameMode in sm",
	version = PLUGIN_VERSION,
	url = ""
};

int teamHidden;
bool hasHiddenStarted = false;

//const char weaponWhitelist = { "weapon_decoy", "weapon_flashbang", "weapon_smokegrenade", "weapon_hegrenade", "weapon_molotov", "weapon_incgrenade", "item_assaultsuit", "weapon_c4", "item_defuser", "weapon_taser", "item_kevlar" };
char c_weaponWhitelist[][] = {"weapon_decoy", "weapon_flashbang", "weapon_smokegrenade", "weapon_hegrenade", "weapon_molotov", "weapon_incgrenade", "item_assaultsuit", "weapon_c4", "item_defuser", "weapon_taser", "item_kevlar"};
int c_weaponWhitelistSIZE = 11;

int c_hiddenHealth = 200;
float c_movementMulti = 1.5;
int c_alphaValue = 15;

public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO && g_Game != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");
	}
	
	PrintToServer("\nHidden Plugin Started 45");
	
	ServerCommand("sv_disable_immunity_alpha 1");
	ServerCommand("sv_disable_radar 1");
	
	RegServerCmd("h_start", Hidden_Start);
	HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", OnRoundEnd, EventHookMode_PostNoCopy);
	
	for (int i = 1; i <= MaxClients; i++)
	{
	    if (IsClientInGame(i))
	    {
	    	if(GetClientTeam(i) == teamHidden)
	    	{
	    		PrintToServer("Unhook ROUNDEND");
	    		SDKUnhook(i, SDKHook_WeaponEquipPost, OnWeaponEquip);
				SDKUnhook(i, SDKHook_WeaponDropPost, OnWeaponDrop);
				SDKUnhook(i, SDKHook_PostThink, HideRadar);
				
				SetEntityRenderMode(i, RENDER_NORMAL);
				SetEntityRenderColor(i, 255, 255, 255, 255);
				
				DispatchKeyValue(i, "shadowcastdist", "1");
				DispatchKeyValue(i, "disablereceiveshadows", "0");
				DispatchKeyValue(i, "disableshadows", "0");
				DispatchKeyValue(i, "disableshadowdepth", "0");
				DispatchKeyValue(i, "disableselfshadowing", "0");
	    	}
	    	
	
	    }
	}
	
	//weaponWhitelist
	
	//HookEvent("round_end", OnRoundEnd, EventHookMode_Pre);
	//HookEvent("WeaponEquip", WeaponEquip); //item_pickup
	//SDKHook(1, SDKHook_WeaponEquip, WeaponEquip);
}

public void OnPluginEnd()
{
  	for (int i = 1; i <= MaxClients; ++i)
  	{
    	if (IsClientInGame(i))
    	{
    		OnClientDisconnect(i);
   		}
      
  	}
}

public void OnClientDisconnect(int client)
{
	//SDKUnhook(client, SDKHook_TraceAttack, OnHit);
	PrintToServer("Unhook");
	SDKUnhook(client, SDKHook_WeaponEquipPost, OnWeaponEquip);
	SDKUnhook(client, SDKHook_WeaponDropPost, OnWeaponDrop);
	SDKUnhook(client, SDKHook_PostThink, HideRadar);
	
	SetEntityRenderMode(client, RENDER_NORMAL);
	SetEntityRenderColor(client, 255, 255, 255, 255);
	
	DispatchKeyValue(client, "shadowcastdist", "1");
	DispatchKeyValue(client, "disablereceiveshadows", "0");
	DispatchKeyValue(client, "disableshadows", "0");
	DispatchKeyValue(client, "disableshadowdepth", "0");
	DispatchKeyValue(client, "disableselfshadowing", "0");
		    	
}

public void OnWeaponEquip(int client, int weapon)
{
	char clsName[32] = " ";
	GetEntityClassname(weapon, clsName, 32);
	//PrintToServer("OnWeaponEquip: detected with (%d, %d)", client, weapon);
	//PrintToServer("clsName = %s", clsName);
	
	//PrintToServer("weapon_flashbang in Array? %s", ArrayContains(weaponWhitelist, "weapon_flashbang", weaponWhitelistSIZE) ? "true" : "false");
	
	if(!ArrayContains(c_weaponWhitelist, clsName, c_weaponWhitelistSIZE))
	{
		
		SDKHooks_DropWeapon(client, weapon, _, _);
	}
	
}

public void OnWeaponDrop(int client, int weapon)
{
	PrintToServer("OnWeaponDrop: detected with (%d, %d)", client, weapon);
}

public void HideRadar(int client)
{
	/*
	if(GetClientTeam(client) == teamHidden)
	{
		PrintToServer("client is Hidden Radar func");
		SetEntProp(client, Prop_Send, "m_bSpotted", 0);
		
		DispatchKeyValue(client, "m_bSpotted", "0");
		DispatchKeyValue(client, "bSpotted", "0");
	}
	*/
}


/*
public Action WeaponEquip(Event event, const char[] name, bool dontBroadcast)//(Handle event, const char[] name, bool dontBroadcast)
{
    
    PrintToServer("Item Pickup 1");
    
    //return Plugin_Handled;
}
*/
public Action OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	PrintToServer("Round Start");
    if(hasHiddenStarted)
    {
    	PrintToServer("Round Start Has Started");
    	
    	for (int i = 1; i <= MaxClients; i++)
		{
		    if (IsClientInGame(i))
		    {
		    	if(GetClientTeam(i) == teamHidden)
		    	{
					RemoveWeapons(i);
					
					//int PlayerEnt = GetClientOfUserId(i);
					//SetEntPropFloat(i, Prop_Data, "m_flMaxspeed", 500);
					SetClientSpeed(i, c_movementMulti);
					
					if(c_alphaValue != 0)
					{
						SetEntityRenderMode(i, RENDER_TRANSALPHA);
						SetEntityRenderColor(i, 0, 0, 0, c_alphaValue); 
						PrintToServer("Aplha Value set %d", c_alphaValue);
						
						DispatchKeyValue(i, "shadowcastdist", "0");
				        DispatchKeyValue(i, "disablereceiveshadows", "1");
				        DispatchKeyValue(i, "disableshadows", "1");
				        DispatchKeyValue(i, "disableshadowdepth", "1");
				        DispatchKeyValue(i, "disableselfshadowing", "1");
					}
					else
					{
						SetEntityRenderMode(i, RENDER_NONE);
					}
					
					
					
					SetEntityHealth(i, c_hiddenHealth);
					
					SetEntityHealth(i, c_hiddenHealth);
					
					SDKHook(i, SDKHook_WeaponEquipPost, OnWeaponEquip);
					SDKHook(i, SDKHook_WeaponDropPost, OnWeaponDrop);
					//SDKHook(i, SDKHook_PostThink, HideRadar);
					
		    	}
		    	
		
		    }
		}
   	}
}

public Action OnRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	if(hasHiddenStarted)
    {
    	for (int i = 1; i <= MaxClients; i++)
		{
		    if (IsClientInGame(i))
		    {
		    	if(GetClientTeam(i) == teamHidden)
		    	{
		    		PrintToServer("Unhook ROUNDEND");
		    		SDKUnhook(i, SDKHook_WeaponEquipPost, OnWeaponEquip);
					SDKUnhook(i, SDKHook_WeaponDropPost, OnWeaponDrop);
					SDKUnhook(i, SDKHook_PostThink, HideRadar);
					
					SetEntityRenderMode(i, RENDER_NORMAL);
					SetEntityRenderColor(i, 255, 255, 255, 255);
					
					DispatchKeyValue(i, "shadowcastdist", "1");
					DispatchKeyValue(i, "disablereceiveshadows", "0");
					DispatchKeyValue(i, "disableshadows", "0");
					DispatchKeyValue(i, "disableshadowdepth", "0");
					DispatchKeyValue(i, "disableselfshadowing", "0");
		    	}
		    	
		
		    }
		}
   	}
}

public Action Hidden_Start(int args)
{
	//ServerCommand("mp_restartgame 1");
	
	// CLEAR ALL EFFECTS SO CAN RESTART EASILY
	ServerCommand("sv_disable_immunity_alpha 1");
	ServerCommand("sv_disable_radar 1");
	
	for (int i = 1; i <= MaxClients; i++)
	{
	    if (IsClientInGame(i))
	    {
	    	//PrintToServer("Unhook");
	    	//SDKUnhook(i, SDKHook_WeaponEquipPost, OnWeaponEquip);
			//SDKUnhook(i, SDKHook_WeaponDropPost, OnWeaponDrop);
	
	    }
	}
	
	
    char arg[128];
    char full[256];
    
    teamHidden = 0; // 0 = none, 1 = spec, 2 = t, 3 = ct // CORRECT
 
    GetCmdArgString(full, sizeof(full));
 
    //PrintToServer("Argument string: %s", full);
    //PrintToServer("Argument count: %d", args);
    /*
    if(sizeof(args) >= 1)
    {
    	GetCmdArg(1, arg, sizeof(arg));
    
	    if (StrEqual(arg, "t")) { teamHidden = 2; }
	    else if (StrEqual(arg, "ct")) { teamHidden = 3; }
	    
	   	
   	}
   	*/
    
 	
 	
    for (int i = 1; i <= args; i++)
    {
        GetCmdArg(i, arg, sizeof(arg));
        
        if(i == 1)
        {
        	if (StrEqual(arg, "t")) { teamHidden = 2; }
	    	else if (StrEqual(arg, "ct")) { teamHidden = 3; }
	    	else if (StrEqual(arg, "auto")) { teamHidden = 0; }
       	}
       	else if(i == 2)
       	{
       		c_hiddenHealth = StringToInt(arg);
       	}
       	else if(i == 3)
       	{
       		c_movementMulti = StringToFloat(arg);

       	}
       	else if(i == 4)
       	{
       		c_alphaValue = StringToInt(arg);
       	}
       	/*
       	else if(i == 5)
       	{
       		if(StrEqual(arg, "1"))
       		{
       			for (int iLoop = 1; iLoop <= MaxClients; ++iLoop)
			  	{
			    	if (IsClientInGame(iLoop))
			    	{
			    		ClientCommand(iLoop, "hud_showtargetid 1");
			    		FakeClientCommand(iLoop, "hud_showtargetid 1");
			   		}
			      
			  	}
       		}
       		else if(StrEqual(arg, "0"))
       		{
       			for (int iLoop = 1; iLoop <= MaxClients; ++iLoop)
			  	{
			    	if (IsClientInGame(iLoop))
			    	{
			    		ClientCommand(iLoop, "hud_showtargetid 0");
			    		FakeClientCommand(iLoop, "hud_showtargetid 0");
			   		}
			      
			  	}
       		}
       	}
       	*/
        
        //PrintToServer("Argument %d: %s", i, arg);
    }
    
    
    if(teamHidden == 0)
    {
    	int t_Count = 0;
	    int ct_Count = 0;
	    
	    int t_BotCount = 0;
	    int ct_BotCount = 0;
	    
	    for (int i = 1; i <= MaxClients; i++)
		{
		    if (IsClientInGame(i))
		    {
		    	//int player_team = -1; 
		    	//player_team = GetClientTeam(i);
		        // Only trigger for client indexes actually in the game
		        //PrintToServer("Player %d Is In Player Loop Iterate, TEAM : %d", i, player_team);
		        if (GetClientTeam(i) == 2) { t_Count += 1; if (IsFakeClient(i)) { t_BotCount += 1; } }
		        else if (GetClientTeam(i) == 3) { ct_Count += 1; if (IsFakeClient(i)) { ct_BotCount += 1; } }
		
		    }
		}
		
		//PrintToServer("T Count: %d, CT Count: %d, BOT T: %d, BOT CT: %d", t_Count, ct_Count, t_BotCount, ct_BotCount);
		if (t_Count > ct_Count) { teamHidden = 3; }
		else if (t_Count < ct_Count) { teamHidden = 2; }
		else if(t_Count == ct_Count)
		{
			PrintToServer("Team are Equal Please Select Team for hidden");
			return Plugin_Handled;
		}
		
		if (t_Count == 0) { teamHidden = 3; }
		else if (ct_Count == 0) { teamHidden = 2; }
		
   	}
   	
   	for (int i = 1; i <= MaxClients; i++)
	{
	    if (IsClientInGame(i))
	    {
	    	if(GetClientTeam(i) == teamHidden)
	    	{
	    		SDKHook(i, SDKHook_WeaponEquipPost, OnWeaponEquip);
				SDKHook(i, SDKHook_WeaponDropPost, OnWeaponDrop);
				//SDKHook(i, SDKHook_PostThink, HideRadar);
				
				RemoveWeapons(i);
				
				//int PlayerEnt = GetClientOfUserId(i);
				//SetEntPropFloat(i, Prop_Data, "m_flMaxspeed", 500);
				SetClientSpeed(i, c_movementMulti);
				
				//SetEntityRenderMode(i, RENDER_NONE);
				
				if(c_alphaValue != 0)
				{
					SetEntityRenderMode(i, RENDER_TRANSALPHA);
					SetEntityRenderColor(i, 0, 0, 0, c_alphaValue); 
					PrintToServer("Aplha Value set %d", c_alphaValue);
					
					DispatchKeyValue(i, "shadowcastdist", "0");
			        DispatchKeyValue(i, "disablereceiveshadows", "1");
			        DispatchKeyValue(i, "disableshadows", "1");
			        DispatchKeyValue(i, "disableshadowdepth", "1");
			        DispatchKeyValue(i, "disableselfshadowing", "1");
				}
				else
				{
					SetEntityRenderMode(i, RENDER_NONE);
				}
				
				SetEntityHealth(i, c_hiddenHealth);
	    	}
	    	
	
	    }
	}
	
	hasHiddenStarted = true;
   	
   	//PrintToServer("TeamHidden : %d", teamHidden);
    
    
 
    return Plugin_Handled;
}

void RemoveWeapons(int client)
{
	char clsName[128];
	
    for (int i = 0; i < 2; i++)
    {
        int weapon;
        while ((weapon = GetPlayerWeaponSlot(client, i)) != -1)
        {
			GetEntityClassname(weapon, clsName, 128);
			if (StrContains("knife", clsName, false) == -1 && !ArrayContains(c_weaponWhitelist, clsName, c_weaponWhitelistSIZE))
			{
				//PrintToServer("clsName = %s", clsName);
				// SUCCESS
				RemovePlayerItem(client, weapon);
		        //RemoveEntity(weapon);
		        AcceptEntityInput(weapon, "Kill");
			}
        	
            
        }
    }
}

public void SetClientSpeed(int client, float speed)
{
      SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", speed);
      //SetEntPropFloat()
}

public bool ArrayContains(char[][] arrayTMP, char[] value, int arrayTMPSize)
{
	bool bIsInArray;
	//PrintToServer("arraySize %d", arrayTMPSize);
	
	for (int i = 0; i < arrayTMPSize; i++)
	{
		//PrintToServer("strEqual %s = %s", arrayTMP[i], value);
	    if (StrEqual(arrayTMP[i], value)) {
	        bIsInArray = true;
	        break;
	    }
	}
	
	return bIsInArray;
}
