/// assign operational groups
AIX_ATK_G_BLU = [];
AIX_DEF_G_BLU = [];
AIX_REC_G_BLU = [];

AIX_ATK_G_OPF = [];
AIX_DEF_G_OPF = [];
AIX_REC_G_OPF = [];

/// assign groups and sort by values
AIX_ALL_G_BLU = [AIX_ALL_G_BLU, [], {(_x getVariable "AIX_ATK") + (_x getVariable "AIX_VAL")}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_ATK_G_BLU = AIX_ALL_G_BLU select [0, (round (count AIX_ALL_G_BLU * AIX_ATK_W_BLU))];
_allGrpBLU = AIX_ALL_G_BLU - AIX_ATK_G_BLU;
_allGrpBLU = [_allGrpBLU, [], {(_x getVariable "AIX_REC") + (_x getVariable "AIX_VAL")}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_REC_G_BLU = _allGrpBLU select [0, (round (count _allGrpBLU * AIX_REC_W_BLU))];
_allGrpBLU = [_allGrpBLU, [], {_x getVariable "AIX_VAL"}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_DEF_G_BLU = _allGrpBLU - AIX_REC_G_BLU;

/// assign groups and sort by values
AIX_ALL_G_OPF = [AIX_ALL_G_OPF, [], {(_x getVariable "AIX_ATK") + (_x getVariable "AIX_VAL")}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_ATK_G_OPF = AIX_ALL_G_OPF select [0, (round (count AIX_ALL_G_OPF * AIX_ATK_W_OPF))];
_allGrpOPF = AIX_ALL_G_OPF - AIX_ATK_G_OPF;
_allGrpOPF = [_allGrpOPF, [], {(_x getVariable "AIX_REC") + (_x getVariable "AIX_VAL")}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_REC_G_OPF = _allGrpOPF select [0, (round (count _allGrpOPF * AIX_REC_W_OPF))];
_allGrpOPF = [_allGrpOPF, [], {_x getVariable "AIX_VAL"}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_DEF_G_OPF = _allGrpOPF - AIX_REC_G_OPF;

/// Assign objectives
/// Based mostly on "personality" for now
AIX_ATK_BLU = AIX_ATK_BLU select [0, (AIX_CMD_BLU select 3)];
AIX_DEF_BLU = AIX_DEF_BLU select [0, (AIX_CMD_BLU select 4)];
AIX_REC_BLU = AIX_REC_BLU select [0, (AIX_CMD_BLU select 5)]; 

AIX_ATK_OPF = AIX_ATK_OPF select [0, (AIX_CMD_OPF select 3)];
AIX_DEF_OPF = AIX_DEF_OPF select [0, (AIX_CMD_OPF select 4)];
AIX_REC_OPF = AIX_REC_OPF select [0, (AIX_CMD_OPF select 5)];

/// Task risk calc
_fnc_risk = {
	private _pos = _this select 0;
	private _eny = _this select 1;
	private _risk = 0;
	
	{
		private _grp = _x;
		private _val = _grp getVariable "AIX_VAL";
		private _sup = _grp getVariable "AIX_SUP";

		private _side = side _grp;
		private _ldr = leader _grp;
		private _pos2 = getPosATL _ldr;
		private _dist = AIX_SIZE*2;
		if (isNil "_val") then {continue};
	
		if (side _grp == _eny && !_sup && _pos2 distance _pos < _dist) then {
			_risk = _risk + _val;
		};
	
	}forEach allGroups;

	
	/// The more unknown the threats, the higher baseline threat?
	/// Impossible to model intuition, must cheat for this part
	/// AI is bling to WHERE this threat could go -> Outmaneuver
	
	/// Risk = Eny Threat - Blu threat in area??
	_risk
};

/// TASKS SYSTEM: [_pos, _type, _risk, _sizeMod]
AIX_TASKS_BLU = [];

/// Recon Tasks (2x default)
AIX_TASKS_BLU pushBack [AIX_CENT_BLU, "PATROL", [AIX_CENT_BLU, AIX_OPF] call _fnc_risk, AIX_SIZE * 2]; /// Fob patrol
AIX_TASKS_BLU pushBack [AIX_CENT_ALL, "RECON", [AIX_CENT_ALL, AIX_OPF] call _fnc_risk, AIX_SIZE * 2]; /// Recon CENT

{
	private _pos = _x select 0;
	private _risk = [_pos , AIX_OPF] call _fnc_risk;
	private _size = AIX_SIZE * 2;
	if (_x select 2) then {_size = AIX_SIZE};
	AIX_TASKS_BLU pushBack [_pos, "RECON", _risk, _size];
}forEach AIX_REC_BLU;

{
	private _pos = _x select 0;
	private _risk = [_pos , AIX_OPF] call _fnc_risk;
	private _size = AIX_SIZE * 2;
	if (_x select 2) then {_size = AIX_SIZE};
	AIX_TASKS_BLU pushBack [_pos, "PATROL", _risk, _size];
}forEach AIX_DEF_BLU; 

/// Defend tasks (1x default)
AIX_TASKS_BLU pushBack [AIX_CENT_BLU, "DEFEND", [AIX_CENT_BLU, AIX_OPF] call _fnc_risk, AIX_SIZE]; /// Defend BLU COM

{
	private _pos = _x select 0;
	private _risk = [_pos , AIX_OPF] call _fnc_risk;
	private _size = AIX_SIZE;
	if (_x select 2) then {_size = AIX_SIZE / 2};
	AIX_TASKS_BLU pushBack [_pos, "DEFEND", _risk, _size];
}forEach AIX_DEF_BLU;

/// Attack tasks (0x default)

{
	private _pos = _x select 0;
	private _risk = [_pos , AIX_OPF] call _fnc_risk;
	AIX_TASKS_BLU pushBack [_pos, "ATTACK", _risk];
	private _size = AIX_SIZE;
	if (_x select 2) then {_size = AIX_SIZE / 2};
}forEach AIX_ATK_BLU;

{
	private _pos = getPos leader _x;
	private _risk = [_pos , AIX_OPF] call _fnc_risk;
	private _size = AIX_SIZE / 2;
	AIX_TASKS_BLU pushBack [_pos, "DESTROY", _size];
}forEach AIX_ENY_G_BLU;

AIX_TASKS_OPF = [];

/// Recon Tasks (2x default)
AIX_TASKS_OPF pushBack [AIX_CENT_OPF, "PATROL", [AIX_CENT_OPF, AIX_BLU] call _fnc_risk, AIX_SIZE * 2]; /// Fob patrol
AIX_TASKS_OPF pushBack [AIX_CENT_ALL, "RECON", [AIX_CENT_ALL, AIX_BLU] call _fnc_risk, AIX_SIZE * 2]; /// Recon CENT

{
	private _pos = _x select 0;
	private _risk = [_pos , AIX_BLU] call _fnc_risk;
	private _size = AIX_SIZE * 2;
	if (_x select 2) then {_size = AIX_SIZE};
	AIX_TASKS_OPF pushBack [_pos, "RECON", _risk, _size];
}forEach AIX_REC_OPF;

{
	private _pos = _x select 0;
	private _risk = [_pos , AIX_BLU] call _fnc_risk;
	private _size = AIX_SIZE * 2;
	if (_x select 2) then {_size = AIX_SIZE};
	AIX_TASKS_OPF pushBack [_pos, "PATROL", _risk, _size];
}forEach AIX_DEF_OPF; 

/// Defend tasks (1x default)
AIX_TASKS_OPF pushBack [AIX_CENT_OPF, "DEFEND", [AIX_CENT_OPF, AIX_BLU] call _fnc_risk, AIX_SIZE]; /// Defend BLU COM

{
	private _pos = _x select 0;
	private _risk = [_pos , AIX_BLU] call _fnc_risk;
	private _size = AIX_SIZE;
	if (_x select 2) then {_size = AIX_SIZE / 2};
	AIX_TASKS_OPF pushBack [_pos, "DEFEND", _risk, _size];
}forEach AIX_DEF_OPF;

/// Attack tasks (0x default)

{
	private _pos = _x select 0;
	private _risk = [_pos , AIX_BLU] call _fnc_risk;
	AIX_TASKS_OPF pushBack [_pos, "ATTACK", _risk];
	private _size = AIX_SIZE;
	if (_x select 2) then {_size = AIX_SIZE / 2};
}forEach AIX_ATK_OPF;

{
	private _pos = getPos leader _x;
	private _risk = [_pos , AIX_BLU] call _fnc_risk;
	private _size = AIX_SIZE / 2;
	AIX_TASKS_OPF pushBack [_pos, "DESTROY", _size];
}forEach AIX_ENY_G_OPF;

if (AIX_DEBUG) then {
	sleep 0.1;
	
	systemchat ("BLU ALL_G: " + str (count AIX_ALL_G_BLU) + " ATK_G: " + str (count AIX_ATK_G_BLU) + " DEF_G: " + str (count AIX_DEF_G_BLU) + " REC_G: " + str (count AIX_REC_G_BLU) + " SUP_G: " + str (count AIX_SUP_G_BLU));
	systemchat ("OPF ALL_G: " + str (count AIX_ALL_G_OPF) + " ATK_G: " + str (count AIX_ATK_G_OPF) + " DEF_G: " + str (count AIX_DEF_G_OPF) + " REC_G: " + str (count AIX_REC_G_OPF) + " SUP_G: " + str (count AIX_SUP_G_OPF));
	
	/// Groups debug
	{
		private _side = "n_";
		if (side _x == AIX_BLU) then {_side = "b_"};
		if (side _x == AIX_OPF) then {_side = "o_"};
		private _marker = "AIX_" + _side + groupID _x;
		private _text = "NAN";
		private _val = str (_x getVariable "AIX_VAL");
		private _atk = str (_x getVariable "AIX_ATK");
		private _rec = str (_x getVariable "AIX_REC");
		if (_x in (AIX_ATK_G_BLU + AIX_ATK_G_OPF)) then {_text = "ATK"};
		if (_x in (AIX_DEF_G_BLU + AIX_DEF_G_OPF)) then {_text = "DEF"};
		if (_x in (AIX_REC_G_BLU + AIX_REC_G_OPF)) then {_text = "REC"};
		if (_x in (AIX_SUP_G_BLU + AIX_SUP_G_OPF)) then {_text = "SUP"};
		private _text = _text + " V: " + _val + " A: " + _atk + " R: " + _rec;
		_marker setMarkerText _text;
	}forEach (AIX_ATK_G_BLU + AIX_DEF_G_BLU + AIX_REC_G_BLU + AIX_SUP_G_BLU + AIX_ATK_G_OPF + AIX_DEF_G_OPF + AIX_REC_G_OPF + AIX_SUP_G_OPF);
	
	/// Tasks debug
	{
		private _pos = _x select 0;
		private _type = _x select 1;
		private _risk = _x select 2;
		private _size = (_x select 3) / 10;
		
		private _pos = [[[_pos, _size]], []] call BIS_fnc_randomPos;
		
		private _idx = _forEachIndex;
		private _marker =  	"hd_dot";
		switch _type do {
			case "RECON": {_marker = "hd_warning"};
			case "PATROL": {_marker = "hd_unknown"};
			case "DEFEND": {_marker = "hd_flag"};
			case "ATTACK": {_marker = "hd_arrow"};
			case "DESTROY": {_marker = "hd_destroy"};
		};
		
		private _mrk = createMarker ["AIX_DBG_BLU_" + str _idx, _pos];
		_mrk setMarkerType _marker;
		_mrk setMarkerText (str _risk);
		_mrk setMarkerColor "ColorWEST";
	}forEach AIX_TASKS_BLU;
	
	{
		private _pos = _x select 0;
		private _type = _x select 1;
		private _risk = _x select 2;
		private _size = (_x select 3) / 10;
		
		private _pos = [[[_pos, _size]], []] call BIS_fnc_randomPos;
		
		private _idx = _forEachIndex;
		private _marker =  	"hd_dot";
		switch _type do {
			case "RECON": {_marker = "hd_warning"};
			case "PATROL": {_marker = "hd_unknown"};
			case "DEFEND": {_marker = "hd_flag"};
			case "ATTACK": {_marker = "hd_arrow"};
			case "DESTROY": {_marker = "hd_destroy"};
		};
		
		private _mrk = createMarker ["AIX_DBG_OPF_" + str _idx, _pos];
		_mrk setMarkerType _marker;
		_mrk setMarkerText (str _risk);
		_mrk setMarkerColor "ColorEAST";
	}forEach AIX_TASKS_OPF;
};