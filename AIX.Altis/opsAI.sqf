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
	
	/// Objectives debug
	{
		private _count = count _x;
		private _dbg = _forEachIndex;
		{
			private _pos = _x select 0;
			

			private _dbgText = "BLU_NAN";
			if (_dbg == 0) then {_dbgText = "BLU_ATK"};
			if (_dbg == 1) then {_dbgText = "BLU_DEF"};
			if (_dbg == 2) then {_dbgText = "BLU_REC"};
			_dbgMrk = createMarker ["AIX_DBG_BLU" + str _pos, _pos];
			_dbgMrk setMarkerType "hd_dot";
			_dbgMrk setMarkerColor "ColorWEST";
			_dbgMrk setMarkerText _dbgText;
		
		}forEach _x;
	}forEach [AIX_ATK_BLU, AIX_DEF_BLU, AIX_REC_BLU];
	
	{
		private _count = count _x;
		private _dbg = _forEachIndex;
		{
			private _pos = _x select 0;
			
			private _dbgText = "OPF_NAN";
			if (_dbg == 0) then {_dbgText = "OPF_ATK"};
			if (_dbg == 1) then {_dbgText = "OPF_DEF"};
			if (_dbg == 2) then {_dbgText = "OPF_REC"};
			_dbgMrk = createMarker ["AIX_DBG_OPF" + str _pos, [_pos select 0, (_pos select 1) + 50]];
			_dbgMrk setMarkerType "hd_dot";
			_dbgMrk setMarkerColor "ColorEAST";
			_dbgMrk setMarkerText _dbgText;
		}forEach _x;
	}forEach [AIX_ATK_OPF, AIX_DEF_OPF, AIX_REC_OPF];
};