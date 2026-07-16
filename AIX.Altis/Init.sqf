if (!isServer) exitWith {hint "not server"};

AIX_DEBUG = true;
AIX_BLU = west;
AIX_OPF = east;
AIX_CMD_BLU = [4, 0.5, 2]; /// [Number of sections (3-5), Attack force ratio, Defend force ratio]
AIX_CMD_OPF = [5, 0.5, 2];

/// Create Tactical Grid

AIX_GRID = []; /// [_pos, _type, _bluInfo, _opfInfo]
AIX_SIZE = 200;

for "_col" from 0 to (worldSize / AIX_SIZE) do {
    for "_row" from 0 to (worldSize / AIX_SIZE) do {
		_pos = [_col * AIX_SIZE, _row * AIX_SIZE];
		if !(_pos inArea "AIX_AO") then {continue};
		private _city = nearestLocation [_pos, ["NameCityCapital"], AIX_SIZE * 2];
		private _hill = nearestLocation [_pos, ["Hill"], AIX_SIZE * 2];
		private _town = nearestLocation [_pos, ["NameCity", "NameLocal", "NameVillage"], AIX_SIZE];
		private _mount = nearestLocation [_pos, ["Mount"], AIX_SIZE];
		
		/// 0 - water, 1 - ground, 2 - elevation, 3 - cover
		private _type = 1;

		if !(isNull _mount) then {_type = 2};
		if !(isNull _town) then {_type = 3};
		if !(isNull _hill) then {_type = 2};
		if !(isNull _city) then {_type = 3};
		if (surfaceIsWater _pos) then {_type = 0};
		
		AIX_GRID pushback [_pos, _type, 0, 0];
    };
};

{
	private _idx = _forEachIndex;
	private _pos = _x select 0;
	private _type = _x select 1;
	private _mrkName = "AIX_" + str _pos;
	private _mrk = createMarker ["AIX_" + str _pos, _pos];
	_mrkName setMarkerPos _pos;
	_mrkName setMarkerShape "RECTANGLE";
	_mrkName setMarkerSize [AIX_SIZE / 2, AIX_SIZE / 2];
	_brush = "Solid";
	_alpha = 0.5;
	if (_type == 0) then {_brush = "Cross"; _alpha = 0.25};
	if (_type == 2) then {_brush = "FDiagonal"; _alpha = 1};
	if (_type == 3) then {_brush = "BDiagonal"; _alpha = 1};
	_mrkName setMarkerBrush _brush;
	_mrkName setMarkerAlpha _alpha;
}forEach AIX_GRID;

sleep 1;

/// spawn random INF
for "_i" from 1 to 12 do {
	_pos = [["AIX_SPAWN_BLU"], [], {
		private _pos = _this;
		private _inOBJ = false;
		{
			if (_pos distance (_x select 0) < AIX_SIZE) then {_inOBJ = true};
		}forEach AIX_GRID;
		(getPosASL nearestObject _this) distance _this > 5 && _inOBJ
	}] call BIS_fnc_randomPos;
	[_pos, west, 4 + floor random 6] call BIS_fnc_spawnGroup;
};

for "_i" from 1 to 12 do {
	_pos = [["AIX_SPAWN_OPF"], [], {
		private _pos = _this;
		private _inOBJ = false;
		{
			if (_pos distance (_x select 0) < AIX_SIZE) then {_inOBJ = true};
		}forEach AIX_GRID;
		(getPosASL nearestObject _this) distance _this > 5 && _inOBJ
	}] call BIS_fnc_randomPos;
	[_pos, east, 4 + floor random 6] call BIS_fnc_spawnGroup;
};

[] spawn {
	while {true} do	{
		private _classAI = execVM "classAI.sqf";
		waitUntil {scriptDone _classAI};
		private _stratAI = execVM "stratAI.sqf";
		waitUntil {scriptDone _stratAI};
		///sleep 0.5;
		///private _opsAI = execVM "opsAI.sqf";
		///waitUntil {scriptDone _opsAI};
		///sleep 1;
		///private _tasksAI = execVM "tasksAI.sqf";
		///waitUntil {scriptDone _tasksAI};
		///sleep 1;
		///private _tacAI = execVM "tacAI.sqf";
		///waitUntil {scriptDone _tacAI};
	}
};