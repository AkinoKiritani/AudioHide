/*
Audiohide Message System by BlackAce


Das entfernen der Copyrights wird mit einem schlechten gewissen Bestraft!


Version 3.0.0

Änderungen:

V 2.1

- besseres hooking der SAMP Natives
- bessere detection, ob das Filterscript geladen wurde
- Versions detection hinzugefügt

V 2.1.1

- Behebung der Meldung, dass das Filterscript nicht geladen werden konnte,
  wenn das Filterscript bereits geladen wurde

V 3.0.0
- Behebung eines Crashes, wenn eine leere Nachricht oder nur ein Leerzeichen gesendet wurde
- neue Strukturierung des Codes
- Custom Error hinzugefügt, falls die Maximalen Chatlines den Wert 4 unterschreiten.

  
*/

native _SendClientMessage(playerid, Color, const string[]) = SendClientMessage;
native _SendClientMessageToAll(Color, const string[]) = SendClientMessageToAll;
native _PlayAudioStreamForPlayer(playerid, url[], Float:posX = 0.0, Float:posY = 0.0, Float:posZ = 0.0, Float:distance = 50.0, usepos = 0) = PlayAudioStreamForPlayer;

#define Version 300

#if !defined isnull
	#define isnull(%1)  ((%1[0] == 0) || (%1[0] == 1 && %1[1] == 0))
#endif
	
#if defined _ALS_SendClientMessage
	#undef SendClientMessage
#else
	#define _ALS_SendClientMessage
#endif
#define SendClientMessage __SendClientMessage
#if defined _ALS_SendClientMessageToAll
	#undef SendClientMessageToAll
#else
	#define _ALS_SendClientMessageToAll
#endif
#define SendClientMessageToAll __SendClientMessageToAll
#if defined _ALS_PlayAudioStreamForPlayer
	#undef PlayAudioStreamForPlayer
#else
	#define _ALS_PlayAudioStreamForPlayer
#endif
#define PlayAudioStreamForPlayer __PlayAudioStreamForPlayer

new static bool:_AHLoaded=false; 
public OnGameModeInit()
{
	if(!getproperty(.name="AH_Loaded")) SendRconCommand("loadfs AudioHide");
	if(!getproperty(.name="AH_Init")) CallRemoteFunction("AH_Init","");
	
	if(!(_AHLoaded=bool:getproperty(.name="AH_Init"))) print("Vorsicht! Das Filterscript zum Verstecken der Streammessage ist nicht vorhanden");
	
	if(getproperty(.name = "Version") != Version) print("Die Filterscript Version entspricht nicht der Include Version.\nBitte Updaten"),_AHLoaded=false,SendRconCommand("unloadfs AudioHide");
	__OnGameModeInit();
	return true;
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit __OnGameModeInit
forward __OnGameModeInit();

stock __SendClientMessage(playerid, color, const string[])
{	
	if(!_AHLoaded) return _SendClientMessage(playerid, color, string);
	
	if(isnull(string) || string[0] == ' ')
	{
		new str[144];
		format(str, sizeof(str), "AH_SendClientMessage_%s", string);
		return CallRemoteFunction("AH_SendClientMessage", "ixs", playerid, color, str);
	}
	return CallRemoteFunction("AH_SendClientMessage", "ixs", playerid, color, string);
}

stock __SendClientMessageToAll(color, const string[])
{	
	if(!_AHLoaded)return _SendClientMessageToAll(color, string);
	
	if(isnull(string) || string[0] == ' ')
	{
		new str[144];
		format(str, sizeof(str), "AH_SendClientMessageToAll_%s", string);
		return CallRemoteFunction("AH_SendClientMessage", "xs", color, str);
	}
	return CallRemoteFunction("AH_SendClientMessageToAll","xs", color, string);
}
stock __PlayAudioStreamForPlayer(playerid, url[], Float:posX = 0.0, Float:posY = 0.0, Float:posZ = 0.0, Float:distance = 50.0, usepos=0)
{
	if(!_AHLoaded) return _PlayAudioStreamForPlayer(playerid, url, posX, posY, posZ, distance, usepos);
	CallRemoteFunction("AH_PlayAudioStreamForPlayer","isffffi", playerid, url, posX, posY, posZ, distance, usepos);
	return true;
}