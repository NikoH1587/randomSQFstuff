/// spawn strategic units
{
	private _hex = _x;
	private _row = _x select 0;
	private _col = _x select 1;
	private _pos = _x select 2;
	private _type = _x select 3;
	private _side = _x select 4;
	private _count = _x select 6; /// how many groups are stored
	
	private _factions = [HEX_WEST];
	if (_side == east) then {_factions = [HEX_EAST]};
	private _configs = [_factions, _type] call HEX_SRV_FNC_VEHICLES;
	
	private _select = _configs select floor random count _configs;
	private _group = [_pos, _side, _select] call HEX_FNC_SRV_SPAWNVEHICLE;
	_group setVariable ["HEX_ICON", _type, true];
	_group setVariable ["HEX_ID", [_row, _col], true];
	_group setVariable ["MARTA_customIcon", [_type], true];
	_group deleteGroupWhenEmpty true;
	
	if (_type == "b_hq") then {
		HEX_OFFICER_WEST = (units _group) select 0;
	};
	
	if (_type == "o_hq") then {
		HEX_OFFICER_EAST = (units _group) select 0;
	};
}forEach HEX_STRATEGIC;

/// Start 1h counter, call debriefing after
HEX_PHASE = "TACTICAL";
publicVariable "HEX_PHASE";

private _martaGRP = createGroup sideLogic;
private _marta = "MartaManager" createUnit [
	[0, 0, 0],
	_martaGRP,
	"setGroupIconsVisible [true, false];"
];

HEX_REQ_WEST synchronizeObjectsAdd [HEX_OFFICER_WEST];
private _westGroups = west call HEX_LOC_FNC_GROUPS;
private _drones = false;

{
	private _group = _x;
	private _icon = _group getVariable "HEX_ICON";
	private _leader = [vehicle leader _group];
	HEX_OFFICER_WEST hcSetGroup [_group];
	
	switch (_icon) do {
		case "b_mortar": {HEX_ART_WEST synchronizeObjectsAdd _leader};	
		case "b_art": {HEX_ART_WEST synchronizeObjectsAdd _leader};
		case "b_antiair": {};
		case "b_air": {HEX_HAT_WEST synchronizeObjectsAdd _leader; HEX_TRA_WEST synchronizeObjectsAdd _leader};
		case "b_plane": {HEX_CAS_WEST synchronizeObjectsAdd _leader};
		case "b_uav": {_drones = true};
		case "b_support": {};
	};
}forEach _westGroups;

if (_drones) then {
	HEX_OFFICER_WEST linkItem "B_UavTerminal"; 
};

HEX_BUNKER_WEST setpos (getPos HEX_OFFICER_WEST);

HEX_REQ_EAST synchronizeObjectsAdd [HEX_OFFICER_EAST];
private _eastGroups = east call HEX_LOC_FNC_GROUPS;
private _drones = false;

{
	private _group = _x;
	private _icon = _group getVariable "HEX_ICON";
	private _leader = [vehicle leader _group];
	HEX_OFFICER_EAST hcSetGroup [_group];
	switch (_icon) do {

		case "o_mortar": {HEX_ART_EAST synchronizeObjectsAdd _leader};	
		case "o_art": {HEX_ART_EAST synchronizeObjectsAdd _leader};
		case "o_antiair": {};
		case "o_air": {HEX_HAT_EAST synchronizeObjectsAdd _leader; HEX_TRA_EAST synchronizeObjectsAdd _leader};
		case "o_plane": {HEX_CAS_EAST synchronizeObjectsAdd _leader};
		case "o_uav": {_drones = true};
		case "o_support": {};
	};
}forEach _eastGroups;

if (_drones) then {
	HEX_OFFICER_EAST linkItem "O_UavTerminal"; 
};

HEX_BUNKER_EAST setpos (getPos HEX_OFFICER_EAST);

/// remove all other (grid?) markers
0 call HEX_SRV_FNC_GRIDDELETE;

/// Close tactical briefing locally
remoteExec ["HEX_LOC_FNC_CLOSEBRIEFING", 0, false];

HEX_OBJECTIVES = []; /// objective positions
{
	private _hex = _x;
	private _row = _x select 0;
	private _col = _x select 1;
	private _pos = _x select 2;
	private _type = _x select 3;
	private _side = _x select 4;
	private _count = _x select 6; /// how many groups are stored

	private _name = format ["HEX_TAC_%1_%2", _row, _col];
	private _marker = createMarker [_name, _pos];
	
		/// create TAC markers;
	if (_side != resistance) then {
		_marker setMarkerType _type;
		_marker setMarkerSize [1.5, 1.5];
		_marker setMarkerAlpha 0.5;
		HEX_OBJECTIVES pushbackUnique _pos;
	};
	
	/// add locations to objectives
	private _locs = nearestLocations [_pos, ["hill", "NameCityCapital", "NameCity", "NameVillage", "NameLocal"], HEX_SIZE];
	{
		private _locPos = position _x;
		HEX_OBJECTIVES pushbackUnique [_locPos select 0, _locPos select 1];
	} forEach _locs;
}ForEach HEX_TACTICAL;

/// create objective markers
{
	private _pos = _x;
	private _name = format ["HEX_OBJ_%1", _forEachIndex];
	private _marker = createMarker [_name, _pos];
	_marker setMarkerShape "HEXAGON";
	_marker setMarkerBrush "Solid";
	_marker setMarkerAlpha 0.5;
	_marker setMarkerDir 90;
	_marker setMarkerSize [HEX_SIZE / 3, HEX_SIZE / 3];	
}forEach HEX_OBJECTIVES;

/// start game functions loop and spawn tactical groups
execVM "HEX\Server\Game.sqf";

sleep 5;

/// remove all counter markers;
remoteExec ["HEX_LOC_FNC_COTEDELETE", 0, true];

/// Open Slotting menu locally with JIP
remoteExec ["HEX_LOC_FNC_SLOTTING", 0, true];