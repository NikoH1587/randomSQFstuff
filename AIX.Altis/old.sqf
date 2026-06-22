
/// groups
for "_i" from 1 to 8 do {
	private _pos = [position _spawnBLU, 0, 500] call BIS_fnc_findSafePos;
	[_pos, west, 4 + (floor random 4)] call BIS_fnc_spawnGroup;
};

/// vehicles

for "_i" from 1 to 8 do {
	_vehs = ["B_Truck_01_covered_F", "B_APC_Wheeled_01_cannon_F", "B_APC_Tracked_01_rcws_F", "B_MBT_01_cannon_F", "B_MRAP_01_gmg_F"];
	private _veh = _vehs select floor random count _vehs;
	private _pos = [position _spawnBLU, 0, 500, 10] call BIS_fnc_findSafePos;
	[_pos, random 360, _veh, west] call BIS_fnc_spawnVehicle
};

/// groups
for "_i" from 1 to 8 do {
	private _pos = [position _spawnBLU, 0, 500] call BIS_fnc_findSafePos;
	[_pos, east, 4 + (floor random 4)] call BIS_fnc_spawnGroup;
};

/// vehicles

for "_i" from 1 to 8 do {
	_vehs = ["O_MBT_02_cannon_F", "O_APC_Tracked_02_cannon_F", "O_APC_Wheeled_02_rcws_v2_F", "O_Truck_02_covered_F", "O_MRAP_02_gmg_F"];
	private _veh = _vehs select floor random count _vehs;
	private _pos = [position _spawnBLU, 0, 500, 10] call BIS_fnc_findSafePos;
	[_pos, random 360, _veh, east] call BIS_fnc_spawnVehicle
};

	private _grp = _x;
	private _ldr = leader _x;
	///private _veh = assignedVehicle _ldr;
	private _veh = vehicle _ldr;
	private _cfg = configFile >> "CfgVehicles" >> typeOf _veh;
	private _sim = toLower (getText (_cfg >> "simulation"));
	private _art = getNumber (_cfg >> "artilleryScanner");
	
	private _cst = getNumber (_cfg >> "cost");
	private _thr = getArray (_cfg >> "threat");
	///private _inf = _thr select 0;
	///private _att = _thr select 1;
	///private _aaa = _thr select 2;
	
	private _tra = getNumber (_cfg >> "transportSoldier");
	////private _sup = getNumber (_cfg >> "attendant") + getNumber (_cfg >> "engineer") + getNumber (_cfg >> "artilleryScanner") + getNumber (_cfg >> "artilleryScanner")
	private _cat = "INF";
	if (_sim == "carx") then {_cat = "MOT"};
	if (_sim in ["planex", "plane", "helicopterrtd"]) then {_cat = "AIR"};
	if (_art == 1) then {_cat = "ART"};
	_grp setVariable ["AIX_CAT", _cat, true];
	
	AIX_BLU_FACTION = ["West", "BLU_F"];
AIX_OPF_FACTION = ["East", "OPF_F"];

"AIX_BLU" setMarkerPos ([] call BIS_fnc_randomPos);
"AIX_OPF" setMarkerPos ([] call BIS_fnc_randomPos);
private _posBLU = getMarkerPos "AIX_BLU";
private _posOPF = getMarkerPos "AIX_OPF";
private _posCNT = [(((_posBLU select 0) + (_posOPF select 0)) / 2), (((_posBLU select 1) + (_posOPF select 1)) / 2)];
private _locations = nearestLocations [_posCNT, ["NameCityCapital","NameCity", "NameVillage", "NameLocal", "Hill"], worldSize];
private _locations = _locations select [0, 5];

private _spawnBLU = ([_locations, [], {_posBLU distance _x}, "ASCEND"] call BIS_fnc_sortBy) select 0;
private _spawnOPF = ([_locations, [], {_posOPF distance _x}, "ASCEND"] call BIS_fnc_sortBy) select 0;
"AIX_BLU" setMarkerPos position _spawnBLU;
"AIX_OPF" setMarkerPos position _spawnOPF;

AIX_OBJECTIVES = [];
{
	private _pos = position _x;
	private _index = _forEachIndex;
	private _marker = createMarker [("AIX_OBJ_" + str _index), _pos];
	_marker setMarkerShape "ELLIPSE";
	_marker setMarkerSize [250, 250];
	_marker setMarkerBrush "Border";
	AIX_OBJECTIVES pushback _marker;
}forEach _locations;


AIX_GRID = []; /// [_x, _y, _type(brush), _control(0 BLK, 1 BLU, 2 OPF, 3 CIV)];
for "_col" from 0 to round(_worldSize / _cellSize) do {
    for "_row" from 0 to round(_worldSize / _cellSize) do {

        private _x = _col * _cellSize + (_cellRad);
        private _y = _row * _cellSize + (_cellRad);
		private _pos = [_x, _y];
		private _coord = str _x + str _y;

		if (_pos inArea "AIX_AO") then {
			private _isWater = surfaceIsWater _pos;
			private _isCover = count (nearestTerrainObjects [_pos, ["TREE", "ROCK"], _cellRad]) > 5;
			private _isMount = !isNull (nearestLocation [_pos, "Mount", _cellSize]);
			private _isHill = !isNull (nearestLocation [_pos, "Hill", _cellSize*2]);
			private _isObjects = count (nearestTerrainObjects [_pos, ["HOUSE", "WALL"], _cellRad]) > 5;
			
			private _brush = "Border"; /// default

			if (_isCover) then {_brush = "BDiagonal"}; /// Cover
			if (_isMount or _isHill) then {_brush = "FDiagonal"}; /// Elevation
			if (_isCover && _isMount) then {_brush = "DiagGrid"}; /// Cover2
			if (_isObjects) then {_brush = "Vertical"}; /// Hard Cover
			if (_isWater) then {_brush = "Cross"}; /// Water
			/// cover + hill (Mount locations?)
			
			AIX_GRID pushback [];
			
			if (AIX_DEBUG) then {
				private _marker = createMarker ["AIX_" + _coord, _pos];
				_marker setMarkerShape "RECTANGLE";
				_marker setMarkerSize [_cellRad, _cellRad];
				_marker setMarkerBrush _brush;
			}
		}
	};
};

/// spawn random INF
for "_i" from 1 to 16 do {
	private _pos = [getMarkerPos "AIX_BLU_SPAWN", 0, 500] call BIS_fnc_findSafePos;
	[_pos, west, 2 + floor random 8] call BIS_fnc_spawnGroup;
};

for "_i" from 1 to 16 do {
	private _pos = [getMarkerPos "AIX_OPF_SPAWN", 0, 500] call BIS_fnc_findSafePos;
	[_pos, east, 2 + floor random 8] call BIS_fnc_spawnGroup;
};


{
	private _grp = _x;
	private _cat = _grp getVariable "AIX_CAT";
	private _id = groupID _grp;
	private _side = side _grp;
	if (isNil "_cat") then {
		if (AIX_DEBUG) then {
			diag_log format ["%1, %2, %3", "AIX stratAI.sqf skipped group:", _side, _id];
		};	
		continue;
	};
	
	private _val = 0; /// SUP/STA/AMB/TRA
	
	switch _cat do {
		case "recon": {_val = 0.5};
		case "inf": {_val = 1};
		case "service": {_val = 2};
		
		case "motor_inf": {_val = 2};
		case "mech_inf": {_val = 4};
		case "armor": {_val = 6};
		
		case "air": {_val = 4};
		case "uav": {_val = 4};
		case "plane": {_val = 6};
		
		case "antiair": {_val = 4};
		case "mortar": {_val = 6};
		case "art": {_val = 8};
	};
	
	if (side _grp == AIX_BLU) then {
		_bluForce = _bluForce + _val;
	};
	
	if (side _grp == AIX_OPF) then {
		_opfForce = _opfForce + _val;
	};
}forEach allGroups;

{
	private _grp = _x;
	private _cat = _grp getVariable "AIX_CAT";
	private _side = side _grp;
	private _id = groupID _grp;

	private _tgdREC = [];
	private _tgdATK = [];
	private _tgdDEF = [];

	if (side _grp == AIX_BLU) then {
		private _tgdREC = AIX_REC_BLU;
		private _tgdATK = AIX_ATK_BLU;
		private _tgdDEF = AIX_DEF_BLU;
	};	
	
	if (isNil "_cat") then {
		if (AIX_DEBUG) then {
			diag_log format ["%1, %2, %3, %4, %5, %6,", "AIX tacAI.sqf skipped group:", _side, _id, _tgdREC, _tgdATK, _tdgDEF];
		};	
		continue;
	};
	
	private _atk = random 1;
	private _rec = random 1;
	
		switch (_cat) do {
			case "recon": {_rec = _rec + 1};
		};
	
	if (_rec > _atk) then {
		[_x, _tgdREC] call _fnc_recon;
	};
}forEach allGroups;

/// sort objectives based on type
AIX_REC_BLU = [AIX_REC_BLU, [], {_x select 2}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_DEF_BLU = [AIX_DEF_BLU, [], {_x select 2}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_ATK_BLU = [AIX_ATK_BLU, [], {_x select 2}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_CMB_BLU = [AIX_CMB_BLU, [], {_x select 2}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_REC_OPF = [AIX_REC_OPF, [], {_x select 2}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_DEF_OPF = [AIX_DEF_OPF, [], {_x select 2}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_ATK_OPF = [AIX_ATK_OPF, [], {_x select 2}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_CMB_OPF = [AIX_CMB_OPF, [], {_x select 2}, "DESCEND", {true}] call BIS_fnc_sortBy;

{
	private _grp = _x;
	private _cat = _grp getVariable "AIX_CAT";
	private _id = groupID _grp;
	private _side = side _grp;
	if (isNil "_cat") then {
		if (AIX_DEBUG) then {
			diag_log format ["%1, %2, %3", "AIX opsAI.sqf skipped group:", _side, _id];
		};	
		continue;
	};
	
	if (side _grp == AIX_BLU) then {
		switch (_cat) do {
			case "recon": {AIX_REC_G_BLU pushback _grp};
			case "motor_inf": {AIX_REC_G_BLU pushback _grp};
			case "uav": {AIX_REC_G_BLU pushback _grp};
		
			case "mech_inf": {AIX_ATK_G_BLU pushback _grp};
			case "armor": {AIX_ATK_G_BLU pushback _grp};
		
			case "inf": {AIX_DEF_G_BLU pushback _grp};
			case "service": {AIX_DEF_G_BLU pushback _grp};
			default {AIX_SUP_G_BLU pushback _grp};
		};
	};
	
	if (side _grp == AIX_OPF) then {
		switch (_cat) do {
			case "recon": {AIX_REC_G_OPF pushback _grp};
			case "motor_inf": {AIX_REC_G_OPF pushback _grp};
			case "uav": {AIX_REC_G_OPF pushback _grp};
		
			case "mech_inf": {AIX_ATK_G_OPF pushback _grp};
			case "armor": {AIX_ATK_G_OPF pushback _grp};
		
			case "inf": {AIX_DEF_G_OPF pushback _grp};
			case "service": {AIX_DEF_G_OPF pushback _grp};
			default {AIX_SUP_G_OPF pushback _grp};
		};
	};
}forEach allGroups;
/// sort based on value (most valuable gets best cover?)
AIX_REC_G_BLU = [AIX_REC_G_BLU, [], {_x getVariable "AIX_VAL"}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_ATK_G_BLU = [AIX_ATK_G_BLU, [], {_x getVariable "AIX_VAL"}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_DEF_G_BLU = [AIX_DEF_G_BLU, [], {_x getVariable "AIX_VAL"}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_SUP_G_BLU = [AIX_SUP_G_BLU, [], {_x getVariable "AIX_VAL"}, "DESCEND", {true}] call BIS_fnc_sortBy;

AIX_REC_G_OPF = [AIX_REC_G_OPF, [], {_x getVariable "AIX_VAL"}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_ATK_G_OPF = [AIX_ATK_G_OPF, [], {_x getVariable "AIX_VAL"}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_DEF_G_OPF = [AIX_DEF_G_OPF, [], {_x getVariable "AIX_VAL"}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_SUP_G_OPF = [AIX_SUP_G_OPF, [], {_x getVariable "AIX_VAL"}, "DESCEND", {true}] call BIS_fnc_sortBy;

/// re-assign overflow (rec->atk->def)
/// priority depend of mode
/// ATK: atk->rec/def
/// DEF: def->rec/atk
/// GMB: rec->atk/def

/// Assign groups to sections
if (AIX_MODE_BLU == "ATTACK") then {
	private _atk = count AIX_ATK_G_BLU;
	private _def = count AIX_DEF_G_BLU;
	private _rec = count AIX_REC_G_BLU;
	private _res = _def + _rec;
	private _sel = 0;
	
	while {_res > _atk} do {
		_atk = count AIX_ATK_G_BLU;
		_def = count AIX_DEF_G_BLU;
		_rec = count AIX_REC_G_BLU;
		_res = _def + _rec;
		
		if (_sel == 0) then {
			if (_def > 0) then {
				private _grp = AIX_DEF_G_BLU select 0;
				AIX_ATK_G_BLU pushback _grp;
				AIX_DEF_G_BLU deleteAt 0;
			};
			_sel = 1;
		} else {
			if (_rec > 0) then {
				private _grp = AIX_REC_G_BLU select 0;
				AIX_ATK_G_BLU pushback _grp;
				AIX_REC_G_BLU deleteAt 0;
			};
			_sel = 0;
		};
	};
};

if (AIX_MODE_BLU == "DEFEND") then {
	private _atk = count AIX_ATK_G_BLU;
	private _def = count AIX_DEF_G_BLU;
	private _rec = count AIX_REC_G_BLU;
	private _res = _atk + _rec;
	private _sel = 0;
	
	while {_res > _def} do {
		_atk = count AIX_ATK_G_BLU;
		_def = count AIX_DEF_G_BLU;
		_rec = count AIX_REC_G_BLU;
		_res = _atk + _rec;
		
		if (_sel == 0) then {
			if (_atk > 0) then {
				private _grp = AIX_ATK_G_BLU select 0;
				AIX_DEF_G_BLU pushback _grp;
				AIX_ATK_G_BLU deleteAt 0;
			};
			_sel = 1;
		} else {
			if (_rec > 0) then {
				private _grp = AIX_REC_G_BLU select 0;
				AIX_DEF_G_BLU pushback _grp;
				AIX_REC_G_BLU deleteAt 0;
			};
			_sel = 0;
		};
	};
};

if (AIX_MODE_BLU == "GAMBIT") then {
	private _atk = count AIX_ATK_G_BLU;
	private _def = count AIX_DEF_G_BLU;
	private _rec = count AIX_REC_G_BLU;
	private _res = _atk + _def;
	private _sel = 0;
	
	while {_res > _rec} do {
		_atk = count AIX_ATK_G_BLU;
		_def = count AIX_DEF_G_BLU;
		_rec = count AIX_REC_G_BLU;
		_res = _atk + _def;
		
		if (_sel == 0) then {
			if (_atk > 0) then {
				private _grp = AIX_ATK_G_BLU select 0;
				AIX_REC_G_BLU pushback _grp;
				AIX_ATK_G_BLU deleteAt 0;
			};
			_sel = 1;
		} else {
			if (_def > 0) then {
				private _grp = AIX_DEF_G_BLU select 0;
				AIX_REC_G_BLU pushback _grp;
				AIX_DEF_G_BLU deleteAt 0;
			};
			_sel = 0;
		};
	};
};

if (!isServer) exitWith {hint "not server"};

AIX_DEBUG = true;
AIX_BLU = west;
AIX_OPF = east;

/// spawn random INF
for "_i" from 1 to 8 do {
	private _pos = [getMarkerPos "AIX_SPAWN_BLU", 0, 500] call BIS_fnc_findSafePos;
	[_pos, west, 2 + floor random 8] call BIS_fnc_spawnGroup;
};

for "_i" from 1 to 8 do {
	private _pos = [getMarkerPos "AIX_SPAWN_OPF", 0, 500] call BIS_fnc_findSafePos;
	[_pos, east, 2 + floor random 8] call BIS_fnc_spawnGroup;
};

/// group classification
{
	/// skip dead groups
	
	if (count units _x == 0) then {
	
		if (AIX_DEBUG) then {
			diag_log format ["%1, %2", "AIX Init.sqf skipped group: ", str _x];
		};	
		continue
	};
	private _grp = _x;
	private _ldr = leader _x;
	private _veh = assignedVehicle _ldr;
	private _cfg = configFile >> "CfgVehicles" >> typeOf _veh;
	private _sim = toLower (getText (_cfg >> "simulation"));
	private _art = getNumber (_cfg >> "artilleryScanner");
	private _arm = getNumber (_cfg >> "armor");
	
	private _sup = getNumber (_cfg >> "transportRepair") + getNumber (_cfg >> "transportAmmo") + getNumber (_cfg >> "transportFuel") + getNumber (_cfg >> "attendant");
	private _tra = _veh emptyPositions "Cargo";
	private _uni = count units _grp;
	private _drv = getNumber (_cfg >> "hasDriver");
	
	private _aaa = getText (_cfg >> "editorSubcategory") == "EdSubcat_AAs";
	private _uav = getText (_cfg >> "editorSubcategory") == "EdSubcat_Drones";
	private _apc = getText (_cfg >> "editorSubcategory") == "EdSubcat_APCs";
	private _amb = getNumber (_cfg >> "canSwim");

	/// find how many AT group has
	private _hat = 0;
	{
		private _cfg2 = configFile >> "CfgVehicles" >> typeOf vehicle _x;
		private _hat2 = getText (_cfg2 >> "icon") == "iconManAT";
		if (_hat2) then {_hat = _hat + 1};
	}forEach units _grp;

	private _cat = "recon"; ///Light INF
	private _val = 0.5;
	if (_hat > 0) then {_cat = "inf", _val = 1}; ///INF LAT
	if (_hat > 1) then {_cat = "service", _val = 2}; ///INF HAT
	
	if (_sim == "carx") then {_cat = "motor_inf", _val = 2}; ///APC/AFV
	if (_sim == "carx" && _uni == 1) then {_cat = "unknown", _val = 0}; ///Transport
	
	if (_sim == "tankx") then {_cat = "armor", _val = 6}; /// TANK
	if (_sim == "tankx" && _apc) then {_cat = "mech_inf", _val = 4}; /// IFV/Light armor/bewup
	/// https://www.youtube.com/watch?v=MmwSHcu8RQ0
	if (_sim == "tankx" && _drv == 0) then {_cat = "installation", _val = 1}; /// Turret
	if (_aaa) then {_cat = "antiair", _val = 4}; /// Anti-air
	
	if (_sim in ["airplanex", "airplane"]) then {_cat = "plane", _val = 6}; /// Fixed wing
	if (_sim == "helicopterrtd") then {_cat = "air", _val = 4}; /// Rotary wing
	if (_uav) then {_cat = "uav", _val = 4}; /// Drone
	
	if (_art == 1) then {_cat = "art", _val = 8}; /// SPG
	if (_art == 1 && _drv == 0) then {_cat = "mortar", _val = 6}; /// Mortar/Arty
	if (_sim != "soldier" && _sup > 0) then {_cat = "support", _val = 0}; /// Support unit, further classification maybe
	if (_sim in ["shipx","submarinex"]) then {_cat = "naval", _val = 2}; /// Boats
	
	_val = _val + (_uni * 0.1);
	_grp setVariable ["AIX_CAT", _cat, true];
	_grp setVariable ["AIX_VAL", _val, true];
	/// add variable that marks that unit is amphibious
	
	if (AIX_DEBUG) then {
		private _side = "n_";
		if (side _grp == AIX_BLU) then {_side = "b_"};
		if (side _grp == AIX_OPF) then {_side = "o_"};
		private _marker = _side + _cat;
		private _id = "AIX_" + _side + groupID _grp;
		_grpMarker = createMarker [_id, getPos _ldr];
		_grpMarker setMarkerType _marker;
		_grpMarker setMarkerText _id;
		
		0 spawn {
			while {AIX_DEBUG} do {
				{
					private _grp = _x;
					private _var = _grp getVariable "AIX_CAT";
					if (!isNil "_var") then {
						private _side = "n_";
						if (side _grp == AIX_BLU) then {_side = "b_"};
						if (side _grp == AIX_OPF) then {_side = "o_"};
						private _id = "AIX_" + _side + groupID _grp;
						_id setMarkerPos (getPos leader _grp); 
					};
					sleep 0.1;
				}forEach allGroups;
			}
		};
	};
}forEach allGroups;

AIX_SIZE = 100;
private _cellRad = AIX_SIZE / 2;
private _worldSize = worldSize;

/// Create grid

AIX_GRID = []; /// [_x, _y, _type(brush), _control(0 BLK, 1 BLU, 2 OPF, 3 CIV)];

for "_col" from 0 to round(_worldSize / AIX_SIZE) do {
    for "_row" from 0 to round(_worldSize / AIX_SIZE) do {

        private _posX = _col * AIX_SIZE + (_cellRad);
        private _posY = _row * AIX_SIZE + (_cellRad);
		private _pos = [_posX, _posY];

		if (_pos inArea "AIX_AO") then {
			private _isWater = surfaceIsWater _pos;
			private _isCover = count (nearestTerrainObjects [_pos, ["TREE", "ROCK"], _cellRad]) > 5;
			private _isMount = !isNull (nearestLocation [_pos, "Mount", AIX_SIZE]);
			private _isHill = !isNull (nearestLocation [_pos, "Hill", AIX_SIZE*2]);
			private _isObjects = count (nearestTerrainObjects [_pos, ["HOUSE", "WALL"], _cellRad]) > 5;
			
			private _type = 1; /// default

			if (_isCover) then {_type = 1.25}; /// Cover
			if (_isMount or _isHill) then {_type = 1.5}; /// Elevation
			if (_isCover && _isMount) then {_type = 1.75}; /// Cover2
			if (_isObjects) then {_type = 2}; /// Hard Cover
			if (_isWater) then {continue}; /// Water
			/// if (_isWater) then {_type = 5}; /// Water
			
			AIX_GRID pushback [_posX, _posY, _type, 0];
		}
	};
};

AIX_FNC_GRID = {
	{
		private _posX = _x select 0;
		private _posY = _x select 1;
		private _pos = [_posX, _posY];
		private _type = _x select 2;
		private _control = _x select 3;
		
		private _coord = str _posX + str _posY;
		private _marker = createMarker ["AIX_" + _coord, _pos];
		_marker setMarkerShape "RECTANGLE";
		_marker setMarkerAlpha 0.5;
		_marker setMarkerSize [AIX_SIZE / 2, AIX_SIZE / 2];
				
		private _brush = "Solid"; /// default / 1
		switch (_type) do {
			case 1.25: {_brush = "BDiagonal"};
			case 1.5: {_brush = "FDiagonal"};
			case 1.75: {_brush = "DiagGrid"};
			case 2: {_brush = "Vertical"};
			///case 5: {_brush = "Cross"}; /// TODO: determine if unit is amphibious?
		};
				
		_marker setMarkerBrush _brush;
		
		_color = "Default";
		switch (_control) do {
			case 1: {_color = "ColorWEST"};
			case 2: {_color = "ColorEAST"};
			case 3: {_color = "ColorCIV"};
		};
		_marker setMarkerColor _color;
	}forEach AIX_GRID;
};

[] spawn {
	private _stratAI = execVM "stratAI.sqf";
	waitUntil {scriptDone _stratAI};
	private _opsAI = execVM "opsAI.sqf";
	waitUntil {scriptDone _opsAI};
	///private _tacAI = execVM "tacAI.sqf";
	///waitUntil {scriptDone _tacAI};
};

AIX_ATK_G_BLU = [];
AIX_DEF_G_BLU = [];
AIX_REC_G_BLU = [];
AIX_SUP_G_BLU = [];

{
	private _grp = _x;
	private _val = _grp getVariable "AIX_VAL";
	private _atk = _val select 0;
	private _def = _val select 1;
	private _rec = _val select 2;
	private _sup = _val select 3;
	private _index = _forEachIndex;

	/// remove support units from pool
	if (_sup > 0) then {
		AIX_SUP_G_BLU pushback _x;
		AIX_ALL_G_BLU deleteAt _index;
	};

}forEach AIX_ALL_G_BLU;

AIX_REC_BLU = [];
AIX_ATK_BLU = [];
AIX_DEF_BLU = [];
AIX_CMB_BLU = [];

AIX_REC_OPF = [];
AIX_ATK_OPF = [];
AIX_DEF_OPF = [];
AIX_CMB_OPF = [];

{
	private _posX = _x select 0;
	private _posY = _x select 1;
	private _posXY = [_posX, _posY];
	if (_posXY inArea "AIX_BLU") then {AIX_REC_BLU pushback _x};
	if (_posXY inArea "AIX_OPF") then {AIX_REC_OPF pushback _x};
}forEach AIX_GRID_BLK;

{
	private _posX = _x select 0;
	private _posY = _x select 1;
	private _posXY = [_posX, _posY];
	if (_posXY inArea "AIX_BLU") then {AIX_ATK_BLU pushback _x};
	if (_posXY inArea "AIX_OPF") then {AIX_ATK_OPF pushback _x};
}forEach AIX_GRID_OPF;

{
	private _posX = _x select 0;
	private _posY = _x select 1;
	private _posXY = [_posX, _posY];
	if (_posXY inArea "AIX_BLU") then {AIX_DEF_BLU pushback _x};
	if (_posXY inArea "AIX_OPF") then {AIX_DEF_OPF pushback _x};
}forEach AIX_GRID_BLU;

{
	private _posX = _x select 0;
	private _posY = _x select 1;
	private _posXY = [_posX, _posY];
	if (_posXY inArea "AIX_BLU") then {AIX_CMB_BLU pushback _x};
	if (_posXY inArea "AIX_OPF") then {AIX_CMB_OPF pushback _x};
}forEach AIX_GRID_CMB;

/// Default arrays if not enough

AIX_ALL_BLU = AIX_REC_BLU + AIX_ATK_BLU + AIX_DEF_BLU + AIX_CMB_BLU;
AIX_ALL_OPF = AIX_REC_OPF + AIX_ATK_OPF + AIX_DEF_OPF + AIX_CMB_OPF;

{
	if (count _x < 3) then {
		_x append AIX_ALL_BLU;
	};
}forEach [AIX_REC_BLU, AIX_ATK_BLU, AIX_DEF_BLU, AIX_CMB_BLU];

{
	if (count _x < 3) then {
		_x append AIX_ALL_OPF;
	};
}forEach [AIX_REC_OPF, AIX_ATK_OPF, AIX_DEF_OPF, AIX_CMB_OPF];

/// sort objectives based on distance and type
AIX_REC_BLU = [AIX_REC_BLU, [], {([_x select 0,_x select 1] distance AIX_CENT_BLU) / (_x select 2)}, "ASCEND", {true}] call BIS_fnc_sortBy;
AIX_DEF_BLU = [AIX_DEF_BLU, [], {([_x select 0,_x select 1] distance AIX_CENT_BLU) / (_x select 2)}, "ASCEND", {true}] call BIS_fnc_sortBy;
AIX_ATK_BLU = [AIX_ATK_BLU, [], {([_x select 0,_x select 1] distance AIX_CENT_BLU) / (_x select 2)}, "ASCEND", {true}] call BIS_fnc_sortBy;
AIX_CMB_BLU = [AIX_CMB_BLU, [], {([_x select 0,_x select 1] distance AIX_CENT_BLU) / (_x select 2)}, "ASCEND", {true}] call BIS_fnc_sortBy;
AIX_REC_OPF = [AIX_REC_OPF, [], {([_x select 0,_x select 1] distance AIX_CENT_OPF) / (_x select 2)}, "ASCEND", {true}] call BIS_fnc_sortBy;
AIX_DEF_OPF = [AIX_DEF_OPF, [], {([_x select 0,_x select 1] distance AIX_CENT_OPF) / (_x select 2)}, "ASCEND", {true}] call BIS_fnc_sortBy;
AIX_ATK_OPF = [AIX_ATK_OPF, [], {([_x select 0,_x select 1] distance AIX_CENT_OPF) / (_x select 2)}, "ASCEND", {true}] call BIS_fnc_sortBy;
AIX_CMB_OPF = [AIX_CMB_OPF, [], {([_x select 0,_x select 1] distance AIX_CENT_OPF) / (_x select 2)}, "ASCEND", {true}] call BIS_fnc_sortBy;

if (AIX_DEBUG) then {
	private _count = count AIX_REC_BLU;
	{
		private _pos = [_x select 0, _x select 1];
		private _index = _forEachIndex;
		private _mrk = createMarker ["AIX_OPS_" + str _index, _pos];
		_mrk setMarkerType "hd_dot";
		if (_index == 0) then {
			_mrk setMarkerColor "colorRED";
		} else {
			_mrk setMarkerAlpha (1 - (_index / _count));
		}
	}forEach AIX_REC_BLU;
};

/// sort objectives based on distance, priority and type
AIX_DIST_BLU = 0;
AIX_DIST_OPF = 0;

AIX_ALL_BLU = AIX_GRID select {[_x select 0, _x select 1] inArea "AIX_BLU";};
AIX_ALL_OPF = AIX_GRID select {[_x select 0, _x select 1] inArea "AIX_OPF";};

{
	private _dist = [_x select 0,_x select 1] distance AIX_CENT_BLU;
	if (_dist > AIX_DIST_BLU) then {AIX_DIST_BLU = _dist};
}forEach AIX_ALL_BLU;

{
	private _dist = [_x select 0,_x select 1] distance AIX_CENT_OPF;
	if (_dist > AIX_DIST_OPF) then {AIX_DIST_OPF = _dist};
}forEach AIX_ALL_OPF;

AIX_ALL_BLU = [
	AIX_ALL_BLU, 
	[], 
	{
		private _dist = [_x select 0,_x select 1] distance AIX_CENT_BLU;
		private _dist = (AIX_DIST_BLU / _dist * 3);
		private _type = _x select 2;
		private _control = _x select 3;
		
		private _priority = 0;
		if (AIX_MODE_BLU == "ATTACK") then {
			 /// 0 blk, 1 blu, 2 opf, 3 civ
			if (_control == 0) then {_priority = 1}; ///BLK
			if (_control == 1) then {_priority = 0}; ///BLU
			if (_control == 2) then {_priority = 2}; ///OPF
			if (_control == 3) then {_priority = 3}; ///CMB
		};
		
		if (AIX_MODE_BLU == "DEFEND") then {
			if (_control == 0) then {_priority = 1}; ///BLK
			if (_control == 1) then {_priority = 3}; ///BLU
			if (_control == 2) then {_priority = 0}; ///OPF
			if (_control == 3) then {_priority = 2}; ///CMB
		};		 
		
		if (AIX_MODE_BLU == "GAMBIT") then {
			if (_control == 0) then {_priority = 3}; ///BLK
			if (_control == 1) then {_priority = 1}; ///BLU
			if (_control == 2) then {_priority = 0}; ///OPF
			if (_control == 3) then {_priority = 2}; ///CMB
		};
		
		private _priority = _dist + _type + _priority;
		_priority
	}, "DESCEND", {
		[_x select 0,_x select 1] inArea "AIX_BLU"
	}
] call BIS_fnc_sortBy;

AIX_ALL_BLU = AIX_ALL_BLU select [0, ceil ((count AIX_ALL_BLU) / 2)];

if (AIX_DEBUG) then {
	private _count = count AIX_ALL_BLU;
	{
		private _pos = [_x select 0, _x select 1];
		private _index = _forEachIndex;
		private _mrk = createMarker ["AIX_OPS_" + str _index, _pos];
		_mrk setMarkerType "hd_dot";
		if (_index == 0) then {
			_mrk setMarkerColor "colorRED";
		} else {
			_mrk setMarkerAlpha (1 - (_index / _count));
		}
	}forEach AIX_ALL_BLU;
};

/// assign operational groups

AIX_ATK_G_BLU = [];
AIX_DEF_G_BLU = [];
AIX_REC_G_BLU = [];

AIX_ATK_G_OPF = [];
AIX_DEF_G_OPF = [];
AIX_REC_G_OPF = [];

private _atkBlu = 1;
private _defBlu = 1;
private _recBlu = 1;

if (AIX_MODE_BLU == "ATTACK") then {_atkBlu = 3, _defBlu = 2, _recBlu = 1};
if (AIX_MODE_BLU == "DEFEND") then {_atkBlu = 3, _defBlu = 2, _recBlu = 1};
if (AIX_MODE_BLU == "GAMBIT") then {_atkBlu = 3, _defBlu = 2, _recBlu = 1};

/// sort groups
AIX_ATK_G_BLU = [AIX_ALL_G_BLU, [], {(_x getVariable "AIX_VAL") select 0}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_DEF_G_BLU = [AIX_ALL_G_BLU, [], {(_x getVariable "AIX_VAL") select 1}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_REC_G_BLU = [AIX_ALL_G_BLU, [], {(_x getVariable "AIX_VAL") select 2}, "DESCEND", {true}] call BIS_fnc_sortBy;

/// choose best attack units
/// choose best defense units
/// choose best recon units

if (AIX_DEBUG) then {
	sleep 0.1;
	///systemchat ("BLU ATK: " + str (count AIX_ATK_G_BLU) + " DEF: " + str (count AIX_DEF_G_BLU) + " REC: " + str (count AIX_REC_G_BLU) + " SUP: " + str (count AIX_SUP_G_BLU));
	///systemchat ("OPF ATK: " + str (count AIX_ATK_G_OPF) + " DEF: " + str (count AIX_DEF_G_OPF) + " REC: " + str (count AIX_REC_G_OPF) + " SUP: " + str (count AIX_SUP_G_OPF));
};


		private _priority = 0;
		if (AIX_MODE_BLU == "ATTACK") then {
			 /// 0 blk, 1 blu, 2 opf, 3 civ
			if (_control == 0) then {_priority = 1}; ///BLK
			if (_control == 1) then {_priority = 0}; ///BLU
			if (_control == 2) then {_priority = 2}; ///OPF
			if (_control == 3) then {_priority = 3}; ///CMB
		};
		
		if (AIX_MODE_BLU == "DEFEND") then {
			if (_control == 0) then {_priority = 1};
			if (_control == 1) then {_priority = 3};
			if (_control == 2) then {_priority = 0};
			if (_control == 3) then {_priority = 2};
		};		 
		
		if (AIX_MODE_BLU == "GAMBIT") then {
			if (_control == 0) then {_priority = 3};
			if (_control == 1) then {_priority = 1};
			if (_control == 2) then {_priority = 0};
			if (_control == 3) then {_priority = 2};
		};