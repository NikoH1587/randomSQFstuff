/// TODO: MAKE TASK GROUPS FOR TASKS (2x default rec, 1x default defend, 0x default attack
/// 	MAKE UNASSIGED GROUPS DO WAIT TASK?

/// Assign tasks to groups
{
	private _grp = _x;
	private _val = _grp getVariable "AIX_VAL";
	private _task = [AIX_CENT_BLU, _grp, 0, AIX_SIZE * 2]; /// Default FOB patrol
	
	if (count AIX_REC_BLU > 0) then {
		private _select = AIX_REC_BLU select floor random count AIX_REC_BLU;
		private _pos = _select select 0;
		private _rsk = 0;
		private _ctrl = _select select 1;
		if (_ctrl == 0) then {_rsk = 1}; /// FLIP FOR OPF
		if (_ctrl == 2) then {_rsk = 2}; /// FLIP FOR OPF
		private _isSec = _select select 2;
		
		_rad = AIX_SIZE * 2;
		if (_isSec) then {_rad = AIX_SIZE};
		_task = [_pos, _grp, _rsk, _rad];
	};
	
	_task call AIX_FNC_RECON
}forEach AIX_REC_G_BLU;

{
	private _grp = _x;
	private _val = _grp getVariable "AIX_VAL";
	private _veh = false;
	private _task = [[[[AIX_CENT_BLU, AIX_SIZE]], []] call BIS_fnc_randomPos, _grp, _veh, AIX_CENT_BLU getDir AIX_CENT_OPF]; /// Default FOB defence	
	
	if (count AIX_DEF_BLU > 0) then {
		private _select = AIX_DEF_BLU select floor random count AIX_DEF_BLU;
		private _pos = _select select 0;
		private _isSec = _select select 2;
		private _rad = AIX_SIZE;
		if (_isSec) then {_rad = AIX_SIZE / 2};
		private _pos = [[[_pos, _rad]], ["water"]] call BIS_fnc_randomPos;
		private _dir = _pos getDir AIX_CENT_OPF;
		_task = [_pos, _grp, _veh, _dir];
	};
	
	_task call AIX_FNC_DEFEND
}forEach AIX_DEF_G_BLU;

/// Tasks:
/// ATTACK (OBJ), ATTACK (GRP), ATTACK (FOB)
/// DEFEND (OBJ), DEFEND (FOB)
/// RECON (OBJ_OBJ), RECON (OBJ_SEC), PATROL (OBJ_BLU)  
///
/// RETREAT (OBJ), RETREAT (FOB), WAIT (POS)
/// AIRSTRIKE (GRP), FIREMISSION (GRP), TRANPORT (GRP)