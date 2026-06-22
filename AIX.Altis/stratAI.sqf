/// calculate forces
AIX_BLU_FORCE = 0;
AIX_OPF_FORCE = 0;
AIX_ALL_G_BLU = [];
AIX_ALL_G_OPF = [];
AIX_SUP_G_BLU = [];
AIX_SUP_G_OPF = [];
private _bluPos = [];
private _opfPos = [];

{
	private _grp = _x;
	private _val = _grp getVariable "AIX_VAL";
	private _id = groupID _grp;
	private _side = side _grp;
	private _pos = getPosATL leader _grp;
	if (isNil "_val") then {
		if (AIX_DEBUG) then {
			diag_log format ["%1, %2, %3", "AIX stratAI.sqf skipped group:", _side, _id];
		};	
		continue;
	};
	
	if (side _grp == AIX_BLU) then {
		AIX_BLU_FORCE = AIX_BLU_FORCE + ((_val select 0) + (_val select 1) + (_val select 2) + (_val select 3));
		AIX_ALL_G_BLU pushback _x;
		_bluPos pushback _pos;
	};
	
	if (side _grp == AIX_OPF) then {
		AIX_OPF_FORCE = AIX_OPF_FORCE + ((_val select 0) + (_val select 1) + (_val select 2) + (_val select 3));
		AIX_ALL_G_OPF pushback _x;
		_opfPos pushback _pos;
	};
}forEach allGroups;

private _bluCentX = 0;
private _bluCentY = 0;
private _opfCentX = 0;
private _opfCentY = 0;

{
	_bluCentX = _bluCentX + (_x select 0);
	_bluCentY = _bluCentY + (_x select 1);
}forEach _bluPos;

{
	_opfCentX = _opfCentX + (_x select 0);
	_opfCentY = _opfCentY + (_x select 1);
}forEach _opfPos;

/// side center of mass
AIX_CENT_BLU = [_bluCentX / count _bluPos, _bluCentY / count _bluPos];
AIX_CENT_OPF = [_opfCentX / count _opfPos, _opfCentY / count _opfPos];

if (AIX_DEBUG) then {
	private _mrkBLU = createMarker ["AIX_CENT_BLU", AIX_CENT_BLU];
	_mrkBLU setMarkerType "b_hq";
	private _mrkOPF = createMarker ["AIX_CENT_OPF", AIX_CENT_OPF];
	_mrkOPF setMarkerType "o_hq";
};

/// grid tracking

AIX_GRID_BLK = [];
AIX_GRID_BLU = [];
AIX_GRID_OPF = [];
AIX_GRID_CMB = [];

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
		private _posLdr = getPosATL leader _x;
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
	if (_control == 3) then {AIX_GRID_CMB pushback _x};
	
}forEach AIX_GRID;

if (AIX_DEBUG) then {
	0 call AIX_FNC_GRID;
};

/// choose strategy type
AIX_MODE_BLU = "GAMBIT";
AIX_MODE_OPF = "GAMBIT";

if ((AIX_BLU_FORCE / 1.5) > AIX_OPF_FORCE) then {AIX_MODE_BLU = "ATTACK"; AIX_MODE_OPF = "DEFEND"};
if ((AIX_OPF_FORCE / 1.5) > AIX_BLU_FORCE) then {AIX_MODE_OPF = "ATTACK"; AIX_MODE_BLU = "DEFEND"};

if (AIX_DEBUG) then {
	sleep 0.1;
	systemchat ("BLU FORCE: " + str AIX_BLU_FORCE + " MODE: " + AIX_MODE_BLU);
	systemchat ("OPF FORCE: " + str AIX_OPF_FORCE + " MODE: " + AIX_MODE_OPF);
};

private _size = ((getMarkerSize "AIX_AO") select 0) / 2;
private _gambitOP = [_size * 1.5, _size* 1.5];
private _attackOP = [_size, _size * 2];
private _defendOP = [_size * 2, _size];

/// remove support units from pool
{
	private _grp = _x;
	private _val = _grp getVariable "AIX_VAL";
	private _sup = _val select 3;
	private _index = _forEachIndex;

	/// remove support units from pool
	if (_sup > 0) then {
		AIX_SUP_G_BLU pushback _x;
		AIX_ALL_G_BLU deleteAt _index;
	};

}forEach AIX_ALL_G_BLU;

{
	private _grp = _x;
	private _val = _grp getVariable "AIX_VAL";
	private _sup = _val select 3;
	private _index = _forEachIndex;

	/// remove support units from pool
	if (_sup > 0) then {
		AIX_SUP_G_OPF pushback _x;
		AIX_ALL_G_OPF deleteAt _index;
	};

}forEach AIX_ALL_G_OPF;

/// STRATEGIC PLAN "GAMBIT"
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

/// STRATEGIC PLAN "ATTACK"
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

/// STRATEGIC PLAN "DEFEND"
/// TODO: change to force's centre, make area size and position dependent on "personality" weights
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

/// TODO: secondary operations/more shapes or types? (ambphibious, airlift, guerrilla style ambushes...)