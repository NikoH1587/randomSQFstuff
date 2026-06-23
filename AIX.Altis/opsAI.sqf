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
		private _dist1 = [_x select 0,_x select 1] distance AIX_CENT_BLU;
		private _dist1 = 3 - ((_dist1 / AIX_DIST_BLU) * 3);
		private _dist2 = [_x select 0,_x select 1] distance AIX_CENT_OPF;
		private _dist2 = 3 - ((_dist2 / AIX_DIST_OPF) * 3);
		private _type = _x select 2;
		private _control = _x select 3;
		
		private _priority = 0;
		
		if (AIX_MODE_BLU == "ATTACK") then {
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
		
		private _priority = ((_dist1 + _dist2) / 2) + _type + _priority;
		_priority
	}, "DESCEND", {
		[_x select 0,_x select 1] inArea "AIX_BLU"
	}
] call BIS_fnc_sortBy;

AIX_ALL_OPF = [
	AIX_ALL_OPF, 
	[], 
	{
		private _dist1 = [_x select 0,_x select 1] distance AIX_CENT_OPF;
		private _dist1 = 3 - ((_dist1 / AIX_DIST_OPF) * 3);
		private _dist2 = [_x select 0,_x select 1] distance AIX_CENT_BLU;
		private _dist2 = 3 - ((_dist2 / AIX_DIST_BLU) * 3);
		private _type = _x select 2;
		private _control = _x select 3;
		
		private _priority = 0;
		
		if (AIX_MODE_OPF == "ATTACK") then {
			if (_control == 0) then {_priority = 1}; ///BLK
			if (_control == 1) then {_priority = 2}; ///BLU
			if (_control == 2) then {_priority = 0}; ///OPF
			if (_control == 3) then {_priority = 3}; ///CMB
		};
		
		if (AIX_MODE_OPF == "DEFEND") then {
			if (_control == 0) then {_priority = 1};
			if (_control == 1) then {_priority = 0};
			if (_control == 2) then {_priority = 3};
			if (_control == 3) then {_priority = 2};
		};		 
		
		if (AIX_MODE_OPF == "GAMBIT") then {
			if (_control == 0) then {_priority = 3};
			if (_control == 1) then {_priority = 0};
			if (_control == 2) then {_priority = 1};
			if (_control == 3) then {_priority = 2};
		};
		
		private _priority = ((_dist1 + _dist2) / 2) + _type + _priority;
		_priority
	}, "DESCEND", {
		[_x select 0,_x select 1] inArea "AIX_OPF"
	}
] call BIS_fnc_sortBy;

/// choose best 50% and per control
AIX_ALL_BLU = AIX_ALL_BLU select [0, ceil ((count AIX_ALL_BLU) / 2)];
AIX_ATK_BLU = AIX_ALL_BLU select {_x select 3 == 2};
AIX_DEF_BLU = AIX_ALL_BLU select {_x select 3 == 1};
AIX_REC_BLU = AIX_ALL_BLU select {_x select 3 == 0};

/// choose best 50% and per control
AIX_ALL_OPF = AIX_ALL_OPF select [0, ceil ((count AIX_ALL_OPF) / 2)];
AIX_ATK_OPF = AIX_ALL_OPF select {_x select 3 == 2};
AIX_DEF_OPF = AIX_ALL_OPF select {_x select 3 == 1};
AIX_REC_OPF = AIX_ALL_OPF select {_x select 3 == 0};

/// assign operational groups

AIX_ATK_G_BLU = [];
AIX_DEF_G_BLU = [];
AIX_REC_G_BLU = [];

AIX_ATK_G_OPF = [];
AIX_DEF_G_OPF = [];
AIX_REC_G_OPF = [];

/// sort groups
AIX_ATK_G_BLU = [AIX_ALL_G_BLU, [], {(_x getVariable "AIX_VAL") select 0}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_DEF_G_BLU = [AIX_ALL_G_BLU, [], {(_x getVariable "AIX_VAL") select 1}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_REC_G_BLU = [AIX_ALL_G_BLU, [], {(_x getVariable "AIX_VAL") select 2}, "DESCEND", {true}] call BIS_fnc_sortBy;

AIX_ATK_G_OPF = [AIX_ALL_G_OPF, [], {(_x getVariable "AIX_VAL") select 0}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_DEF_G_OPF = [AIX_ALL_G_OPF, [], {(_x getVariable "AIX_VAL") select 1}, "DESCEND", {true}] call BIS_fnc_sortBy;
AIX_REC_G_OPF = [AIX_ALL_G_OPF, [], {(_x getVariable "AIX_VAL") select 2}, "DESCEND", {true}] call BIS_fnc_sortBy;

/// choose best attack groups for attack
if (AIX_MODE_BLU == "ATTACK") then {
	AIX_ATK_G_BLU = AIX_ATK_G_BLU select [0, ceil ((count AIX_ATK_G_BLU) / 2)];
	AIX_DEF_G_BLU = AIX_DEF_G_BLU - AIX_ATK_G_BLU;
	AIX_DEF_G_BLU = AIX_DEF_G_BLU select [0, ceil ((count AIX_DEF_G_BLU) / 2)];
	AIX_REC_G_BLU = AIX_REC_G_BLU - (AIX_ATK_G_BLU + AIX_DEF_G_BLU);
};

/// choose best defence units for defence
if (AIX_MODE_BLU == "DEFEND") then {
	AIX_DEF_G_BLU = AIX_DEF_G_BLU select [0, ceil ((count AIX_DEF_G_BLU) / 2)];
	AIX_ATK_G_BLU = AIX_ATK_G_BLU - AIX_DEF_G_BLU;
	AIX_ATK_G_BLU = AIX_ATK_G_BLU select [0, ceil ((count AIX_ATK_G_BLU) / 2)];
	AIX_REC_G_BLU = AIX_REC_G_BLU - (AIX_ATK_G_BLU + AIX_DEF_G_BLU);
};

if (AIX_MODE_BLU == "GAMBIT") then {
	AIX_REC_G_BLU = AIX_REC_G_BLU select [0, ceil ((count AIX_REC_G_BLU) / 2)];
	AIX_DEF_G_BLU = AIX_DEF_G_BLU - AIX_REC_G_BLU;
	AIX_ATK_G_BLU = AIX_ATK_G_BLU select [0, ceil ((count AIX_ATK_G_BLU) / 2)];
	AIX_DEF_G_BLU = AIX_DEF_G_BLU - (AIX_REC_G_BLU + AIX_ATK_G_BLU);
};


if (AIX_MODE_OPF == "ATTACK") then {
	AIX_ATK_G_OPF = AIX_ATK_G_OPF select [0, ceil ((count AIX_ATK_G_OPF) / 2)];
	AIX_DEF_G_OPF = AIX_DEF_G_OPF - AIX_ATK_G_OPF;
	AIX_DEF_G_OPF = AIX_DEF_G_OPF select [0, ceil ((count AIX_DEF_G_OPF) / 2)];
	AIX_REC_G_OPF = AIX_REC_G_OPF - (AIX_ATK_G_OPF + AIX_DEF_G_OPF);
};

if (AIX_MODE_OPF == "DEFEND") then {
	AIX_DEF_G_OPF = AIX_DEF_G_OPF select [0, ceil ((count AIX_DEF_G_OPF) / 2)];
	AIX_ATK_G_OPF = AIX_ATK_G_OPF - AIX_DEF_G_OPF;
	AIX_ATK_G_OPF = AIX_ATK_G_OPF select [0, ceil ((count AIX_ATK_G_OPF) / 2)];
	AIX_REC_G_OPF = AIX_REC_G_OPF - (AIX_ATK_G_OPF + AIX_DEF_G_OPF);
};

if (AIX_MODE_OPF == "GAMBIT") then {
	AIX_REC_G_OPF = AIX_REC_G_OPF select [0, ceil ((count AIX_REC_G_OPF) / 2)];
	AIX_DEF_G_OPF = AIX_DEF_G_OPF - AIX_REC_G_OPF;
	AIX_ATK_G_OPF = AIX_ATK_G_OPF select [0, ceil ((count AIX_ATK_G_OPF) / 2)];
	AIX_DEF_G_OPF = AIX_DEF_G_OPF - (AIX_REC_G_OPF + AIX_ATK_G_OPF);
};

if (AIX_DEBUG) then {
	sleep 0.1;
	systemchat ("BLU ALL: " + str (count AIX_ALL_G_BLU) + " BLU ATK: " + str (count AIX_ATK_G_BLU) + " DEF: " + str (count AIX_DEF_G_BLU) + " REC: " + str (count AIX_REC_G_BLU) + " SUP: " + str (count AIX_SUP_G_BLU));
	systemchat ("OPF ALL: " + str (count AIX_ALL_G_OPF) + " OPF ATK: " + str (count AIX_ATK_G_OPF) + " DEF: " + str (count AIX_DEF_G_OPF) + " REC: " + str (count AIX_REC_G_OPF) + " SUP: " + str (count AIX_SUP_G_OPF));
	
	{
		private _pos = [_x select 0, _x select 1];
		private _index = _forEachIndex;
		private _mrk = createMarker ["AIX_OPS_B_" + str _index, _pos];
		_mrk setMarkerType "hd_dot";
		_mrk setMarkerText str _index;
		_mrk setMarkerColor "colorBLUFOR";
		_mrk setMarkerAlpha 0.25;
	}forEach AIX_ALL_BLU;
	
	{
		private _pos = [_x select 0, _x select 1];
		private _index = _forEachIndex;
		private _mrk = createMarker ["AIX_OPS_O_" + str _index, _pos];
		_mrk setMarkerType "hd_dot";
		_mrk setMarkerText str _index;
		_mrk setMarkerColor "colorOPFOR";
		_mrk setMarkerAlpha 0.25;
	}forEach AIX_ALL_OPF;
	
	{
		private _side = "n_";
		if (side _x == AIX_BLU) then {_side = "b_"};
		if (side _x == AIX_OPF) then {_side = "o_"};
		private _marker = "AIX_" + _side + groupID _x;
		private _text = "NAN";
		if (_x in AIX_ATK_G_BLU) then {_text = "ATK"};
		if (_x in AIX_DEF_G_BLU) then {_text = "DEF"};
		if (_x in AIX_REC_G_BLU) then {_text = "REC"};
		if (_x in AIX_SUP_G_BLU) then {_text = "SUP"};
		private _text = _text + " " + str (_x getVariable "AIX_VAL") + " " + str (_x getVariable "AIX_UNI") + " " + str (_x getVariable "AIX_VHS");
		_marker setMarkerText _text;
	}forEach AIX_ALL_G_BLU;
	
	{
		private _side = "n_";
		if (side _x == AIX_BLU) then {_side = "b_"};
		if (side _x == AIX_OPF) then {_side = "o_"};
		private _marker = "AIX_" + _side + groupID _x;
		private _text = "NAN";
		if (_x in AIX_ATK_G_OPF) then {_text = "ATK"};
		if (_x in AIX_DEF_G_OPF) then {_text = "DEF"};
		if (_x in AIX_REC_G_OPF) then {_text = "REC"};
		if (_x in AIX_SUP_G_OPF) then {_text = "SUP"};
		private _text = _text + " " + str (_x getVariable "AIX_VAL") + " " + str (_x getVariable "AIX_UNI") + " " + str (_x getVariable "AIX_VHS");
		_marker setMarkerText "ATK";
	}forEach AIX_ALL_G_OPF;
};