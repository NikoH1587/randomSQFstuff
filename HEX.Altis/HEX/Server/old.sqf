	for "_i" from 1 to _amount do {
		private _select = _groups selectRandomWeighted _weights;
		private _config = "true" configClasses _select;
		if (_armor) then {_config = [_config select 0]};
	
		private _group = createGroup _side;
		_group setVariable ["HEX_ICON", _type, true];
		private _pos2 = [_pos, 0, HEX_SIZE / 2, 5, 0, 0, 0, [], _pos] call BIS_fnc_findSafePos;
		private _crews = [];
		
		private _infantry = [];
		private _vehicles = [];
		
		{
			private _vehCfg = getText (_x >> "vehicle");
			private _rank = getText (_x >> "rank");
			private _cfg = (configFile >> "CfgVehicles" >> _vehCfg);
			private _isMan = getNumber (_cfg >> "isMan");
			
			if (_isMan == 1) then {
				_infantry pushback [_rank, _vehCfg];
			} else {
				_vehicles pushback [_rank, _vehCfg];				
			};
		}forEach _config;
		
		
		_infantry deleteRange [8, 16];
		
		{
			private _rnkI = _x select 0;
			private _vehI = _x select 1;
			private _unit = _vehI createUnit [_pos2, _group, "", 1, _rnkI];	
		}forEach _infantry;
		
		{
			private _rnkV = _x select 0;
			private _vehV = _x select 1;
			private _pos3 = [_pos2, 0, 50, 5, 0, 0, 0, [], _pos2] call BIS_fnc_findSafePos;
			private _spawned = [_pos3, 0, _vehV, _group] call BIS_fnc_spawnVehicle;
			private _crew = _spawned select 1;
			{_x setSkill 1}forEach _crew;
			(_crew select 0) setRank "PRIVATE";
			if (count _crew > 0) then {(_crew select 1) setRank "CORPORAL"};
			if (count _crew > 1) then {(_crew select 2) setRank "SERGEANT"};
		}forEach _vehicles;
		
		if (count _infantry > 0) then {
				_group selectLeader ((units _group) select 0);
			} else {
				private _count = count units _group;
				_group selectLeader ((units _group) select (_count - 1));
		};		
		
		if (_side == west && HEX_SINGLEPLAYER) then {{addSwitchableUnit _x}forEach (units _group)};
		/// TODO: PERFORMANCE TESTING
		_group addWaypoint [_pos, HEX_SIZE / 2];
	};
	
/// Create subgrid overlay on server
HEX_SRV_FNC_SUBGRID = {
	{
		private _row = _x select 0;
		private _col = _x select 1;
		private _idx = _x select 2;
		private _pos = _x select 3;
		private _name = format ["HEX_%1_%2_%3", _row, _col, _idx];
		private _marker = createMarker [_name, _pos];
		_marker setMarkerShape "HEXAGON";
		_marker setMarkerBrush "Border";
		_marker setMarkerDir 90;
		_marker setMarkerSize [HEX_SIZE / 4, HEX_SIZE / 4];
	}forEach HEX_SUBGRID;
};

/// create sub-grid
{
	private _row = _x select 0;
	private _col = _x select 1;
	private _pos = _x select 2;
	private _marker = format ["HEX_%1_%2", _row, _col];
	private _types = ["NameCityCapital","NameCity","NameVillage","NameLocal","Hill"];
	private _locs = nearestLocations [_pos, _types, HEX_SIZE];
	private _posLocs = [];
	
	{
		private _posLoc = position _x;
		if (_posLoc inArea _marker) then {
			_posLocs pushback [_posLoc select 0, _posLoc select 1];
		}
	}forEach _locs;
	
	{
		private _pos2 = _x;
		private _idx = _forEachIndex;
		HEX_SUBGRID pushback [_row, _col, _idx, _pos2, "hd_dot", civilian, 0, 0, "colorBLACK"];
	}forEach _posLocs;
}forEach HEX_GRID;	
	
	
/// performacne testing

private _testWest = west call HEX_LOC_FNC_GROUPS;
{
	private _obj = HEX_OBJECTIVES_NEUT select floor random count HEX_OBJECTIVES_NEUT;
	private _pos = _obj select 2;
	private _wp = _x addWaypoint [_pos, HEX_SIZE];
}forEach _testWest;

private _testEast = east call HEX_LOC_FNC_GROUPS;
{
	private _obj = HEX_OBJECTIVES_NEUT select floor random count HEX_OBJECTIVES_NEUT;
	private _pos = _obj select 2;
	private _wp = _x addWaypoint [_pos, HEX_SIZE];
}forEach _testEast;

{
	private _unit = _x;
	if (side _unit == west && HEX_SINGLEPLAYER) then {addSwitchableUnit _unit};
}forEach AllUnits;


/// (re)spawn tactical groups
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
	
	private _armor = false;
	if (_type in ["b_armor", "o_armor"]) then {_armor = true};
	private _groupsAndWeights = [_factions, _type] call HEX_SRV_FNC_GROUPS;
	private _weights = [];
	private _groups = [];
	
	{
		_weights pushback (_x select 0);
		_groups pushback (_x select 1);
	}ForEach _groupsAndWeights;
	
	/// remove groups from pool
	[_hex, _amount] call HEX_SRV_FNC_SUBTRACT;
	
	for "_i" from 1 to _amount do {
		private _select = _groups selectRandomWeighted _weights;
		private _config = "true" configClasses _select;
		if (_armor) then {_config = [_config select 0]};
	
		private _group = [_pos, _side, _config, _type] call HEX_FNC_SRV_SPAWNGROUP;
		_group setVariable ["HEX_ICON", _type, true];
		_group setVariable ["HEX_ID", [_row, _col], true];
		_group setVariable ["MARTA_customIcon", [_type], true];
		/// synchronize to HQ
	};
}forEach HEX_TACTICAL;

{
	private _cell = _x select 0;
	private _seed = _x select 1;
	
	private _marker = createMarker ["VOX_" + (str _forEachIndex), _cell];
	_marker setMarkerShape "RECTANGLE";
	_marker setMarkerBrush "Solid";
	_marker setMarkerAlpha 0.5;
	_marker setMarkerSize [VOX_SIZE / 2, VOX_SIZE / 2];
}forEach VOX_VORONOI;

VOX_GRID = [];

/// Grid generation
for "_col" from 0 to round(worldSize / VOX_SIZE) do {
    for "_row" from 0 to round(worldSize / VOX_SIZE) do {
        private _x = _col * VOX_SIZE;
        private _y = _row * VOX_SIZE;

        if !(surfaceisWater [_x, _y]) then {VOX_GRID pushBack [_x,_y]};
    };
};
/// "Hill", "NameCityCapital", "NameCity", "NameVillage", "NameLocal"

{
	private _nearvox = _x call VOX_FNC_NEAREST;
	private _marker = createMarker ["VOX_" + (str _forEachIndex), _x];
	_marker setMarkerShape "RECTANGLE";
	_marker setMarkerBrush "Solid";
	_marker setMarkerAlpha 0.5;
	_marker setMarkerSize [VOX_SIZE / 2, VOX_SIZE / 2];
	_marker setMarkerColor (_nearvox select 1);
}forEach VOX_GRID;


private _colors2 = _colors;
{
	private _pos = [round (position _x select 0), round (position _x select 1)];
	if (count _colors2 == 0) then {_colors2 = _colors};
	private _color = _colors2 select 0;
	_colors2 = _colors2 - [_color];
	VOX_VORONOI pushback [_pos, []];
}forEach _locs;


private _colors = [
	"ColorBlack", "ColorGrey", "ColorRed",
	"ColorBrown", "ColorOrange", "ColorYellow",
	"ColorKhaki", "ColorGreen", "ColorBlue", 
	"ColorPink", "ColorWhite", "ColorWEST", 
	"ColorEAST", "ColorGUER", "ColorCIV",
	"ColorUNKNOWN", "colorBLUFOR", "colorOPFOR",
	"colorIndependent", "colorCivilian", "Color1_FD_F",
	"Color2_FD_F", "Color3_FD_F", "Color4_FD_F",
	"Color5_FD_F", "Color6_FD_F"
];


////////////// coolbeans

VOX_SIZE = 250;
VOX_VORONOI = [];

private _locs = nearestLocations [[worldSize / 2, worldSize / 2], ["Hill", "NameCityCapital", "NameCity", "NameVillage", "NameLocal"], worldSize];
{
	private _pos = [round (position _x select 0), round (position _x select 1)];
	VOX_VORONOI pushback [_pos, [random 1, random 1, random 1], []];
}forEach _locs;

_fnc_nearest = {
	private _pos = _this;
	
	private _nearest = VOX_VORONOI select 0;
	private _minDist = _pos distance2D (_nearest select 0);
	
	{
		private _d = _pos distance2D (_x select 0);
		if (_d < _minDist) then {
			_minDist = _d;
			_nearest = _x;
		};
	}forEach VOX_VORONOI;
	
	_nearest
};

for "_col" from 0 to round(worldSize / VOX_SIZE) do {
    for "_row" from 0 to round(worldSize / VOX_SIZE) do {
	
		private _pos = [(_col * VOX_SIZE) + VOX_SIZE / 2, (_row * VOX_SIZE) + VOX_SIZE / 2];
		if (surfaceIsWater _pos) then {continue};
		if !(_pos inArea "VOX_AO") then {continue};
		
		private _nearest = _pos call _fnc_nearest;

		(_nearest select 2) pushback _pos;
		
		private _marker = createMarker [format ["VOX_%1_%2", _col, _row], _pos];
		_marker setMarkerShape "RECTANGLE";
		_marker setMarkerBrush "Solid";
		_marker setMarkerSize [VOX_SIZE / 2, VOX_SIZE / 2];
		private _color = _nearest select 1;
		_marker setMarkerColor (format ["#(%1,%2,%3,1)", _color select 0, _color select 1, _color select 2]);
    };
};

/// neighboring list
/// find nearest road
/// find if nearest road is connected to the cell
/// if no road connection -> remove link?


VOX_SIZE = 250;
VOX_VORONOI = [];

hint "TEST1";
sleep 1;

private _locs = nearestLocations [[worldSize / 2, worldSize / 2], ["Hill"], worldSize];
{
	private _pos = [round (position _x select 0), round (position _x select 1)];
	VOX_VORONOI pushback [_pos, []];
}forEach _locs;

hint "TEST2";
sleep 1;

// VOX_VORONOI = [[pos, []], ...] already populated

{
    private _posA = _x select 0;
    private _neighbors = [];

    {
        private _posB = _x select 0;
        if (_posA isEqualTo _posB == false) then {
            // check if there exists a third point that forms a triangle with _posA and _posB
            {
                private _posC = _x select 0;
                if ((_posC isEqualTo _posA == false) && (_posC isEqualTo _posB == false)) then {
                    // compute circumcircle of A,B,C
                    private _midAB = [((_posA select 0) + (_posB select 0))/2, ((_posA select 1) + (_posB select 1))/2];
                    private _midAC = [((_posA select 0) + (_posC select 0))/2, ((_posA select 1) + (_posC select 1))/2];
                    // ... more math to check if circumcircle contains no other points ...
                    // if valid triangle -> _posA and _posB are neighbors
                    _neighbors pushBack _posB;
                };
            } forEach VOX_VORONOI;
        };
    } forEach VOX_VORONOI;

    _x set [1, _neighbors];
} forEach VOX_VORONOI;


hint "TEST3";
sleep 1;


{
	private _posA = _x select 0;
	private _connected = _x select 1;
	
	{
		private _posB = _x;
		private _name = format ["VOX_%1_%2", _posA, _posB];
		private _marker = createMarker [_name, _posA];
		_marker setMarkerShape "POLYLINE";
		private _start = [_posA select 0, _posA select 1];
		_marker setMarkerPolyline [_posA select 0, _posA select 1, _posB select 0, _posB select 1];
		hint str _marker;
	}forEach _connected;
}forEach VOX_VORONOI;

hint "TEST5";
sleep 1;

/// neighboring seeds list
/// find nearest road
/// find if nearest road is connected to the cell
/// if no road connection -> remove link?


VOX_SIZE = 250;
VOX_GRID = [];

hint "TEST1";
sleep 1;

private _locs = nearestLocations [[worldSize / 2, worldSize / 2], ["Hill", "NameCityCapital", "NameCity", "NameVillage", "NameLocal"], worldSize, [worldSize / 2, worldSize / 2]];


hint "TEST2";
sleep 1;

VOX_GRID = [];

{
	private _loc = _x;
	private _pos = position _x;
	private _locs2 = nearestLocations [_pos, ["Hill", "NameCityCapital", "NameCity", "NameVillage", "NameLocal"], worldSize, _pos];
	
	private _org = [_pos select 0, _pos select 1];
	private _near = [];
	
	
	for "_i" from 1 to 4 do {
		private _loc2 = _locs2 select _i;
		private _pos2 = position _loc2;
		_near pushback [_pos2 select 0, _pos2 select 1];
	};
	
	VOX_GRID pushback [_org,_near];
}forEach _locs;

hint "TEST3";
sleep 1;


{
	private _posA = _x select 0;
	private _connected = _x select 1;
	
	{
		private _posB = _x;
		private _name = format ["VOX_%1_%2", _posA, _posB];
		private _marker = createMarker [_name, _posA];
		_marker setMarkerShape "POLYLINE";
		private _start = [_posA select 0, _posA select 1];
		_marker setMarkerPolyline [_posA select 0, _posA select 1, _posB select 0, _posB select 1];
		hint str _marker;
	}forEach _connected;
}forEach VOX_GRID;

hint "TEST5";
sleep 1;

/// neighboring seeds list
/// find nearest road
/// find if nearest road is connected to the cell
/// if no road connection -> remove link?

{
	private _posA = _x select 0;
	private _connected = _x select 3;
	
	{
		private _posB = _x;
		private _name = format ["VOX_%1_%2", _posA, _posB];
		private _marker = createMarker [_name, _posA];
		_marker setMarkerShape "POLYLINE";
		private _start = [_posA select 0, _posA select 1];
		_marker setMarkerPolyline [_posA select 0, _posA select 1, _posB select 0, _posB select 1];
		hint str _marker;
	}forEach _connected;
}forEach VOX_VORONOI;

{
	private _seed = _x select 0;
	private _cells = _x select 2;
	private _seeds = [];
	
	{
		private _cell = _x;
		{
			private _nSeed = _x select 0;
			private _nCells = _x select 2;
			private _found = _nCells find _cell;
			
			if (_found != -1 && _seed isEqualTo _nSeed == false) then {
				_seeds pushbackUnique _nSeed;
			};
		}forEach VOX_VORONOI;
	}forEach _nearCells;
	
	(_x select 3) pushback _seeds;
}forEach VOX_VORONOI;

private _locs2 = [];

/// Filter out too close objectives
{
	private _loc = _x;
	private _index = _forEachIndex;
	private _pos = position _x;
	private _tooClose = false;
	{
		private _pos2 = position _x;
		if (_pos distance _pos2 < VOX_SIZE) then {
			_tooClose = true;
		};
	}forEach _locs;
	
	if (_tooClose == false) then {
		_locs2 pushback _loc;
	};
}forEach _locs;
