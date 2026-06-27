AIX_FNC_RECON = {
	private _pos = _this select 0;
	private _grp = _this select 1;
	private _rsk = _this select 2; /// 0 - BLU; 1 - BLK; 2 - ENY
	private _rad = _this select 3;
	
	private _posGrp = getPosASL leader _grp;
	private _posMid = [((_pos select 0) + (_posGrp select 0)) / 2, ((_pos select 1) + (_posGrp select 1)) / 2];
	
	private _behaviour = ["SAFE", "AWARE", "STEALTH"] select _rsk;
	
    private _wp1 = _grp addWaypoint [_posMid, _rad];
	_wp1 setWaypointFormation "COLUMN";
	_wp1 setWaypointBehaviour "AWARE";
	_wp1 setWaypointCombatMode "GREEN";
	_wp1 setWaypointSpeed "NORMAL";
	
    private _wp2 = _grp addWaypoint [_pos, _rad];
	_wp2 setWaypointFormation "WEDGE";
	_wp2 setWaypointBehaviour _behaviour;
    private _wp3 = _grp addWaypoint [_pos, _rad];
};

/// modifier for speed if groups is infantry/motorized
AIX_FNC_ATTACK = {};

/// modifier for speed if groups is infantry/motorized
AIX_FNC_DEFEND = {
	private _pos = _this select 0;
	private _grp = _this select 1;
	private _veh = _this select 2;
	private _dir = _this select 3; /// TODO: add wp0 in opposite dir so group faces likely enemy dir
	
	private _mode = "RED";
	private _building = nearestBuilding _pos;
	if (_building distance _pos < 100) then {
		_pos = getPos _building; 
		_mode = "YELLOW";
	};
	
	private _wp1 = _grp addWaypoint [_pos, -1];
	_wp1 setWaypointFormation "WEDGE";
	_wp1 setWaypointBehaviour "AWARE";
	_wp1 setWaypointCombatMode _mode;
	_wp1 setWaypointSpeed "NORMAL";
};

/// modifier is transported group
AIX_FNC_TRANSPORT = {};

AIX_FNC_AIRSTRIKE = {};

AIX_FNC_FIREMISSION = {};

AIX_FNC_AIRPATROL = {};