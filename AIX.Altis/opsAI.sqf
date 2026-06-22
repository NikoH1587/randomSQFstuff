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
		
		private _priority = _dist1 + _dist2 + _type + _priority;
		_priority
	}, "DESCEND", {
		[_x select 0,_x select 1] inArea "AIX_BLU"
	}
] call BIS_fnc_sortBy;

AIX_ATK_BLU = AIX_ALL_BLU select {_x select 3 == 2};
AIX_DEF_BLU = AIX_ALL_BLU select {_x select 3 == 1};
AIX_REC_BLU = AIX_ALL_BLU select {_x select 3 == 0};


///AIX_ALL_BLU = AIX_ALL_BLU select [0, ceil ((count AIX_ALL_BLU) / 2)];

if (AIX_DEBUG) then {
	private _count = count AIX_REC_BLU;
	{
		private _pos = [_x select 0, _x select 1];
		private _index = _forEachIndex;
		private _mrk = createMarker ["AIX_OPS_" + str _index, _pos];
		_mrk setMarkerType "hd_dot";
		private _dist = [_x select 0,_x select 1] distance AIX_CENT_BLU;
		private _dist = 3 - ((_dist / AIX_DIST_BLU) * 3);
		_mrk setMarkerText str (round _dist);
		if (_index == 0) then {
			_mrk setMarkerColor "colorRED";
		} else {
			_mrk setMarkerAlpha (1 - (_index / _count));
		}
	}forEach AIX_REC_BLU;
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