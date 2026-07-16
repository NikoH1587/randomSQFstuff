/// TODO: MAKE TASK GROUPS FOR TASKS (2x default rec, 1x default defend, 0x default attack
/// 	MAKE UNASSIGED GROUPS DO WAIT TASK?

/// Assign task formations (based on personality)
AIX_ATK_F_BLU = [];
AIX_DEF_F_BLU = [];
AIX_REC_F_BLU = [];
private _bluATK = ceil ((count AIX_ATK_G_BLU) / (AIX_CMD_BLU select 6));
private _bluDEF = ceil ((count AIX_DEF_G_BLU) / (AIX_CMD_BLU select 7));
private _bluREC = ceil ((count AIX_REC_G_BLU) / (AIX_CMD_BLU select 8));

AIX_ATK_F_OPF = [];
AIX_DEF_F_OPF = [];
AIX_REC_F_OPF = [];
private _opfATK = ceil ((count AIX_ATK_G_OPF) / (AIX_CMD_OPF select 6));
private _opfDEF = ceil ((count AIX_DEF_G_OPF) / (AIX_CMD_OPF select 7));
private _opfREC = ceil ((count AIX_REC_G_OPF) / (AIX_CMD_OPF select 8));

for "_i" from 1 to _bluATK do {
	private _formation = AIX_ATK_G_BLU select [0, (AIX_CMD_BLU select 6)];
	AIX_ATK_F_BLU pushback _formation;
	AIX_ATK_G_BLU = AIX_ATK_G_BLU - _formation;
};

for "_i" from 1 to _bluDEF do {
	private _formation = AIX_DEF_G_BLU select [0, (AIX_CMD_BLU select 7)];
	AIX_DEF_F_BLU pushback _formation;
	AIX_DEF_G_BLU = AIX_DEF_G_BLU - _formation;
};

for "_i" from 1 to _bluREC do {
	private _formation = AIX_REC_G_BLU select [0, (AIX_CMD_BLU select 8)];
	AIX_REC_F_BLU pushback _formation;
	AIX_REC_G_BLU = AIX_REC_G_BLU - _formation;
};

for "_i" from 1 to _opfATK do {
	private _formation = AIX_ATK_G_OPF select [0, (AIX_CMD_OPF select 6)];
	AIX_ATK_F_OPF pushback _formation;
	AIX_ATK_G_OPF = AIX_ATK_G_OPF - _formation;
};

for "_i" from 1 to _opfDEF do {
	private _formation = AIX_DEF_G_OPF select [0, (AIX_CMD_OPF select 7)];
	AIX_DEF_F_OPF pushback _formation;
	AIX_DEF_G_OPF = AIX_DEF_G_OPF - _formation;
};

for "_i" from 1 to _opfREC do {
	private _formation = AIX_REC_G_OPF select [0, (AIX_CMD_OPF select 8)];
	AIX_REC_F_OPF pushback _formation;
	AIX_REC_G_OPF = AIX_REC_G_OPF - _formation;
};

/// TASKS SYSTEM: [_pos, _type, _risk, _sizeMod]
{
	private _types = ["DEFEND"];
	private _force = 0;
	private _groups = _x;
	
	{
		_force = _force + (_x getVariable "AIX_ATK");
	}forEach _groups;
	
	private _tasks = AIX_TASKS_BLU select {
		private _type = _x select 1;
		private _risk = _x select 2;
		
		_type in _types && _risk <= _force;
	};
	
	if (count _tasks > 0) then {
		_task = _tasks select floor random count _tasks; /// change to be based on formation position etc...?
		AIX_TASKS_BLU = AIX_TASKS_BLU - _task;
		
		{
			private _pos = _task select 0;
			private _grp = _x;
			private _veh = false;
			private _dir = _pos getDir AIX_CENT_OPF;
			[_pos, _grp, _veh, _dir] call AIX_FNC_DEFEND;
		}forEach _groups;
	};
}forEach AIX_DEF_F_BLU;

/// Tasks:
/// ATTACK (OBJ), ATTACK (GRP), ATTACK (FOB)
/// DEFEND (OBJ), DEFEND (FOB)
/// RECON (OBJ_OBJ), RECON (OBJ_SEC), PATROL (OBJ_BLU)  
///
/// RETREAT (OBJ), RETREAT (FOB), WAIT (POS)
/// AIRSTRIKE (GRP), FIREMISSION (GRP), TRANPORT (GRP)