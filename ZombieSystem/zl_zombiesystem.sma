/* 
	ZombieSystem
	
	http://vk.com/zombielite
	Telegram: @zombielite
*/

#include < amxmodx >
#include < engine >
#include < hamsandwich >
#include < fakemeta >
#include < xs >

#define NAME 			"[API] ZombieSystem"
#define VERSION			"2.1"
#define AUTHOR			"Alexander.3"

/*-----------*/
// SETTING
/*-----------*/
//#define SUPPLYBOX
const Float:time_delete =	5.0
const zombie_blood = 		83
new ZombieMdl[][] = {
	"models/zl/npc/zombie/classic.mdl",	// 0	
	"models/zl/npc/zombie/big.mdl",
	"models/zl/npc/zombie/fast.mdl",
	"models/zl/npc/zombie/healer.mdl",
	"models/zl/npc/zombie/siren.mdl",
	"models/zl/npc/zombie/spider.mdl"	// 5
}
new const SoundList[][] = {
	"zl/npc/zombie/die1.wav",
	"zl/npc/zombie/die2.wav",
	"zl/npc/zombie/pain1.wav",
	"zl/npc/zombie/pain2.wav",
	"zl/npc/zombie/pain3.wav"
}

#if defined SUPPLYBOX
native zl_supplybox(Float:Origin[3], num = 1)
#endif
native zl_boss_map()
native zl_player_random()
#define pev_victim			pev_euser4
#define pev_attack			pev_euser3

public plugin_init() {
	register_plugin(NAME, VERSION, AUTHOR)
	
	if (!zl_boss_map())
		return
	
	RegisterHam(Ham_Killed, "info_target", "Hook_Killed")
	RegisterHam(Ham_BloodColor, "info_target", "Hook_Blood")
	
	register_think("classname_zombie", "npc_think")
	register_touch("classname_zombie", "player", "npc_touch")
}

public npc_think( e ) {
	if (!pev_valid( e ))
		return
		
	if (pev(e, pev_deadflag) == DEAD_DYING) {
		engfunc(EngFunc_RemoveEntity, e)
		return
	}
	
	if (pev(e, pev_attack)) {
		set_pev(e, pev_movetype, MOVETYPE_PUSHSTEP)
		set_pev(e, pev_attack, 0)
				
		new name[32]
		pev(e, pev_model, name, charsmax(name))
		if(name[0] == 'm' && name[21] == 's' && name[26] == 'r')
			zl_anim(e, 4, 1.0)
		else
			zl_anim(e, 2, 1.0)
		
	}
		
	if (!is_user_alive(pev(e, pev_victim))) {
		set_pev(e, pev_victim, zl_player_random())
		set_pev(e, pev_nextthink, get_gametime() + 0.1)
		return
	}
	
	static Float:velocity[3], Float:angle[3], Float:speed = 250.0
	pev(e, pev_fuser4, speed)
	zl_move(e, pev(e, pev_victim), Float:speed, Float:velocity, Float:angle)
	
	set_pev(e, pev_velocity, velocity)
	set_pev(e, pev_angles, angle)
	
	set_pev(e, pev_nextthink, get_gametime() + 0.1)
}

public npc_touch( e, p ) {
	if (!pev_valid( e ))
		return
		
	if (is_user_alive(p) != pev(e, pev_victim))
		set_pev(e, pev_victim, p)
	
	if (pev(e, pev_attack))
		return
	
	set_pev(e, pev_nextthink, get_gametime() + 1.0)
	set_pev(e, pev_movetype, MOVETYPE_NONE)
	set_pev(e, pev_attack, 1)
	zl_damage(p, pev(e, pev_button), 0)
	new name[32]
	pev(e, pev_model, name, charsmax(name))
	if(name[0] == 'm' && name[21] == 's' && name[26] == 'r')
		zl_anim(e, 11, 1.0)
	else
		zl_anim(e, 3, 1.0)
}

public Hook_Killed( v, a ) {
	if (!native_zl_zombie_valid(v))
		return HAM_IGNORED
	
	#if defined SUPPLYBOX
	new Float:Origin[3]
	pev(v, pev_origin, Origin)
	zl_supplybox(Origin)
	#endif
	
	engfunc(EngFunc_EmitSound, v, CHAN_VOICE, SoundList[random(2)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	set_pev(v, pev_solid, SOLID_NOT)
	set_pev(v, pev_movetype, MOVETYPE_NONE)
	set_pev(v, pev_deadflag, DEAD_DYING)
	new name[32]
	pev(v, pev_model, name, charsmax(name))
	if(name[0] == 'm' && name[21] == 's' && name[26] == 'r') {
		set_pev(v, pev_nextthink, get_gametime() + 0.1)
		zl_anim(v, 0, 1.0)
	 } else {
	 	set_pev(v, pev_nextthink, get_gametime() + time_delete)
		zl_anim(v, 6, 1.0)
	}
	return HAM_SUPERCEDE
}

public Hook_Blood( e ) {
	if (!native_zl_zombie_valid( e ))
		return HAM_IGNORED
	
	engfunc(EngFunc_EmitSound, e, CHAN_VOICE, SoundList[random_num(2, 4)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	SetHamReturnInteger(zombie_blood)
	return HAM_SUPERCEDE
}

public native_zl_zombie_create(Float:Origin[3], Health, speed, dmg) {
	param_convert(1)
	
	new e = create_entity("info_target")
	engfunc(EngFunc_SetOrigin, e, Origin)
	engfunc(EngFunc_SetModel, e, ZombieMdl[ (zl_boss_map() == 7) ? 5 : random(5)])
	engfunc(EngFunc_SetSize, e, Float:{-32.0, -32.0, -36.0}, Float:{32.0, 32.0, 32.0})
	set_pev(e, pev_movetype, MOVETYPE_PUSHSTEP)
	set_pev(e, pev_solid, SOLID_BBOX)
	set_pev(e, pev_takedamage, DAMAGE_YES)
	set_pev(e, pev_deadflag, DEAD_NO)
	set_pev(e, pev_classname, "classname_zombie")
	set_pev(e, pev_nextthink, get_gametime() + 1.0)
	set_pev(e, pev_max_health, float(Health))
	set_pev(e, pev_health, float(Health))
	
			
	set_pev(e, pev_fuser4, float(speed))
	set_pev(e, pev_button, dmg)
	new name[32]
	pev(e, pev_model, name, charsmax(name))
	if(name[0] == 'm' && name[21] == 's' && name[26] == 'r')
		zl_anim(e, 4, 2.0)
	else
		zl_anim(e, 2, 1.0)
	
	return e
}

public native_zl_zombie_valid(index) {
	/* Return: 
		1 = Valid Zombie Entity
		0 = InValid Zombie Entity
		2 = DeadZombie ( ValidEntity )
	*/
	
	if (!pev_valid(index))
		return 0
	
	static ClassName[64]
	pev(index, pev_classname, ClassName, charsmax(ClassName))
	
	if (equal(ClassName, "classname_zombie" )) {
		if (pev(index, pev_deadflag) == DEAD_DYING)
			return 2
		return 1
	}	
	return 0
}

public native_zl_zombie_count() {
	new n = 0, e = -1
	while ( (e = engfunc(EngFunc_FindEntityByString, e, "classname", "classname_zombie")) )
		n++
	return n
}

public plugin_natives() {
	register_native("zl_zombie_create", "native_zl_zombie_create", 1)
	register_native("zl_zombie_valid", "native_zl_zombie_valid", 1)
	register_native("zl_zombie_count", "native_zl_zombie_count")
}

public plugin_precache() {
	if (!zl_boss_map())
		return
		
	new i
	for (i = 0; i < sizeof ZombieMdl; ++i)
		precache_model(ZombieMdl[i])
	
	for (i = 0; i < sizeof SoundList; ++i)
		precache_sound(SoundList[i])
}

stock zl_move(Start, End, Float:speed = 250.0, Float:Velocity[] = {0.0, 0.0, 0.0}, Float:Angles[] = {0.0, 0.0, 0.0}) {
	static Float:Origin[3], Float:Origin2[3], Float:Angle[3], Float:Vector[3], Float:Len
	pev(Start, pev_origin, Origin2)
	pev(End, pev_origin, Origin)
	
	xs_vec_sub(Origin, Origin2, Vector)
	Len = xs_vec_len(Vector)
	
	vector_to_angle(Vector, Angle)
	
	Angles[0] = 0.0
	Angles[1] = Angle[1]
	Angles[2] = 0.0
	
	xs_vec_normalize(Vector, Vector)
	xs_vec_mul_scalar(Vector, speed, Velocity)
	if(Velocity[2] > 0.0)
		Velocity[2] = 0.0
	else
		Velocity[2] -= 500.0 
	
	return floatround(Len, floatround_round)
}

stock zl_damage(victim, damage, corpse) {
	if (pev(victim, pev_health) - float(damage) <= 0)
		ExecuteHamB(Ham_Killed, victim, victim, corpse ? 2 : 0)
	else
		ExecuteHamB(Ham_TakeDamage, victim, 0, victim, float(damage), DMG_BLAST)
}

stock zl_anim(ent, sequence, Float:speed) {		
	set_pev(ent, pev_sequence, sequence)
	set_pev(ent, pev_animtime, halflife_time())
	set_pev(ent, pev_framerate, speed)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
