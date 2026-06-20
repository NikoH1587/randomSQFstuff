/// calculate forces
AIX_BLU_FORCE = 0;
AIX_OPF_FORCE = 0;

{
	private _grp = _x;
	private _val = _grp getVariable "AIX_VAL";
	private _id = groupID _grp;
	private _side = side _grp;
	if (isNil "_val") then {
		if (AIX_DEBUG) then {
			diag_log format ["%1, %2, %3", "AIX stratAI.sqf skipped group:", _side, _id];
		};	
		continue;
	};
	
	if (side _grp == AIX_BLU) then {
		AIX_BLU_FORCE = AIX_BLU_FORCE + _val;
	};
	
	if (side _grp == AIX_OPF) then {
		AIX_OPF_FORCE = AIX_OPF_FORCE + _val;
	};
}forEach allGroups;

AIX_GRID_BLK = [];
AIX_GRID_BLU = [];
AIX_GRID_OPF = [];
AIX_GRID_CIV = [];

/// grid tracking
{
	private _posX = _x select 0;
	private _posY = _x select 1;
	private _pos = [_posX, _posY];
	private _type = _x select 2;
	
	private _control = 0;
	
	private _blu = false;
	private _opf = false;
	
	{
		private _side = side _x;
		private _posLdr = position leader _x;
		private _distance = _posLdr distance _pos;
		if (_distance < 300) then {
			if (_side == AIX_BLU) then {
				_blu = true;
			};
			
			if (_side == AIX_OPF) then {
				_opf = true;
			};
		};
	}forEach allGroups;
	
	if (_blu) then {_control = 1};
	if (_opf) then {_control = 2};
	if (_blu && _opf) then {_control = 3};
	
	_x set [3, _control];
	
	if (_control == 0) then {AIX_GRID_BLK pushback _x};
	if (_control == 1) then {AIX_GRID_BLU pushback _x};
	if (_control == 2) then {AIX_GRID_OPF pushback _x};
	if (_control == 3) then {AIX_GRID_CIV pushback _x};
	
}forEach AIX_GRID;

if (AIX_DEBUG) then {
	0 call AIX_FNC_GRID;
};

/// choose operation type
AIX_MODE_BLU = "GAMBIT";
AIX_MODE_OPF = "GAMBIT";

if ((AIX_BLU_FORCE / 2) > AIX_OPF_FORCE) then {AIX_MODE_BLU = "ATTACK"; AIX_MODE_OPF = "DEFEND"};
if ((AIX_OPF_FORCE / 2) > AIX_BLU_FORCE) then {AIX_MODE_OPF = "ATTACK"; AIX_MODE_BLU = "DEFEND"};
/// choose operation position (between captured cells and target cells)

if (AIX_DEBUG) then {
	sleep 1;
	systemchat ("BLU FORCE: " + str AIX_BLU_FORCE + " MODE: " + AIX_MODE_BLU);
	systemchat ("OPF FORCE: " + str AIX_OPF_FORCE + " MODE: " + AIX_MODE_OPF);
};

private _size = ((getMarkerSize "AIX_AO") select 0) / 2;
private _gambitOP = [_size, _size];
private _attackOP = [_size, _size * 2];
private _defendOP = [_size * 2, _size];

/// OPERATIONAL PLAN "GAMBIT"
if (AIX_MODE_BLU == "GAMBIT") then {
	private _old = AIX_GRID_BLU select floor random count AIX_GRID_BLU;
	private _oldX = _old select 0;
	private _oldY = _old select 1;

	private _new = AIX_GRID_BLK select floor random count AIX_GRID_BLK;
	private _newX = _new select 0;
	private _newY = _new select 1;
	
	private _centPos = [(_oldX + _newX) / 2, (_oldY + _newY) / 2];
	private _dir = [_oldX, _oldY] getDir [_newX, _newY];
	"AIX_BLU" setMarkerPos _centPos;
	"AIX_BLU" setMarkerDir _dir;
	"AIX_BLU" setMarkerSize _gambitOP;
};

if (AIX_MODE_OPF == "GAMBIT") then {
	private _old = AIX_GRID_OPF select floor random count AIX_GRID_OPF;
	private _oldX = _old select 0;
	private _oldY = _old select 1;

	private _new = AIX_GRID_BLK select floor random count AIX_GRID_BLK;
	private _newX = _new select 0;
	private _newY = _new select 1;
	
	private _centPos = [(_oldX + _newX) / 2, (_oldY + _newY) / 2];
	private _dir = [_oldX, _oldY] getDir [_newX, _newY];
	"AIX_OPF" setMarkerPos _centPos;
	"AIX_OPF" setMarkerDir _dir;
	"AIX_OPF" setMarkerSize _gambitOP;
};

/// OPERATIONAL PLAN "ATTACK"
if (AIX_MODE_BLU == "ATTACK") then {
	private _old = AIX_GRID_BLU select floor random count AIX_GRID_BLU;
	private _oldX = _old select 0;
	private _oldY = _old select 1;

	private _new = AIX_GRID_OPF select floor random count AIX_GRID_OPF;
	private _newX = _new select 0;
	private _newY = _new select 1;
	
	private _centPos = [(_oldX + _newX) / 2, (_oldY + _newY) / 2];
	private _dir = [_oldX, _oldY] getDir [_newX, _newY];
	"AIX_BLU" setMarkerPos _centPos;
	"AIX_BLU" setMarkerDir _dir;
	"AIX_BLU" setMarkerSize _attackOP;
};

if (AIX_MODE_OPF == "ATTACK") then {
	private _old = AIX_GRID_OPF select floor random count AIX_GRID_OPF;
	private _oldX = _old select 0;
	private _oldY = _old select 1;

	private _new = AIX_GRID_BLU select floor random count AIX_GRID_BLU;
	private _newX = _new select 0;
	private _newY = _new select 1;
	
	private _centPos = [(_oldX + _newX) / 2, (_oldY + _newY) / 2];
	private _dir = [_oldX, _oldY] getDir [_newX, _newY];
	"AIX_OPF" setMarkerPos _centPos;
	"AIX_OPF" setMarkerDir _dir;
	"AIX_OPF" setMarkerSize _attackOP;
};

/// OPERATIONAL PLAN "DEFEND"
if (AIX_MODE_BLU == "DEFEND") then {
	private _old = AIX_GRID_BLU select floor random count AIX_GRID_BLU;
	private _oldX = _old select 0;
	private _oldY = _old select 1;

	private _new = AIX_GRID_OPF select floor random count AIX_GRID_OPF;
	private _newX = _new select 0;
	private _newY = _new select 1;
	
	private _centPos = [(_oldX + _newX) / 2, (_oldY + _newY) / 2];
	private _dir = [_oldX, _oldY] getDir [_newX, _newY];
	"AIX_BLU" setMarkerPos [_oldX, _oldY];
	"AIX_BLU" setMarkerDir _dir;
	"AIX_BLU" setMarkerSize _defendOP;
};

if (AIX_MODE_OPF == "DEFEND") then {
	private _old = AIX_GRID_OPF select floor random count AIX_GRID_OPF;
	private _oldX = _old select 0;
	private _oldY = _old select 1;

	private _new = AIX_GRID_BLU select floor random count AIX_GRID_BLU;
	private _newX = _new select 0;
	private _newY = _new select 1;
	
	private _centPos = [(_oldX + _newX) / 2, (_oldY + _newY) / 2];
	private _dir = [_oldX, _oldY] getDir [_newX, _newY];
	"AIX_OPF" setMarkerPos [_oldX, _oldY];
	"AIX_OPF" setMarkerDir _dir;
	"AIX_OPF" setMarkerSize _defendOP;
};