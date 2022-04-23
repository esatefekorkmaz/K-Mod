#include <amxmodx>
#include <fakemeta>
#include <engine>
#define SC_NORESPAWN (1<<10)
#pragma tabsize 0
enum
{
	SCW_CROWBAR = 1,	
	SCW_9MMHANDGUN,	 
	SCW_357,				
	SCW_9MMAR,			
	SCW_M203,			
	SCW_CROSSBOW,		
	SCW_SHOTGUN,			
	SCW_RPG,				
	SCW_GAUSS,			
	SCW_EGON,			
	SCW_HORNETGUN,		
	SCW_HANDGRENADE, 		
	SCW_TRIPMINE,	
	SCW_SATCHEL,			
	SCW_SNARK,			
	SCW_UZIAKIMBO,		
	SCW_UZI,			
	SCW_MEDKIT,			
	SCW_UNKNOWN,		
	SCW_PIPEWRENCH,			
	SCW_MINIGUN,		
	SCW_GRAPPLE,		
	SCW_SNIPERRIFLE,		
	SCW_M249, 
	SCW_M16,				
	SCW_SPORELAUNCHER, 
	SCW_EAGLE,	
	SCW_SHOCKRIFLE, 
}
enum
{
	OFFSET_MONSTER_ALLY = 17,
	OFFSET_AMMO_CLIP1 = 8247,
	OFFSET_AMMO_CLIP2,
	OFFSET_NEXTATTACK = 8247, //Float
	OFFSET_NEXTATTACKW = 8241, //Float
	OFFSET_AMMO_ID = 8245,
	OFFSET_AMMO_ID2
}
enum
{
	OFFSET_AMMO_SHOTGUN = 8668,
	OFFSET_AMMO_MEDKIT,
	OFFSET_AMMO_M249,
	OFFSET_AMMO_SNIPER,
	OFFSET_AMMO_M16GRENADE,
	OFFSET_AMMO_357,		
	OFFSET_AMMO_9MM,		
	OFFSET_AMMO_SHOCK,
	OFFSET_AMMO_SPORE,
	OFFSET_AMMO_URANIUM,
	OFFSET_AMMO_RPG,
	OFFSET_AMMO_CROSSBOW,
	OFFSET_AMMO_TRIPMINE,
	OFFSET_AMMO_SATCHEL,
	OFFSET_AMMO_HANDGRENADE,
	OFFSET_AMMO_SNARK,
	OFFSET_AMMO_HORNET
}
enum
{
	MAX_AMMO = 0,
	AMMO_OFFSET,
	MAX_CLIP_AMMO,
	CLIP_COUNT,
	IS_WEAPON
}
new bool:WeaponLoaded;
new WeaponList[29][5];
public GetAmmoIdByWeapon(userid, weaponid)
{
	if(!userid) return -1;
	if(!is_user_connected(userid)) return -1;
	if(weaponid < 0) return -1;
	new WName[40];
	get_weaponname(weaponid, WName, 39);
	if(strlen(WName) <= 0) return -1;
	new entw = find_ent_by_owner(-1,WName, userid, 0);
	if(!entw) return -1;
	return get_pdata_int(entw, OFFSET_AMMO_ID);
}
public ShowMessage(id, ammo, amount)
{
	if(amount <= 0) return;
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("AmmoPickup"), _, id)
	write_byte(ammo)
	write_long(amount)
	message_end()
}
public sc_give_item(id, entname[])
{
    new Float:origin[3];
    pev(id,pev_origin,origin);
    new ent;
    ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, entname))
    if(ent) 
	{
        engfunc(EngFunc_SetOrigin, ent, origin);
		set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SC_NORESPAWN)
        dllfunc(DLLFunc_Spawn, ent)
		dllfunc(DLLFunc_Touch, ent, id)
    }
    return ent;
}
public bool:isValidWeapon(playerid, weaponid)
{
	if(!WeaponLoaded) SilahArraylariYukle();
	new Weapons[32]
	new numWeapons
	get_user_weapons(playerid, Weapons, numWeapons)
	for (new i=0; i<numWeapons; i++)
	{
	   if(Weapons[i] == weaponid) return true;
	   if(Weapons[i] == SCW_M16 && weaponid == SCW_M203)
	   {
			return true;
	   }
	}
	return false;
}
public get_weapon_data(weaponid, memberid)
{
	if(!WeaponLoaded) SilahArraylariYukle();
	if(weaponid < 0 || weaponid >= 29) return 0;
	if(memberid < 0 || memberid >= 5) return 0;
	return WeaponList[weaponid][memberid];
}
stock SilahArraylariYukle()
{
	for(new c = 1; c < 29; c++) //Default variants
	{
		WeaponList[c][CLIP_COUNT] = 2
		WeaponList[c][MAX_CLIP_AMMO] = 0
		WeaponList[c][AMMO_OFFSET] = -1
		WeaponList[c][MAX_AMMO] = 0
		WeaponList[c][IS_WEAPON] = 1
	}
	WeaponList[SCW_CROWBAR][CLIP_COUNT] = 0
	
	WeaponList[SCW_9MMHANDGUN][MAX_AMMO] = 500
	WeaponList[SCW_9MMHANDGUN][MAX_CLIP_AMMO] = 17
	WeaponList[SCW_9MMHANDGUN][AMMO_OFFSET] = OFFSET_AMMO_9MM
	
	WeaponList[SCW_9MMAR][MAX_AMMO] = 500
	WeaponList[SCW_9MMAR][MAX_CLIP_AMMO] = 30
	WeaponList[SCW_9MMAR][AMMO_OFFSET] = OFFSET_AMMO_9MM
	
	WeaponList[SCW_357][MAX_AMMO] = 72
	WeaponList[SCW_357][MAX_CLIP_AMMO] = 6
	WeaponList[SCW_357][AMMO_OFFSET] = OFFSET_AMMO_357
	
	WeaponList[SCW_M203][IS_WEAPON] = 4
	WeaponList[SCW_M203][MAX_AMMO] = 10
	WeaponList[SCW_M203][MAX_CLIP_AMMO] = 1
	WeaponList[SCW_M203][AMMO_OFFSET] = OFFSET_AMMO_M16GRENADE
	
	WeaponList[SCW_CROSSBOW][MAX_AMMO] = 100
	WeaponList[SCW_CROSSBOW][MAX_CLIP_AMMO] = 5
	WeaponList[SCW_CROSSBOW][AMMO_OFFSET] = OFFSET_AMMO_CROSSBOW
	
	WeaponList[SCW_SHOTGUN][MAX_AMMO] = 250
	WeaponList[SCW_SHOTGUN][MAX_CLIP_AMMO] = 8
	WeaponList[SCW_SHOTGUN][AMMO_OFFSET] = OFFSET_AMMO_SHOTGUN
	
	WeaponList[SCW_RPG][MAX_AMMO] = 10
	WeaponList[SCW_RPG][MAX_CLIP_AMMO] = 1
	WeaponList[SCW_RPG][AMMO_OFFSET] = OFFSET_AMMO_RPG
	
	WeaponList[SCW_GAUSS][MAX_AMMO] = 200
	WeaponList[SCW_GAUSS][MAX_CLIP_AMMO] = 200
	WeaponList[SCW_GAUSS][CLIP_COUNT] = 1
	WeaponList[SCW_GAUSS][AMMO_OFFSET] = OFFSET_AMMO_URANIUM
	
	WeaponList[SCW_EGON][MAX_AMMO] = 200
	WeaponList[SCW_EGON][MAX_CLIP_AMMO] = 200
	WeaponList[SCW_EGON][CLIP_COUNT] = 1
	WeaponList[SCW_EGON][AMMO_OFFSET] = OFFSET_AMMO_URANIUM
	
	
	WeaponList[SCW_HORNETGUN][MAX_AMMO] = 200
	WeaponList[SCW_HORNETGUN][MAX_CLIP_AMMO] = 200
	WeaponList[SCW_HORNETGUN][CLIP_COUNT] = 1
	WeaponList[SCW_HORNETGUN][AMMO_OFFSET] = OFFSET_AMMO_HORNET
	
	WeaponList[SCW_HANDGRENADE][IS_WEAPON] = 2
	WeaponList[SCW_HANDGRENADE][MAX_AMMO] = 20
	WeaponList[SCW_HANDGRENADE][MAX_CLIP_AMMO] = 20
	WeaponList[SCW_HANDGRENADE][CLIP_COUNT] = 1
	WeaponList[SCW_HANDGRENADE][AMMO_OFFSET] = OFFSET_AMMO_HANDGRENADE
	
	WeaponList[SCW_TRIPMINE][IS_WEAPON] = 2
	WeaponList[SCW_TRIPMINE][MAX_AMMO] = 10
	WeaponList[SCW_TRIPMINE][MAX_CLIP_AMMO] = 10
	WeaponList[SCW_TRIPMINE][CLIP_COUNT] = 1
	WeaponList[SCW_TRIPMINE][AMMO_OFFSET] = OFFSET_AMMO_TRIPMINE
	
	WeaponList[SCW_SATCHEL][IS_WEAPON] = 2
	WeaponList[SCW_SATCHEL][MAX_AMMO] = 10
	WeaponList[SCW_SATCHEL][MAX_CLIP_AMMO] = 10
	WeaponList[SCW_SATCHEL][CLIP_COUNT] = 1
	WeaponList[SCW_SATCHEL][AMMO_OFFSET] = OFFSET_AMMO_SATCHEL

	WeaponList[SCW_SNARK][MAX_AMMO] = 30
	WeaponList[SCW_SNARK][MAX_CLIP_AMMO] = 30
	WeaponList[SCW_SNARK][CLIP_COUNT] = 1
	WeaponList[SCW_SNARK][AMMO_OFFSET] = OFFSET_AMMO_SNARK
	
	WeaponList[SCW_UZIAKIMBO][MAX_AMMO] = 500
	WeaponList[SCW_UZIAKIMBO][MAX_CLIP_AMMO] = 32
	WeaponList[SCW_UZIAKIMBO][CLIP_COUNT] = 3
	WeaponList[SCW_UZIAKIMBO][AMMO_OFFSET] = OFFSET_AMMO_9MM
	
	WeaponList[SCW_UZI][MAX_AMMO] = 500
	WeaponList[SCW_UZI][MAX_CLIP_AMMO] = 32
	WeaponList[SCW_UZI][AMMO_OFFSET] = OFFSET_AMMO_9MM
	
	WeaponList[SCW_MEDKIT][MAX_AMMO] = 200
	WeaponList[SCW_MEDKIT][MAX_CLIP_AMMO] = 200
	WeaponList[SCW_MEDKIT][CLIP_COUNT] = 1
	WeaponList[SCW_MEDKIT][AMMO_OFFSET] = OFFSET_AMMO_MEDKIT
	WeaponList[SCW_MEDKIT][IS_WEAPON] = 0

	WeaponList[SCW_PIPEWRENCH][CLIP_COUNT] = 0
	
	WeaponList[SCW_MINIGUN][MAX_AMMO] = 1200
	WeaponList[SCW_MINIGUN][MAX_CLIP_AMMO] = 1200
	WeaponList[SCW_MINIGUN][CLIP_COUNT] = 1
	WeaponList[SCW_MINIGUN][AMMO_OFFSET] = OFFSET_AMMO_M249
	
	WeaponList[SCW_M249][MAX_AMMO] = 1200
	WeaponList[SCW_M249][MAX_CLIP_AMMO] = 200
	WeaponList[SCW_M249][CLIP_COUNT] = 2
	WeaponList[SCW_M249][AMMO_OFFSET] = OFFSET_AMMO_M249

	WeaponList[SCW_GRAPPLE][CLIP_COUNT] = 0

	WeaponList[SCW_SNIPERRIFLE][MAX_AMMO] = 30
	WeaponList[SCW_SNIPERRIFLE][MAX_CLIP_AMMO] = 5
	WeaponList[SCW_SNIPERRIFLE][CLIP_COUNT] = 2
	WeaponList[SCW_SNIPERRIFLE][AMMO_OFFSET] = OFFSET_AMMO_SNIPER
	

	WeaponList[SCW_M16][MAX_AMMO] = 1200
	WeaponList[SCW_M16][MAX_CLIP_AMMO] = 30
	WeaponList[SCW_M16][CLIP_COUNT] = 3
	WeaponList[SCW_M16][AMMO_OFFSET] = OFFSET_AMMO_M249

	WeaponList[SCW_SPORELAUNCHER][MAX_AMMO] = 60
	WeaponList[SCW_SPORELAUNCHER][MAX_CLIP_AMMO] = 8
	WeaponList[SCW_SPORELAUNCHER][AMMO_OFFSET] = OFFSET_AMMO_SPORE
	
	WeaponList[SCW_EAGLE][MAX_AMMO] = 72
	WeaponList[SCW_EAGLE][MAX_CLIP_AMMO] = 7
	WeaponList[SCW_EAGLE][AMMO_OFFSET] = OFFSET_AMMO_357
	
	WeaponList[SCW_SHOCKRIFLE][MAX_AMMO] = 200
	WeaponList[SCW_SHOCKRIFLE][MAX_CLIP_AMMO] = 200
	WeaponList[SCW_SHOCKRIFLE][CLIP_COUNT] = 1
	WeaponList[SCW_SHOCKRIFLE][AMMO_OFFSET] = OFFSET_AMMO_SHOCK;
	WeaponLoaded = true;
}
public bool:check_user_item(playerid, itemid, bool:AllowExp)
{
	if(!WeaponLoaded) SilahArraylariYukle();
	if(playerid < 1 || playerid > 32) return false
	if(!is_user_alive(playerid)) return false
	if(itemid > 28 || itemid < 1) return false
	if(	AllowExp)
	{
		if(get_weapon_data(itemid, IS_WEAPON) < 1) return false
	}
	else
	{
		if(get_weapon_data(itemid, IS_WEAPON) != 1) return false
	}
	if(get_weapon_data(itemid, MAX_AMMO) <= 0) return false
	if(get_weapon_data(itemid, AMMO_OFFSET) == -1) return false
	if(!isValidWeapon(playerid, itemid)) return false
	return true
}
public bool:add_ammo_to_user(playerid, itemid, amount, bool:AllowExp, bool:AllowOver)
{
	if(!WeaponLoaded) SilahArraylariYukle();
	if(!check_user_item(playerid, itemid, AllowExp)) return false
	if(amount == 0) return false
	if(amount < 0) amount *= -1
	new GetAmmoCount = get_ammo_count_to_user(playerid, itemid)
	if(GetAmmoCount + amount > WeaponList[itemid][MAX_AMMO])
	{
		if(WeaponList[itemid][MAX_AMMO] > GetAmmoCount && !AllowOver)
		{
			amount = WeaponList[itemid][MAX_AMMO];
		}
		else
		{
			if(!AllowOver) return false;
			amount = GetAmmoCount + amount;
		}
	}
	else
	{
		amount = GetAmmoCount + amount;
	}
	set_pdata_int ( playerid, get_weapon_data(itemid, AMMO_OFFSET), amount) 
	return true
}
public bool:remove_ammo_to_user(playerid, itemid, amount, bool:AllowExp)
{	
	if(!WeaponLoaded) SilahArraylariYukle();
	if(!check_user_item(playerid, itemid, AllowExp)) return false
	if(amount == 0) return false
	if(amount < 0) amount *= -1
	new GetAmmoCount = get_ammo_count_to_user(playerid, itemid)
	if(GetAmmoCount - amount < 0)
	{
		amount = 0
	}
	else
	{
		amount = GetAmmoCount - amount
	}
	set_pdata_int ( playerid, get_weapon_data(itemid, AMMO_OFFSET), amount) 
	return true
}
public get_ammo_count_to_user(playerid, itemid)
{
	if(!WeaponLoaded) SilahArraylariYukle();
	if(!check_user_item(playerid, itemid, true)) return -1
	return get_pdata_int ( playerid, get_weapon_data(itemid, AMMO_OFFSET)) 
}
public bool:CheckAmmoOffset(OffsetList[], ammo_offset, len)
{
	for(new g = 0; g < len; g++)
	{
		if(OffsetList[g] == ammo_offset)
		{
			return false;
		}
	}
	return true;
}