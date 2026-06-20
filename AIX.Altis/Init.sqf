if (!isServer) exitWith {hint "not server"};

AIX_DEBUG = true;
AIX_BLU = west;
AIX_OPF = east;

/// spawn random INF
for "_i" from 1 to 8 do {
	private _pos = [getMarkerPos "AIX_BLU_SPAWN", 0, 500] call BIS_fnc_findSafePos;
	[_pos, west, 2 + floor random 8] call BIS_fnc_spawnGroup;
};

for "_i" from 1 to 8 do {
	private _pos = [getMarkerPos "AIX_OPF_SPAWN", 0, 500] call BIS_fnc_findSafePos;
	[_pos, east, 2 + floor random 8] call BIS_fnc_spawnGroup;
};

/// group classification
{
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
	if (_sim == "tankx" && _apc) then {_cat = "mech_inf", _val = 4}; /// IFV/Light armor
	if (_sim == "tankx" && _drv == 0) then {_cat = "installation", _val = 1}; /// Turret
	if (_aaa) then {_cat = "antiair", _val = 4};
	
	if (_sim in ["airplanex", "airplane"]) then {_cat = "plane", _val = 6}; /// Fixed wing
	if (_sim == "helicopterrtd") then {_cat = "air", _val = 4}; /// Rotary wing
	if (_uav) then {_cat = "uav", _val = 4}; /// Drone
	
	if (_art == 1) then {_cat = "art", _val = 8}; /// SPG
	if (_art == 1 && _drv == 0) then {_cat = "mortar", _val = 6}; /// Mortar/Arty
	if (_sim != "soldier" && _sup > 0) then {_cat = "support", _val = 0}; /// Support unit, further classification maybe
	if (_sim in ["shipx","submarinex"]) then {_cat = "naval", _val = 2}; /// Boats
	
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

/// Create grid
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
			
			private _type = 0; /// default

			if (_isCover) then {_type = 1}; /// Cover
			if (_isMount or _isHill) then {_type = 2}; /// Elevation
			if (_isCover && _isMount) then {_type = 3}; /// Cover2
			if (_isObjects) then {_type = 4}; /// Hard Cover
			if (_isWater) then {_type = 5}; /// Water
			/// cover + hill (Mount locations?)
			
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
				
		private _brush = "Solid"; /// default / 0
		switch (_type) do {
			case 1: {_brush = "BDiagonal"};
			case 2: {_brush = "FDiagonal"};
			case 3: {_brush = "DiagGrid"};
			case 4: {_brush = "Vertical"};
			case 5: {_brush = "Cross"};
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

0 spawn {
	execVM "stratAI.sqf";
};