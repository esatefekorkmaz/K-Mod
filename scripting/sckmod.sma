#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <engine>
#include <fakemeta>
#include <nvault>
#include <ibm_say>
#include <xp_weapon>
#define VERSION "1.0.0"
#define BUYMENU_VERSION "1.0.0"
#define AUTHOR "korki635"
new loc[33][3];
new g_Vault;               //Global var to hold our vault handle
new g_szAuthID[33][35];    //Global array to store auth ids of players
new g_pExpireDays;        //CVar pointer for expiredays cvar
new weaponfilename[256];
new ammofilename[256];
new itemfilename[256];
new weapons[64][256];
new ammos[64][256];
new items[64][256];
public plugin_init()
{
    register_plugin("K-Mod", VERSION, AUTHOR);
    register_forward(FM_GetGameDescription,"change_gamename");
	set_task(120.0, "ECommandsText");
	set_task(60.0, "GiveTL");
	set_task(1.0, "ShowData");
	get_configsdir(weaponfilename,255)
	get_configsdir(ammofilename,255)
	get_configsdir(itemfilename,255)
    format(weaponfilename,255,"%s/km_weapons.ini",weaponfilename)
	format(ammofilename,255,"%s/km_ammos.ini",ammofilename)
	format(itemfilename,255,"%s/km_items.ini",itemfilename)
	register_clcmd("say buy", "BuyMenu");
	register_clcmd("say shop", "BuyMenu");
	read_weapons();
	read_ammos();
	read_items();
}
public ibm_say_main()
{
	register_saycmd("respawn", "RespawnPlayer", ADMIN_ADMIN, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("god", "GodMode", ADMIN_ADMIN, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("noclip", "Noclip", ADMIN_ADMIN, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("hp", "SetHp", ADMIN_ADMIN, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("kill", "KillPlayer", ADMIN_ADMIN, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("armor", "SetArmor", ADMIN_ADMIN, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("give", "GiveItem", ADMIN_ADMIN, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("model", "ChangeModel", ADMIN_ADMIN, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("name", "ChangeName", ADMIN_ADMIN, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("resetplayer", "ResetPlayer", ADMIN_ADMIN, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("setmoney", "SetMoney", ADMIN_ADMIN, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("addmoney", "AddMoney", ADMIN_ADMIN, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("getmoney", "GetMoney", ADMIN_ADMIN, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("gravity", "ChangeGravity", ADMIN_ADMIN, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("goto", "TeleportToPlayer", ADMIN_ADMIN, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("bring", "BringPlayer", ADMIN_ADMIN, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("survival", "SurvivalMode", ADMIN_ADMIN, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("classic", "ClassicMode", ADMIN_ADMIN, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("s", "SaveLoc", ADMIN_ALL, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("tpr", "PlayerLoc", ADMIN_ALL, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("t", "TeleportLoc", ADMIN_ALL, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("buy", "BuyMenu", ADMIN_ALL, 1, "", "info", "[K-MOD] ", false, false, false);
	register_saycmd("shop", "BuyMenu", ADMIN_ALL, 1, "", "info", "[K-MOD] ", false, false, false);
    register_saycmd("gift", "SendMoney", ADMIN_ALL, 1, "", "info", "[K-MOD] ", false, false, false);
}
public read_weapons()
{
    /*open file in read-mode*/
    new filepointer = fopen(weaponfilename,"r")
    /*check if file is open,on an error filepointer is 0*/
    if(filepointer)
    {
        new readdata[128]
    
        /*Read the file until it is at end of file*/
        /*fgets - Reads a line from a text file -- includes newline!*/
		new i;
        while(fgets(filepointer,readdata,127) && i < 20)
        {   
			weapons[i] = readdata;
			i++;
        }
        fclose(filepointer)
    }
} 
public read_ammos()
{
    /*open file in read-mode*/
    new filepointer = fopen(ammofilename,"r")
    /*check if file is open,on an error filepointer is 0*/
    if(filepointer)
    {
        new readdata[128]
    
        /*Read the file until it is at end of file*/
        /*fgets - Reads a line from a text file -- includes newline!*/
		new i;
        while(fgets(filepointer,readdata,127) && i < 20)
        {   
			ammos[i] = readdata;
			i++;
        }
        fclose(filepointer)
    }
}
public read_items()
{
    /*open file in read-mode*/
    new filepointer = fopen(itemfilename,"r")
    /*check if file is open,on an error filepointer is 0*/
    if(filepointer)
    {
        new readdata[128]
    
        /*Read the file until it is at end of file*/
        /*fgets - Reads a line from a text file -- includes newline!*/
		new i;
        while(fgets(filepointer,readdata,127) && i < 20)
        {   
			items[i] = readdata;
			i++;
        }
        fclose(filepointer)
    }
} 
public plugin_cfg()
{
    //Open our vault and have g_Vault store the handle.
    g_Vault = nvault_open( "emodvault" );

    //Make the plugin error if vault did not successfully open
    if ( g_Vault == INVALID_HANDLE )
        set_fail_state( "Error opening nVault" );

    //This will remove all entries in the vault that are 5+ (or cvar+) days old at server-start
    //or map-change
    nvault_prune( g_Vault , 0 , get_systime() - ( 86400 * get_pcvar_num( g_pExpireDays ) ) );
}

public plugin_end()
{
    //Close the vault when the plugin ends (map change\server shutdown\restart)
    nvault_close( g_Vault );
}

public client_authorized(id)
{
    //Get the connecting users authid and store it in our global string array so it
    //will not need to be retrieved every time we want to do an nvault transaction.
    get_user_authid( id , g_szAuthID[id] , charsmax( g_szAuthID[] ) );
}
public change_gamename()
{ 
	new g[32];
	format(g,31,"K-Mod: %s",VERSION);
	forward_return(FMV_STRING,g);
	return FMRES_SUPERCEDE;
} 
public ECommandsText(){
	client_print(0, print_chat, "[K-MOD] v%s by %s", VERSION, AUTHOR);
	set_task(120.0, "ECommandsText");
	return PLUGIN_HANDLED;
}
public ShowData(){
	 new szData[8];
	new iPlayers[32],iNum
	get_players(iPlayers,iNum)
	for(new g=0;g<iNum;g++)
	{
		new i=iPlayers[g]
		new szKey[40];
		formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[i] );
		new iMoney = nvault_get( g_Vault , szKey );
		new name[24];
		get_user_name(i, name, 24);
		if(is_user_connected(i) && nvault_get( g_Vault , szKey , szData , charsmax( szData ) ))
		{
			set_hudmessage(50,135,180,0.0,0.25,0,1.0,255.0,0.0,0.0,31)
			show_hudmessage(i, "Merhaba %s^nBakiyeniz: %i TL", name, iMoney);
			if(!is_user_alive(i)){
				new menu = menu_create( "\r100 TL karsiliginda yeniden canlandir?", "revmenu_handler" );
				menu_additem( menu, "\wEvet", "", 0 );
				menu_additem( menu, "\wHayir", "", 0 );
				menu_display( i, menu, 0 );
			}
		}
		else if(is_user_connected(i) && !nvault_get( g_Vault , szKey , szData , charsmax( szData ) ))
		{
			new szMoney[7];        //Data holder for the money amount
			new szKey[40];        //Key used to save money "STEAM_0:0:1234MONEY"

			formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[i] );
			formatex( szMoney , charsmax( szMoney ) , "%d" , 0 );
			nvault_set( g_Vault , szKey , szMoney );
		}
	}
	set_task(1.0, "ShowData");
}
public GiveTL(){
	 new szData[8];
	new iPlayers[32],iNum
	get_players(iPlayers,iNum)
	for(new g=0;g<iNum;g++)
	{
		new i=iPlayers[g]
		new szKey[40];
		formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[i] );
		new iMoney = nvault_get( g_Vault , szKey );
		if(is_user_connected(i) && nvault_get( g_Vault , szKey , szData , charsmax( szData ) ) && iMoney < 200000)
		{
					new newMoney = iMoney + 10;
					if(newMoney > 200000){
						newMoney = 200000;
					}
					new szMoney[7];        //Data holder for the money amount
					formatex( szMoney , charsmax( szMoney ) , "%d" , newMoney );
					
					nvault_set( g_Vault , szKey , szMoney );
					client_print(i, print_chat, "[K-MOD] Sunucuda oynadiginiz icin 10 TL elde ettiniz.");
		}
		else if(iMoney >= 200000){
			client_print(i, print_chat, "[K-MOD] Bakiye limiti asildi. Daha fazla para kazanamazsiniz. (Limit: 200000 TL)");
		}
	}
	set_task(60.0, "GiveTL");
}
public SendMoney(id)
{
	new name[24];
	get_user_name(id, name, 24);
	new arg1[24];
	get_say_argv(1, arg1, charsmax(arg1));
	new arg2[32];
	get_say_argv(2, arg2, charsmax(arg2));
	new target = find_player("a", arg1);
		new szKey[40];
		formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
		new iMoney1 = nvault_get( g_Vault , szKey );
	if(target && iMoney1 >= str_to_num(arg2)){
		new newMoney1 = iMoney1 - str_to_num(arg2);
							new szMoney1[7];        //Data holder for the money amount

					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
					formatex( szMoney1 , charsmax( szMoney1 ) , "%d" , newMoney1 );
		nvault_set( g_Vault , szKey , szMoney1 );

		new szKey2[40];
		formatex( szKey2 , charsmax( szKey2 ) , "%sMONEY" , g_szAuthID[target] );
		new iMoney = nvault_get( g_Vault , szKey2 );
		new newMoney = iMoney + str_to_num(arg2);
							if(newMoney > 200000){
						newMoney = 200000;
					}
		client_print(id, print_chat, "[K-MOD] Oyuncuya %s TL para verildi: %s", arg2, arg1);
		client_print(target, print_chat, "[K-MOD] Oyuncu size %s TL para verdi: %s", arg2, name);
							new szMoney[7];        //Data holder for the money amount

					formatex( szKey2 , charsmax( szKey2 ) , "%sMONEY" , g_szAuthID[target] );
					formatex( szMoney , charsmax( szMoney ) , "%d" , newMoney );
		nvault_set( g_Vault , szKey2 , szMoney );
	}
    return PLUGIN_HANDLED;
}
public RespawnPlayer(id)
{
	new name[24];
	get_user_name(id, name, 24);
	new arg1[24];
	get_say_argv(1, arg1, charsmax(arg1));
	new target = find_player("a", arg1);
	if(target && !is_user_alive(target)){
		client_print(0, print_chat, "[K-MOD] ADMIN %s: Oyuncu canlandirildi: %s", name, arg1);
		spawn(target);
	}
    return PLUGIN_HANDLED;
}
public GodMode(id)
{
	new name[24];
	get_user_name(id, name, 24);
	new arg1[24];
	get_say_argv(1, arg1, charsmax(arg1));
	new arg2[24];
	get_say_argv(2, arg2, charsmax(arg2));
	new target = find_player("a", arg1);
	if(target && is_user_alive(target)){
		client_print(0, print_chat, "[K-MOD] ADMIN %s: Oyuncunun olumsuzlugu degistirildi: %s", name, arg1);
		set_user_godmode(target, str_to_num(arg2));
		if(str_to_num(arg2)){
			set_user_rendering(target, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 10); 
		}
		else{
			set_user_rendering(target, kRenderFxNone, 255, 255, 255, kRenderNormal, 10); 
		}
	}
    return PLUGIN_HANDLED;
}
public Noclip(id)
{
	new name[24];
	get_user_name(id, name, 24);
	new arg1[24];
	get_say_argv(1, arg1, charsmax(arg1));
	new arg2[24];
	get_say_argv(2, arg2, charsmax(arg2));
	new target = find_player("a", arg1);
	if(target && is_user_alive(target)){
		client_print(0, print_chat, "[K-MOD] ADMIN %s: Oyuncunun noclip modu degistirildi: %s", name, arg1);
		set_user_noclip(target, str_to_num(arg2));
	}
    return PLUGIN_HANDLED;
}
public SetHp(id)
{
	new name[24];
	get_user_name(id, name, 24);
	new arg1[24];
	get_say_argv(1, arg1, charsmax(arg1));
	new arg2[4];
	get_say_argv(2, arg2, charsmax(arg2));
	new target = find_player("a", arg1);
	if(target && is_user_alive(target)){
		client_print(0, print_chat, "[K-MOD] ADMIN %s: Oyuncunun sagligi degistirildi: %s", name, arg1);
		set_user_health(target, str_to_num(arg2));
	}
    return PLUGIN_HANDLED;
}
public SetArmor(id)
{
	new name[24];
	get_user_name(id, name, 24);
	new arg1[24];
	get_say_argv(1, arg1, charsmax(arg1));
	new arg2[4];
	get_say_argv(2, arg2, charsmax(arg2));
	new target = find_player("a", arg1);
	if(target && is_user_alive(target)){
		client_print(0, print_chat, "[K-MOD] ADMIN %s: Oyuncunun zirhi degistirildi: %s", name, arg1);
		set_user_armor(target, str_to_num(arg2));
	}
    return PLUGIN_HANDLED;
}
public GiveItem(id)
{
	new name[24];
	get_user_name(id, name, 24);
	new arg1[24];
	get_say_argv(1, arg1, charsmax(arg1));
	new arg2[32];
	get_say_argv(2, arg2, charsmax(arg2));
	new target = find_player("a", arg1);
	if(target && is_user_alive(target)){
		client_print(0, print_chat, "[K-MOD] ADMIN %s: Oyuncuya esya verildi: %s", name, arg1);
		sc_give_item(id, arg2);
		set_task(0.01, "CheatsZero");
	}
    return PLUGIN_HANDLED;
}
public ChangeModel(id)
{
	new name[24];
	get_user_name(id, name, 24);
	new arg1[24];
	get_say_argv(1, arg1, charsmax(arg1));
	new arg2[32];
	get_say_argv(2, arg2, charsmax(arg2));
	new target = find_player("a", arg1);
	if(target && is_user_alive(target)){
		client_print(0, print_chat, "[K-MOD] ADMIN %s: Oyuncunun modeli degistirildi: %s", name, arg1);
		client_cmd(target, "model %s", arg2);
	}
    return PLUGIN_HANDLED;
}
public ChangeName(id)
{
	new name[24];
	get_user_name(id, name, 24);
	new arg1[24];
	get_say_argv(1, arg1, charsmax(arg1));
	new arg2[32];
	get_say_argv(2, arg2, charsmax(arg2));
	new target = find_player("a", arg1);
	if(target && is_user_alive(target)){
		client_print(0, print_chat, "[K-MOD] ADMIN %s: Oyuncunun ismi degistirildi: %s", name, arg1);
		client_cmd(target, "name ^"%s^"", arg2);
	}
    return PLUGIN_HANDLED;
}
public ResetPlayer(id)
{
	new name[24];
	get_user_name(id, name, 24);
	new arg1[24];
	get_say_argv(1, arg1, charsmax(arg1));
	new target = find_player("a", arg1);
	if(target && is_user_alive(target)){
		new szKey[40];
		formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[target] );
		client_print(0, print_chat, "[K-MOD] ADMIN %s: Oyuncu sifirlandi: %s", name, arg1);
		nvault_remove(g_Vault, szKey);
					new szMoney[7];        //Data holder for the money amount

					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[target] );
					formatex( szMoney , charsmax( szMoney ) , "%d" , 0 );
		nvault_set( g_Vault , szKey , szMoney );
	}
    return PLUGIN_HANDLED;
}
public SetMoney(id)
{
	new name[24];
	get_user_name(id, name, 24);
	new arg1[24];
	get_say_argv(1, arg1, charsmax(arg1));
	new arg2[32];
	get_say_argv(2, arg2, charsmax(arg2));
	new target = find_player("a", arg1);
	if(target && is_user_alive(target)){
		new szKey[40];
		formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[target] );
		client_print(0, print_chat, "[K-MOD] ADMIN %s: Oyuncunun parasi degistirildi: %s", name, arg1);
							new szMoney[7];        //Data holder for the money amount

					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[target] );
					formatex( szMoney , charsmax( szMoney ) , "%d" , str_to_num(arg2) );
		nvault_set( g_Vault , szKey , szMoney );
	}
    return PLUGIN_HANDLED;
}
public AddMoney(id)
{
	new name[24];
	get_user_name(id, name, 24);
	new arg1[24];
	get_say_argv(1, arg1, charsmax(arg1));
	new arg2[32];
	get_say_argv(2, arg2, charsmax(arg2));
	new target = find_player("a", arg1);
	if(target && is_user_alive(target)){
		new szKey[40];
		formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[target] );
		new iMoney = nvault_get( g_Vault , szKey );
		new newMoney = iMoney + str_to_num(arg2);
							if(newMoney > 200000){
						newMoney = 200000;
					}
		client_print(0, print_chat, "[K-MOD] ADMIN %s: Oyuncuya para verildi: %s", name, arg1);
							new szMoney[7];        //Data holder for the money amount

					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[target] );
					formatex( szMoney , charsmax( szMoney ) , "%d" , newMoney );
		nvault_set( g_Vault , szKey , szMoney );
	}
    return PLUGIN_HANDLED;
}
public GetMoney(id)
{
	new name[24];
	get_user_name(id, name, 24);
	new arg1[24];
	get_say_argv(1, arg1, charsmax(arg1));
	new arg2[32];
	get_say_argv(2, arg2, charsmax(arg2));
	new target = find_player("a", arg1);
	if(target && is_user_alive(target)){
		new szKey[40];
		formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[target] );
		new iMoney = nvault_get( g_Vault , szKey );
		client_print(id, print_chat, "[K-MOD] %s adli oyuncunun parasi: %i", arg1, iMoney);
	}
    return PLUGIN_HANDLED;
}
public KillPlayer(id)
{
	new name[24];
	get_user_name(id, name, 24);
	new arg1[24];
	get_say_argv(1, arg1, charsmax(arg1));
	new target = find_player("a", arg1);
	if(target && is_user_alive(target)){
		client_print(0, print_chat, "[K-MOD] ADMIN %s: Oyuncu olduruldu: %s", name,arg1);
		set_user_health(target, 0);
	}
    return PLUGIN_HANDLED;
}
public ChangeGravity(id)
{
	new name[24];
	get_user_name(id, name, 24);
	new arg1[24];
	get_say_argv(1, arg1, charsmax(arg1));
	new arg2[32];
	get_say_argv(2, arg2, charsmax(arg2));
	new target = find_player("a", arg1);
	if(target && is_user_alive(target)){
		client_print(0, print_chat, "[K-MOD] ADMIN %s: Oyuncunun yer cekimi degistirildi: %s", name, arg1);
		set_user_gravity(target, str_to_float(arg2));
	}
    return PLUGIN_HANDLED;
}
public TeleportToPlayer(id)
{
	new name[24];
	get_user_name(id, name, 24);
	new origin[3];
	new arg1[24];
	get_say_argv(1, arg1, charsmax(arg1));
	new arg2[32];
	get_say_argv(2, arg2, charsmax(arg2));
	new target = find_player("a", arg1);
	get_user_origin(target, origin);
	if(target && is_user_alive(target)){
		client_print(0, print_chat, "[K-MOD] ADMIN %s: Oyuncuya isinlandiniz: %s", name, arg1);
		set_user_origin(id, origin);
	}
    return PLUGIN_HANDLED;
}
public BringPlayer(id)
{
	new name[24];
	get_user_name(id, name, 24);
	new origin[3];
	new arg1[24];
	get_say_argv(1, arg1, charsmax(arg1));
	new arg2[32];
	get_say_argv(2, arg2, charsmax(arg2));
	new target = find_player("a", arg1);
	get_user_origin(id, origin);
	if(target && is_user_alive(target)){
		client_print(0, print_chat, "[K-MOD] ADMIN %s: Oyuncu size isinlandi: %s", name, arg1);
		set_user_origin(target, origin);
	}
    return PLUGIN_HANDLED;
}
public SurvivalMode(id)
{
	server_cmd("toggle_survival_mode");
    return PLUGIN_HANDLED;
}
public ClassicMode(id)
{
	server_cmd("toggle_classic_mode");
    return PLUGIN_HANDLED;
}
public PlayerLoc(id)
{
	new name[24];
	get_user_name(id, name, 24);
	new origin[3];
	new arg1[24];
	get_say_argv(1, arg1, charsmax(arg1));
	new arg2[32];
	get_say_argv(2, arg2, charsmax(arg2));
	new target = find_player("a", arg1);
	get_user_origin(target, origin);
	if(is_user_alive(target)){
		client_print(id, print_chat, "[K-MOD] Oyuncuya isinlanma istegi gonderildi: %s", arg1);
		new title[128];
		format(title, 128, "\r%s size isinlanmak istiyor. Kabul ediyor musunuz?", name);
		new menu = menu_create(title, "telereqmenu_handler");
		menu_additem( menu, "\wEvet", name, 0 );
		menu_additem( menu, "\wHayir", "", 0 );
		menu_display( target, menu, 0 );
	}
    return PLUGIN_HANDLED;
}
 public telereqmenu_handler( id, menu, item )
 {
		switch( item )
		{
			case 0:
			{
				if(is_user_alive(id)){
					new targetName[128], targetNameName[64];
					new _access, item_callback;
					new name[24];
					get_user_name(id, name, 24);
					menu_item_getinfo(menu, item, _access, targetName, 128, targetNameName, 64, item_callback);
					new target = find_player("a", targetName);
					client_print(target, print_chat, "[K-MOD] %s isinlanma istegini kabul etti", name);
					new origin[3];
					get_user_origin(id, origin);
					set_user_origin(target, origin);
				}
				return PLUGIN_HANDLED;
			}
		}
		menu_destroy( menu );
		return PLUGIN_HANDLED;
 }
public SaveLoc(id)
{
	if(is_user_alive(id)){
		client_print(id, print_chat, "[K-MOD] Basariyla lokasyon kaydedildi. Daha sonra 5 TL karsiliginda /t yazarak buraya isinlanabilirsiniz");
		new origin[3];
		get_user_origin(id, origin);	
		loc[id] = origin;
	}
    return PLUGIN_HANDLED;
}
public TeleportLoc(id)
{
				if(is_user_alive(id)){
					new menu = menu_create( "\rKaydedilen lokasyona isinlan?", "telemenu_handler" );
					menu_additem( menu, "\wEvet", "", 0 );
					menu_additem( menu, "\wHayir", "", 0 );
					menu_display( id, menu, 0 );
				}
				return PLUGIN_HANDLED;
 }
 public BuyMenu(id)
{
	new szData[8];
		new szKey[40];
		formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
	if(is_user_alive(id) && nvault_get( g_Vault , szKey , szData , charsmax( szData ) )){
		new menutext[64];
		format(menutext, 63, "\rK-Mod Buymenu %s", BUYMENU_VERSION);
		new menu = menu_create(menutext, "shopmenu_handler" );
		menu_additem( menu, "\wSilahlar", "", 0 );
		menu_additem( menu, "\wCephaneler", "", 0 );
		menu_additem( menu, "\wEsyalar", "", 0 );
		menu_display( id, menu, 0 );
	}
 }
 public shopmenu_handler( id, menu, item )
 {
		switch( item )
		{
			case 0:
			{
				new szData[8];
					new szKey[40];
					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
				if(is_user_alive(id) && nvault_get( g_Vault , szKey , szData , charsmax( szData ) )){
					new menutext[64];
		format(menutext, 63, "\rK-Mod Buymenu %s", BUYMENU_VERSION);
					new menu = menu_create(menutext, "shopmenuweapon_handler" );
					/*open file in read-mode*/
					new filepointer = fopen(weaponfilename,"r")
					/*check if file is open,on an error filepointer is 0*/
					if(filepointer)
					{
						new readdata[128]
						new parsedconstname[32],parsedname[32],parsedprice[8]
					
						/*Read the file until it is at end of file*/
						/*fgets - Reads a line from a text file -- includes newline!*/
						new i;
						while(fgets(filepointer,readdata,127) && i < 20)
						{   
							parse(weapons[i],parsedconstname,31,parsedname,31,parsedprice,7)
							new price = str_to_num(parsedprice);
							new itemtext[64];
							format(itemtext, 63, "\w%s | %i TL", parsedname, price);
							menu_additem(menu, itemtext, "", 0);
							i++;
						}
						fclose(filepointer)
					}
					menu_display( id, menu, 0 );
				}
				return PLUGIN_HANDLED;
			}
			case 1:
			{
				new szData[8];
					new szKey[40];
					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
				if(is_user_alive(id) && nvault_get( g_Vault , szKey , szData , charsmax( szData ) )){
					new menutext[64];
		format(menutext, 63, "\rK-Mod Buymenu %s", BUYMENU_VERSION);
					new menu = menu_create(menutext, "shopmenuammo_handler" );
					/*open file in read-mode*/
					new filepointer = fopen(ammofilename,"r")
					/*check if file is open,on an error filepointer is 0*/
					if(filepointer)
					{
						new readdata[128]
						new parsedconstname[32],parsedname[32],parsedprice[8]
					
						/*Read the file until it is at end of file*/
						/*fgets - Reads a line from a text file -- includes newline!*/
						new i;
						while(fgets(filepointer,readdata,127) && i < 20)
						{   
							parse(ammos[i],parsedconstname,31,parsedname,31,parsedprice,7)
							new price = str_to_num(parsedprice);
							new itemtext[64];
							format(itemtext, 63, "\w%s | %i TL", parsedname, price);
							menu_additem(menu, itemtext, "", 0);
							i++;
						}
						fclose(filepointer)
					}
					menu_display( id, menu, 0 );
				}
				return PLUGIN_HANDLED;
			}
			case 2:
			{
				new szData[8];
					new szKey[40];
					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
				if(is_user_alive(id) && nvault_get( g_Vault , szKey , szData , charsmax( szData ) )){
					new menutext[64];
			format(menutext, 63, "\rK-Mod Buymenu %s", BUYMENU_VERSION);
					new menu = menu_create(menutext, "shopmenuitem_handler" );
					/*open file in read-mode*/
					new filepointer = fopen(itemfilename,"r")
					/*check if file is open,on an error filepointer is 0*/
					if(filepointer)
					{
						new readdata[128]
						new parsedconstname[32],parsedname[32],parsedprice[8]
					
						/*Read the file until it is at end of file*/
						/*fgets - Reads a line from a text file -- includes newline!*/
						new i;
						while(fgets(filepointer,readdata,127) && i < 20)
						{   
							parse(items[i],parsedconstname,31,parsedname,31,parsedprice,7)
							new price = str_to_num(parsedprice);
							new itemtext[64];
							format(itemtext, 63, "\w%s | %i TL", parsedname, price);
							menu_additem(menu, itemtext, "", 0);
							i++;
						}
						fclose(filepointer)
					}
					menu_display( id, menu, 0 );
				}
				return PLUGIN_HANDLED;
			}
		}
		menu_destroy( menu );
		return PLUGIN_HANDLED;
 }
 public shopmenuweapon_handler( id, menu, item )
 {
	 new parsedconstname[32],parsedname[32],parsedprice[8]
	 parse(weapons[item],parsedconstname,31,parsedname,31,parsedprice,7)
							new price = str_to_num(parsedprice);
				new szKey[40];
				formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
				new iMoney = nvault_get( g_Vault , szKey );
				if(iMoney >= price){
					client_print(id, print_chat, "[K-MOD] Basariyla %s satin aldiniz.", parsedname);
					sc_give_item(id, parsedconstname);
					new szKey[40];
					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
					new iMoney = nvault_get( g_Vault , szKey );
					new newMoney = iMoney - price;
					new szMoney[7];        //Data holder for the money amount
					formatex( szMoney , charsmax( szMoney ) , "%d" , newMoney );
					
					nvault_set( g_Vault , szKey , szMoney );
				}
				else{
					client_print(id, print_chat, "[K-MOD] Bakiyeniz yetersiz.");
				}
				menu_destroy( menu );
				return PLUGIN_HANDLED;
 }
 public shopmenuammo_handler( id, menu, item )
 {
	 new parsedconstname[32],parsedname[32],parsedprice[8]
	 parse(ammos[item],parsedconstname,31,parsedname,31,parsedprice,7)
							new price = str_to_num(parsedprice);
				new szKey[40];
				formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
				new iMoney = nvault_get( g_Vault , szKey );
				if(iMoney >= price){
					client_print(id, print_chat, "[K-MOD] Basariyla %s satin aldiniz.", parsedname);
					sc_give_item(id, parsedconstname);
					new szKey[40];
					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
					new iMoney = nvault_get( g_Vault , szKey );
					new newMoney = iMoney - price;
					new szMoney[7];        //Data holder for the money amount
					formatex( szMoney , charsmax( szMoney ) , "%d" , newMoney );
					
					nvault_set( g_Vault , szKey , szMoney );
				}
				else{
					client_print(id, print_chat, "[K-MOD] Bakiyeniz yetersiz.");
				}
				menu_destroy( menu );
				return PLUGIN_HANDLED;
 }
 public shopmenuitem_handler( id, menu, item )
 {
	 new parsedconstname[32],parsedname[32],parsedprice[8]
	 parse(items[item],parsedconstname,31,parsedname,31,parsedprice,7)
							new price = str_to_num(parsedprice);
				new szKey[40];
				formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
				new iMoney = nvault_get( g_Vault , szKey );
				if(iMoney >= price){
					client_print(id, print_chat, "[K-MOD] Basariyla %s satin aldiniz.", parsedname);
					sc_give_item(id, parsedconstname);
					new szKey[40];
					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
					new iMoney = nvault_get( g_Vault , szKey );
					new newMoney = iMoney - price;
					new szMoney[7];        //Data holder for the money amount
					formatex( szMoney , charsmax( szMoney ) , "%d" , newMoney );
					
					nvault_set( g_Vault , szKey , szMoney );
				}
				else{
					client_print(id, print_chat, "[K-MOD] Bakiyeniz yetersiz.");
				}
				menu_destroy( menu );
				return PLUGIN_HANDLED;
 }
 public telemenu_handler( id, menu, item )
 {
		switch( item )
		{
			case 0:
			{
				new szKey[40];
				formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
				new iMoney = nvault_get( g_Vault , szKey );
				if(iMoney >= 5){
					client_print(id, print_chat, "[K-MOD] Basariyla isinlandiniz.");
					set_user_origin(id, loc[id]);
					new szKey[40];
					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
					new iMoney = nvault_get( g_Vault , szKey );
					new newMoney = iMoney - 5;
					new szMoney[7];        //Data holder for the money amount
					formatex( szMoney , charsmax( szMoney ) , "%d" , newMoney );
					
					nvault_set( g_Vault , szKey , szMoney );
				}
				else{
					client_print(id, print_chat, "[K-MOD] Bakiyeniz yetersiz.");
				}
				menu_destroy( menu );
				return PLUGIN_HANDLED;
			}
		}
		menu_destroy( menu );
		return PLUGIN_HANDLED;
 }
public revmenu_handler( id, menu, item )
 {
		switch( item )
		{
			case 0:
			{
				new szKey[40];
				formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
				new iMoney = nvault_get( g_Vault , szKey );
				if(iMoney >= 100){
					new origin[3];
					get_user_origin(id, origin);
					client_print(id, print_chat, "[K-MOD] Basariyla yeniden canlandiniz.");
					spawn(id);
					set_user_origin(id, origin);
					new szKey[40];
					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
					new iMoney = nvault_get( g_Vault , szKey );
					new newMoney = iMoney - 100;
					new szMoney[7];        //Data holder for the money amount
					formatex( szMoney , charsmax( szMoney ) , "%d" , newMoney );
					
					nvault_set( g_Vault , szKey , szMoney );
				}
				else{
					client_print(id, print_chat, "[K-MOD] Bakiyeniz yetersiz.");
				}
				menu_destroy( menu );
				return PLUGIN_HANDLED;
			}
		}
		menu_destroy( menu );
		return PLUGIN_HANDLED;
 }
