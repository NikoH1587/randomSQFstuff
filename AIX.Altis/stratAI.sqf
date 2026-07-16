/// Get group values, sort to manoeuvre and support array
_val_blu = 0;
_val_opf = 0;
_grp_blu = []; /// [_grp];
_sup_blu = [];
_grp_opf = [];
_sup_opf = [];

{
	private _grp = _x;
	private _ldr = leader _grp;
	private _side = side _grp;
	private _sup = _grp getVariable "AIX_SUP";
	private _val = _grp getVariable "AIX_VAL";
	
	if (isNil "_sup") then {continue};
	
	if (_side == AIX_BLU) then {
		if (!_sup) then {_grp_blu pushback _grp};
		if (_sup) then {_sup_blu pushback _grp};
		_val_blu = _val_blu + _val;
	};
	
	if (_side == AIX_OPF) then {
		if (!_sup) then {_grp_opf pushback _grp};
		if (_sup) then {_sup_opf pushback _grp};
		_val_opf = _val_opf + _val;		
	};
}forEach allGroups;

/// Calculate number of sections (based on commander personality)
_bluDIV = count _grp_blu/ ((AIX_CMD_BLU select 0) - 1);
_opfDIV = count _grp_opf/ ((AIX_CMD_OPF select 0) - 1);

/// Assign groups to sections
AIX_ORBAT = [[],[],[],[],[]]; /// [[_group, _group],[_group, _group],[_group]]

AIX_ORBAT_BLU = AIX_ORBAT select [0, AIX_CMD_BLU select 0];
AIX_ORBAT_OPF = AIX_ORBAT select [0, AIX_CMD_OPF select 0];

{
	private _idx = _forEachIndex;
	private _plt = _sup_blu;
	
	if (_idx != 0) then {
		_plt = _grp_blu select [0, _bluDIV];
		_grp_blu = _grp_blu - _plt;
	};
	
	AIX_ORBAT_BLU set [_idx, _plt];
}forEach AIX_ORBAT_BLU;

{
	private _idx = _forEachIndex;
	private _plt = _sup_opf;
	
	if (_idx != 0) then {
		_plt = _grp_opf select [0, _opfDIV];
		_grp_opf = _grp_opf - _plt;
	};
	
	AIX_ORBAT_OPF set [_idx, _plt];
}forEach AIX_ORBAT_OPF;

/// set COM and VAL to sections
/// ORBAT = [[_group, _group], [0, 0], 0];
{
	private _idx = _forEachIndex;
	private _val = 0;
	private _posX = 0;
	private _posY = 0;
	
	private _groups = _x;
	private _count = 0;
	{
		private _valG = _x getVariable "AIX_VAL";
		private _ldr = leader _x;
		private _pos = getPosASL _ldr;
		if (_pos select 0 != 0) then {
			_val = _val + _valG;
			_posX = _posX + (_pos select 0);
			_posY = _posY + (_pos select 1);
			_count = _count + 1;
		};
	}forEach _groups;
	
	AIX_ORBAT_BLU set [_idx, [_groups, [_posX / _count, _posY / _count], _val]];
}forEach AIX_ORBAT_BLU;

{
	private _idx = _forEachIndex;
	private _val = 0;
	private _posX = 0;
	private _posY = 0;
	
	private _groups = _x;
	private _count = 0;
	{
		private _valG = _x getVariable "AIX_VAL";
		private _ldr = leader _x;
		private _pos = getPosASL _ldr;
		if (_pos select 0 != 0) then {
			_val = _val + _valG;
			_posX = _posX + (_pos select 0);
			_posY = _posY + (_pos select 1);
			_count = _count + 1;
		};
	}forEach _groups;
	
	AIX_ORBAT_OPF set [_idx, [_groups, [_posX / _count, _posY / _count], _val]];
}forEach AIX_ORBAT_OPF;

/// set side strategy

if (AIX_DEBUG) then {

	{
		private _idx = _forEachIndex;
		private _color = "ColorWHITE";
		private _pos = _x select 1;
		private _val = _x select 2;
		
		switch (_idx) do {
			case 1: {_color = "colorRED"};
			case 2: {_color = "colorGREEN"};
			case 3: {_color = "colorYELLOW"};
			case 4: {_color = "colorBLUE"};
		};
		
		{
			private _mrk = "AIX_b_" + groupID _x;
			_mrk setMarkerColor _color;
		}forEach (_x select 0);
		
		private _mrkName = "AIX_B_" + str _idx;
		createMarker ["AIX_B_" + str _idx, _pos];
		_mrkName setMarkerType "b_hq";
		_mrkName setMarkerPos _pos;
		_mrkName SetMarkerColor _color;
		_mrkName setMarkerText str _val;
	}forEach AIX_ORBAT_BLU;
	
	{
		private _idx = _forEachIndex;
		private _color = "ColorWHITE";
		private _pos = _x select 1;
		private _val = _x select 2;
		
		switch (_idx) do {
			case 1: {_color = "colorRED"};
			case 2: {_color = "colorGREEN"};
			case 3: {_color = "colorYELLOW"};
			case 4: {_color = "colorBLUE"};
		};
		
		{
			private _mrk = "AIX_o_" + groupID _x;
			_mrk setMarkerColor _color;
		}forEach (_x select 0);
		
		private _mrkName = "AIX_O_" + str _idx;
		createMarker ["AIX_O_" + str _idx, _pos];
		_mrkName setMarkerType "o_hq";
		_mrkName setMarkerPos _pos;
		_mrkName SetMarkerColor _color;
		_mrkName setMarkerText str _val;
	}forEach AIX_ORBAT_OPF;
	
};