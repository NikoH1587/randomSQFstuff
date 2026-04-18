/// debug markers for connected seeds;

{
	private _pos = _x select 0;
	private _neighbors = _x select 3;
	
	{
		private _polyline = [_x select 0, _x select 1, _pos select 0, _pos select 1];
		private _marker = createMarker [str _polyline, _pos];
		_marker setMarkerShape "Polyline";
		_marker setMarkerPolyline _polyline;
	}forEach _neighbors;
}forEach VOX_GRID;

/// cover rest of map
private _center = getMarkerPos "VOX_AO";
private _size = getMarkerSize "VOX_AO";

private _cx = _center select 0;
private _cy = _center select 1;

private _sx = _size select 0;
private _sy = _size select 1;

private _world = worldSize;

// AO edges
private _left   = _cx - _sx;
private _right  = _cx + _sx;
private _bottom = _cy - _sy;
private _top    = _cy + _sy;

/// NORTH (top strip)
private _nPos = [_world / 2, _top + (_world - _top) / 2];
private _nSize = [_world / 2, (_world - _top) / 2];

private _n = createMarker ["OUT_N", _nPos];
_n setMarkerShape "RECTANGLE";
_n setMarkerSize _nSize;

/// SOUTH (bottom strip)
private _sPos = [_world / 2, _bottom / 2];
private _sSize = [_world / 2, _bottom / 2];

private _s = createMarker ["OUT_S", _sPos];
_s setMarkerShape "RECTANGLE";
_s setMarkerSize _sSize;

/// EAST (right strip)
private _ePos = [_right + (_world - _right) / 2, _cy];
private _eSize = [(_world - _right) / 2, _sy];

private _e = createMarker ["OUT_E", _ePos];
_e setMarkerShape "RECTANGLE";
_e setMarkerSize _eSize;

/// WEST (left strip)
private _wPos = [_left / 2, _cy];
private _wSize = [_left / 2, _sy];

private _w = createMarker ["OUT_W", _wPos];
_w setMarkerShape "RECTANGLE";
_w setMarkerSize _wSize;

/// markers for polygons
{
	private _cells = (_x select 2);
	///private _color = format ["#(%1,%2,%3)", random 1, random 1, random 1];	
	
	{
		private _pos = [(_x select 0) * VOX_SIZE, (_x select 1) * VOX_SIZE];
		private _marker = createMarker [str _pos, _pos];
		_marker setMarkerSize [VOX_SIZE / 2, VOX_SIZE / 2];
		_marker setMarkerShape "RECTANGLE";
		///_marker setMarkerColor _color;
		_cover = count (nearestObjects [_pos, [], VOX_SIZE * 0.7, true]);
		_marker setMarkerAlpha ((_cover / 500) min 0.5);
	}foreach _cells;
}forEach VOX_GRID;