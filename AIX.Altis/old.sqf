
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