//-----------
// [ZL] CvarSystem
//
// http://vk.com/zombielite
// Telegram: @zombielite

#include < amxmodx >

#define NAME 			"[ZL] CvarSystem"
#define VERSION			"1.0"
#define AUTHOR			"Alexander.3"

native zl_boss_map()

public plugin_init() {
	register_plugin(NAME, VERSION, AUTHOR)
	
	set_task(5.0, "ChangeCvars")
}

public ChangeCvars() {
	if (zl_boss_map()) {
		set_cvar_num("sv_noroundend", 1)
		//set_cvar_string("zp_lighting", "z")
	} else {
		set_cvar_num("sv_noroundend", 0)
		//set_cvar_string("zp_lighting", "a")
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
