/// Find counter in combat
/// counters tounching are in tactical array
private _tactical = [];
{
	private _hex = _x;
	private _cfg = _x select 3;
	private _sid = _x select 4;
	
	private _near = _hex call HEX_GLO_FNC_NEAR;
	private _sides = [_sid];

	{
		private _sid2 = _x select 4;
		_sides pushback _sid2;
	}forEach _near;

	if (resistance in _sides && (_cfg != "hd_dot" or _sid == resistance)) then {
		_tactical pushback _hex;
	};
}forEach HEX_GRID;

/// counters of strategic type and next to active are auxiliary/reserves
private _strategic = [];

{
	private _hex = _x;
	private _row = _x select 0;
	private _col = _x select 1;
	private _pos = _x select 2;
	private _cfg = _x select 3;
	private _sid = _x select 4;
	private _act = _x select 5;
	private _org = _x select 6;
	
	private _isStrat = false;
	if (_cfg in ["b_hq", "b_support", "b_mortar", "b_art", "b_antiair", "b_air", "b_plane", "b_uav"]) then {_isStrat = true};
	if (_cfg in ["o_hq", "o_support", "o_mortar", "o_art", "o_antiair", "o_air", "o_plane", "o_uav"]) then {_isStrat = true};
	
	private _near = _hex call HEX_GLO_FNC_NEAR;
	if (_isStrat) then {
		_strategic pushback _hex;
	};
}forEach HEX_GRID;

/// Start tactical phase
if (count _tactical > 0) then {
	HEX_TACTICAL = _tactical;
	HEX_STRATEGIC = _strategic;
	HEX_PHASE = "BRIEFING";
	publicVariable "HEX_PHASE";
	publicVariable "HEX_TACTICAL";
	publicVariable "HEX_STRATEGIC";
	
	/// Open briefing locally for all
	remoteExec ["HEX_LOC_FNC_BRIEFING", 0, false];
	
/// Changes current state only if still in strategic phase
} else {

	/// Switch turn globally
	private _turn = civilian;
	if (HEX_TURN == west) then {_turn = east};
	if (HEX_TURN == east) then {_turn = west};
	HEX_TURN = _turn;

	/// Create new weather
	HEX_WEATHER = ["CLEAR", "CLEAR", "CLEAR", "CLEAR", "CLOUDS", "CLOUDS", "STORM", "FOG"] select floor random 8;

	/// Create new time
	private _time = "NONE";
	if (HEX_TIME == "NIGHT") then {_time = "DAWN"};
	if (HEX_TIME == "DAWN") then {_time = "DAY1"};
	if (HEX_TIME == "DAY1") then {_time = "DAY2"};
	if (HEX_TIME == "DAY2") then {_time = "DAY3"};
	if (HEX_TIME == "DAY3") then {_time = "DUSK"};
	if (HEX_TIME == "DUSK") then {_time = "NIGHT"};

	HEX_TIME = _time;

	/// Set new day
	if (_time == "NIGHT") then {HEX_DAY = HEX_DAY + 1};

	/// Update grid counter moves;
	{
		private _index = _forEachIndex;
		private _hex = _x;
		private _cfg = _x select 3;
		private _sid = _x select 4;
	
		private _act = 0;
		if (HEX_TURN == _sid) then {
				if (_cfg in ["b_inf"]) then {_act = 1};
				if (_cfg in ["b_hq", "b_mech_inf", "b_armor", "b_antiair", "b_art", "b_antiair", "b_support", "b_unknown", "b_mortar"]) then {_act = 2};
				if (_cfg in ["b_motor_inf", "b_recon"]) then {_act = 3};
				if (_cfg in ["o_inf"]) then {_act = 1};
				if (_cfg in ["o_hq", "o_unknown", "o_mortar", "o_mech_inf", "o_armor", "o_antiair", "o_art", "o_antiair", "o_support"]) then {_act = 2};
				if (_cfg in ["o_motor_inf", "o_recon"]) then {_act = 3};
			_hex set [5, _act];
			HEX_GRID set [_index, _hex];
		};
	}forEach HEX_GRID;

	/// update variables globally
	publicVariable "HEX_DAY";
	publicVariable "HEX_TURN";
	publicVariable "HEX_TIME";
	publicVariable "HEX_WEATHER";
	publicVariable "HEX_GRID";

	/// update time and weather 
	call compile preprocessFile "HEX\Server\Time.sqf";

	/// Clear local orders, markers and sound
	remoteExec ["HEX_LOC_FNC_CLIC", 0, false];

	/// Update counters globally
	remoteExec ["HEX_LOC_FNC_COTE", 0, false];
}