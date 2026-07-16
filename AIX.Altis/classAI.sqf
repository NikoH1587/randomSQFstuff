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

																	/// 0 - cannot do - 1 can do - 2 can do well
	_cat = "recon",													_val = 0.5, _sup = false;  /// INF
	if (_hat > 0) then {_cat = "inf", 								_val = 1}; /// INF LAT
	if (_hat > 1) then {_cat = "service", 							_val = 2}; /// INF HAT
	
	if (_sim == "carx") then {_cat = "motor_inf", 					_val = 2}; /// AFV
	if (_sim == "carx" && _uni == 1) then {_cat = "unknown", 		_val = 1, _sup = true}; /// Transport
	
	if (_sim == "tankx") then {_cat = "armor", 						_val = 4}; /// MBT
	if (_sim == "tankx" && _apc) then {_cat = "mech_inf",			_val = 3}; /// IFV
	
	if (_sim == "tankx" && _drv == 0) then {_cat = "installation", 	_val = 1, _sup = true}; /// Turret
	if (_aaa) then {_cat = "antiair", 								_val = 3, _sup = true}; /// Anti-air
	
	if (_sim in ["airplanex", "airplane"]) then {_cat = "plane", 	_val = 4, _sup = true}; /// Fixed wing
	if (_sim == "helicopterrtd") then {_cat = "air", 				_val = 3, _sup = true}; /// Rotary wing
	if (_uav) then {_cat = "uav", 									_val = 2, _sup = true}; /// Drone
	
	if (_art == 1) then {_cat = "art", 								_val = 4, _sup = true}; /// SPG
	if (_art == 1 && _drv == 0) then {_cat = "mortar", 				_val = 3, _sup = true}; /// Mortar/Arty
	if (_sim != "soldier" && _log > 0) then {_cat = "support", 		_val = 1, _sup = true}; /// Support
	if (_sim in ["shipx","submarinex"]) then {_cat = "naval", 		_val = 2, _sup = true}; /// Boats
	
	if (_ldr == CMD_BLU or _ldr == CMD_OPF) then {_cat = "hq",		_val = 0, _sup = true}; /// HQ
	
	if (_vhs > 0) then {_val = _val * _vhs};
	///_val = _val + (0.1 * _uni);

	_grp setVariable ["AIX_CAT", _cat, true];
	_grp setVariable ["AIX_VAL", _val, true];
	_grp setVariable ["AIX_SUP", _sup, true];
	
	if (AIX_DEBUG) then {
		private _side = "n_";
		if (side _grp == AIX_BLU) then {_side = "b_"};
		if (side _grp == AIX_OPF) then {_side = "o_"};
		private _marker = _side + _cat;
		private _id = "AIX_" + _side + groupID _grp;
		_grpMarker = createMarker [_id, getPos _ldr];
		_id setMarkerPos getPosASL _ldr;
		_id setMarkerType _marker;
		_id setMarkerText str _val;
		_id setMarkerSize [0.75, 0.75];
	};
}forEach allGroups;

/// Grid classification
/// 0 - unknown, 1 - captured, 2 - contested
/// -1 Enemy, 0 Unknown, 1 Blu
/// TODO: Old info decaus over time, evey cycle -+0.1 towards 0
{
	private _pos = _x select 0;
	private _size = _x select 1;
	private _blu = _x select 2;
	private _opf = _x select 3;
	private _isBLU = false;
	private _isOPF = false;
	private _isBLUeny = false;
	private _isOPFeny = false;
	
	{
		private _grp = _x;
		private _ldr = leader _x;
		private _side = side _grp;
		private _posG = getPosASL _ldr;
		private _posG = [_posG select 0, _posG select 1];
		private _isClose = _pos distance _posG < AIX_SIZE;
		private _isGblu = _side == AIX_BLU;
		private _isGopf = _side == AIX_OPF;
		if (_isClose && _isGblu) then {_isBLU = true};
		if (_isClose && _isGopf) then {_isOPF = true};
		if (_isClose && _isGopf && AIX_BLU knowsAbout vehicle _ldr > 0) then {_isBLUeny = true};
		if (_isClose && _isGblu && AIX_OPF knowsAbout vehicle _ldr > 0) then {_isOPFeny = true};
	}forEach allGroups;
	
	if (_isBLU) then {_blu = 1};
	if (_isBLUeny) then {_blu = -1};
	if (_isOPF) then {_opf = 1};
	if (_isOPFeny) then {_opf = -1};
	
	_x set [2, _blu];
	_x set [3, _opf];
	
	if (AIX_DEBUG) then {
		private _mrk = "AIX_" + str _pos;
		private _color = "default";
		if (_blu == 1) then {_color = "ColorWEST"};
		if (_opf == 1) then {_color = "ColorEAST"};
		if (_blu == 1 && _opf == 1) then {_color = "ColorWHITE"};
		if (_blu == - 1 or _opf == - 1) then {_color = "ColorCIV"};
		_mrk setMarkerColor _color;
	};
}forEach AIX_GRID;

/// Create/update side Center Of Mass

AIX_COM_BLU = [0, 0];
AIX_COM_OPF = [0, 0];
private _bluGrp = 0;
private _opfGrp = 0;

{
	private _grp = _x;
	private _ldr = leader _x;
	private _side = side _grp;
	private _val = _x getVariable "AIX_VAL";
	private _pos = getPosASL _ldr;
	private _posX = _pos select 0;
	private _posY = _pos select 1;
	
	if (_pos select 0 == 0 or isNil "_val") then {continue};
	if (_side == AIX_BLU) then {_bluGrp = _bluGrp + 1; AIX_COM_BLU = [(AIX_COM_BLU select 0) + _posX, (AIX_COM_BLU select 1) + _posY]};
	if (_side == AIX_OPF) then {_opfGrp = _opfGrp + 1; AIX_COM_OPF = [(AIX_COM_OPF select 0) + _posX, (AIX_COM_OPF select 1) + _posY]};
	
}forEach AllGroups;

AIX_COM_BLU = [(AIX_COM_BLU select 0) / _bluGrp,(AIX_COM_BLU select 1) / _bluGrp];
AIX_COM_OPF = [(AIX_COM_OPF select 0) / _opfGrp,(AIX_COM_OPF select 1) / _opfGrp];
AIX_COM_ALL = [((AIX_COM_BLU select 0) + (AIX_COM_OPF select 0)) / 2,((AIX_COM_BLU select 1) + (AIX_COM_OPF select 1)) / 2];

/// Create/Update side direction and REAR/LEFT/RIGHT positions
_offset = 1000;
AIX_DIR_BLU = AIX_COM_BLU getdir AIX_COM_OPF;
AIX_RGT_BLU = AIX_COM_BLU getPos [_offset, AIX_DIR_BLU + 90];
AIX_LFT_BLU = AIX_COM_BLU getPos [_offset, AIX_DIR_BLU - 90];
AIX_RES_BLU = AIX_COM_BLU getPos [_offset, AIX_DIR_BLU + 180];

AIX_DIR_OPF = AIX_COM_OPF getdir AIX_COM_BLU;
AIX_RGT_OPF = AIX_COM_OPF getPos [_offset, AIX_DIR_OPF + 90];
AIX_LFT_OPF = AIX_COM_OPF getPos [_offset, AIX_DIR_OPF - 90];
AIX_RES_OPF = AIX_COM_OPF getPos [_offset, AIX_DIR_OPF + 180];

AIX_RGT_ALL = AIX_COM_ALL getPos [_offset, AIX_DIR_BLU + 90];
AIX_LFT_ALL = AIX_COM_ALL getPos [_offset, AIX_DIR_BLU - 90];


if (AIX_DEBUG) then {
	createMarker ["AIX_COM_BLU", AIX_COM_BLU];
	"AIX_COM_BLU" setMarkerPos AIX_COM_BLU;
	"AIX_COM_BLU" setMarkerType "b_hq";
	"AIX_COM_BLU" setMarkerText "CENT";
	
	createMarker ["AIX_RGT_BLU", AIX_RGT_BLU];
	"AIX_RGT_BLU" setMarkerPos AIX_RGT_BLU;
	"AIX_RGT_BLU" setMarkerType "b_hq";
	"AIX_RGT_BLU" setMarkerText "RIGHT";
	"AIX_RGT_BLU" setMarkerDir 90;
	
	createMarker ["AIX_LFT_BLU", AIX_LFT_BLU];
	"AIX_LFT_BLU" setMarkerPos AIX_LFT_BLU;
	"AIX_LFT_BLU" setMarkerType "b_hq";
	"AIX_LFT_BLU" setMarkerText "LEFT";
	"AIX_LFT_BLU" setMarkerDir -90;
	
	createMarker ["AIX_RES_BLU", AIX_RES_BLU];
	"AIX_RES_BLU" setMarkerPos AIX_RES_BLU;
	"AIX_RES_BLU" setMarkerType "b_hq";
	"AIX_RES_BLU" setMarkerText "REAR";
	"AIX_RES_BLU" setMarkerDir 180;
	
	createMarker ["AIX_COM_OPF", AIX_COM_OPF];
	"AIX_COM_OPF" setMarkerPos AIX_COM_OPF;
	"AIX_COM_OPF" setMarkerType "o_hq";
	"AIX_COM_OPF" setMarkerText "CENT";
	
	createMarker ["AIX_RGT_OPF", AIX_RGT_OPF];
	"AIX_RGT_OPF" setMarkerPos AIX_RGT_OPF;
	"AIX_RGT_OPF" setMarkerType "o_hq";
	"AIX_RGT_OPF" setMarkerText "RIGHT";
	"AIX_RGT_OPF" setMarkerDir 90;
	
	createMarker ["AIX_LFT_OPF", AIX_LFT_OPF];
	"AIX_LFT_OPF" setMarkerPos AIX_LFT_OPF;
	"AIX_LFT_OPF" setMarkerType "o_hq";
	"AIX_LFT_OPF" setMarkerText "LEFT";
	"AIX_LFT_OPF" setMarkerDir -90;
	
	createMarker ["AIX_RES_OPF", AIX_RES_OPF];
	"AIX_RES_OPF" setMarkerPos AIX_RES_OPF;
	"AIX_RES_OPF" setMarkerType "o_hq";
	"AIX_RES_OPF" setMarkerText "REAR";
	"AIX_RES_OPF" setMarkerDir 180;
	
	createMarker ["AIX_COM_ALL", AIX_COM_ALL];
	"AIX_COM_ALL" setMarkerPos AIX_COM_ALL;
	"AIX_COM_ALL" setMarkerType "n_hq";
	"AIX_COM_ALL" setMarkerText "CENT";
	
	createMarker ["AIX_RGT_ALL", AIX_RGT_ALL];
	"AIX_RGT_ALL" setMarkerPos AIX_RGT_ALL;
	"AIX_RGT_ALL" setMarkerType "n_hq";
	"AIX_RGT_ALL" setMarkerText "RIGHT";
	"AIX_RGT_ALL" setMarkerDir 90;
	
	createMarker ["AIX_LFT_ALL", AIX_LFT_ALL];
	"AIX_LFT_ALL" setMarkerPos AIX_LFT_ALL;
	"AIX_LFT_ALL" setMarkerType "n_hq";
	"AIX_LFT_ALL" setMarkerText "LEFT";
	"AIX_LFT_ALL" setMarkerDir -90;
};