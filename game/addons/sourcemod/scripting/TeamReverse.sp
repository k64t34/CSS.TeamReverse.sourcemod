#define nDEBUG 1
#define DEBUG_PLAYER "Kom64t"
#define INFO 1
#define SMLOG 1
#define DEBUG_LOG 1
#define PLUGIN_VERSION "0.4"
#define SND_REVERSE	"k64t\\whistle.mp3\0"
//#define USE_WEAPON 
#define USE_PLAYER 
#define GAME_CSS 
#include <k64t>
int gTimeToTeamReverse=0;
int gMapHour=0;
Handle cvar_mp_startmoney  = INVALID_HANDLE;
int g_mp_startmoney=800;
char soundFileName[]=SND_REVERSE;
//*****************************************************************************
public Plugin myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "Swap teams",
	version = PLUGIN_VERSION,
	url = "https://github.com/k64t34/TeamReverse"};
//*****************************************************************************
public void OnPluginStart(){	
//*****************************************************************************
#if defined DEBUG
	DebugPrint("OnPluginStart");
#endif 
//HookEvent("round_end", EventRoundEnd);
//HookEvent("round_start", EventRoundStart);
#if defined DEBUG 
	RegConsoleCmd("k_tr", cmd_TeamReverse);
#endif	
g_iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount");
if (g_iAccount == -1) SetFailState("Could not find m_iAccount");
cvar_mp_startmoney = FindConVar("mp_startmoney");
if ( cvar_mp_startmoney != INVALID_HANDLE )
	g_mp_startmoney	=GetConVarInt(cvar_mp_startmoney);	

}

//***********************************************
public void OnMapStart(){
//***********************************************
#if defined DEBUG
	DebugPrint("OnMapStart");
#endif
char buffer[PLATFORM_MAX_PATH];
PrecacheSound(soundFileName, true);	
Format(buffer, PLATFORM_MAX_PATH, "sound\\%s",soundFileName);	
AddFileToDownloadsTable(buffer);
 
int Ctime=GetTime();
char M[3];
FormatTime(M,3,"%H",Ctime);
gMapHour=StringToInt(M);
FormatTime(M,3,"%M",Ctime);
gTimeToTeamReverse=Ctime+((60-StringToInt(M))/2)*60;
#if defined DEBUG 
LogMessage("m=%d",StringToInt(M));	
LogMessage("60-m=%d",60-StringToInt(M));	
LogMessage("(60-m)/2=%d",(60-StringToInt(M))/2);	
LogMessage("RoundFloat(60-m)/2=%d",((60-StringToInt(M))/2));	
LogMessage("RoundFloat(60-m)/2 * 60 =%d",((60-StringToInt(M))/2)*60);		

LogMessage("m=%s d=%d gTimeToTeamReverse=%d Ctime=%d",M,gTimeToTeamReverse-Ctime,gTimeToTeamReverse,Ctime);	
#endif
}
//***********************************************
public void EventRoundStart(Handle event, const char[] name,bool dontBroadcast){
//***********************************************
#if defined DEBUG
DebugPrint("EventRoundStart");
#endif
}
//*****************************************************************************
public void EventRoundEnd(Handle event, char[] name, bool dontBroadcast){
//*****************************************************************************
#if defined DEBUG 
DebugPrint("OnRoundEnd. d=%d gTimeToTeamReverse=%d GetTime=%d",gTimeToTeamReverse-GetTime(),gTimeToTeamReverse,GetTime());	
#endif	
if (gTimeToTeamReverse==0) 
	{	
	char M[3];
	FormatTime(M,3,"%H",GetTime());
	if (gMapHour<StringToInt(M)) OnMapStart();
	return;
	}
if (GetTime()>gTimeToTeamReverse)
	{
	PrecacheSound(soundFileName, true);	
	EmitSoundToAll(soundFileName);	
	gTimeToTeamReverse=0;
	PrintCenterTextAll("Time to change team");
	PrintHintTextToAll("Time to change team");	
	PrintToChatAll("\4Time to change team\1");	
	int clTeam;
	//Swap Team Score
	clTeam=CS_GetTeamScore(CS_TEAM_T);
	CS_SetTeamScore(CS_TEAM_T, CS_GetTeamScore(CS_TEAM_CT));
	CS_SetTeamScore(CS_TEAM_CT,clTeam);
	//Swap Player Team 
	for (int client = 1; client <=MaxClients ; client++)
		{
		if (IsClientConnected(client))if(IsClientInGame(client))
			{
			clTeam=GetClientTeam(client);
			if (clTeam==CS_TEAM_T)      TeamReverse(client, CS_TEAM_CT);
			else if (clTeam==CS_TEAM_CT)TeamReverse(client, CS_TEAM_T);
			}		
		}
	}
}

//*****************************************************************************
void TeamReverse (const  int client,const int Team){
//*****************************************************************************
CS_SwitchTeam(client, Team);
SetMoney(client, g_mp_startmoney);
}

#if defined DEBUG 
public Action cmd_TeamReverse(int client, any args){gTimeToTeamReverse=1;DebugPrint("TeamForce at the end round");}
#endif
#endinput
