#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <engine>
#include <fakemeta>
#include <nvault>
#include <ibm_say>
#include <xp_weapon>
#define VERSION "1.0"
#define AUTHOR "Esat Efe"
new loc[33][3];
new g_Vault;               //Global var to hold our vault handle
new g_szAuthID[33][35];    //Global array to store auth ids of players
new g_pExpireDays;         //CVar pointer for expiredays cvar
new cheatsCvar;
public plugin_init()
{
    register_plugin("SC-EMod", VERSION, AUTHOR);
    register_forward(FM_GetGameDescription,"change_gamename");

	cheatsCvar = register_cvar("sv_cheats", "0");
	set_task(120.0, "ECommandsText");
	set_task(60.0, "GiveTL");
	set_task(1.0, "ShowData");
}
public ibm_say_main()
{
	register_saycmd("respawn", "RespawnPlayer", ADMIN_ADMIN, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("god", "GodMode", ADMIN_ADMIN, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("noclip", "Noclip", ADMIN_ADMIN, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("hp", "SetHp", ADMIN_ADMIN, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("kill", "KillPlayer", ADMIN_ADMIN, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("armor", "SetArmor", ADMIN_ADMIN, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("give", "GiveItem", ADMIN_ADMIN, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("model", "ChangeModel", ADMIN_ADMIN, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("name", "ChangeName", ADMIN_ADMIN, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("resetplayer", "ResetPlayer", ADMIN_ADMIN, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("setmoney", "SetMoney", ADMIN_ADMIN, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("addmoney", "AddMoney", ADMIN_ADMIN, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("getmoney", "GetMoney", ADMIN_ADMIN, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("gravity", "ChangeGravity", ADMIN_ADMIN, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("goto", "TeleportToPlayer", ADMIN_ADMIN, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("bring", "BringPlayer", ADMIN_ADMIN, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("survival", "SurvivalMode", ADMIN_ADMIN, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("classic", "ClassicMode", ADMIN_ADMIN, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("saveloc", "SaveLoc", ADMIN_ALL, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("playerloc", "PlayerLoc", ADMIN_ALL, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("teleport", "TeleportLoc", ADMIN_ALL, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("buy", "ShopMenu", ADMIN_ALL, 1, "", "info", "[SC-EMod] ", false, false, false);
	register_saycmd("shop", "ShopMenu", ADMIN_ALL, 1, "", "info", "[SC-EMod] ", false, false, false);
    register_saycmd("gift", "SendMoney", ADMIN_ALL, 1, "", "info", "[SC-EMod] ", false, false, false);
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
	format(g,31,"SC-EMod v%s",VERSION);
	forward_return(FMV_STRING,g);
	return FMRES_SUPERCEDE;
	return PLUGIN_HANDLED;
} 
public ECommandsText(){
	client_print(0, print_chat, "[SC-EMod] v%s by Esat Efe", VERSION);
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
		if(is_user_connected(i) && nvault_get( g_Vault , szKey , szData , charsmax( szData ) ))
		{
			set_hudmessage(50,135,180,0.0,0.85,0,1.0,255.0,0.0,0.0,3)
			show_hudmessage(i, "------> SC-EMod v%s <------^n- Bakiye: %i TL^n- github: esatefekorkmaz", VERSION, iMoney);
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
					new szKey2[40];        //Key used to save money "STEAM_0:0:1234MONEY"

					formatex( szKey2 , charsmax( szKey2 ) , "%sMONEY" , g_szAuthID[i] );
					formatex( szMoney , charsmax( szMoney ) , "%d" , newMoney );
					
					nvault_set( g_Vault , szKey2 , szMoney );
					client_print(i, print_chat, "[SC-EMod] Sunucuda oynadiginiz icin 10 TL elde ettiniz.");
		}
		else if(iMoney >= 200000){
			client_print(i, print_chat, "[SC-EMod] Bakiye limiti asildi. Daha fazla para kazanamazsiniz. (Limit: 200000 TL)");
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
		client_print(id, print_chat, "[SC-EMod] Oyuncuya %s TL para verildi: %s", arg2, arg1);
		client_print(target, print_chat, "[SC-EMod] Oyuncu size %s TL para verdi: %s", arg2, name);
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
		client_print(0, print_chat, "[SC-EMod] ADMIN %s: Oyuncu canlandirildi: %s", name, arg1);
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
		client_print(0, print_chat, "[SC-EMod] ADMIN %s: Oyuncunun olumsuzlugu degistirildi: %s", name, arg1);
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
		client_print(0, print_chat, "[SC-EMod] ADMIN %s: Oyuncunun noclip modu degistirildi: %s", name, arg1);
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
		client_print(0, print_chat, "[SC-EMod] ADMIN %s: Oyuncunun sagligi degistirildi: %s", name, arg1);
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
		client_print(0, print_chat, "[SC-EMod] ADMIN %s: Oyuncunun zirhi degistirildi: %s", name, arg1);
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
		client_print(0, print_chat, "[SC-EMod] ADMIN %s: Oyuncuya esya verildi: %s", name, arg1);
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
		client_print(0, print_chat, "[SC-EMod] ADMIN %s: Oyuncunun modeli degistirildi: %s", name, arg1);
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
		client_print(0, print_chat, "[SC-EMod] ADMIN %s: Oyuncunun ismi degistirildi: %s", name, arg1);
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
		client_print(0, print_chat, "[SC-EMod] ADMIN %s: Oyuncu sifirlandi: %s", name, arg1);
		nvault_remove(g_Vault, szKey);
					new szMoney[7];        //Data holder for the money amount

					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
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
		client_print(0, print_chat, "[SC-EMod] ADMIN %s: Oyuncunun parasi degistirildi: %s", name, arg1);
							new szMoney[7];        //Data holder for the money amount

					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
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
		client_print(0, print_chat, "[SC-EMod] ADMIN %s: Oyuncuya para verildi: %s", name, arg1);
							new szMoney[7];        //Data holder for the money amount

					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
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
		client_print(id, print_chat, "[SC-EMod] %s adli oyuncunun parasi: %i", arg1, iMoney);
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
		client_print(0, print_chat, "[SC-EMod] ADMIN %s: Oyuncu olduruldu: %s", name,arg1);
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
		client_print(0, print_chat, "[SC-EMod] ADMIN %s: Oyuncunun yer cekimi degistirildi: %s", name, arg1);
		set_user_gravity(target, str_to_num(arg2));
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
		client_print(0, print_chat, "[SC-EMod] ADMIN %s: Oyuncuya isinlandiniz: %s", name, arg1);
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
		client_print(0, print_chat, "[SC-EMod] ADMIN %s: Oyuncu size isinlandi: %s", name, arg1);
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
		client_print(id, print_chat, "[SC-EMod] Oyuncuya isinlanma istegi gonderildi: %s", arg1);
		new title[128];
		format(title, 128, "\r%s size isinlanmak istiyor. Kabul ediyor musunuz?", name);
		new menu = menu_create(title, "telereqmenu_handler");
		menu_additem( menu, "\wEvet", name, 0 );
		menu_additem( menu, "\wHayir", "", 0 );
		menu_display( id, menu, 0 );
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
					client_print(target, print_chat, "[SC-EMod] %s isinlanma istegini kabul etti", name);
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
		client_print(id, print_chat, "[SC-EMod] Basariyla lokasyon kaydedildi. Daha sonra 5 TL karsiliginda /teleport yazarak buraya isinlanabilirsiniz");
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
 public ShopMenu(id)
{
	new szData[8];
		new szKey[40];
		formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
		new iMoney = nvault_get( g_Vault , szKey );
	if(is_user_alive(id) && nvault_get( g_Vault , szKey , szData , charsmax( szData ) )){
		new menu = menu_create( "\rSC-EMod Shop Menu", "shopmenu_handler" );
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
					new iMoney = nvault_get( g_Vault , szKey );
				if(is_user_alive(id) && nvault_get( g_Vault , szKey , szData , charsmax( szData ) )){
					new menu = menu_create( "\rSC-EMod Shop Menu", "shopmenuweapon_handler" );
					menu_additem( menu, "\wM249 | 100 TL", "", 0 );
					menu_additem( menu, "\wGauss | 500 TL", "", 0 );
					menu_display( id, menu, 0 );
				}
				return PLUGIN_HANDLED;
			}
			case 1:
			{
				new szData[8];
					new szKey[40];
					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
					new iMoney = nvault_get( g_Vault , szKey );
				if(is_user_alive(id) && nvault_get( g_Vault , szKey , szData , charsmax( szData ) )){
					new menu = menu_create( "\rSC-EMod Shop Menu", "shopmenuammo_handler" );
					menu_additem( menu, "\w556 | 10 TL", "", 0 );
					menu_additem( menu, "\wGauss Battery | 50 TL", "", 0 );
					menu_display( id, menu, 0 );
				}
				return PLUGIN_HANDLED;
			}
			case 2:
			{
				new szData[8];
					new szKey[40];
					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
					new iMoney = nvault_get( g_Vault , szKey );
				if(is_user_alive(id) && nvault_get( g_Vault , szKey , szData , charsmax( szData ) )){
					new menu = menu_create( "\rSC-EMod Shop Menu", "shopmenuesya_handler" );
					menu_additem( menu, "\wLongjump | 50 TL", "", 0 );
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
		switch( item )
		{
			case 0:
			{
				new szKey[40];
				formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
				new iMoney = nvault_get( g_Vault , szKey );
				if(iMoney >= 100){
					client_print(id, print_chat, "[SC-EMod] Basariyla M249 satin aldiniz.");
					sc_give_item(id, "weapon_m249");
					new szKey[40];
					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
					new iMoney = nvault_get( g_Vault , szKey );
					new newMoney = iMoney - 100;
					new szMoney[7];        //Data holder for the money amount
					new szKey2[40];        //Key used to save money "STEAM_0:0:1234MONEY"

					formatex( szKey2 , charsmax( szKey2 ) , "%sMONEY" , g_szAuthID[id] );
					formatex( szMoney , charsmax( szMoney ) , "%d" , newMoney );
					
					nvault_set( g_Vault , szKey2 , szMoney );
				}
				else{
					client_print(id, print_chat, "[SC-EMod] Bakiyeniz yetersiz.");
				}
				menu_destroy( menu );
				return PLUGIN_HANDLED;
			}
			case 1:
			{
				new szKey[40];
				formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
				new iMoney = nvault_get( g_Vault , szKey );
				if(iMoney >= 500){
					client_print(id, print_chat, "[SC-EMod] Basariyla Gauss satin aldiniz.");
					sc_give_item(id, "weapon_gauss");
					new szKey[40];
					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
					new iMoney = nvault_get( g_Vault , szKey );
					new newMoney = iMoney - 500;
					new szMoney[7];        //Data holder for the money amount
					new szKey2[40];        //Key used to save money "STEAM_0:0:1234MONEY"

					formatex( szKey2 , charsmax( szKey2 ) , "%sMONEY" , g_szAuthID[id] );
					formatex( szMoney , charsmax( szMoney ) , "%d" , newMoney );
					
					nvault_set( g_Vault , szKey2 , szMoney );
				}
				else{
					client_print(id, print_chat, "[SC-EMod] Bakiyeniz yetersiz.");
				}
				menu_destroy( menu );
				return PLUGIN_HANDLED;
			}
		}
		menu_destroy( menu );
		return PLUGIN_HANDLED;
 }
 public shopmenuesya_handler( id, menu, item )
 {
		switch( item )
		{
			case 0:
			{
				new szKey[40];
				formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
				new iMoney = nvault_get( g_Vault , szKey );
				if(iMoney >= 50){
					client_print(id, print_chat, "[SC-EMod] Basariyla Longjump satin aldiniz.");
					sc_give_item(id, "item_longjump");
					new szKey[40];
					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
					new iMoney = nvault_get( g_Vault , szKey );
					new newMoney = iMoney - 50;
					new szMoney[7];        //Data holder for the money amount
					new szKey2[40];        //Key used to save money "STEAM_0:0:1234MONEY"

					formatex( szKey2 , charsmax( szKey2 ) , "%sMONEY" , g_szAuthID[id] );
					formatex( szMoney , charsmax( szMoney ) , "%d" , newMoney );
					
					nvault_set( g_Vault , szKey2 , szMoney );
				}
				else{
					client_print(id, print_chat, "[SC-EMod] Bakiyeniz yetersiz.");
				}
				menu_destroy( menu );
				return PLUGIN_HANDLED;
			}
		}
		menu_destroy( menu );
		return PLUGIN_HANDLED;
 }
 public shopmenuammo_handler( id, menu, item )
 {
		switch( item )
		{
			case 0:
			{
				new szKey[40];
				formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
				new iMoney = nvault_get( g_Vault , szKey );
				if(iMoney >= 10){
					client_print(id, print_chat, "[SC-EMod] Basariyla 556 satin aldiniz.");
					sc_give_item(id, "ammo_556");
					new szKey[40];
					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
					new iMoney = nvault_get( g_Vault , szKey );
					new newMoney = iMoney - 10;
					new szMoney[7];        //Data holder for the money amount
					new szKey2[40];        //Key used to save money "STEAM_0:0:1234MONEY"

					formatex( szKey2 , charsmax( szKey2 ) , "%sMONEY" , g_szAuthID[id] );
					formatex( szMoney , charsmax( szMoney ) , "%d" , newMoney );
					
					nvault_set( g_Vault , szKey2 , szMoney );
				}
				else{
					client_print(id, print_chat, "[SC-EMod] Bakiyeniz yetersiz.");
				}
				menu_destroy( menu );
				return PLUGIN_HANDLED;
			}
			case 1:
			{
				new szKey[40];
				formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
				new iMoney = nvault_get( g_Vault , szKey );
				if(iMoney >= 50){
					client_print(id, print_chat, "[SC-EMod] Basariyla Battery satin aldiniz.");
					sc_give_item(id, "ammo_gaussclip");
					new szKey[40];
					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
					new iMoney = nvault_get( g_Vault , szKey );
					new newMoney = iMoney - 50;
					new szMoney[7];        //Data holder for the money amount
					new szKey2[40];        //Key used to save money "STEAM_0:0:1234MONEY"

					formatex( szKey2 , charsmax( szKey2 ) , "%sMONEY" , g_szAuthID[id] );
					formatex( szMoney , charsmax( szMoney ) , "%d" , newMoney );
					
					nvault_set( g_Vault , szKey2 , szMoney );
				}
				else{
					client_print(id, print_chat, "[SC-EMod] Bakiyeniz yetersiz.");
				}
				menu_destroy( menu );
				return PLUGIN_HANDLED;
			}
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
					client_print(id, print_chat, "[SC-EMod] Basariyla isinlandiniz.");
					set_user_origin(id, loc[id]);
					new szKey[40];
					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
					new iMoney = nvault_get( g_Vault , szKey );
					new newMoney = iMoney - 5;
					new szMoney[7];        //Data holder for the money amount
					new szKey2[40];        //Key used to save money "STEAM_0:0:1234MONEY"

					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
					formatex( szMoney , charsmax( szMoney ) , "%d" , newMoney );
					
					nvault_set( g_Vault , szKey , szMoney );
				}
				else{
					client_print(id, print_chat, "[SC-EMod] Bakiyeniz yetersiz.");
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
					client_print(id, print_chat, "[SC-EMod] Basariyla yeniden canlandiniz.");
					spawn(id);
					set_user_origin(id, origin);
					new szKey[40];
					formatex( szKey , charsmax( szKey ) , "%sMONEY" , g_szAuthID[id] );
					new iMoney = nvault_get( g_Vault , szKey );
					new newMoney = iMoney - 100;
					new szMoney[7];        //Data holder for the money amount
					new szKey2[40];        //Key used to save money "STEAM_0:0:1234MONEY"

					formatex( szKey2 , charsmax( szKey2 ) , "%sMONEY" , g_szAuthID[id] );
					formatex( szMoney , charsmax( szMoney ) , "%d" , newMoney );
					
					nvault_set( g_Vault , szKey2 , szMoney );
				}
				else{
					client_print(id, print_chat, "[SC-EMod] Bakiyeniz yetersiz.");
				}
				menu_destroy( menu );
				return PLUGIN_HANDLED;
			}
		}
		menu_destroy( menu );
		return PLUGIN_HANDLED;
 }
