/*
	By Ghostrider-GRG-

	--------------------------
	License
	--------------------------
	All the code and information provided here is provided under an Attribution Non-Commercial ShareAlike 4.0 Commons License.

	http://creativecommons.org/licenses/by-nc-sa/4.0/
*/

#include "\q\addons\custom_server\Configs\blck_defines.hpp";
if ( !(isServer) || hasInterface) exitWith{};
if !(isNil "blck_Initialized") exitWith{};
// find and set Mod
blck_modType = if (!isNull (configFile >> "CfgPatches" >> "exile_server")) then {"Exile"} else {if (!isnull (configFile >> "CfgPatches" >> "a3_epoch_server")) then {"Epoch"} else {""}};
publicVariable "blck_modType";

if ((tolower blck_modType) isEqualto "epoch") then {
	diag_log "[blckeagls] Waiting until EpochMod is ready...";
	waituntil {!isnil "EPOCH_SERVER_READY"};
	diag_log "[blckeagls] EpochMod is ready...loading blckeagls";
};
if ((toLower blck_modType) isEqualTo "exile") then
{
	diag_log "[blckeagls] Waiting until ExileMod is ready ...";
	waitUntil {!PublicServerIsLoaded};
	diag_log "[blckeagls] Exilemod is ready...loading blckeagls";	
};

private _blck_loadingStartTime = diag_tickTime;
#include "\q\addons\custom_server\init\build.sqf";
diag_log format["[blckeagls] Loading Server Mission System"];

// compile functions
call compileFinal preprocessFileLineNumbers "\q\addons\custom_server\Compiles\blck_functions.sqf";
diag_log format["[blckeagls] functions compiled"];

call compile preprocessfilelinenumbers "\q\addons\custom_server\Configs\blck_configs.sqf";
waitUntil{(!isNil "blck_useHC") && (!isNil "blck_simulationManager") && (!isNil "blck_debugOn")};
diag_log format["[blckeagls] blck_useHC = %1 | 	blck_simulationManager = %2 ",blck_useHC,blck_simulationManager];
diag_log format["[blckeagls] debug mode settings:blck_debugON = %1 blck_debugLevel = %2",blck_debugON,blck_debugLevel];

// Load any user-defined specifications or overrides
call compileFinal preprocessFileLineNumbers "\q\addons\custom_server\Configs\blck_custom_config.sqf";
//diag_log format["[blckeagls]  configurations loaded at %1",diag_tickTime];

call compileFinal preprocessFileLineNumbers "\q\addons\custom_server\Compiles\blck_variables.sqf";

uiSleep 15;

if (blck_simulationManager == 2) then 
{
	"Group" setDynamicSimulationDistance 1800;
	enableDynamicSimulationSystem true;
};

// spawn map addons to give the server time to position them before spawning in crates etc.
if (blck_spawnMapAddons) then
{
	call compileFinal preprocessFileLineNumbers "\q\addons\custom_server\MapAddons\MapAddons_init.sqf";
}else{
	diag_log "[blckeagls] Map Addons disabled";
};


// find and set Mapcenter and size
diag_log "[blckeagls] Loading Map-specific information";
call compileFinal preprocessFileLineNumbers "\q\addons\custom_server\init\GMS_fnc_findWorld.sqf";

// set up the lists of available missions for each mission category
//diag_log "[blckeagls] Loading Mission Lists";
#include "\q\addons\custom_server\Missions\GMS_missionLists.sqf";
diag_log "[blckeagls] Mission Lists Loaded Successfully";

call compile preprocessfilelinenumbers "\q\addons\custom_server\Missions\Static\GMS_StaticMissions_init.sqf";
call compile preprocessfilelinenumbers "q\addons\custom_server\Missions\UMS\GMS_UMS_init.sqf";  // loads functions and spawns any static missions.
diag_log "[blckeagls] blck_init_server: ->> Static and UMS systems initialized.";

switch (blck_simulationManager) do
{
	case 2: {diag_log "[blckeagls] dynamic simulation manager enabled"}; 
	case 1: {diag_log "[blckeagls] blckeagls simulation manager enabled"};
	case 0: {diag_log "[blckeagls] simulation management disabled"};
};

diag_log format["[blckeagls] version %1 Build %2 Loaded in %3 seconds",blck_versionNumber,blck_buildNumber,diag_tickTime - _blck_loadingStartTime]; //,blck_modType];
diag_log format["[blckeagls] waiting for players to join ----    >>>>"];

if ( !(blck_debugON) && (blck_debugLevel isEqualTo 0)) then
{
	waitUntil{{isPlayer _x}count allPlayers > 0};
	diag_log "[blckeagls] Player Connected, spawning missions";
} else {
	diag_log "[blckeagls] Debug mode ON, proceding without players";
};

if (blck_spawnStaticLootCrates) then
{
	call compile preprocessfilelinenumbers "\q\addons\custom_server\SLS\SLS_init.sqf";
	diag_log "[blckeagls] SLS::  -- >>  Static Loot Spawner Done";
}else{
	diag_log "[blckeagls] SLS::  -- >>  Static Loot Spawner disabled";
};

if (blck_blacklistTraderCities) then
{
	call compile preprocessfilelinenumbers "\q\addons\custom_server\init\GMS_fnc_getTraderCites.sqf";
};

if (blck_ai_offload_to_client) then 
{
	if (blck_useHC) then 
	{
		blck_useHC = false;
		diag_log "[blckeagls] <WARNING> blck_useHC has been diabled to allow offloading to clients";
	};
	// Broadcast some code to clients
	publicVariable "blck_fnc_setNextWaypoint";
	publicVariable "blck_EH_unitWeaponReloaded";
	publicVariable "blck_EH_AIfiredNear";
	publicVariable "blck_fnc_processAIfiredNear";
	publicVariable "blck_EH_vehicleGetOut";
	publicVariable "blck_fnc_handleVehicleGetOut";
	publicVariable "blck_EH_vehicleManGetOut";
	publicVariable "blck_fnc_checkForEmptyVehicle";
	publicVariable "blck_fnc_handleEmptyVehicle";
	publicVariable "blck_fnc_unlockVehicle";
	publicVariable "blck_EH_AIKilled";
	publicVariable "blck_fnc_processAIKill";
};

//Start the mission timers
if (blck_enableOrangeMissions > 0) then
{
	//[_missionListOrange,_pathOrange,"OrangeMarker","orange",blck_TMin_Orange,blck_TMax_Orange] spawn blck_fnc_missionTimer;//Starts major mission system (Orange Map Markers)
	[_missionListOrange,_pathOrange,"OrangeMarker","orange",blck_TMin_Orange,blck_TMax_Orange,blck_enableOrangeMissions] call blck_fnc_addMissionToQue;
};
if (blck_enableGreenMissions > 0) then
{
	//[_missionListGreen,_pathGreen,"GreenMarker","green",blck_TMin_Green,blck_TMax_Green] spawn blck_fnc_missionTimer;//Starts major mission system 2 (Green Map Markers)
	[_missionListGreen,_pathGreen,"GreenMarker","green",blck_TMin_Green,blck_TMax_Green,blck_enableGreenMissions] call blck_fnc_addMissionToQue;
};
if (blck_enableRedMissions > 0) then
{
	//[_missionListRed,_pathRed,"RedMarker","red",blck_TMin_Red,blck_TMax_Red] spawn blck_fnc_missionTimer;//Starts minor mission system (Red Map Markers)//Starts minor mission system 2 (Red Map Markers)
	[_missionListRed,_pathRed,"RedMarker","red",blck_TMin_Red,blck_TMax_Red,blck_enableRedMissions] call blck_fnc_addMissionToQue;
};
if (blck_enableBlueMissions > 0) then
{
	//[_missionListBlue,_pathBlue,"BlueMarker","blue",blck_TMin_Blue,blck_TMax_Blue] spawn blck_fnc_missionTimer;//Starts minor mission system (Blue Map Markers)
	[_missionListBlue,_pathBlue,"BlueMarker","blue",blck_TMin_Blue,blck_TMax_Blue,blck_enableBlueMissions] call blck_fnc_addMissionToQue;
};
// Setup a group for AI corpses
// params[["_side",blck_AI_Side],["_deleteWhenEmpty",true]];
blck_graveyardGroup = createGroup [blck_AI_Side,false];
blck_graveyardGroup setGroupId ["blck_graveyard"];
blck_graveyardGroup setVariable ["blck_group",1];

//  start the main thread for the mission system which monitors missions running and stuff to be cleaned up
[] spawn blck_fnc_mainThread;
blck_pvs_version = blck_versionNumber;
publicVariable "blck_pvs_version";
diag_log "[blckeagls] < MISSION SYSTEM FULLY INITIALIZED AND RUNNING >";
