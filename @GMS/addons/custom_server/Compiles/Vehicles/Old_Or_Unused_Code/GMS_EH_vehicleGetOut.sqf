/*
	_EH_vehicleGetOut
	By Ghostrider [GRG]
	Handles the case where a unit gets out of a vehiclet.
	// TODO: Not presently used
	--------------------------
	License
	--------------------------
	All the code and information provided here is provided under an Attribution Non-Commercial ShareAlike 4.0 Commons License.

	http://creativecommons.org/licenses/by-nc-sa/4.0/
*/
//diag_log format["_EH_vehicleGetOut: _this = %1",_this];
// params ["_vehicle", "_role", "_unit", "_turret"];
#define affectedvehicle (_this select 0)
if (isServer || local affectedvehicle) then {affectedvehicle call blck_fnc_handleVehicleGetOut};




