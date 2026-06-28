/// objective tracking

{
	private _obj = _x;
	private _pos = _obj select 0;
	private _isSec = _obj select 2;
	private _color = "Default";
	private _size = AIX_SIZE;
	if (_isSec) then {_size = AIX_SIZE/2};
	private _blu = false;
	private _opf = false;
	private _cmb = false;
	
	{
		private _grp = _x;
		private _ldr = leader _grp;
		private _side = side _grp;
		private _posLdr = getPosATL _ldr;
		private _distance = _posLdr distance _pos;
		
		if (_distance < _size) then {
			if (_side == AIX_BLU) then {
				_blu = true;
				if (AIX_OPF knowsAbout _ldr > 0) then {
					_cmb = true;
				};
			};
			if (_side == AIX_OPF) then {
				_opf = true;
				if (AIX_BLU knowsAbout _ldr > 0) then {
					_cmb = true;
				};
			};
		};
	}forEach allGroups;
	
	/// DO NOT SET TO: _obj set [2, 0]; ACTS AS "MEMORY"
	if (_blu && !_opf) then {_obj set [1, 1]; _color = "ColorWEST"};
	if (_opf && !_blu) then {_obj set [1, 2]; _color = "ColorEAST"};
	if (_cmb) then {_obj set [1, 3]; _color = "ColorCIV"};
	
	/// _x set [2, _control];
	// 1,2
	if (AIX_DEBUG) then {
		private _mrk = createMarker ["AIX_OBJ_" + str _forEachIndex, _pos];
		_mrk setMarkerShape "ELLIPSE";
		_mrk setMarkerBrush "Border";
		_mrk setMarkerSize [_size, _size];
		_mrk setMarkerColor _color;
	};
}forEach AIX_OBJ;

AIX_ATK_BLU = AIX_OBJ select {_x select 1 == 3}; /// Attack
AIX_DEF_BLU = AIX_OBJ select {_x select 1 == 1}; /// Defend
AIX_REC_BLU = AIX_OBJ select {_x select 1 in [0, 2]}; /// Recon
AIX_ALL_BLU = AIX_ATK_BLU + AIX_DEF_BLU + AIX_REC_BLU;

AIX_ATK_OPF = AIX_OBJ select {_x select 1 == 3}; /// Attack
AIX_DEF_OPF = AIX_OBJ select {_x select 1 == 2}; /// Defend
AIX_REC_OPF = AIX_OBJ select {_x select 1 in [0, 1]}; /// Recon
AIX_ALL_OPF = AIX_ATK_OPF + AIX_DEF_OPF + AIX_REC_OPF;


/// Sort objectives based on distance to centers
private _bluCentX = 0;
private _bluCentY = 0;
private _opfCentX = 0;
private _opfCentY = 0;
private _posBlu = count AIX_POS_BLU;
private _posOpf = count AIX_POS_OPF;

{
	_bluCentX = _bluCentX + (_x select 0);
	_bluCentY = _bluCentY + (_x select 1);
}forEach AIX_POS_BLU;

{
	_opfCentX = _opfCentX + (_x select 0);
	_opfCentY = _opfCentY + (_x select 1);
}forEach AIX_POS_OPF;

AIX_CENT_BLU = [_bluCentX / _posBlu, _bluCentY / _posBlu];
AIX_CENT_OPF = [_opfCentX / _posOpf, _opfCentY / _posOpf];
AIX_CENT_ALL = [((AIX_CENT_BLU select 0) + (AIX_CENT_OPF select 0)) / 2, ((AIX_CENT_BLU select 1) + (AIX_CENT_OPF select 1)) / 2];

AIX_ATK_BLU = [AIX_ATK_BLU, [], {(_x select 0) distance AIX_CENT_BLU}, "ASCEND", {true}] call BIS_fnc_sortBy;
AIX_DEF_BLU = [AIX_DEF_BLU, [], {(_x select 0) distance AIX_CENT_OPF}, "ASCEND", {true}] call BIS_fnc_sortBy;
AIX_REC_BLU = [AIX_REC_BLU, [], {(_x select 0) distance AIX_CENT_BLU}, "ASCEND", {true}] call BIS_fnc_sortBy;
AIX_ATK_OPF = [AIX_ATK_OPF, [], {(_x select 0) distance AIX_CENT_OPF}, "ASCEND", {true}] call BIS_fnc_sortBy;
AIX_DEF_OPF = [AIX_DEF_OPF, [], {(_x select 0) distance AIX_CENT_BLU}, "ASCEND", {true}] call BIS_fnc_sortBy;
AIX_REC_OPF = [AIX_REC_OPF, [], {(_x select 0) distance AIX_CENT_OPF}, "ASCEND", {true}] call BIS_fnc_sortBy;

/// Calculate operational weights
AIX_ATK_W_BLU = AIX_VAL_BLU / AIX_VAL_OPF;
AIX_DEF_W_BLU = AIX_VAL_OPF / AIX_VAL_BLU;
AIX_REC_W_BLU = 1 - (count AIX_ENY_G_BLU / (count AIX_ALL_G_OPF + count AIX_SUP_G_OPF));
AIX_ALL_W_BLU = AIX_ATK_W_BLU + AIX_DEF_W_BLU + AIX_REC_W_BLU;

AIX_ATK_W_BLU = (AIX_ATK_W_BLU / AIX_ALL_W_BLU) * (AIX_CMD_BLU select 0);
AIX_DEF_W_BLU = (AIX_DEF_W_BLU / AIX_ALL_W_BLU) * (AIX_CMD_BLU select 1);
AIX_REC_W_BLU = (AIX_REC_W_BLU / AIX_ALL_W_BLU) * (AIX_CMD_BLU select 2);

AIX_ATK_W_OPF = AIX_VAL_OPF / AIX_VAL_BLU;
AIX_DEF_W_OPF = AIX_VAL_BLU / AIX_VAL_OPF;
AIX_REC_W_OPF = 1 - (count AIX_ENY_G_OPF / (count AIX_ALL_G_BLU + count AIX_SUP_G_BLU));
AIX_ALL_W_OPF = AIX_ATK_W_OPF + AIX_DEF_W_OPF + AIX_REC_W_OPF;

AIX_ATK_W_OPF = (AIX_ATK_W_OPF / AIX_ALL_W_OPF) * (AIX_CMD_OPF select 0);
AIX_DEF_W_OPF = (AIX_DEF_W_OPF / AIX_ALL_W_OPF) * (AIX_CMD_OPF select 1);
AIX_REC_W_OPF = (AIX_REC_W_OPF / AIX_ALL_W_OPF) * (AIX_CMD_OPF select 2);

if (AIX_DEBUG) then {
	
	systemchat str ("BLU VAL: " + str AIX_VAL_BLU + " ATK_W: " +  str AIX_ATK_W_BLU + " DEF_W: " +  str AIX_DEF_W_BLU + " REC_W: " +  str AIX_REC_W_BLU);
	systemchat str ("OPF VAL: " + str AIX_VAL_OPF + " ATK_W: " +  str AIX_ATK_W_OPF + " DEF_W: " +  str AIX_DEF_W_OPF + " REC_W: " +  str AIX_REC_W_OPF);	
	
	createMarker ["AIX_BLU", AIX_CENT_BLU];
	createMarker ["AIX_OPF", AIX_CENT_OPF];
	createMarker ["AIX_CNT", AIX_CENT_ALL];
	"AIX_BLU" setMarkerType "b_hq";
	"AIX_OPF" setMarkerType "o_hq";
	"AIX_CNT" setMarkerType "n_hq";
};