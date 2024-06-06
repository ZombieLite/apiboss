/* 
	SpawnSystem
	
	http://vk.com/zombielite
	Telegram: @zombielite
*/

#include < amxmodx >
#include < hamsandwich >
#include < fakemeta >

#define NAME 			"[ZL] SpawnSystem"
#define VERSION			"1.5"
#define AUTHOR			"Alexander.3"

#define RESPAWN

const human_hp =		200
#if defined RESPAWN
const RespawnNum =		5
const RespawnTime =		15

static bool:buffResp[33]
static idRespTime[33]
#endif
static bool:idRespawn[33]
native zl_boss_map()
native zl_player_alive()

#if defined RESPAWN
forward zl_timer(timer, prepare)
static g_MaxPlayers
#endif

public plugin_init() {
	register_plugin(NAME, VERSION, AUTHOR)
	
	if (!zl_boss_map()) {
		pause("ad")
		return
	}	
	RegisterHam(Ham_Spawn, "player", "Hook_Spawn", 1)
	#if defined RESPAWN
	RegisterHam(Ham_Killed, "player", "Hook_Killed", 1)
	#endif
	register_dictionary("zl_spawnsystem.txt")
	
	#if defined RESPAWN
	g_MaxPlayers = get_maxplayers()
	#endif
}

public Hook_Spawn(id) {
	if (!is_user_connected(id) || is_user_bot(id))
		return HAM_IGNORED
			
	set_pev(id, pev_health, float(human_hp))
	idRespawn[id] = true
	return HAM_HANDLED
}

#if defined RESPAWN
public Hook_Killed(victim, attacker, corpse) {
	if (!is_user_connected(victim) || !(0 < victim <= 32))
		return HAM_IGNORED
				
	static Respawn[33], a[33]
	
	a[victim] = RespawnNum - Respawn[victim]
	
	if (!a[victim]) {
		client_print(victim, print_center, "%L", LANG_PLAYER, "RESP_END")
		return HAM_IGNORED
	}
	idRespTime[victim] = RespawnTime
	
	client_print(victim, print_chat, "%L", LANG_PLAYER, "RESP_NUM", a[victim] - 1)
	Respawn[victim]++
	buffResp[victim] = true
	return HAM_IGNORED
}

public zl_timer(t, p) {
	new id = 1
	for(id = 1; id <= g_MaxPlayers; id++) {
		if (is_user_alive(id) || is_user_bot(id))
			continue
		
		if (!idRespawn[id] || !buffResp[id])
			continue
		
		if (!idRespTime[id]) {
			idRespawn[id] = false
			buffResp[id] = false
			ExecuteHam(Ham_CS_RoundRespawn, id)
			continue
		}
		client_print(id, print_center, "%L", LANG_PLAYER, "RESP_ACTIVE", idRespTime[id])
		idRespTime[id]--
	}
}
#endif