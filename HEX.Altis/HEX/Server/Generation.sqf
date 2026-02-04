/// coord steps for grid
private _hexX = HEX_SIZE * 1.5;
private _hexY = HEX_SIZE * sqrt 3;
private _hexS = worldSize;
private _count = ((count HEX_CFG_WEST) + (count HEX_CFG_EAST)) * 4;

HEX_GRID = [];

/// Grid generation
for "_col" from 0 to round(_hexS / _hexX) do {
    for "_row" from 0 to round(_hexS / _hexY) do {

        private _offset = if (_col mod 2 == 0) then {0} else {_hexY / 2};
        private _x = _col * _hexX;
        private _y = _row * _hexY + _offset;

        if (_x > _hexS or _y > _hexS) exitWith {};
		private _land = false;
		private _landL = !(surfaceisWater [_x - (HEX_SIZE / 2), _y]);
		private _landR = !(surfaceisWater [_x + (HEX_SIZE / 2), _y]);
		private _landB = !(surfaceisWater [_x, _y - (HEX_SIZE / 2)]);
		private _landT = !(surfaceisWater [_x, _y + (HEX_SIZE / 2)]);
		{if (_x == true) then {_land = true}}forEach [_landL, _landR, _landB, _landT];
        if (_land) then {
			HEX_GRID pushBack [_row, _col, [_x,_y], "hd_dot", civilian, 0, 0];
		};
    };
};

/// Select positon and restrict grid with fill, ignore if fullmap mode is on;
if (HEX_FULLMAP == false) then {HEX_GRID = [selectRandom HEX_GRID, _count] call HEX_GLO_FNC_FILL};

/// create grid overlay markers
0 call HEX_SRV_FNC_GRID;

{
	private _counter = _x;
	private _act = 0;
	if (_x in ["b_inf"]) then {_act = 1};
	if (_x in ["b_mech_inf", "b_armor", "b_antiair", "b_art", "b_support", "b_unknown", "b_mortar", "b_hq"]) then {_act = 2};
	if (_x in ["b_motor_inf", "b_recon"]) then {_act = 3};
	private _count = 10;
	if (_x in ["b_hq", "b_support", "b_mortar", "b_antiair", "b_art", "b_air", "b_plane", "b_uav"]) then {_count = 4};
	
	private _sorted = [
		HEX_GRID, 
		[], 
		{
			private _pos = _x select 2;
			private _posX = _pos select 0;
			private _posY = _pos select 1;
			_result = _posY;
			if (HEX_SCENARIO == "N") then {_result = _posY};
			if (HEX_SCENARIO == "E") then {_result = _posX};
			if (HEX_SCENARIO == "S") then {_result = -_posY};
			if (HEX_SCENARIO == "W") then {_result = -_posX};
			_result
		}, 
		"DESCEND", 
		{(_x select 3) == "hd_dot"}
	] call BIS_fnc_sortBy;
	private _hex = _sorted select 0;
	_hex set [3, _counter];
	_hex set [4, west];
	_hex set [5, _act];
	_hex set [6, _count];
}forEach HEX_CFG_WEST;

{
	private _counter = _x;
	private _act = 0;
	if (_x in ["o_inf"]) then {_act = 1};
	if (_x in ["o_hq", "o_unknown", "o_mortar", "o_mech_inf", "o_armor", "o_antiair", "o_art", "o_support"]) then {_act = 2};
	if (_x in ["o_motor_inf", "o_recon"]) then {_act = 3};
	private _count = 10;
	if (_x in ["o_hq", "o_support", "o_mortar", "o_antiair", "o_art", "o_air", "o_plane", "o_uav"]) then {_count = 4};
	
	private _sorted = [
		HEX_GRID, 
		[], 
		{
			private _pos = _x select 2;
			private _posX = _pos select 0;
			private _posY = _pos select 1;
			_result = _posY;
			if (HEX_SCENARIO == "N") then {_result = _posY};
			if (HEX_SCENARIO == "E") then {_result = _posX};
			if (HEX_SCENARIO == "S") then {_result = -_posY};
			if (HEX_SCENARIO == "W") then {_result = -_posX};
			_result
		}, 
		"ASCEND", 
		{(_x select 3) == "hd_dot"}
	] call BIS_fnc_sortBy;
	private _hex = _sorted select 0;
	_hex set [3, _counter];
	_hex set [4, east];
	_hex set [5, _act];
	_hex set [6, _count];
}forEach HEX_CFG_EAST;

/// Randomize Weather
HEX_WEATHER = ["CLEAR", "CLEAR", "CLEAR", "CLEAR", "CLOUDS", "CLOUDS", "STORM", "FOG"] select floor random 8;

publicVariable "HEX_GRID";
publicVariable "HEX_WEATHER";