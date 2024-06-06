//-----------
// [ZL] NoRoundEnd (Amxx)
// +SupportBot
//
// http://vk.com/zombielite
// Telegram: @zombielite

#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >

#define NAME 			"[ZL] NoRoundEnd (Amxx)"
#define VERSION			"1.0"
#define AUTHOR			"Alexander.3"

#define DEADMSG			// Support dead message

new const NameOberon[] =		"OberonBoss"
new const NameAlien[] =		"AlienBoss"
new const NameRevenant[] =	"RevenantBoss"
new const NameApache[] =		"ApacheBoss"

new const NameCt[] =		"Defender"

native zl_boss_map()
native cs_set_user_team(index, team)

static BotBoss

public plugin_init() {
	register_plugin(NAME, VERSION, AUTHOR)
	
	if (!zl_boss_map()) {
		pause("ad")
		return
	}
	
	register_logevent("RoundStart", 2, "1=Round_Start")
	#if defined DEADMSG
	if (zl_boss_map() && zl_boss_map() != 3)
		RegisterHam(Ham_Killed, "player", "Hook_Killed", 1)
		
	set_msg_block(get_user_msgid("DeathMsg"), BLOCK_SET)
	#endif
}

public RoundStart() {
	switch (zl_boss_map()) {
		case 1: BotBoss = engfunc(EngFunc_CreateFakeClient, NameOberon)
		case 2: BotBoss = engfunc(EngFunc_CreateFakeClient, NameAlien)
		case 4: BotBoss = engfunc(EngFunc_CreateFakeClient, NameRevenant)
		case 5: BotBoss = engfunc(EngFunc_CreateFakeClient, NameApache)
	}
	
	if (BotBoss) {
		dllfunc(MetaFunc_CallGameEntity, "player", BotBoss)
		cs_set_user_team(BotBoss, 1)
		set_user_info(BotBoss, "*bot", "1")
	}
	
	new BotCt = engfunc(EngFunc_CreateFakeClient, NameCt)
	
	if (BotCt) {
		dllfunc(MetaFunc_CallGameEntity, "player", BotCt)
		cs_set_user_team(BotCt, 2)
		dllfunc(DLLFunc_Spawn, BotCt)
		switch (zl_boss_map()) { // Origin/Angle for spectating
			case 1: { // Oberon
				engfunc(EngFunc_SetOrigin, BotCt, Float:{558.610290, 706.489685, 884.939758})
				set_pev(BotCt, pev_angles, Float:{-4.725952, -132.758789, 0.000000})
			}
			case 2: { // Alien ( Not Complete )
				engfunc(EngFunc_SetOrigin, BotCt, Float:{8192.0,8192.0,8192.0})
				//set_pev(BotCt, pev_angles, Float:{-4.725952, -132.758789, 0.000000})
			}
			case 3: { // Angra ( Not Complete )
				engfunc(EngFunc_SetOrigin, BotCt, Float:{8192.0,8192.0,8192.0})
				//set_pev(BotCt, pev_angles, Float:{-4.725952, -132.758789, 0.000000})
			}
			case 4: { // Revenant ( Not Complete )
				engfunc(EngFunc_SetOrigin, BotCt, Float:{8192.0,8192.0,8192.0})
				//set_pev(BotCt, pev_angles, Float:{-4.725952, -132.758789, 0.000000})
			}
			case 5: { // Apache ( Not Complete )
				engfunc(EngFunc_SetOrigin, BotCt, Float:{8192.0,8192.0,8192.0})
				//set_pev(BotCt, pev_angles, Float:{-4.725952, -132.758789, 0.000000})
			}
		}
		set_pev(BotCt, pev_effects, pev(BotCt, pev_effects) & ~EF_NODRAW) 
		set_user_info(BotCt, "*bot", "1")
	}
}

#if defined DEADMSG
public Hook_Killed(victim, attacker, corpse)
	make_deathmsg(BotBoss, victim, 0, "knife")
#endif
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
