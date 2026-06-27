if (!isServer) exitWith {hint "not server"};

AIX_DEBUG = true;
AIX_BLU = west;
AIX_OPF = east;
AIX_SIZE = 250;

/// Commander personalities
AIX_CMD_BLU = [1, 1, 1, 1, 1, 2]; /// 0 - Attack weight, 1 Defence w, 2 Recon w, 3 max Atk Objectives, 4 Max Def Obj, 5 Max Rec Obj
AIX_CMD_OPF = [1, 1, 1, 1, 1, 2];

/// get primary objectives
AIX_OBJ = [];
private _locs = nearestLocations [getMarkerPos "AIX_AO", ["NameCityCapital", "NameCity", "NameVillage", "NameLocal", "Hill"], worldsize];
{
	private _pos = position _x;
	private _posX = round (_pos select 0);
	private _posY = round (_pos select 1);
	if (_pos inArea "AIX_AO") then {
		AIX_OBJ pushback [[_posX, _posY], 0, false]; /// [_pos, _control, _isSecondary]
	};
}forEach _locs;

/// add secondary objetives;
private _locs2 = nearestLocations [getMarkerPos "AIX_AO", ["Mount"], worldsize];
private _locs2 = [_locs2, [], {getTerrainHeightASL (position _x)}, "DESCEND", {true}] call BIS_fnc_sortBy;

{
	private _pos = position _x;
	private _posX = round (_pos select 0);
	private _posY = round (_pos select 1);
	private _close = false;
	
	{
		if ((_x select 0) distance _pos < AIX_SIZE * 2) then {_close = true};
	}forEach AIX_OBJ;
	
	if (_pos inArea "AIX_AO" && !_close) then {
		AIX_OBJ pushback [[_posX, _posY], 0, true];
	};
}forEach _locs2;

/// spawn random INF
for "_i" from 1 to 16 do {
	_pos = [["AIX_SPAWN_BLU"], [], {(getPosASL nearestObject _this) distance _this > 5}] call BIS_fnc_randomPos;
	[_pos, west, 2 + floor random 8] call BIS_fnc_spawnGroup;
};

for "_i" from 1 to 16 do {
	_pos = [["AIX_SPAWN_OPF"], [], {getpos nearestObject _this distance _this > 5}] call BIS_fnc_randomPos;
	[_pos, east, 2 + floor random 8] call BIS_fnc_spawnGroup;
};

sleep 1;

[] spawn {
	sleep 1;
	private _groupsAI = execVM "groupsAI.sqf";
	waitUntil {scriptDone _groupsAI};
	sleep 1;
	private _stratAI = execVM "stratAI.sqf";
	waitUntil {scriptDone _stratAI};
	sleep 1;
	private _opsAI = execVM "opsAI.sqf";
	waitUntil {scriptDone _opsAI};
	sleep 1;
	private _tasksAI = execVM "tasksAI.sqf";
	waitUntil {scriptDone _tasksAI};
	sleep 1;
	private _tacAI = execVM "tacAI.sqf";
	waitUntil {scriptDone _tacAI};
};