#include <a_samp>
#include <a_http>

#undef MAX_PLAYERS
#define MAX_PLAYERS 	50 // anpassen auf die Slotzahl
#define MAX_CHAT_LINES 	50 // bis ganz nach oben scrollt wohl keiner :D | sonst auf 100 stellen
#define VERSION 		300

#define SERVERIP ("127.0.0.1") // bitte anpassen

#define MAX_PACKED_MESSAGE 	37 // 37 -> 37 * 4 = 148 -> 144 / 4 = 36 | bei 144 Zeichen würde der EOS fehlen, darum 37 Bytes

#if MAX_CHAT_LINES < 4
	#error "MAX_CHAT_LINES darf nicht kleiner als 4 sein"
#endif

#if !defined SERVERIP
	#error "Die ServerIP wurde nicht festgelegt"
#endif

forward AH_SendClientMessage(playerid, Color, string[]);
forward AH_SendClientMessageToAll(Color, string[]);
forward AH_PlayAudioStreamForPlayer(playerid, url[], Float:posX, Float:posY, Float:posZ, Float:distance, usepos);

forward AH_Init();

enum ch
{
	color,
	message[MAX_PACKED_MESSAGE]
};
new Chat[MAX_PLAYERS][MAX_CHAT_LINES][ch];

new bool:sended[MAX_PLAYERS char];

public OnFilterScriptInit()
{
	print("/--------------------------------\\");
	print("|    Audiomessage Hidesystem     |");
	print("|         von BlackAce           |");
	print("|      erfolgreich geladen       |");
	print("\\--------------------------------/");
	setproperty(.name = "AH_Loaded", .value = true);
	return true;
}

public OnFilterScriptExit()
{
	print("/--------------------------------\\");
	print("|    Audiomessage Hidesystem     |");
	print("|         von BlackAce           |");
	print("|      erfolgreich beendet       |");
	print("\\--------------------------------/");
	return true;
}

public AH_Init()
{
	print("Audiomessage Hidesystem erfolreich initialisiert");
	setproperty(.name = "AH_Init", .value = true);
	setproperty(.name = "Version", .value = VERSION);
	return true;
}

public AH_SendClientMessage(playerid, Color, string[])
{
	if(strfind(string, "AH_SendClientMessage_") != -1)
	{
		strdel(string, 0, 21);
	}
	for(new i = 1; i != MAX_CHAT_LINES; i++)
	{
		strpack(Chat[playerid][i - 1][message], Chat[playerid][i][message], MAX_PACKED_MESSAGE);
		Chat[playerid][i - 1][color] = Chat[playerid][i][color];
	}
	strpack(Chat[playerid][MAX_CHAT_LINES - 1][message],string, MAX_PACKED_MESSAGE);
	Chat[playerid][MAX_CHAT_LINES - 1][color] = Color;
	
	return SendClientMessage(playerid, Color, string);
}

public AH_SendClientMessageToAll(Color, string[])
{
	if(strfind(string, "AH_SendClientMessageToAll_") != -1)
	{
		strdel(string, 0, 25);
	}
	for(new playerid, i; playerid != MAX_PLAYERS; playerid++)
	{
		if(!IsPlayerConnected(playerid)) continue;
		for(i = 1; i != MAX_CHAT_LINES; i++) 
		{
			strpack(Chat[playerid][i - 1][message], Chat[playerid][i][message], MAX_PACKED_MESSAGE);
			Chat[playerid][i - 1][color] = Chat[playerid][i][color];
		}
		strpack(Chat[playerid][MAX_CHAT_LINES - 1][message], string, MAX_PACKED_MESSAGE);
		Chat[playerid][MAX_CHAT_LINES - 1 ][color] = Color;
	}
	return SendClientMessageToAll(Color, string);
}

public AH_PlayAudioStreamForPlayer(playerid, url[], Float:posX, Float:posY, Float:posZ, Float:distance, usepos)
{
	PlayAudioStreamForPlayer(playerid, url, posX, posY, posZ, distance, usepos);
	for(new i; i != MAX_CHAT_LINES; i++)
	{
		SendClientMessage(playerid, Chat[playerid][i][color], Chat[playerid][i][message]);
	}
	return true;
}

public OnPlayerConnect(playerid)
{
	for(new i; i!= MAX_CHAT_LINES; i++)
	{
		strdel(Chat[playerid][i][message], 0, 128);
		for(new j; j != MAX_PACKED_MESSAGE; j++)
		{
			Chat[playerid][i][message][j] = '\0';
		}
		Chat[playerid][i][color] = -1;
	}
	SetPlayerColor(playerid, -1);
	sended{playerid} = false;
	
	new str[50], port;
	port = GetServerVarAsInt("port");
	GetPlayerVersion(playerid, str, 16);
	
	format(str, sizeof(str), "SA-MP {B9B9BF}%s {FFFFFF}Started", str);
	strpack(Chat[playerid][MAX_CHAT_LINES - 4][message], str, MAX_PACKED_MESSAGE);
	
	Chat[playerid][MAX_CHAT_LINES - 4][color] =- 1;
	format(str, sizeof(str), "Connecting to %s:%d...", SERVERIP, (port) ? port : 8192);
	strpack(Chat[playerid][MAX_CHAT_LINES - 3][message], str, MAX_PACKED_MESSAGE);
	
	Chat[playerid][MAX_CHAT_LINES - 3][color] = 0xA9C4E4FF;
	format(str, sizeof(str), "Connected. Joining the game...");
	
	strpack(Chat[playerid][MAX_CHAT_LINES - 2][message], str, MAX_PACKED_MESSAGE);
	Chat[playerid][MAX_CHAT_LINES - 2][color] = 0xA9C4E4FF;
	return true;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(!sended{playerid})
	{
		if(Chat[playerid][MAX_CHAT_LINES - 1][message][0])
		{
			for(new i=1;i!=MAX_CHAT_LINES;i++)
			{
				if(Chat[playerid][i][message][0])
				{
					strpack(Chat[playerid][i - 1][message], Chat[playerid][i][message], MAX_PACKED_MESSAGE);
					Chat[playerid][i - 1][color] = Chat[playerid][i][color];
				}
			}
		}
		new str[50];
		GetServerVarAsString("hostname", str, sizeof(str));
		
		format(str, sizeof(str), "Connected to {B9B9BF}%s", str);
		strpack(Chat[playerid][MAX_CHAT_LINES - 1][message], str, MAX_PACKED_MESSAGE);
		Chat[playerid][MAX_CHAT_LINES - 1][color] = 0xA9C4E4FF;
		
		sended{playerid}=true;
	}
	return true;
}

public OnPlayerText(playerid,text[])
{
	if(CallRemoteFunction("AH_Local", "")) return true;
	for(new i = 1; i != MAX_CHAT_LINES; i++)
	{
		strpack(Chat[playerid][i - 1][message], Chat[playerid][i][message], MAX_PACKED_MESSAGE);
		Chat[playerid][i - 1][color] = Chat[playerid][i][color];
	}
	new name[148];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	format(name, 148, "%s: {FFFFFF}%s", name, text);
	strpack(Chat[playerid][MAX_CHAT_LINES - 1][message], name, MAX_PACKED_MESSAGE);
	Chat[playerid][MAX_CHAT_LINES - 1][color] = GetPlayerColor(playerid);
	return true;
}
