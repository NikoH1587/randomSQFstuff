/// TODO: make players receive orders as tasks

private _cellRad = AIX_SIZE/2;

_fnc_recon = {
	private _group = _this select 0;
	private _cells = _this select 1;
	private _trg1 = _cells 0;
	private _trg2 = _cells 1;
	private _trg3 = _cells 2;
	private _pos1 = [_trg1 select 0, _trg1 select 1];
	private _pos2 = [_trg1 select 0, _trg1 select 1];
	private _pos3 = [_trg1 select 0, _trg1 select 1];
	
    private _wp1 = _group addWaypoint [_trg1, _cellRad];
	_wp1 setWaypointFormation "COLUMN";
	_wp1 setWaypointBehaviour "AWARE";
	_wp2 setWaypointCombatMode "GREEN";
	_wp1 setWaypointSpeed "NORMAL";
    private _wp2 = _group addWaypoint [_trg2, _cellRad];
	_wp1 setWaypointFormation "WEDGE";
	_wp2 setWaypointBehaviour "STEALTH";
    private _wp3 = _group addWaypoint [_trg3, _cellRad];
};

_fnc_patrol = {
	private _group = _this select 0;
	private _cells = _this select 1;
	private _trg1 = _cells select 0;
	private _trg2 = _cells select 1;
	private _trg3 = _cells select 2;
	private _pos1 = [_trg1 select 0, _trg1 select 1];
	private _pos2 = [_trg1 select 0, _trg1 select 1];
	private _pos3 = [_trg1 select 0, _trg1 select 1];
	
    private _wp1 = _group addWaypoint [_trg1, _cellRad];
	_wp1 setWaypointFormation "COLUMN";
	_wp1 setWaypointBehaviour "AWARE";
	_wp2 setWaypointCombatMode "GREEN";
	_wp1 setWaypointSpeed "NORMAL";
    private _wp2 = _group addWaypoint [_trg2, _cellRad];
	_wp1 setWaypointFormation "WEDGE";
	_wp2 setWaypointBehaviour "SAFE";
    private _wp3 = _group addWaypoint [_trg3, _cellRad];
};

_fnc_attackINF = {};

_fnc_attackVEH = {};

_fnc_defendINF = {};

_fnc_defendVEH = {};

_fnc_transport = {};

_fnc_airstrike = {};

_fnc_firemission = {};

_fnc_airpatrol = {};