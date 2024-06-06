/* 
	SupplyBox
	
	http://vk.com/zombielite
	Telegram: @zombielite
*/

#include < amxmodx >
#include < engine >
#include < hamsandwich >

#define NAME 			"SupplyBox"
#define VERSION			"2.2"
#define AUTHOR			"Alexander.3"
	
new GiftMdl[] =			"models/zl/supplybox.mdl"
const GiftNum =			10
const Float:GiftRad =		250.0
const min_rewards =		1000
const max_rewards =		10000

//Color HudMessage
new const h_color[] = {
				255, // RED
				0,   // GREEN
				0    // BLUE
}

//Glow Eff.
const g_true =			2	// 0 - NoRendering, 1 - CustomColor, 2 - RandomColor
new const g_color[] = {
				255, // RED
				0,   // GREEN
				0    // BLUE
}
const g_layer =			40	// Size

#define ONEBOX

native zl_give_reward(index, num)
native zl_boss_map()
native zl_boss_valid(index)

public plugin_init() {
	register_plugin(NAME, VERSION, AUTHOR)
	
	if (!zl_boss_map()) {
		pause("ad")
		return
	}
	
	RegisterHam(Ham_Killed, "info_target", "Hook_Killed")
	register_touch("classname_gift", "player", "Hook_Touch")
	register_dictionary("zl_supplybox.txt")
}

public Hook_Touch(e, p) {
	#if defined ONEBOX
	static bool:onebox[33]
	if (onebox[p]) return
	onebox[p] = true
	#endif
	
	new r = random_num(min_rewards, max_rewards)
	
	set_hudmessage(h_color[0], h_color[1], h_color[2], 0.29, 0.59, 0, 6.0, 12.0)
	show_hudmessage(p, "%L", LANG_PLAYER, "SUPPLY_SPAWN", r)
	
	zl_give_reward(p, r)
	remove_entity(e)
}

public Hook_Killed( it ) {
	if (!zl_boss_valid( it ))
		return HAM_IGNORED
		
	new Float: Origin[3]
	entity_get_vector(it, EV_VEC_origin, Origin)
	SupplySpawn( Origin, GiftNum )
	return HAM_HANDLED
}

public native_spawn(Float:Origin[3], num) {
	param_convert(1)
	SupplySpawn(Origin, num)
}

public SupplySpawn( Float:Origin[3], num) {
	new n = num
	while (n > 0) {
		new g = zl_create_entity(
			Origin, GiftMdl, _, 0.0, 
			SOLID_TRIGGER, MOVETYPE_TOSS, DAMAGE_NO, DEAD_NO, 
			"info_target", "classname_gift", Float:{-10.0, -10.0, -1.0}, Float:{10.0, 10.0, 10.0})
		
		new Float:velocity[3]
		velocity[0] = random_float(-(GiftRad), (GiftRad))	
		velocity[1] = random_float(-(GiftRad), (GiftRad))
		velocity[2] = GiftRad
		switch(g_true) {
			case 1: set_rendering(g, kRenderFxGlowShell, g_color[0], g_color[1], g_color[2], kRenderNormal, g_layer)
			case 2: set_rendering(g, kRenderFxGlowShell, random(255), random(255), random(255), kRenderNormal, g_layer)
		}
		entity_set_vector(g, EV_VEC_velocity, velocity)
		--n
	}
}

public plugin_precache()
	precache_model(GiftMdl)

public plugin_natives()
	register_native("zl_supplybox", "native_spawn", 1)
	
stock zl_create_entity 
	(
		Float:Origin[3], 
		Model[] = "models/player/sas/sas.mdl", 
		HP = 100,
		Float:NextThink = 1.0,
		SOLID_ = SOLID_BBOX, 
		MOVETYPE_ = MOVETYPE_PUSHSTEP, 
		Float:DAMAGE_ = DAMAGE_YES, 
		DEAD_ = DEAD_NO, 
		ClassNameOld[] = "info_target", 
		ClassNameNew[] = "player_entity", 
		Float:SizeMins[3] = {-32.0, -32.0, -36.0}, 
		Float:SizeMax[3] = {32.0, 32.0, 96.0}, 
		bool:invise = false
	) {
	
	new Ent = create_entity(ClassNameOld)
	
	if (!is_valid_ent(Ent))
		return 0
	
	entity_set_model(Ent, Model)
	entity_set_size(Ent, SizeMins, SizeMax)
	entity_set_origin(Ent, Origin)
	if (NextThink > 0.0) entity_set_float(Ent, EV_FL_nextthink, get_gametime() + NextThink)
	if (invise) entity_set_int(Ent, EV_INT_effects, entity_get_int(Ent, EV_INT_effects) & ~EF_NODRAW)
	entity_set_string(Ent, EV_SZ_classname, ClassNameNew)
	entity_set_int(Ent, EV_INT_solid, SOLID_)
	entity_set_int(Ent, EV_INT_movetype, MOVETYPE_)
	entity_set_int(Ent, EV_INT_deadflag, DEAD_)
	entity_set_float(Ent, EV_FL_dmg_take, DAMAGE_)
	entity_set_float(Ent, EV_FL_max_health, float(HP))
	entity_set_float(Ent, EV_FL_health, float(HP))
	
	return Ent
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
