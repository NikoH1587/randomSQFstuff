VOX_PHASE = "STRATEGIC";

_fnc_updatecounters = {
	{
		private _pos = _x select 0;
		private _cells = _x select 2;
		private _unit = _x select 4;
		private _status = _x select 5;
		private _index = _forEachIndex;
		
		if (_unit != "hd_dot" or true) then {
			private _marker = str _pos;
			deleteMarker _marker;
			private _marker = createMarker [str _pos, _pos];
			_marker setMarkerType _unit;
			///_marker setMarkerText str _forEachIndex;
			_marker setMarkerText str count _cells;
		};
	}forEach VOX_GRID;
};

_fnc_updategrid = {
	{
		private _color = _x select 1;
		private _cells = _x select 2;
		{
			private _pos = [(_x select 0) * VOX_SIZE, (_x select 1) * VOX_SIZE];
			private _marker = str _pos;
			if (markerColor _marker != _color) then {
				_marker setMarkerColor _color;
			};
		}forEach _cells;
	}forEach VOX_GRID;
};

0 call _fnc_updatecounters;
0 call _fnc_updategrid;

openMap true;
mapAnimAdd [0, 0.35, getMarkerPos "VOX_AO"];
mapAnimCommit;