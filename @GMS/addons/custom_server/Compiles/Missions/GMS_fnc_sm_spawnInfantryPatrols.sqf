/*
	GMS_fnc_sm_spawnInfantryPatrols
	
	by Ghostrider [GRG]
	for ghostridergaming
	12/5/17
	--------------------------
	License
	--------------------------
	All the code and information provided here is provided under an Attribution Non-Commercial ShareAlike 4.0 Commons License.

	http://creativecommons.org/licenses/by-nc-sa/4.0/	
*/
#include "\q\addons\custom_server\Configs\blck_defines.hpp";
//  TODO: Used?
//  	params["_coords",["_minNoAI",3],["_maxNoAI",6],["_aiDifficultyLevel","red"],["_uniforms",blck_SkinList],["_headGear",blck_BanditHeadgear]];
params["_patrols","_coords",["_minNoAI",3],["_maxNoAI",6],["_aiDifficultyLevel","red"]];
private ["_weaponList","_sideArms","_uniforms","_headgear","_vests","_backpacks"];

_weaponList = [_aiDifficultyLevel] call blck_fnc_selectAILoadout;
_sideArms 	= [_aiDifficultyLevel] call blck_fnc_selectAISidearms;
_uniforms 	= [_aiDifficultyLevel] call blck_fnc_selectAIUniforms;
_headGear 	= [_aiDifficultyLevel] call blck_fnc_selectAIHeadgear;
_vests 		= [_aiDifficultyLevel] call blck_fnc_selectAIVests;
_backpacks 	= [_aiDifficultyLevel] call blck_fnc_selectAIBackpacks;

if (_patrols isEqualTo []) then 
{
	// Use the random spawn logic from the regular dyanmic mission system.
	//params[_coords,"_maxNoAI,_missionGroups,_aiDifficultyLevel,_uniforms,_headGear,_vests,_backpacks,_weapons,sideArms,_isScubaGroup];
	[_coords,_minNoAI,_maxNoAI,_aiDifficultyLevel,_uniforms,_headGear,_vests,_backpacks,_weaponList,_sidearms,false] call blck_fnc_spawnMissionAI;
} else {
	{
		//diag_log format["_sm_spawnInfantryPatrols.sqf:: _x = %1",_x];
		// Use the pre-defined spawn positions and other parameters for each group.
		//  [[22819.4,16929.5,5.33892],"red",4, 75]
		_x params ["_pos","_difficulty","_noAI","_patrolRadius"];
		private _group = [blck_AI_Side,true]  call blck_fnc_createGroup;
		// params[["_group","Error"],"_pos",  "_center", ["_numai1",5],  ["_numai2",10],  ["_skillLevel","red"], ["_minDist",30], ["_maxDist",45],["_configureWaypoints",true], ["_uniforms",[]], ["_headGear",[]],["_vests",[]],["_backpacks",[]],
		// ["_weaponList",[]],["_sideArms",[]], ["_scuba",false],["_patrolRadius",30]];
		#define setupWaypoints true
		if !(isNull _group) then 
		{
			[_group,_pos,_pos,_noAI,_noAI,_difficulty,_patrolRadius - 2,_patrolRadius,setupWaypoints,_uniforms,_headGear,_vests,_backpacks,_weaponList,_sideArms,_scuba,_patrolRadius] call blck_fnc_spawnGroup;
			blck_monitoredMissionAIGroups pushback _group;			
		};
	}forEach _patrols;
};

