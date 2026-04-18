private _AOpos = getMarkerPos "VOX_AO";
private _AOsize = (getMarkerSize "VOX_AO") select 0;

switch (VOX_SCENARIO) do {
	case "WEST": {_AOpos = [(_AOpos select 0) - _AOsize, _AOpos select 1, 0]};
	case "NORTH": {_AOpos = [_AOpos select 0, (_AOpos select 1) + _AOsize, 0]};
	case "EAST": {_AOpos = [(_AOpos select 0) + _AOsize, _AOpos select 1, 0]};
	case "SOUTH": {_AOpos = [_AOpos select 0, (_AOpos select 1) - _AOsize, 0]};
};

private _locations = [
	"NameCityCapital",
	"NameCity",
	"Hill",
	"NameVillage",
	"NameLocal"
];

private _allLocations = nearestLocations [_AOpos, _locations, _AOsize * 3];

/// make sure locations are not too close to each other
private _minDist = 1500;
private _filtered = [];

{
	private _pos = position _x;
	private _close = false;
	
	{
		if (_pos distance2D _x < _minDist) exitWith {
			_close = true;
		}
	}forEach _filtered;
	
	if (!_close) then {
		_filtered pushBack _pos;
	}
	
}forEach _allLocations;

{
	private _pos = _x;
	private _pos = [round (_pos select 0), round (_pos select 1)];
	 /// 0 position, 1 control, 2 cells, 3 neighboring seeds, 4 current unit, 5 unit status (0 or 1)
	 if (_pos inArea "VOX_AO") then {
		VOX_GRID pushback [_pos, "ColorBLACK", [], [], "hd_dot", 0];
	}
}forEach _filtered;

/// generate grid on valid positions
_fnc_nearest = {
	private _pos = _this;
	
	private _nearest = VOX_GRID select 0;
	private _minDist = _pos distance2D (_nearest select 0);
	
	{
		private _d = _pos distance2D (_x select 0);
		if (_d < _minDist) then {
			_minDist = _d;
			_nearest = _x;
		};
	}forEach VOX_GRID;
	
	_nearest
};


_cellmap = createHashMap;

for "_col" from 0 to round(worldSize / VOX_SIZE) do {
    for "_row" from 0 to round(worldSize / VOX_SIZE) do {
		_pos = [_col * VOX_SIZE, _row * VOX_SIZE];
		if (surfaceIsWater _pos or !(_pos inArea "VOX_AO")) then {continue};
		private _nearest = _pos call _fnc_nearest;
		
		(_nearest select 2) pushback [_col, _row];
		
		_cellmap set [[_col, _row], _nearest]
    };
};

/// filter out grids with not enough cells
private _minCells = 20;
VOX_GRID = VOX_GRID select {
	(count(_x select 2)) >= _minCells;
};

/// rebuild cellmap after filtering
_cellmap = createHashMap;

{
	_x set [2, []];
}forEach VOX_GRID;

for "_col" from 0 to round(worldSize / VOX_SIZE) do {
    for "_row" from 0 to round(worldSize / VOX_SIZE) do {
		_pos = [_col * VOX_SIZE, _row * VOX_SIZE];
		if (surfaceIsWater _pos or !(_pos inArea "VOX_AO")) then {continue};
		private _nearest = _pos call _fnc_nearest;
		
		(_nearest select 2) pushback [_col, _row];
		
		_cellmap set [[_col, _row], _nearest]
    };
};

/// markers for polygons
{
	private _cells = (_x select 2);
	///private _color = format ["#(%1,%2,%3)", random 1, random 1, random 1];	
	
	{
		private _pos = [(_x select 0) * VOX_SIZE, (_x select 1) * VOX_SIZE];
		private _marker = createMarker [str _pos, _pos];
		_marker setMarkerSize [VOX_SIZE / 2, VOX_SIZE / 2];
		_marker setMarkerShape "RECTANGLE";
		_marker setMarkerAlpha 0.25;
	}foreach _cells;
}forEach VOX_GRID;

/// get neighboring seeds
_fnc_findSeeds = {
	private _col = _x select 0;
	private _row = _x select 1;
	private _dirs = [[-1, 0],[1, 0],[0, -1],[0, 1]];
	private _seeds = [];
	{
		private _nCol = _col + (_x select 0);
		private _nRow = _row + (_x select 1);
		
		private _neighbor = _cellmap get [_nCol, _nRow];
		if (!isNil "_neighbor") then {
			private _seedPos = _neighbor select 0;
			_seeds pushBackUnique _seedPos;
		}
	}forEach _dirs;
	
	_seeds
};

{	
	private _pos = _x select 0;
	private _cells = _x select 2;
	private _seeds = [];
	
	{
		private _cellSeeds = _x call _fnc_findSeeds;
		private _edge = false;
		{
			if !(_x isEqualTo _pos) then {
				_seeds pushBackUnique _x;
				_edge = true;
			};
		}forEach _cellSeeds;
		
		if (_edge) then {
			private _pos = [(_x select 0) * VOX_SIZE, (_x select 1) * VOX_SIZE];
			private _marker = str _pos;
			_marker setMarkerAlpha 0.75;
			_marker setMarkerBrush "Solid";
		};
	}forEach _cells;
	
	_x set [3, _seeds];
}forEach VOX_GRID;

/// debug markers for connected seeds;
if (VOX_DEBUG) then {
	{
		private _pos = _x select 0;
		private _neighbors = _x select 3;
	
		{
			private _polyline = [_x select 0, _x select 1, _pos select 0, _pos select 1];
			private _marker = createMarker [str _polyline, _pos];
			_marker setMarkerShape "Polyline";
			_marker setMarkerPolyline _polyline;
			_marker setMarkerAlpha 0.1;
		}forEach _neighbors;
	}forEach VOX_GRID;
};

/// place starting objectives
private _westHQ = VOX_GRID select 0;
_westHQ set [1, "ColorBLUFOR"];

private _eastHQ = VOX_GRID select ((count VOX_GRID) - 1);
_eastHQ set [1, "ColorOPFOR"];