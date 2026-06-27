/// group classification
{
	/// skip dead groups
	if (count units _x == 0) then {
	
		if (AIX_DEBUG) then {
			diag_log format ["%1, %2", "AIX groupsAI.sqf skipped group: ", str _x];
		};	
		continue
	};
	private _grp = _x;
	private _ldr = leader _x;
	private _veh = assignedVehicle _ldr;
	private _cfg = configFile >> "CfgVehicles" >> typeOf _veh;
	private _sim = toLower (getText (_cfg >> "simulation"));
	private _art = getNumber (_cfg >> "artilleryScanner");
	
	private _log = getNumber (_cfg >> "transportRepair") + getNumber (_cfg >> "transportAmmo") + getNumber (_cfg >> "transportFuel") + getNumber (_cfg >> "attendant");
	private _tra = _veh emptyPositions "Cargo";
	private _uni = count units _grp;
	private _vhs = count ([_grp, false] call BIS_fnc_groupVehicles);
	private _drv = getNumber (_cfg >> "hasDriver");
	
	private _aaa = getText (_cfg >> "editorSubcategory") == "EdSubcat_AAs";
	private _uav = getText (_cfg >> "editorSubcategory") == "EdSubcat_Drones";
	private _apc = getText (_cfg >> "editorSubcategory") == "EdSubcat_APCs";
	private _amb = getNumber (_cfg >> "canSwim");

	/// find how many AT group has/how many vehicles
	private _hat = 0;
	{
		private _cfg2 = configFile >> "CfgVehicles" >> typeOf vehicle _x;
		private _hat2 = getText (_cfg2 >> "icon") == "iconManAT";
		if (_hat2) then {_hat = _hat + 1};
	}forEach units _grp;

	private _sup = false;
	private _cat = "recon"; ///Light INF								  atk,def,rec,sup
																	_val = 0, _atk = 0, _rec = 1;  /// INF
	if (_hat > 0) then {_cat = "inf", 								_val = 1, _atk = 1, _rec = 1}; /// INF LAT
	if (_hat > 1) then {_cat = "service", 							_val = 2, _atk = 2, _rec = 1}; /// INF HAT
	
	if (_sim == "carx") then {_cat = "motor_inf", 					_val = 2, _atk = 2, _rec = 2}; /// AFV
	if (_sim == "carx" && _uni == 1) then {_cat = "unknown", 		_val = 0, _atk = 0, _rec = 0, _sup = true}; /// Transport
	
	if (_sim == "tankx") then {_cat = "armor", 						_val = 4, _atk = 4, _rec = 1}; /// MBT
	if (_sim == "tankx" && _apc) then {_cat = "mech_inf",			_val = 3, _atk = 3, _rec = 1}; /// IFV
	
	if (_sim == "tankx" && _drv == 0) then {_cat = "installation", 	_val = 1, _atk = 0, _rec = 0, _sup = true}; /// Turret
	if (_aaa) then {_cat = "antiair", 								_val = 3, _atk = 2, _rec = 1, _sup = true}; /// Anti-air
	
	if (_sim in ["airplanex", "airplane"]) then {_cat = "plane", 	_val = 4, _atk = 4, _rec = 2, _sup = true}; /// Fixed wing
	if (_sim == "helicopterrtd") then {_cat = "air", 				_val = 3, _atk = 2, _rec = 2, _sup = true}; /// Rotary wing
	if (_uav) then {_cat = "uav", 									_val = 2, _atk = 1, _rec = 3, _sup = true}; /// Drone
	
	if (_art == 1) then {_cat = "art", 								_val = 4, _atk = 0, _rec = 0, _sup = true}; /// SPG
	if (_art == 1 && _drv == 0) then {_cat = "mortar", 				_val = 3, _atk = 0, _rec = 0, _sup = true}; /// Mortar/Arty
	if (_sim != "soldier" && _log > 0) then {_cat = "support", 		_val = 1, _atk = 0, _rec = 0, _sup = true}; /// Support
	if (_sim in ["shipx","submarinex"]) then {_cat = "naval", 		_val = 2, _atk = 2, _rec = 2, _sup = true}; /// Boats
	
	_val = _val * (_vhs max 1);
	_val = _val + (_uni * 0.1);
	_grp setVariable ["AIX_CAT", _cat, true];
	_grp setVariable ["AIX_VAL", _val, true];
	_grp setVariable ["AIX_SUP", _sup, true];
	_grp setVariable ["AIX_ATK", _atk, true];
	_grp setVariable ["AIX_REC", _rec, true];
	
	if (AIX_DEBUG) then {
		private _side = "n_";
		if (side _grp == AIX_BLU) then {_side = "b_"};
		if (side _grp == AIX_OPF) then {_side = "o_"};
		private _marker = _side + _cat;
		private _id = "AIX_" + _side + groupID _grp;
		_grpMarker = createMarker [_id, getPos _ldr];
		_grpMarker setMarkerType _marker;
		_grpMarker setMarkerText str _val;
	};
}forEach allGroups;

/// Sort groups into support category, save positions and force for later use
AIX_ALL_G_BLU = [];
AIX_ALL_G_OPF = [];
AIX_ENY_G_BLU = [];
AIX_SUP_G_BLU = [];
AIX_SUP_G_OPF = [];
AIX_ENY_G_OPF = [];
AIX_POS_BLU = [];
AIX_POS_OPF = [];
AIX_VAL_BLU = 0;
AIX_VAL_OPF = 0;

{
	private _grp = _x;
	private _val = _grp getVariable "AIX_VAL";
	private _sup = _grp getVariable "AIX_SUP";
	private _id = groupID _grp;
	private _side = side _grp;
	private _ldr = leader _grp;
	private _pos = getPosATL _ldr;
	if (isNil "_val") then {
		if (AIX_DEBUG) then {
			diag_log format ["%1, %2, %3", "AIX groupsAI.sqf skipped group:", _side, _id];
		};	
		continue;
	};
	
	if (side _grp == AIX_BLU) then {
		AIX_VAL_BLU = AIX_VAL_BLU + _val;
		if (_sup) then {AIX_SUP_G_BLU pushback _x} else {AIX_ALL_G_BLU pushback _grp};
		if (AIX_OPF knowsAbout _ldr > 0) then {AIX_ENY_G_OPF pushback _grp};
		AIX_POS_BLU pushback _pos;
	};
	
	if (side _grp == AIX_OPF) then {
		AIX_VAL_OPF = AIX_VAL_OPF + _val;
		if (_sup) then {AIX_SUP_G_OPF pushback _x} else {AIX_ALL_G_OPF pushback _grp};
		if (AIX_BLU knowsAbout _ldr > 0) then {AIX_ENY_G_BLU pushback _grp};
		AIX_POS_OPF pushback _pos;
	};
}forEach allGroups;

if (AIX_DEBUG) then {
	systemchat ("BLU ALL_G: " + str count AIX_ALL_G_BLU + " ENY_G " + str count AIX_ENY_G_BLU + " SUP_G " + str count AIX_SUP_G_BLU );
	systemchat ("OPF ALL_G: " + str count AIX_ALL_G_OPF + " ENY_G " + str count AIX_ENY_G_OPF + " SUP_G " + str count AIX_SUP_G_OPF );
};